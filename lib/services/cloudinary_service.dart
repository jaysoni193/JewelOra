import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jewel_ora/core/config/cloudinary_config.dart';
import 'package:jewel_ora/core/errors/upload_exception.dart';

class CloudinaryService {
  /// Uploads one image and returns its secure URL.
  Future<String> uploadImage(XFile file, {String? folder}) async {
    try {
      final bytes = await file.readAsBytes();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(CloudinaryConfig.uploadUrl),
      )
        ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: file.name),
        );
      log('Uploading image to Cloudinary...${Uri.parse(CloudinaryConfig.uploadUrl)}');
      if (folder != null && folder.isNotEmpty) {
        request.fields['folder'] = folder;
      }

      final streamed =
      await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      // Debug: see exactly what Cloudinary says
      debugPrint('Cloudinary URL   : ${CloudinaryConfig.uploadUrl}');
      debugPrint('Cloudinary preset: ${CloudinaryConfig.uploadPreset}');
      debugPrint('Cloudinary status: ${response.statusCode}');
      debugPrint('Cloudinary body  : ${response.body}');
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['secure_url'] != null) {
        return body['secure_url'] as String;
      }

      final apiMessage = (body['error']?['message'] ?? '').toString();
      throw UploadException(
        apiMessage.isNotEmpty ? apiMessage : 'Image upload failed.',
      );
    } on UploadException {
      rethrow;
    } on TimeoutException {
      throw const UploadException('Upload timed out. Check your internet.');
    } catch (_) {
      throw const UploadException(
          'Could not upload the image. Check your internet and try again.');
    }
  }

  /// Uploads several images one by one and returns the URLs in order.
  Future<List<String>> uploadImages(List<XFile> files, {String? folder}) async {
    final urls = <String>[];
    for (final file in files) {
      urls.add(await uploadImage(file, folder: folder));
    }
    return urls;
  }
}