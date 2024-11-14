import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import this line
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class WeatherService {
  final String apiKey = 'RP9BPBBZDJDZDTWU5QQ5ETM68';

  Future<Map<String, dynamic>?> fetchWeather(double lat, double lon) async {
    final String url =
        'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$lat,$lon?key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception caught: $e');
      return null;
    }
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService weatherService = WeatherService();
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('hi', null); // Initialize for Hindi
    Intl.defaultLocale = 'hi'; // Set the default locale to Hindi
    fetchCurrentLocationWeather();
  }

  Future<void> fetchCurrentLocationWeather() async {
    try {
      Position position = await _determinePosition();
      final double lat = position.latitude;
      final double lon = position.longitude;

      final data = await weatherService.fetchWeather(lat, lon);

      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching weather: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : weatherData == null
        ? Center(child: Text('मौसम का डेटा लोड करने में विफल।'))
        : Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildCurrentWeather(),

        ],
      ),
    );
  }

  double fahrenheitToCelsius(double tempF) {
    return (tempF - 32) * 5 / 9;
  }

  Widget _buildCurrentWeather() {
    if (weatherData == null || weatherData!['currentConditions'] == null) {
      return Center(child: Text('कोई मौसम डेटा उपलब्ध नहीं है।'));
    }

    final current = weatherData!['currentConditions'];
    final conditions = current['conditions'];
    final tempF = current['temp'];
    final tempC = fahrenheitToCelsius(tempF);
    final feelsLikeF = current['feelslike'];
    final feelsLikeC = fahrenheitToCelsius(feelsLikeF);
    final windSpeed = current['windspeed'];
    final humidity = current['humidity'];
    final sunrise = current['sunrise'];
    final sunset = current['sunset'];

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            conditions,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud, size: 25),
              SizedBox(width: 5),
              Text(
                '${tempC.toStringAsFixed(1)}°C',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text('महसूस होता है: ${feelsLikeC.toStringAsFixed(1)}°C', style: TextStyle(fontSize: 10)),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _weatherInfo(Icons.waves, '$windSpeed km/h हवा'),
              _weatherInfo(Icons.water_drop, '$humidity% आर्द्रता'),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _weatherInfo(Icons.wb_sunny, 'सूर्योदय: $sunrise'),
              _weatherInfo(Icons.nights_stay, 'सूर्यास्त: $sunset'),
            ],
          ),
          _buildForecast()
        ],
      ),
    );
  }
// Inside the WeatherScreen class

  Widget _buildForecast() {
    if (weatherData == null || weatherData!['days'] == null) {
      return Center(child: Text('कोई पूर्वानुमान डेटा उपलब्ध नहीं है।'));
    }

    final forecastData = weatherData!['days'] as List<dynamic>;
    final nextFourDays = forecastData.take(4).toList();

    return Container(
      padding: EdgeInsets.all(4),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: nextFourDays.map((day) {
          final date = DateFormat('EEE').format(DateTime.parse(day['datetime']));
          final tempF = day['temp'];
          final tempC = fahrenheitToCelsius(tempF);
          final conditions = day['conditions'];
          return _forecastItem(date, Icons.cloud, tempC.toStringAsFixed(1), conditions);
        }).toList(),
      ),
    );
  }

  Widget _forecastItem(String day, IconData icon, String temp, String condition) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Icon(icon, size: 25),
        SizedBox(height: 4),
        Text('$temp°C', style: TextStyle(fontSize: 12)),
        Text(condition, style: TextStyle(fontSize: 12,color: Colors.grey)),
        Text(day, style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.green)),
      ],
    );
  }

  Widget _weatherInfo(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, size: 25),
        SizedBox(height: 5),
        Text(value, style: TextStyle(fontSize: 14)),
      ],
    );
  }


}
