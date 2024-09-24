import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui'; // Import for BackdropFilter

import '../Pages/Api/CurrentWeatherService.dart';

class CurrentWeatherWidget extends StatefulWidget {
  @override
  _CurrentWeatherWidgetState createState() => _CurrentWeatherWidgetState();
}

class _CurrentWeatherWidgetState extends State<CurrentWeatherWidget> {
  late Future<Map<String, dynamic>> _weatherData;
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
        _weatherData = CurrentWeatherService.fetchCurrentWeather(position.latitude, position.longitude).catchError((error) {
          Fluttertoast.showToast(
            msg: "Error: ${error.toString()}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error getting location: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _currentPosition == null
        ? Center(child: CircularProgressIndicator())
        : FutureBuilder<Map<String, dynamic>>(
      future: _weatherData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final data = snapshot.data!;
          final temperature = data['main']['temp'].toString();
          final weather = data['weather'][0]['description'];
          final weatherIcon = data['weather'][0]['icon'];
          final minTemp = data['main']['temp_min'].toString();
          final maxTemp = data['main']['temp_max'].toString();
          final cityName = data['name']; // Added city name

          String assetImage = 'assets/images/mist.png'; // Default image if no match
          if (weather.contains('rain')) {
            assetImage = 'assets/images/rain.png';
          } else if (weather.contains('sun')) {
            assetImage = 'assets/images/sun.png';
          } else if (weather.contains('cloud')) {
            assetImage = 'assets/images/cloudy.png';
          } else if (weather.contains('snow')) {
            assetImage = 'assets/images/snow.png';
          } else if (weather.contains('storm')) {
            assetImage = 'assets/images/strom.png';
          } else if (weather.contains('fog')) {
            assetImage = 'assets/images/fog.png';
          }

          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.1), // Light purple background color
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cityName, // Display city name
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B5BFF), // Blue color for the city name text
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$temperature°C',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B5BFF), // Blue color for the temperature text
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2,),
                Text(
                  weather.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent // Blue color for the description text
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text('Min: $minTemp°C', style: TextStyle(fontSize: 16, color: Colors.black)),
                        Text('Max: $maxTemp°C', style: TextStyle(fontSize: 16, color: Colors.black)),
                      ],
                    ),

                    SizedBox(width: 8),
                    Image.asset(
                      assetImage, // Use local asset image
                      width: 100,
                      height: 75,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
