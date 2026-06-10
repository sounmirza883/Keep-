import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { idle, loading, error }

/// Handles all authentication actions for Slate.
///
/// Writes go directly to Supabase Auth (not through Drift/PowerSync) since
/// auth state is not part of the offline sync domain.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._supabase);

  final SupabaseClient _supabase;

  AuthStatus status = AuthStatus.idle;
  String? errorMessage;

  Future<void> _run(Future<void> Function() action) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      status = AuthStatus.idle;
    } on AuthException catch (e) {
      status = AuthStatus.error;
      errorMessage = e.message;
    } catch (e) {
      status = AuthStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) {
    return _run(() async {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    });
  }

  Future<void> register({required String email, required String password}) {
    return _run(() async {
      await _supabase.auth.signUp(email: email, password: password);
    });
  }

  Future<void> sendMagicLink({required String email}) {
    return _run(() async {
      await _supabase.auth.signInWithOtp(email: email);
    });
  }

  Future<void> signInWithGoogle() {
    return _run(() async {
      await _supabase.auth.signInWithOAuth(OAuthProvider.google);
    });
  }

  Future<void> signInWithApple() {
    return _run(() async {
      await _supabase.auth.signInWithOAuth(OAuthProvider.apple);
    });
  }

  Future<void> signOut() {
    return _run(() async {
      await _supabase.auth.signOut();
    });
  }
}
