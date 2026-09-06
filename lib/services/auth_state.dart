import 'package:supabase_flutter/supabase_flutter.dart';

class AppAuthState {
  final SupabaseClient _supabase;

  AppAuthState(this._supabase);

  Session? get currentSession => _supabase.auth.currentSession;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
