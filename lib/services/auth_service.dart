import 'dart:async';
import 'package:celebrating/models/user.dart';
import 'package:celebrating/services/storage_service.dart';
import 'package:celebrating/services/user_service.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  AuthState({
    required this.status,
    this.user,
    this.error,
  });

  factory AuthState.unknown() => AuthState(status: AuthStatus.unknown);
  factory AuthState.authenticated(User user) => AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
  factory AuthState.unauthenticated([String? error]) => AuthState(
        status: AuthStatus.unauthenticated,
        error: error,
      );
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

      final user = await UserService.fetchUser(
        authData['userId']!,
        isCelebrity: authData['role'] == 'Celebrity',
      );

      _updateState(AuthState.authenticated(user));
    } catch (e) {
      await _storageService.clearAuthData();
      _updateState(AuthState.unauthenticated(e.toString()));
    }
  }

  Future<void> login(String username, String password) async {
    try {
      final token = await UserService.login(username, password);
      // Assuming the login response includes user data
      final user = await UserService.fetchUser(username, isCelebrity: false); // We'll update this after fetching

      await _storageService.storeAuthData(
        token: token,
        userId: user.id.toString(),
        role: user.role,
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
      final token = await UserService.login(user.username, user.password);

      await _storageService.storeAuthData(
        token: token,
        userId: registeredUser.id.toString(),
        role: registeredUser.role,
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
