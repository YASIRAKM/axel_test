import 'package:hive/hive.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> register(UserModel user);
  Future<UserModel> login(
    String username,
    String password, {
    bool rememberMe = false,
  });
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<void> updateUser(UserModel user);
  Future<String?> getRememberedUsername();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<UserModel> userBox;
  final Box sessionBox;

  String? _tempSessionUserId;

  AuthLocalDataSourceImpl({required this.userBox, required this.sessionBox});

  @override
  Future<UserModel> register(UserModel user) async {
    final exists = userBox.values.any((u) => u.username == user.username);
    if (exists) {
      throw CacheException('Username already exists');
    }
    await userBox.put(user.id, user);
    await sessionBox.put('current_user_id', user.id);
    _tempSessionUserId = user.id;
    return user;
  }

  @override
  Future<UserModel> login(
    String username,
    String password, {
    bool rememberMe = false,
  }) async {
    UserModel? user;
    try {
      user = userBox.values.firstWhere((u) => u.username == username);
    } catch (_) {
      throw CacheException('Invalid credentials');
    }

    if (user.lockoutUntil != null) {
      if (DateTime.now().isBefore(user.lockoutUntil!)) {
        final remaining = user.lockoutUntil!.difference(DateTime.now());
        throw LockoutException(
          'Account locked. Try again in ${remaining.inMinutes + 1} minutes.',
        );
      } else {
        user = user.copyWith(failedAttempts: 0, lockoutUntil: null);
        await userBox.put(user.id, user);
      }
    }

    if (user.password != password) {
      int newAttempts = user.failedAttempts + 1;
      DateTime? newLockout;

      if (newAttempts >= 3) {
        newLockout = DateTime.now().add(const Duration(minutes: 1));
      }

      final updatedUser = user.copyWith(
        failedAttempts: newAttempts,
        lockoutUntil: newLockout,
      );
      await userBox.put(user.id, updatedUser);

      if (newLockout != null) {
        throw LockoutException(
          'Account locked due to too many failed attempts.',
        );
      }
      throw CacheException('Invalid credentials');
    }

      if (user.failedAttempts > 0) {
      user = user.copyWith(failedAttempts: 0, lockoutUntil: null);
      await userBox.put(user.id, user);
    }

    if (rememberMe) {
      await sessionBox.put('remembered_username', username);
    } else {
      await sessionBox.delete('remembered_username');
    }

    await sessionBox.put('current_user_id', user.id);
    _tempSessionUserId = user.id;

    return user;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_tempSessionUserId != null) {
      return userBox.get(_tempSessionUserId);
    }
    final userId = sessionBox.get('current_user_id');
    if (userId != null) {
      return userBox.get(userId);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    _tempSessionUserId = null;
    await sessionBox.delete('current_user_id');
  }

  @override
  Future<void> updateUser(UserModel user) async {
    if (userBox.containsKey(user.id)) {
      await userBox.put(user.id, user);

      if (_tempSessionUserId == user.id) {
        _tempSessionUserId = user.id;
      }
    } else {
      throw CacheException('User not found to update');
    }
  }

  Future<String?> getRememberedUsername() async {
    return sessionBox.get('remembered_username') as String?;
  }
}
