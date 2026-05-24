import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/app_settings.dart';

/// DAO for reading/writing app configuration to Supabase.
/// The table `app_settings` has a single row with key-value pairs stored
/// as a JSONB column `value`. Falls back to defaults if the row doesn't exist.
class AppSettingsDao {
  SupabaseClient get _client => Supabase.instance.client;

  static const _table = 'app_settings';

  Future<AppSettings> getSettings() async {
    try {
      final rows = await _client.from(_table).select('*').limit(1);
      if ((rows as List).isEmpty) return const AppSettings();
      final row = (rows as List).first as Map<String, dynamic>;
      return AppSettings.fromMap(row);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    try {
      final map = settings.toMap();
      final existing = await _client.from(_table).select('id').limit(1);
      if ((existing as List).isEmpty) {
        await _client.from(_table).insert(map);
      } else {
        final id = (existing as List).first['id'];
        await _client.from(_table).update(map).eq('id', id);
      }
    } catch (_) {}
  }

  /// Convenience: update just the monthly rate and per-month overrides.
  Future<void> updateInstallmentRates({
    double? monthlyRate,
    Map<int, double>? ratesByMonths,
  }) async {
    try {

    final current = await getSettings();
    final updated = current.copyWith(
      monthlyInstallmentRate: monthlyRate,
      installmentRatesByMonths: ratesByMonths,
    );
    await saveSettings(updated);
    } catch (_) {}
}
}
