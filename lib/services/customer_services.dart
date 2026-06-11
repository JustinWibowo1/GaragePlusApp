import 'package:supabase_flutter/supabase_flutter.dart';

class CarService {
  final _supabase = Supabase.instance.client;

  Future<void> saveCar(Map<String, dynamic> carData) async {
    await _supabase.from('customer').insert(carData);
  }

  Future<bool> isCarExists(String rangka) async {
    final response = await _supabase
      .from('customer')
      .select('nomor_rangka')
      .eq('nomor_rangka', rangka);
      
    return response.isNotEmpty; 
  }

  Future<List<Map<String, dynamic>>> fetchAllCars() async {
    try {
      final data = await _supabase
          .from('customer')
          .select()
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);
      return data;
    } catch (e) {
      throw Exception('Failed to fetch cars: $e');
    }
  }
}