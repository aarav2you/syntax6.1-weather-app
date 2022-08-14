import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/browser.dart' as tz;

void main() {
  tz.initializeTimeZones();
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

String titleCase(String text) {
  return text
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

class _WeatherAppState extends State<WeatherApp> {
  var temp;
  var weatherSvg;
  var date;
  var time;

  Future getWeather(String city) async {
    // String url = "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lng}"

    city = titleCase(city);

    final cities = await json
        .decode(await rootBundle.loadString('assets/data/cities.json'));

    final cityParameter =
        "forecast?latitude=${cities[city]['lat']}&longitude=${cities[city]['lng']}";

    http.Response weatherReponse = await http.get(Uri.parse(
        "https://api.open-meteo.com/v1/$cityParameter&current_weather=true&timezone=auto"));

    var weatherResult = json.decode(weatherReponse.body);
    print(json.decode(weatherReponse.body));

    Future getLocalTime(String cityTimeZone) async {
      await tz.initializeTimeZone();
      var timeZone = tz.getLocation(cityTimeZone);
      var now = tz.TZDateTime.now(timeZone).toString();
      return now;
    }

    var time = await getLocalTime(weatherResult["timezone"]);
    var hour =
        int.tryParse(time.toString().split(" ")[1].split(".")[0].split(":")[0]);
    var isDay = hour! > 6 && hour < 19
        ? true
        : false; // Greater than 6am and less than 7pm = true

    var weatherSvgName;
    var wmoCode = weatherResult["current_weather"]["weathercode"];

    if (wmoCode == 0 && isDay) {
      weatherSvgName = "clear-day";
    } else if (wmoCode == 0 && isDay != true) {
      weatherSvgName = "clear-night";
    } else if ((wmoCode >= 1 && wmoCode <= 3) && isDay) {
      weatherSvgName = "cloudy-day";
    } else if (wmoCode >= 1 && wmoCode <= 3 && isDay != true) {
      weatherSvgName = "cloudy-night";
    } else if (wmoCode >= 51 && wmoCode <= 55) {
      weatherSvgName = "rain1";
    } else if (wmoCode == 56 || wmoCode == 57) {
      weatherSvgName = "rain2";
    } else if (wmoCode >= 61 && wmoCode <= 65) {
      weatherSvgName = "rain3";
    } else if (wmoCode == 66 || wmoCode == 67) {
      weatherSvgName = "rain4";
    } else if (wmoCode >= 71 && wmoCode <= 75) {
      weatherSvgName = "snow1";
    } else if (wmoCode >= 77 && wmoCode <= 82) {
      weatherSvgName = "snow2";
    } else if (wmoCode == 86 || wmoCode == 86) {
      weatherSvgName = "snow3";
    } else {
      weatherSvgName = "thunder";
    }
    setState(() {
      this.temp = weatherResult["current_weather"]["temperature"];
      this.weatherSvg = "assets/weather/" + weatherSvgName + ".svg";
      this.time = time.toString().split(" ")[1].split(".")[0];
      this.date = time.toString().split(" ")[0];
    });

    // print(json.decode(weatherReponse.body)["current_weather"]["temperature"]);
  }

  @override
  void initState() {
    super.initState();
    this.getWeather("new york");
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
            title: Text("CITY!"), // Change
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
                    child: weatherSvg != null
                        ? SvgPicture.asset(weatherSvg, width: 300)
                        : Text("Loading"),
                    // SvgPicture.asset(
                    //   'assets/weather/cloudy-night.svg',
                    //   width: 300,
                    // ),
                  ),
                  Text(
                    temp != null ? temp.toString() + "\u{2103}" : "Loading",
                    style: GoogleFonts.inter(
                        fontSize: 75,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: -0.5),
                  ),
                  Text(
                    date != null ? date : "Loading",
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    time != null ? time : "Loading",
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
