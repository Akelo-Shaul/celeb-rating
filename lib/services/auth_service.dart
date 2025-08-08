import 'dart:async';
import 'package:celebrating/models/user.dart';
import 'package:celebrating/services/storage_service.dart';
import 'package:celebrating/services/user_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  AuthState({required this.status, this.user, this.error});

  factory AuthState.unknown() => AuthState(status: AuthStatus.unknown);
  factory AuthState.authenticated(User user) =>
      AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated([String? error]) =>
      AuthState(status: AuthStatus.unauthenticated, error: error);
}

class AuthService {
  static AuthService? _instance;
  final _storageService = StorageService.instance;
  final _authStateController = StreamController<AuthState>.broadcast();

  Stream<AuthState> get authStateChanges => _authStateController.stream;

  AuthState _currentState = AuthState.unknown();
  AuthState get currentState => _currentState;

  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  AuthService._();

  Future<void> initialize() async {
    final isAuth = await _storageService.isAuthenticated();
    if (!isAuth) {
      _updateState(AuthState.unauthenticated());
      return;
    }

    try {
      final authData = await _storageService.getAuthData();
      if (authData['userId'] == null) {
        throw Exception('User ID not found');
      }
      var role = authData['role'] ?? 'User';
      role = role.toString().toUpperCase();
      final user = await UserService.fetchUser(
        authData['userId']!,
        isCelebrity: role == 'CELEBRITY',
      );

      _updateState(AuthState.authenticated(user));
    } catch (e) {
      await _storageService.clearAuthData();
      _updateState(AuthState.unauthenticated(e.toString()));
    }
  }

  Future<void> login(String username, String password) async {
    try {
      final loginResp = await UserService.login(username, password);
      final token = loginResp['accessToken'] as String?;
      final refreshToken = loginResp['refreshToken'] as String?;
      final userId = loginResp['userId']?.toString();
      final email = loginResp['email'] as String?;
      var role = loginResp['role'] as String? ?? 'User';
      role = role.toUpperCase();
      if (token == null || userId == null) {
        throw Exception('Login failed: missing token or userId');
      }
      final user = await UserService.fetchUser(
        userId,
        isCelebrity: role == 'CELEBRITY',
      );

      await _storageService.storeAuthData(
        token: token,
        userId: user.id.toString(),
        role: role,
        refreshToken: refreshToken,
        email: email,
      );

      _updateState(AuthState.authenticated(user));
    } catch (e) {
      _updateState(AuthState.unauthenticated(e.toString()));
      rethrow;
    }
  }

  Future<void> register(User user) async {
    try {
      final registeredUser = await UserService.register(user);
      final loginResp = await UserService.login(user.username, user.password);
      final token = loginResp['accessToken'] as String?;
      final refreshToken = loginResp['refreshToken'] as String?;
      final userId = loginResp['userId']?.toString();
      final email = loginResp['email'] as String?;
      var role = loginResp['role'] as String? ?? 'User';
      role = role.toUpperCase();
      if (token == null || userId == null) {
        throw Exception('Registration failed: missing token or userId');
      }

      await _storageService.storeAuthData(
        token: token,
        userId: registeredUser.id.toString(),
        role: role,
        refreshToken: refreshToken,
        email: email,
      );

      _updateState(AuthState.authenticated(registeredUser));
    } catch (e) {
      _updateState(AuthState.unauthenticated(e.toString()));
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAuthData();
    _updateState(AuthState.unauthenticated());
  }

  void _updateState(AuthState state) {
    _currentState = state;
    _authStateController.add(state);
  }

  void dispose() {
    _authStateController.close();
  }
}
