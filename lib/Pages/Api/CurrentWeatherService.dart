import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrentWeatherService {
  static const String _apiKey = '26957879c2c9dd0ab5733408862a47f2';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  static Future<Map<String, dynamic>> fetchCurrentWeather(double lat, double lon) async {
    final response = await http.get(Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
