import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/profile/profile_avatar_picker.dart';
import '../../widgets/profile/profile_form.dart';
import '../../widgets/state_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  File? _pickedAvatar;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final provider = context.read<ProfileProvider>();
      if (provider.profile == null && !provider.isLoading) {
        provider.fetchProfile();
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _syncFields(UserProfile profile) {
    if (_nameCtrl.text.isEmpty) _nameCtrl.text = profile.name;
    if (_emailCtrl.text.isEmpty) _emailCtrl.text = profile.email;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null && mounted) {
      setState(() => _pickedAvatar = File(picked.path));
    }
  }

  Future<void> _removeAvatar() async {
    if (_pickedAvatar != null) {
      setState(() => _pickedAvatar = null);
      return;
    }

    final provider = context.read<ProfileProvider>();
    final error = await provider.removeAvatar();
    if (!mounted) return;

    if (error != null) {
      _showSnackbar(error, isError: true);
    } else {
      _showSnackbar('Profile picture removed.');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProfileProvider>();
    final profile = provider.profile;

    final newName = _nameCtrl.text.trim() != (profile?.name ?? '')
        ? _nameCtrl.text.trim()
        : null;
    final newEmail = _emailCtrl.text.trim() != (profile?.email ?? '')
        ? _emailCtrl.text.trim()
        : null;

    if (newName == null && newEmail == null && _pickedAvatar == null) {
      _showSnackbar('No changes to save.');
      return;
    }

    final validationErrors = <String, String>{};
    final error = await provider.updateProfile(
      name: newName,
      email: newEmail,
      avatarFile: _pickedAvatar,
      validationErrors: validationErrors,
    );

    if (!mounted) return;

    if (error != null) {
      _showSnackbar(error, isError: true);
    } else {
      setState(() => _pickedAvatar = null);
      _showSnackbar('Profile updated successfully!');
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "កែប្រែប្រវត្តិរូប (Edit Profile)",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.profile == null) {
            return const AppLoading();
          }

          if (provider.errorMessage != null && provider.profile == null) {
            return AppErrorState(
              message: provider.errorMessage!,
              onRetry: () => provider.fetchProfile(),
            );
          }

          if (provider.profile != null) {
            _syncFields(provider.profile!);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                ProfileAvatarPicker(
                  profile: provider.profile,
                  pickedAvatar: _pickedAvatar,
                  onPickImage: _pickImage,
                  onRemoveAvatar: _removeAvatar,
                ),
                const SizedBox(height: 32),
                ProfileForm(
                  formKey: _formKey,
                  nameController: _nameCtrl,
                  emailController: _emailCtrl,
                  isSaving: provider.isSaving,
                  onSubmit: _save,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
