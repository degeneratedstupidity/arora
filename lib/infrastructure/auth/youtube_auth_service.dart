import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// Manages Google/YouTube OAuth login.
///
/// An authenticated http.Client eliminates YouTube's per-IP rate limiting.
/// Pass the client returned by [getAuthenticatedClient] to
/// [YoutubeExplodeMusicProvider] at startup.
///
/// Linux desktop: google_sign_in has no Linux implementation — callers receive
/// null and the provider falls back to unauthenticated (guest) mode.
class YoutubeAuthService {
  static const _scopes = [
    'https://www.googleapis.com/auth/youtube.readonly',
  ];

  final _googleSignIn = GoogleSignIn(scopes: _scopes);

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  bool get isSignedIn => _googleSignIn.currentUser != null;

  /// Interactive sign-in. Returns null if the user cancels or the platform
  /// does not support Google Sign-In (e.g. Linux desktop).
  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() => _googleSignIn.signOut();

  /// Restores a previous session silently. Call once at app startup.
  /// Returns null without throwing on unsupported platforms.
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (_) {
      return null;
    }
  }

  /// Returns an authenticated [http.Client] whose Authorization header is kept
  /// fresh automatically. Returns null if not signed in or on unsupported
  /// platforms — callers must handle null (guest/unauthenticated mode).
  Future<http.Client?> getAuthenticatedClient() async {
    try {
      return await _googleSignIn.authenticatedClient();
    } catch (_) {
      return null;
    }
  }
}
