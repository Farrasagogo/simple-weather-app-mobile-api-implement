import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CurrentWeatherScreen(),
    );
  }
}

class CurrentWeatherScreen extends StatefulWidget {
  @override
  _CurrentWeatherScreenState createState() => _CurrentWeatherScreenState();
}

class _CurrentWeatherScreenState extends State<CurrentWeatherScreen> {
  final String apiKey = '33e8bdef63762ef264e7eaa7868bf175';
  final double lat = 44.34;
  final double lon = 10.99;

  Future<Map<String, dynamic>?> fetchCurrentWeather() async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load current weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Weather'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Weather App', style: TextStyle(color: Colors.white, fontSize: 24)),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Current Weather'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Forecast'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final weatherData = snapshot.data!;
            final cityName = weatherData['name'];
            final temp = weatherData['main']['temp'];
            final feelsLike = weatherData['main']['feels_like'];
            final description = weatherData['weather'][0]['description'];
            final icon = weatherData['weather'][0]['icon'];

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cityName,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Image.network('https://openweathermap.org/img/wn/$icon@2x.png'),
                  Text(
                    '$temp°C',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Feels like: $feelsLike°C',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final String apiKey = '33e8bdef63762ef264e7eaa7868bf175';
  final double lat = 44.34;
  final double lon = 10.99;

  Future<Map<String, dynamic>?> fetchWeather() async {
    final url = 'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final weatherData = snapshot.data!;
            final cityName = weatherData['city']['name'];
            final weatherList = weatherData['list'] as List<dynamic>;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    cityName,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: weatherList.length,
                    itemBuilder: (context, index) {
                      final item = weatherList[index];
                      final temp = item['main']['temp'];
                      final time = item['dt_txt'];
                      final description = item['weather'][0]['description'];

                      return ListTile(
                        title: Text('Time: $time'),
                        subtitle: Text('Temperature: $temp°C\nDescription: $description'),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
