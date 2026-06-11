import 'package:flutter/material.dart';
import '../services/supabase_services.dart';

class AuthViewModel extends ChangeNotifier{
    final _supabaseService = SupabaseServices();

    bool _isLoading = false;
    bool get isLoading => _isLoading;

    String? _errorMessage;
    String? get errorMessage => _errorMessage;

    Future<bool> register(String email, String password, String name, String role) async{
        _setLoading(true);
        _errorMessage = null;
        try{
            await _supabaseService.registerUser(email, password, name, role);
            _setLoading(false);
            return true;
        } catch (e){
            _setLoading(false);
            _errorMessage = e.toString();
            return false;
        }
    }

    Future<bool> login(String email, String password) async{
        _setLoading(true);
        _errorMessage = null;
        try{
            await _supabaseService.loginUser(email, password);
            _setLoading(false);
            return true;
        } catch (e){
            _setLoading(false);
            _errorMessage = e.toString();
            return false;
        }
    }
    void _setLoading(bool value){
        _isLoading = value;
        notifyListeners();
    }
}