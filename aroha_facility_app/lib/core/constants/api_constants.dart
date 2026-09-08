// import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String baseUrl = 'http://10.10.181.50:8080/api/v1';

  static String get login => '$baseUrl/auth/login';

  static String get getStocks => '$baseUrl/stocks';
  static String get getCriticalityCount => '$baseUrl/facility/stocks/criticality/count';
  
  static String get getMembers => '$baseUrl/members';
  static String get updateLocation => '$baseUrl/movement/location';

  static String get getTeams => '$baseUrl/teams';
  static String getTeamMembers(String teamId) => '$baseUrl/teams/$teamId/members';

  static String get getTopCriticalStocks => '$baseUrl/stocks/top-critical';
}