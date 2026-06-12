import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import '../services/api_service.dart';

@immutable
class AuthState {
  final String? token;
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.token, this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => token != null && user != null;

  AuthState copyWith({
    String? token,
    AppUser? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearToken = false,
    bool clearUser = false,
  }) {
    return AuthState(
      token: clearToken ? null : token ?? this.token,
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');
      final fullName = prefs.getString('user_full_name') ?? '';
      final username = prefs.getString('username') ?? '';
      final roleName = prefs.getString('role_name') ?? 'kasir';

      if (token != null && userId != null) {
        state = state.copyWith(
          token: token,
          user: AppUser(
            id: userId,
            fullName: fullName,
            username: username,
            roleName: roleName,
          ),
        );
      }
    } catch (_) {
      // Silently ignore — user will log in manually.
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ApiService.login(username, password);
      final token = data['token'] as String;
      final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setInt('user_id', user.id);
      await prefs.setString('user_full_name', user.fullName);
      await prefs.setString('username', user.username);
      await prefs.setString('role_name', user.roleName);

      state = state.copyWith(token: token, user: user, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Tidak dapat terhubung ke server. Pastikan server berjalan.',
      );
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_full_name');
      await prefs.remove('username');
      await prefs.remove('role_name');
    } catch (_) {}
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
