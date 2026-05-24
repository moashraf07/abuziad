import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/department.dart';

class DepartmentDao {
  final _client = Supabase.instance.client;

  Future<List<Department>> getAll({bool activeOnly = false}) async {
    try {

    var query = _client.from('departments').select();
    if (activeOnly) query = query.eq('is_active', true);
    final rows = await query.order('name', ascending: true);
    return List<Map<String, dynamic>>.from(rows)
        .map(Department.fromMap)
        .toList();
    } catch (_) {
      return [];
    }
}

  Future<Department?> getByStoreType(String storeType) async {
    try {

    final rows = await _client
        .from('departments')
        .select()
        .eq('store_type', storeType)
        .limit(1);
    if (rows.isEmpty) return null;
    return Department.fromMap(rows.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
}

  Future<void> create(Department d) async {
    try {

    await _client.from('departments').insert(d.toMap());
    } catch (_) {}
}

  Future<void> update(Department d) async {
    try {

    await _client
        .from('departments')
        .update(d.toMap())
        .eq('id', d.id!);
    } catch (_) {}
}

  Future<void> delete(int id) async {
    try {

    await _client.from('departments').delete().eq('id', id);
    } catch (_) {}
}
}
