import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service;

  ProfileProvider({ProfileService? service})
      : _service = service ?? ProfileService();

  // ─── State ──────────────────────────────────────────────────────────────────
  UserProfile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  // ─── Getters ────────────────────────────────────────────────────────────────
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  // ─── Load profile ────────────────────────────────────────────────────────────
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _service.getProfile();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      debugPrint('ProfileProvider.fetchProfile error: $e');
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      debugPrint('ProfileProvider.fetchProfile unexpected: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Update profile ───────────────────────────────────────────────────────────
  /// Returns `null` on success, or an error message string on failure.
  /// [validationErrors] is populated with field-level errors from the backend.
  Future<String?> updateProfile({
    String? name,
    String? email,
    File? avatarFile,
    Map<String, String>? validationErrors,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final updated = await _service.updateProfile(
        name: name,
        email: email,
        avatarFile: avatarFile,
      );
      _profile = updated;
      _isSaving = false;
      notifyListeners();
      return null; // success
    } on ApiException catch (e) {
      _isSaving = false;
      notifyListeners();

      // Populate field-level validation errors (HTTP 422).
      if (e.statusCode == 422 && validationErrors != null) {
        _parseValidationErrors(e.message, validationErrors);
      }

      return e.message;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return 'An unexpected error occurred.';
    }
  }

  // ─── Remove avatar ────────────────────────────────────────────────────────────
  /// Returns `null` on success, or an error message string on failure.
  Future<String?> removeAvatar() async {
    _isSaving = true;
    notifyListeners();

    // Optimistic update.
    final previous = _profile;
    _profile = _profile?.copyWith(avatarUrl: null);
    notifyListeners();

    try {
      await _service.deleteAvatar();
      _isSaving = false;
      notifyListeners();
      return null; // success
    } on ApiException catch (e) {
      // Revert on failure.
      _profile = previous;
      _isSaving = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _profile = previous;
      _isSaving = false;
      notifyListeners();
      return 'An unexpected error occurred.';
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  void _parseValidationErrors(
    String rawMessage,
    Map<String, String> out,
  ) {
    // The Laravel ApiException message is already the top-level "message".
    // Field-level errors are not currently surfaced through ApiClient, but we
    // forward the top-level message as a fallback.
    out['general'] = rawMessage;
  }
}
