import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../Pages/Api/WeatherService.dart';

class WeatherWidget extends StatefulWidget {
  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
      _fetchWeatherData(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error getting location: ${e.toString()}')));
    }
  }

  void _fetchWeatherData(double lat, double lon) {
    // Your code to fetch weather data using the fetched coordinates
  }

  @override
  Widget build(BuildContext context) {
    return _currentPosition == null
        ? Center(child: CircularProgressIndicator())
        : FutureBuilder<List<Map<String, dynamic>>>(
      future: WeatherService.fetchWeather(_currentPosition!.latitude, _currentPosition!.longitude),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No weather data available.'));
        } else {
          final List<Map<String, dynamic>> data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final forecast = data[index];
              final temperature = forecast['temperature'].toString();
              final weather = forecast['description'];
              final weatherIcon = forecast['icon'];
              final date = forecast['date'];

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: TextStyle(fontSize: 16, color: Colors.white)),
                    Row(
                      children: [
                        Image.network(
                          'https://openweathermap.org/img/wn/$weatherIcon.png',
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(width: 10),
                        Text(weather, style: TextStyle(fontSize: 20, color: Colors.white)),
                      ],
                    ),
                    Text('$temperature°C', style: TextStyle(fontSize: 26, color: Colors.white)),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
