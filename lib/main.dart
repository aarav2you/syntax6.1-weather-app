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

Icon customIcon = const Icon(
  Icons.search,
  size: 30,
  color: Colors.white,
);

Widget customSearchBar = const Text('Weather App');

String cityName = "Noida";
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
  var weatherBackground;
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
    print(weatherResult);

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

    var wmoCode = weatherResult["current_weather"]["weathercode"];
    var weatherBackgroundName;
    var weatherSvgName;
    // WMO graph interpretation

    if (wmoCode == 0 && isDay) {
      weatherSvgName = "clear-day";
    } else if (wmoCode == 0 && isDay != true) {
      weatherSvgName = "clear-night";
    } else if (wmoCode >= 1 && wmoCode <= 3 && isDay) {
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
    } else if (wmoCode >= 77 && wmoCode <= 77) {
      weatherSvgName = "snow2";
    } else if (wmoCode >= 80 && wmoCode <= 82) {
      weatherSvgName = "rain3";
    } else if (wmoCode == 85 || wmoCode == 86) {
      weatherSvgName = "snow3";
    } else {
      weatherSvgName = "thunder";
    }

    // Generalizing WMO codes
    if (wmoCode >= 0 && wmoCode <= 3 && isDay) {
      weatherBackgroundName = "morning";
    } else if (wmoCode >= 0 && wmoCode <= 3 && isDay != true) {
      weatherBackgroundName = "night";
    } else if (wmoCode >= 56 && wmoCode <= 67) {
      weatherBackgroundName = "raining";
    } else if (wmoCode >= 71 && wmoCode <= 77) {
      weatherBackgroundName = "snowing";
    } else if (wmoCode >= 80 && wmoCode <= 82) {
      weatherBackgroundName = "raining";
    } else if (wmoCode >= 95 && wmoCode <= 99) {
      weatherBackgroundName = "thunder";
    }

    setState(() {
      this.temp = weatherResult["current_weather"]["temperature"];
      this.weatherSvg = "assets/weather/" + weatherSvgName + ".svg";
      this.weatherBackground = "assets/time/" + weatherBackgroundName + ".jpg";
      this.time = time.toString().split(" ")[1].split(".")[0];
      this.date = time.toString().split(" ")[0];
    });
  }

  @override
  void initState() {
    super.initState();
    this.getWeather(cityName);
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
            title: customSearchBar,
            backgroundColor: Colors.black38,
            elevation: 0,
            leading: IconButton(
                onPressed: () {
                  setState(() {
                    if (customIcon.icon == Icons.search) {
                      customIcon = const Icon(Icons.cancel);
                      customSearchBar = ListTile(
                        title: TextField(
                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) {
                            cityName = value;
                          },
                          decoration: InputDecoration(
                            hintText: 'Type in full name of city...',
                            hintStyle: TextStyle(
                              color: Colors.white38,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    } else {
                      customIcon = Icon(Icons.search);
                      customSearchBar = Text(cityName);
                    }
                  });
                },
                icon: customIcon),
            centerTitle: true,
          ),
          // appBar: AppBar(
          //   title: Icon(
          //     Icons.search,
          //     size: 30,
          //     color: Colors.white,
          //   ),
          //   backgroundColor: Colors.black38,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.vertical(
          //       bottom: Radius.circular(20),
          //     ),
          //   ),
          //   leading: IconButton(
          //     onPressed: () {
          //       setState(() {
          //         if (customIcon.icon == Icons.search) {
          //           customIcon = const Icon(Icons.cancel);
          //           customSearchBar = ListTile(
          //             title: TextField(
          //               textInputAction: TextInputAction.go,
          //               //     onChanged: (text) {
          //               //     print("City Name  is : "+ text);
          //               // },
          //               onSubmitted: (value) {
          //                 cityName = value;
          //                 print("search cityName ->>>>" + cityName);
          //               },

          //               decoration: InputDecoration(
          //                 hintText: 'type in city name...',
          //                 hintStyle: TextStyle(
          //                   color: Colors.white,
          //                   fontSize: 18,
          //                   fontStyle: FontStyle.italic,
          //                 ),
          //                 border: InputBorder.none,
          //               ),
          //               style: TextStyle(
          //                 color: Colors.white,
          //               ),
          //             ),
          //             // title: SelectCityWidget(),
          //           );
          //         } else {
          //           customIcon = const Icon(Icons.search);
          //           customSearchBar = Text(cityName);
          //         }
          //       });
          //     },
          //     icon: customIcon,
          //   ),
          //   // actions: [
          //   //   IconButton(
          //   //     padding: EdgeInsets.only(right: 20),
          //   //     onPressed: null,
          //   //     icon: Icon(
          //   //       Icons.search,
          //   //       size: 25,
          //   //       color: Colors.white,
          //   //     ),
          //   //   ),
          //   // ],
          // ),
          body: Container(
              child: Stack(children: [
            Container(
                child: weatherBackground != null
                    ? Image.asset(
                        weatherBackground,
                        alignment: Alignment.center,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      )
                    : Text("Loading...")),
            Container(
              decoration: BoxDecoration(color: Colors.black45),
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: weatherSvg != null
                        ? SvgPicture.asset(weatherSvg, width: 300)
                        : Text("Loading..."),
                  ),
                  Text(
                    temp != null ? temp.toString() + "\u{2103}" : "Loading...",
                    style: GoogleFonts.inter(
                        fontSize: 75,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: -0.5),
                  ),
                  Text(
                    date != null ? date : "Loading...",
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    time != null ? time : "Loading...",
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
