import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:flutter/foundation.dart';
import '../../models/user.dart';

class UserDao {
  SupabaseClient get _client => Supabase.instance.client;

  String? lastError;

  Future<int> insert(User u) async {
    try {
      final existing = await _client
          .from('users')
          .select('id')
          .eq('username', u.username);
      if ((existing as List).isNotEmpty) {
        lastError = 'اسم المستخدم موجود بالفعل';
        return -2;
      }

      final map = u.toMap()..remove('id');
      map.removeWhere((key, value) => value == null);
      if (map['permissions'] == '') {
        map.remove('permissions');
      }

      final result = await _client.from('users').insert(map).select('id').single();
      return result['id'] as int;
    } catch (error, stack) {
      lastError = error.toString();
      debugPrint('UserDao.insert failed: $error');
      debugPrint('$stack');
      return -1;
    }
}

  Future<User?> findById(int id) async {
    try {

    final r = await _client.from('users').select().eq('id', id);
    return r.isEmpty ? null : User.fromMap(r.first);
    } catch (_) {
      return null;
    }
}

  Future<User?> findByUsername(String username) async {
    try {

    final r = await _client
        .from('users')
        .select()
        .eq('username', username)
        .eq('is_active', true);
    return r.isEmpty ? null : User.fromMap(r.first);
    } catch (_) {
      return null;
    }
}

  Future<User?> findByLoginCode(String code) async {
    try {

    final r = await _client
        .from('users')
        .select()
        .eq('login_code', code)
        .eq('is_active', true);
    return r.isEmpty ? null : User.fromMap(r.first);
    } catch (_) {
      return null;
    }
}

  Future<List<User>> getAll({bool activeOnly = false}) async {
    try {

    var query = _client.from('users').select();
    if (activeOnly) query = query.eq('is_active', true) as dynamic;
    final r = await (query as dynamic).order('name', ascending: true);
    return (r as List).map<User>((m) => User.fromMap(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
}

  Future<List<User>> getByRole(String role) async {
    try {

    final r = await _client
        .from('users')
        .select()
        .eq('role', role)
        .eq('is_active', true)
        .order('name', ascending: true);
    return r.map((m) => User.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
}

  Future<int> update(User u) async {
    try {

    final map = u.toMap()..remove('id');
    await _client.from('users').update(map).eq('id', u.id!);
    return 1;
    } catch (_) {
      return -1;
    }
}

  Future<int> updateLoginCode(int id, String? code) async {
    try {

    await _client.from('users').update({'login_code': code}).eq('id', id);
    return 1;
    } catch (_) {
      return -1;
    }
}

  Future<int> updateCredentials(int id, String username, String passwordHash) async {
    try {

    await _client.from('users').update({
      'username': username,
      'password_hash': passwordHash,
    }).eq('id', id);
    return 1;
    } catch (_) {
      return -1;
    }
}

  Future<int> delete(int id) async {
    try {

    await _client.from('users').update({'is_active': false}).eq('id', id);
    return 1;
    } catch (_) {
      return -1;
    }
}
}
