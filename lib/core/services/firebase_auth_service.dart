import 'package:firebase_auth/firebase_auth.dart';
import 'package:quex/core/config/app_config.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  bool get isDemoMode => !AppConfig.enableFirebase;

  Stream<User?> get authStateChanges =>
      isDemoMode ? const Stream.empty() : _auth.authStateChanges();

  User? get currentUser => isDemoMode ? null : _auth.currentUser;

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onError,
  }) async {
    if (isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      onCodeSent('demo-verification-id');
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (_) {},
      verificationFailed: (e) => onError(e.message ?? 'Verification failed'),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    if (isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      throw UnsupportedError('Demo mode uses local auth state only');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    if (!isDemoMode) {
      await _auth.signOut();
    }
  }
}
