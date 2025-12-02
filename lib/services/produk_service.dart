import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdukService {
  final supabase = Supabase.instance.client;

  /// Ambil semua produk
  Future<List<Map<String, dynamic>>> getAllProduk() async {
    final response = await supabase
        .from('produk')
        .select()
        .order('id', ascending: false);

    return (response as List<dynamic>)
        .map((p) {
          final prod = p as Map<String, dynamic>;
          return {
            'id': prod['id'],
            'nama': prod['nama'],
            'deskripsi': prod['deskripsi'] ?? '',
            'kategori': prod['kategori'] ?? 'Umum',
            'harga': (prod['harga'] as num).toDouble(),
            'gambar_url': prod['gambar_url'] ?? '',
            'stok_saat_ini': prod['stok_saat_ini'] ?? 0,
          };
        })
        .toList();
  }

  /// Upload gambar ke Supabase Storage
  Future<String?> uploadImage(File file, String fileName) async {
    try {
      // Upload ke bucket 'gambar' di folder 'public'
      await supabase.storage.from('gambar').uploadBinary(
        'public/$fileName',
        file.readAsBytesSync(),
        fileOptions: FileOptions(cacheControl: '3600', upsert: true),
      );

      // Ambil URL publik
      final publicUrl = supabase.storage.from('gambar').getPublicUrl('public/$fileName');
      return publicUrl;
    } catch (e) {
      // Tangani error
      print('Upload error: $e'); // Bisa ganti dengan logging
      return null;
    }
  }
  /// Tambah produk
  Future<Map<String, dynamic>?> addProduk(Map<String, dynamic> data) async {
    final response = await supabase
        .from('produk')
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Update produk
  Future<void> updateProduk(int id, Map<String, dynamic> data) async {
    await supabase.from('produk').update(data).eq('id', id);
  }

  /// Hapus produk
  Future<void> deleteProduk(int id) async {
    await supabase.from('produk').delete().eq('id', id);
  }
}