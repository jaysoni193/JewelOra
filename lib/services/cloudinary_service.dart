import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jewel_ora/core/config/cloudinary_config.dart';
import 'package:jewel_ora/core/errors/upload_exception.dart';
import 'package:jewel_ora/core/network/network_logger.dart';

class CloudinaryService {
  /// Uploads one image and returns its secure URL.
  Future<String> uploadImage(XFile file, {String? folder}) async {
    final startTime = DateTime.now();
    NetworkLogger.request(
      method: 'POST (multipart)',
      url: CloudinaryConfig.uploadUrl,
      query: {'folder': folder ?? ''},
      body: 'File: ${file.name}',
    );

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

      if (folder != null && folder.isNotEmpty) {
        request.fields['folder'] = folder;
      }

      final streamed =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      final duration = DateTime.now().difference(startTime);

      NetworkLogger.response(
        statusCode: response.statusCode,
        url: CloudinaryConfig.uploadUrl,
        body: response.body,
        duration: duration,
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['secure_url'] != null) {
        return body['secure_url'] as String;
      }

      final apiMessage = (body['error']?['message'] ?? '').toString();
      throw UploadException(
        apiMessage.isNotEmpty ? apiMessage : 'Image upload failed.',
      );
    } on UploadException catch (e) {
      NetworkLogger.error(
        url: CloudinaryConfig.uploadUrl,
        error: e,
      );
      rethrow;
    } on TimeoutException catch (e) {
      NetworkLogger.error(
        url: CloudinaryConfig.uploadUrl,
        error: e,
      );
      throw const UploadException('Upload timed out. Check your internet.');
    } catch (e) {
      NetworkLogger.error(
        url: CloudinaryConfig.uploadUrl,
        error: e,
      );
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