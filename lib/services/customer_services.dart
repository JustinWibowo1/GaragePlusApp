import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer_models.dart';

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

  Future<List<Customer>> fetchAllCars() async {
    try {
      final data = await _supabase
          .from('customer')
          .select()
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);
      return (data as List)
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cars: $e');
    }
  }

  Future<void> updateCar(String originalRangka, Map<String, dynamic> data) async {
    await _supabase
        .from('customer')
        .update(data)
        .eq('nomor_rangka', originalRangka);
  }

  Future<int> fetchOdometer(String rangka) async {
    try {
      final response = await _supabase
          .from('customer')
          .select('odometer_terakhir')
          .eq('nomor_rangka', rangka)
          .maybeSingle();
      
      return response?['odometer_terakhir'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }
}