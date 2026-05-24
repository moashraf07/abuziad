import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/customer_invoice.dart';

class CustomerInvoiceDao {
  SupabaseClient get _client => Supabase.instance.client;

  Future<int> insertInvoice(CustomerInvoice inv) async {
    try {

    final map = inv.toMap()..remove('id');
    final id = (await _client.from('customer_invoices').insert(map).select('id').single())['id'] as int;
    for (final item in inv.items) {
      final imap = item.toMap()..remove('id');
      imap['invoice_id'] = id;
      await _client.from('customer_invoice_items').insert(imap);
    }
    return id;
    } catch (_) {
      return -1;
    }
}

  Future<List<CustomerInvoice>> getForCustomer(int customerId) async {
    try {

    final rows = await _client
        .from('customer_invoices')
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    final invoices = <CustomerInvoice>[];
    final seenIds = <int>{};
    for (final row in rows) {
      final inv = CustomerInvoice.fromMap(row);
      // Deduplicate by invoice ID to prevent repeated rows from DB
      if (inv.id != null && seenIds.contains(inv.id!)) continue;
      if (inv.id != null) seenIds.add(inv.id!);
      final items = await _getItems(inv.id!);
      invoices.add(CustomerInvoice(
        id: inv.id, customerId: inv.customerId, invoiceNo: inv.invoiceNo,
        total: inv.total, paymentMethod: inv.paymentMethod, receiptPath: inv.receiptPath,
        status: inv.status, notes: inv.notes, date: inv.date, createdAt: inv.createdAt,
        items: items,
      ));
    }
    return invoices;
    } catch (_) {
      return [];
    }
}

  Future<List<CustomerInvoice>> getAll({String? status}) async {
    try {

    var q = _client.from('customer_invoices').select('*, customers(name, phone)');
    if (status != null) q = q.eq('status', status) as dynamic;
    final r = await (q as dynamic).order('created_at', ascending: false);
    final invoices = <CustomerInvoice>[];
    for (final row in r as List) {
      final m = Map<String, dynamic>.from(row as Map);
      final c = m['customers'] as Map?;
      m['customer_name'] = c?['name'];
      m['customer_phone'] = c?['phone'];
      m.remove('customers');
      final inv = CustomerInvoice.fromMap(m);
      final items = await _getItems(inv.id!);
      invoices.add(CustomerInvoice(
        id: inv.id, customerId: inv.customerId, invoiceNo: inv.invoiceNo,
        total: inv.total, paymentMethod: inv.paymentMethod, receiptPath: inv.receiptPath,
        status: inv.status, notes: inv.notes, date: inv.date, createdAt: inv.createdAt,
        items: items, customerName: inv.customerName, customerPhone: inv.customerPhone,
      ));
    }
    return invoices;
    } catch (_) {
      return [];
    }
}

  Future<List<CustomerInvoiceItem>> _getItems(int invoiceId) async {
    try {

    final rows = await _client
        .from('customer_invoice_items')
        .select()
        .eq('invoice_id', invoiceId);
    return rows.map((m) => CustomerInvoiceItem.fromMap(m)).toList();
    } catch (_) {
      return [];
    }
}

  Future<int> updateStatus(int invoiceId, String status) async {
    try {

    await _client.from('customer_invoices').update({'status': status}).eq('id', invoiceId);
    return 1;
    } catch (_) {
      return -1;
    }
}

  Future<int> getPendingCount() async {
    try {

    final r = await _client
        .from('customer_invoices')
        .select('id')
        .eq('status', 'pending');
    return r.length;
    } catch (_) {
      return -1;
    }
}

  Future<String> generateInvoiceNo() async {
    try {

    final r = await _client.from('customer_invoices').select('id');
    final count = r.length + 1;
    final ts = DateTime.now();
    return 'INV-${ts.year}${ts.month.toString().padLeft(2, "0")}-${count.toString().padLeft(4, "0")}';
    } catch (_) {
      return '';
    }
}
}
