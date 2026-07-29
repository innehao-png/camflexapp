import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/profile_provider.dart';
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

  File? _pickedAvatar; // new local file (not yet uploaded)
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

  // Pre-fill form fields from the loaded profile.
  void _syncFields(UserProfile profile) {
    if (_nameCtrl.text.isEmpty) _nameCtrl.text = profile.name;
    if (_emailCtrl.text.isEmpty) _emailCtrl.text = profile.email;
  }

  // ─── Image Picking ─────────────────────────────────────────────────────────
  Future<void> _showAvatarOptions(UserProfile? profile) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.textPrimary),
              title: const Text('Choose from Gallery',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.textPrimary),
              title: const Text('Take a Photo',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickImage(ImageSource.camera);
              },
            ),
            if (profile?.avatarUrl != null || _pickedAvatar != null)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: AppColors.error),
                title: const Text('Remove Photo',
                    style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _removeAvatar();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
    // If a new image was just picked (not yet saved), just clear the local
    // pick without calling the API.
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

  // ─── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProfileProvider>();
    final profile = provider.profile;

    // Only send changed fields.
    final newName =
        _nameCtrl.text.trim() != (profile?.name ?? '') ? _nameCtrl.text.trim() : null;
    final newEmail =
        _emailCtrl.text.trim() != (profile?.email ?? '') ? _emailCtrl.text.trim() : null;

    // Nothing to send and no avatar.
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
      setState(() => _pickedAvatar = null); // clear local pick after upload
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

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const AppLoading();

          if (provider.profile == null && provider.errorMessage != null) {
            return AppErrorState(
              message: provider.errorMessage!,
              onRetry: provider.fetchProfile,
            );
          }

          final profile = provider.profile;
          if (profile != null) _syncFields(profile);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // ── Avatar ──────────────────────────────────────────────
                  _buildAvatar(profile),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAvatarOptions(profile),
                    icon: const Icon(Icons.edit, size: 14,
                        color: AppColors.primary),
                    label: const Text('Change Photo',
                        style: TextStyle(
                            color: AppColors.primary, fontSize: 13)),
                  ),
                  const SizedBox(height: 32),
                  // ── Name ────────────────────────────────────────────────
                  _buildLabel('Full Name'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameCtrl,
                    hint: 'Enter your full name',
                    icon: Icons.person_outline,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // ── Email ────────────────────────────────────────────────
                  _buildLabel('Email Address'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailCtrl,
                    hint: 'Enter your email',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                          .hasMatch(v.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  // ── Phone (read-only) ────────────────────────────────────
                  if (profile?.phone != null) ...[
                    const SizedBox(height: 20),
                    _buildLabel('Phone Number'),
                    const SizedBox(height: 8),
                    _buildReadOnlyField(
                      value: profile!.phone!,
                      icon: Icons.phone_outlined,
                    ),
                  ],
                  const SizedBox(height: 40),
                  // ── Save Button ──────────────────────────────────────────
                  _buildSaveButton(provider.isSaving),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Avatar widget ─────────────────────────────────────────────────────────
  Widget _buildAvatar(UserProfile? profile) {
    final hasNetworkAvatar =
        profile?.avatarUrl != null && _pickedAvatar == null;
    final initials = profile?.initials ?? 'U';

    return GestureDetector(
      onTap: () => _showAvatarOptions(profile),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.15),
              border: Border.all(color: AppColors.primary, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: _pickedAvatar != null
                  ? Image.file(_pickedAvatar!, fit: BoxFit.cover)
                  : hasNetworkAvatar
                      ? Image.network(
                          profile!.avatarUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary)),
                          errorBuilder: (_, __, ___) => _initialsWidget(initials),
                        )
                      : _initialsWidget(initials),
            ),
          ),
          // Camera badge.
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 2),
            ),
            child: const Icon(Icons.camera_alt,
                color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _initialsWidget(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─── Form helpers ──────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: AppColors.cardBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 15)),
          const Spacer(),
          const Icon(Icons.lock_outline,
              color: Colors.white24, size: 16),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isSaving) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: isSaving ? 0 : 4,
          shadowColor: AppColors.primary.withOpacity(0.4),
        ),
        child: isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
