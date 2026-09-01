import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get imageUrl => dotenv.env['IMAGE_URL'] ?? baseUrl;
  static String get socketUrl => dotenv.env['SOCKET_URL'] ?? '';
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  static String get firebaseWebApiKey => dotenv.env['FIREBASE_WEB_API_KEY'] ?? '';
  static String get oneSignalAppId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  static String get appName => dotenv.env['APP_NAME'] ?? 'SwiftDrop Driver';
  static bool get isDebug => dotenv.env['IS_DEBUG'] == 'true';
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30') ?? 30;

  // ─── Reverb (WebSocket) ──────────────────────────────────────────────────
  static String get reverbAppId => dotenv.env['REVERB_APP_ID'] ?? '';
  static String get reverbAppKey => dotenv.env['REVERB_APP_KEY'] ?? '';
  static String get reverbAppSecret => dotenv.env['REVERB_APP_SECRET'] ?? '';
  static String get reverbHost => dotenv.env['REVERB_HOST'] ?? '';
  static int get reverbPort =>
      int.tryParse(dotenv.env['REVERB_PORT'] ?? '8080') ?? 8080;
  static String get reverbScheme => dotenv.env['REVERB_SCHEME'] ?? 'http';
}
