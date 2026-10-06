import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_text_field.dart';
import 'package:jewel_ora/core/widgets/primary_button.dart';
import 'package:jewel_ora/core/widgets/single_image_uploader.dart';
import 'package:jewel_ora/models/banner_model.dart';
import 'package:jewel_ora/providers/banner_provider.dart';
import 'package:provider/provider.dart';

class BannerFormScreen extends StatefulWidget {
  /// null = add mode, otherwise edit mode.
  final BannerModel? banner;
  const BannerFormScreen({super.key, this.banner});

  @override
  State<BannerFormScreen> createState() => _BannerFormScreenState();
}

class _BannerFormScreenState extends State<BannerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late String _imageUrl;
  late bool _isActive;

  bool get _isEdit => widget.banner != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.banner?.title ?? '');
    _imageUrl = widget.banner?.imageUrl ?? '';
    _isActive = widget.banner?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_imageUrl.isEmpty) {
      showAppSnackBar(context, 'Please choose a banner image', isError: true);
      return;
    }

    final provider = context.read<BannerProvider>();
    final ok = await provider.save(
      existing: widget.banner,
      title: _titleCtrl.text.trim(),
      imageUrl: _imageUrl,
      isActive: _isActive,
    );

    if (!mounted) return;
    if (ok) {
      showAppSnackBar(context, _isEdit ? 'Banner updated' : 'Banner added');
      Navigator.of(context).pop();
    } else {
      showAppSnackBar(
        context,
        provider.errorMessage ?? AppStrings.somethingWentWrong,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<BannerProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Banner' : 'Add Banner')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleImageUploader(
                  label: 'Banner image',
                  initialUrl: _imageUrl,
                  folder: 'jewel_ora/banners',
                  height: 170,
                  onUploaded: (url) => _imageUrl = url,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tip: a wide image (about 1600 x 700 px) looks best.',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _titleCtrl,
                  label: 'Title (optional)',
                  prefixIcon: Icons.title,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Visible to customers'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: _isEdit ? 'Save Changes' : 'Add Banner',
                  isLoading: isSaving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}