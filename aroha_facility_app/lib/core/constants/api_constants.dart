// import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String baseUrl = 'http://10.231.50.133:8080/api/v1';

  static String get getStocks => '$baseUrl/stocks';
  
  static String get getMembers => '$baseUrl/members';
  static String get updateLocation => '$baseUrl/movement/location';

  static String get getTeams => '$baseUrl/teams';
  static String getTeamMembers(String teamId) => '$baseUrl/teams/$teamId/members';
}