import 'package:donatopia/services/pelanggan_service.dart';
import 'package:donatopia/fitur/models/customer_history_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:donatopia/fitur/models/customer_history_model.dart'; 

final supabase = Supabase.instance.client;

class PelangganService {

    // READ
    // 🚨 PERBAIKAN: Mengembalikan List<CustomerHistory>, BUKAN List<PelangganPage>
    Future<List<CustomerHistory>> fetchCustomerHistory() async { 
        try {
            final response = await supabase
                .from('customer_transactions') 
                .select('*, order_items(*)')
                .order('created_at', ascending: false);

            // ✅ Konversi ke Model: CustomerHistory.fromJson harus bekerja karena sudah diimpor
            final List<CustomerHistory> data = (response as List<dynamic>)
                .map((json) => CustomerHistory.fromJson(json as Map<String, dynamic>))
                .toList();
            
            return data;
        } catch (e) {
            print('Error saat mengambil data dari Supabase: $e');
            return [];
        }
    }

    // CREATE
    Future<void> addTransaction(String customerName) async {
        try {
            await supabase
                .from('customer_transactions') 
                .insert({'customer_name': customerName});
        } catch (e) {
            print('Error saat menambahkan transaksi: $e');
            rethrow; 
        }
    }

    // UPDATE
    Future<void> updateTransactionName(String transactionId, String newName) async {
        try {
            await supabase
                .from('customer_transactions')
                .update({'customer_name': newName})
                .eq('id', transactionId);
        } catch (e) {
            print('Error saat memperbarui transaksi: $e');
            rethrow;
        }
    }

    // DELETE
    Future<void> deleteTransaction(String transactionId) async {
        try {
            await supabase
                .from('customer_transactions')
                .delete()
                .eq('id', transactionId);
        } catch (e) {
            print('Error saat menghapus transaksi: $e');
            rethrow;
        }
    }

    // REALTIME LISTENER
    Stream<List<Map<String, dynamic>>> get transactionStream {
        return supabase
            .from('customer_transactions')
            .stream(primaryKey: ['id']);
    }
}