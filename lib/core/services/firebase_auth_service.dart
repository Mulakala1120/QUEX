import 'package:firebase_auth/firebase_auth.dart';
import 'package:quex/core/config/app_config.dart';

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth;

  final FirebaseAuth? _auth;

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  bool get isDemoMode => !AppConfig.enableFirebase;

  Stream<User?> get authStateChanges {
    if (isDemoMode) return const Stream.empty();
    return _firebaseAuth.authStateChanges();
  }

  User? get currentUser {
    if (isDemoMode) return null;
    return _firebaseAuth.currentUser;
  }

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

    await _firebaseAuth.verifyPhoneNumber(
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
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    if (!isDemoMode) {
      await _firebaseAuth.signOut();
    }
  }
}
