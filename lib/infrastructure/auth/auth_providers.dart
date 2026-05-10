import 'package:arora/infrastructure/auth/youtube_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Singleton auth service exposed to the widget tree.
///
/// Invalidate this provider after sign-in or sign-out so that all
/// Consumer widgets reading [youtubeAuthServiceProvider] rebuild.
final youtubeAuthServiceProvider = Provider<YoutubeAuthService>((ref) {
  return YoutubeAuthService();
});
