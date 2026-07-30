class ApiConstants {
  // Çalıştığın ortama göre baseUrl'i ayarla:
  static const String baseUrl = 'http://10.0.2.2:5117/api'; // Android Emülatör için
  // static const String baseUrl = 'http://localhost:5117/api'; // Windows / Web için

  static const String register = '$baseUrl/Users/register';
  static const String login = '$baseUrl/Users/login';
  static const String currentUser = '$baseUrl/Users/me';
  static const String radarData = '$baseUrl/RadarData';
  static const String syncLogs = '$baseUrl/SyncLogs';
}
