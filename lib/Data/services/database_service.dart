import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  // READ: Mengambil semua data dari sebuah tabel
  Future<List<Map<String, dynamic>>> getData(String table) async {
    final res = await supabase.from(table).select();
    return List<Map<String, dynamic>>.from(res);
  }

  // CREATE: Menambahkan data baru ke sebuah tabel
  Future<Map<String, dynamic>?> createData(
      String table, Map<String, dynamic> data) async {
    final res = await supabase.from(table).insert(data).select().single();
    return res;
  }

  // UPDATE: Memperbarui data di sebuah tabel berdasarkan ID
  Future<Map<String, dynamic>?> updateData(
      String table, Map<String, dynamic> data, String id) async {
    final res = await supabase
        .from(table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return res;
  }

  // DELETE: Menghapus data dari sebuah tabel berdasarkan ID
  Future<void> deleteData(String table, String id) async {
    await supabase.from(table).delete().eq('id', id);
  }
}