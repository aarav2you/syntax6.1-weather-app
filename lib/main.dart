import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  var temp;
  var date;
  var time;

  Future getWeather(String city) async {
    // String url = "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lng}"

    final cities = await json
        .decode(await rootBundle.loadString('assets/data/cities.json'));

    final cityParameter =
        "forecast?latitude=${cities[city]['lat']}&longitude=${cities[city]['lng']}";

    http.Response response = await http.get(Uri.parse(
        "https://api.open-meteo.com/v1/$cityParameter&current_weather=true&timeformat=unixtime"));

    print(response.body.toString());
  }

  @override
  void initState() {
    super.initState();
    this.getWeather("New York");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather App - Aarav Prasad',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            title: Text("CITY!"),
            backgroundColor: Colors.black38,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            actions: [
              IconButton(
                padding: EdgeInsets.only(right: 20),
                onPressed: null,
                icon: Icon(
                  Icons.search,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          body: Container(
              child: Stack(children: [
            Image.asset(
              "assets/time/night.jpg", // dynamic
              alignment: Alignment.center,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
            Container(
              decoration: BoxDecoration(color: Colors.black45),
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SvgPicture.asset(
                      'assets/weather/cloudy-night.svg',
                      width: 300,
                    ),
                  ),
                  Text(
                    'Temperature',
                    style: GoogleFonts.inter(
                        fontSize: 75,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: -0.5),
                  ),
                  Text(
                    'Date',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Time',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                  // Divider(thickness: 30,)
                ],
              ),
            )
          ])),
        ));
  }
}
