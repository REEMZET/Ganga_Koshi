import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = '26957879c2c9dd0ab5733408862a47f2';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  static Future<List<Map<String, dynamic>>> fetchWeather(double lat, double lon) async {
    final response = await http.get(Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, dynamic>> forecastList = [];

      for (var item in data['list']) {
        forecastList.add({
          'date': item['dt_txt'],
          'temperature': item['main']['temp'],
          'description': item['weather'][0]['description'],
          'icon': item['weather'][0]['icon'],
        });
      }
      return forecastList;
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
