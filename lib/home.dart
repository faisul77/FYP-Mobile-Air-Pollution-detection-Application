import 'dart:async';
import 'package:air_pollution_quality_monitor/read/parameters.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter/cupertino.dart';

class Home extends StatefulWidget {
  final String? co2, co, temp, humidity, pressure, pm25, pm10, uid;
  const Home(
      {Key? key,
      required this.co2,
      required this.co,
      required this.temp,
      required this.humidity,
      required this.pressure,
      required this.pm25,
      required this.pm10,
      required this.uid})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<String> alldatablistedbytime = [];
  late List<String> todaydatablistedbytime = [];
  late List<String> yesterdaydatablistedbytime = [];
  late List<String> yesterdaydatablistedbytimecopy = [];
  late List<double> pm25api = [];
  late List<double> pm10api = [];
  late List<double> coapi = [];
  bool status = false;
  bool yesterdaygotdata=false;
  late String text1 = 'conc';
  List<int>? pm25, pm10, co;
  var blueaccent = Colors.white;
  var lightblueaccent = Colors.white;
  var green = Colors.white;
  var lightgreenaccent = Colors.white;
  var startcolor = Colors.white;
  var endcolor = Colors.white;
  double apivalue = 0;
  var co2value = 0;
  var covalue = 0;
  var pm25value = 0;
  var pm10value = 0;
  var humidityvalue = 0;
  var tempvalue = 0;
  var pressurevalue = 0;
  late int minimumDateinSecondsSinceEpochinteger;

  @override
  void initState() {
    initAPI();
    Timer.periodic(const Duration(seconds: 10), updateAPI);
  }

  @override
  void dispose() {
    //
    super.dispose();
    //...
  }

  void initAPI() async {
    var currentDate = DateTime.now().millisecondsSinceEpoch;
    var currentDateinSecondsSinceEpoch = currentDate / 1000;
    int currentDateinSecondsSinceEpochinteger =
    currentDateinSecondsSinceEpoch.toInt();
    minimumDateinSecondsSinceEpochinteger =
        currentDateinSecondsSinceEpochinteger - 86400;
    await getTodayData();
    await getYesterdayData();
    await combineTodayandYesterdayData();
    await calculateAPI();
  }

  void updateAPI(Timer timer) async {
    var currentDate = DateTime.now().millisecondsSinceEpoch;
    var currentDateinSecondsSinceEpoch = currentDate / 1000;
    int currentDateinSecondsSinceEpochinteger =
        currentDateinSecondsSinceEpoch.toInt();
    minimumDateinSecondsSinceEpochinteger =
        currentDateinSecondsSinceEpochinteger - 86400;
    await getTodayData();
    await getYesterdayData();
    await combineTodayandYesterdayData();
    await calculateAPI();
  }

  Future<void> getTodayData() async {
    var uid = await widget.uid.toString();
    final ref = FirebaseDatabase.instance.refFromURL(
        'https://airpollution-8fa78-default-rtdb.asia-southeast1.firebasedatabase.app');
    final snapshottoday = await ref
        .child(uid)
        .child(DateTime.now().year.toString())
        .child(DateTime.now().month.toString())
        .child(DateTime.now().day.toString())
        .orderByKey()
        .get();
    if (snapshottoday.exists) {
      //print(snapshot.value);
      String all_data =
          snapshottoday.value.toString().replaceAll(RegExp("{| |}"), "");
      //print(all_data);
      todaydatablistedbytime = all_data.split(',');
      todaydatablistedbytime.sort();
      print(todaydatablistedbytime);
    } else {
      print('No data available today.');
    }
  }

  Future<void> getYesterdayData() async {
    var uid = await widget.uid.toString();
    final ref = FirebaseDatabase.instance.refFromURL(
        'https://airpollution-8fa78-default-rtdb.asia-southeast1.firebasedatabase.app');
    final snapshotyesterday = await ref
        .child(uid)
        .child(DateTime.now().year.toString())
        .child(DateTime.now().month.toString())
        .child((DateTime.now().day - 1).toString())
        .orderByKey()
        .get();
    if (snapshotyesterday.exists) {
      yesterdaygotdata=true;
      //print(snapshot.value);
      String all_data =
          snapshotyesterday.value.toString().replaceAll(RegExp("{| |}"), "");
      //print(all_data);
      yesterdaydatablistedbytime = all_data.split(',');
      yesterdaydatablistedbytime.sort();
      yesterdaydatablistedbytimecopy = yesterdaydatablistedbytime.toList();

      for (var x in yesterdaydatablistedbytime) {
        List<String>? splitted_once = x.split(':');
        if (int.parse(splitted_once[0]) <
            minimumDateinSecondsSinceEpochinteger) {
          yesterdaydatablistedbytimecopy.remove(x);
        }
      }
    } else {
      print('No data available yesterday.');
    }
  }

  Future<void> combineTodayandYesterdayData() async {
    if(yesterdaygotdata==true)
        {alldatablistedbytime = todaydatablistedbytime + yesterdaydatablistedbytimecopy;}
    else
        {alldatablistedbytime=todaydatablistedbytime;}
    print("alldatalistedbytime = $alldatablistedbytime");
  }

  Future<void> calculateAPI() async {
    pm25api = [];
    pm10api = [];
    coapi = [];

    for (var x in alldatablistedbytime) {
      List<String>? splitted_once = x.split(':');
      var timestamp = splitted_once[0];
      //------------------------------------------------------------------
      double pm25_double = double.parse(splitted_once[8]);
      double pm25_api = 0;
      if (pm25_double < 12.0) {
        pm25_api = ((50 - 0) / (12.0 - 0)) * (pm25_double - 0) + 0;
      } else if (12.1 <= pm25_double && pm25_double <= 75.4) {
        pm25_api = ((100 - 51) / (75.4 - 12.1)) * (pm25_double - 12.1) + 51;
      } else if (75.5 <= pm25_double && pm25_double <= 150.4) {
        pm25_api = ((200 - 101) / (150.4 - 75.5)) * (pm25_double - 75.5) + 101;
      } else if (150.5 <= pm25_double && pm25_double <= 250.4) {
        pm25_api =
            ((300 - 201) / (250.4 - 150.5)) * (pm25_double - 150.5) + 201;
      } else if (250.5 <= pm25_double && pm25_double <= 350.4) {
        pm25_api =
            ((400 - 301) / (350.4 - 250.5)) * (pm25_double - 250.5) + 301;
      } else if (350.5 <= pm25_double && pm25_double <= 500.4) {
        pm25_api =
            ((500 - 401) / (500.4 - 350.5)) * (pm25_double - 350.5) + 401;
      }
      pm25api.add(pm25_api);
      double pm10_double = double.parse(splitted_once[9]);
      double pm10_api = 0;
      if (pm10_double < 54) {
        pm10_api = ((50 - 0) / (54 - 0)) * (pm10_double - 0) + 0;
      } else if (55 <= pm10_double && pm10_double <= 154) {
        pm10_api = ((100 - 51) / (154 - 55)) * (pm10_double - 55) + 51;
      } else if (155 <= pm10_double && pm10_double <= 254) {
        pm10_api = ((150 - 101) / (254 - 155)) * (pm10_double - 155) + 101;
      } else if (255 <= pm10_double && pm10_double <= 354) {
        pm10_api = ((200 - 151) / (354 - 255)) * (pm10_double - 255) + 251;
      } else if (355 <= pm10_double && pm10_double <= 424) {
        pm10_api = ((300 - 201) / (424 - 355)) * (pm10_double - 355) + 201;
      } else if (425 <= pm10_double && pm10_double <= 504) {
        pm10_api = ((400 - 301) / (504 - 425)) * (pm10_double - 425) + 301;
      } else if (505 <= pm10_double && pm10_double <= 604) {
        pm10_api = ((500 - 401) / (604 - 505)) * (pm10_double - 505) + 401;
      }
      pm10api.add(pm10_api);
      double co_double = double.parse(splitted_once[3]);
      double co_api = 0;
      if (co_double < 54) {
        co_api = ((50 - 0) / (54 - 0)) * (co_double - 0) + 0;
      } else if (55 <= co_double && co_double <= 154) {
        co_api = ((100 - 51) / (154 - 55)) * (co_double - 55) + 51;
      } else if (155 <= co_double && co_double <= 254) {
        co_api = ((150 - 101) / (254 - 155)) * (co_double - 155) + 101;
      } else if (255 <= co_double && co_double <= 354) {
        co_api = ((200 - 151) / (354 - 255)) * (co_double - 255) + 151;
      } else if (355 <= co_double && co_double <= 424) {
        co_api = ((300 - 201) / (424 - 355)) * (co_double - 355) + 201;
      } else if (425 <= co_double && co_double <= 504) {
        co_api = ((400 - 301) / (504 - 425)) * (co_double - 425) + 301;
      } else if (505 <= co_double && co_double <= 604) {
        co_api = ((500 - 401) / (604 - 505)) * (co_double - 505) + 401;
      }
      coapi.add(co_api);
    }
    double pm25_avg_value;
    double total_pm25_value = 0;
    for (var x in pm25api) {
      total_pm25_value = total_pm25_value + x;
    }
    pm25_avg_value = total_pm25_value / pm25api.length.toDouble();

    double pm10_avg_value;
    double total_pm10_value = 0;
    for (var x in pm10api) {
      total_pm10_value = total_pm10_value + x;
    }
    pm10_avg_value = total_pm10_value / pm10api.length.toDouble();

    double co_avg_value;
    double total_co_value = 0;
    for (var x in coapi) {
      total_co_value = total_co_value + x;
    }
    co_avg_value = total_co_value / coapi.length.toDouble();

    List<double> apis = [pm25_avg_value, pm10_avg_value, co_avg_value];
    print("theapis $apis");
    apis.sort();
    double largestapi = apis.last;
if(mounted){
  setState(() {
    if (largestapi.isNaN) {
      largestapi = 0;
    }
    apivalue = largestapi;
    print(largestapi);
  });
}
    pm25?.clear();
    pm25api.clear();
    pm10?.clear();
    pm10api.clear();
    co?.clear();
    coapi.clear();
    alldatablistedbytime.clear();
    todaydatablistedbytime.clear();
    yesterdaydatablistedbytime.clear();
    yesterdaydatablistedbytimecopy.clear();
  }

  @override
  Widget build(BuildContext context) {
    double statusbarHeight = MediaQuery.of(context).viewPadding.top;
    return Container(
        child: Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), color: Colors.white),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("API Info"),
                            content: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text("0 to 50",style: TextStyle(color: Colors.green),),
                                    Text("Good",style: TextStyle(color: Colors.green)),
                                  ],),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text("51 to 100",style: TextStyle(color: Colors.yellow)),
                                    Text("Moderate",style: TextStyle(color: Colors.yellow)),
                                  ],),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text("101 to 150",style: TextStyle(color: Colors.deepOrange)),
                                    Text("Unhealthy for some",style: TextStyle(color: Colors.deepOrange)),
                                  ],),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text("151-200",style: TextStyle(color: Colors.red)),
                                    Text("Unhealthy",style: TextStyle(color: Colors.red)),
                                  ],),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text("201-300",style: TextStyle(color: Colors.purple)),
                                    Text("Very Unhealthy",style: TextStyle(color: Colors.purple)),
                                  ],),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text("301+",style: TextStyle(color: Colors.brown)),
                                    Text("Hazardous",style: TextStyle(color: Colors.brown))
                                  ],),
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("OK"))
                            ],
                          ));
                },
                child: SfRadialGauge(
                    title: GaugeTitle(
                        text: 'Air Pollution Index',
                        textStyle: const TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold)),
                    axes: <RadialAxis>[
                      RadialAxis(
                          minimum: 0,
                          maximum: 500,
                          startAngle: 135,
                          endAngle: 45,
                          radiusFactor: 0.7,
                          ranges: <GaugeRange>[
                            GaugeRange(
                              startValue: 0,
                              endValue: 50,
                              color: Colors.green,
                              startWidth: 10,
                              endWidth: 10
                            ),
                            GaugeRange(
                                startValue: 50,
                                endValue: 100,
                                color: Colors.yellow,
                                startWidth: 10,
                                endWidth: 10),
                            GaugeRange(
                                startValue: 101,
                                endValue: 150,
                                color: Colors.deepOrange,
                                startWidth: 10,
                                endWidth: 10),
                            GaugeRange(
                                startValue: 151,
                                endValue: 200,
                                color: Colors.red,
                                startWidth: 10,
                                endWidth: 10),
                            GaugeRange(
                                startValue: 200,
                                endValue: 300,
                                color: Colors.purple,
                                startWidth: 10,
                                endWidth: 10),
                            GaugeRange(
                                startValue: 300,
                                endValue: 500,
                                color: Colors.brown,
                                startWidth: 10,
                                endWidth: 10),
                          ],
                          pointers: <GaugePointer>[
                            NeedlePointer(
                              value: apivalue,
                              needleColor: Colors.purpleAccent,
                            )
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                                widget: Container(
                                    child: Text(apivalue.floor().toString(),
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold))),
                                angle: 90,
                                positionFactor: 0.5)
                          ])
                    ]),
              ),
            ),
            Container(
              child: CupertinoButton(
                onPressed: () {},
                child: Text("Device connected! Monitoring data..."),
                color: Colors.lightGreenAccent,
                padding: EdgeInsets.all(16),
                disabledColor: Colors.grey,
                pressedOpacity: 0.6,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          SizedBox(height: 10,),
            Container(

                // color: Colors.blueAccent.withOpacity(.2),
                margin: EdgeInsets.all(statusbarHeight / 2),
                padding: EdgeInsets.all(statusbarHeight / 2),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        startcolor,
                        endcolor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.1),
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(25)),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        PARAMETERS(
                          parametervalue: widget.co2,
                          parametername: 'CO2',
                          parameterunit: '(ppm)',
                        ),
                        PARAMETERS(
                            parametervalue: widget.co,
                            parametername: 'CO',
                            parameterunit: '(ppm)'),
                        PARAMETERS(
                            parametervalue: widget.pm10,
                            parametername: 'PM2.5',
                            parameterunit: '(ug/m3)'),
                        PARAMETERS(
                            parametervalue: widget.pm25,
                            parametername: 'PM10',
                            parameterunit: '(ug/m3)'),
                      ],
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        PARAMETERS(
                            parametervalue: widget.temp,
                            parametername: 'Temp',
                            parameterunit: '(°c)'),
                        PARAMETERS(
                            parametervalue: widget.humidity,
                            parametername: 'Humidity',
                            parameterunit: '(%)'),
                        PARAMETERS(
                            parametervalue: widget.pressure,
                            parametername: 'Pressure',
                            parameterunit: '(hPA)'),
                      ],
                    )
                  ],
                )),
          ]),
    ));
  }
}

enum BluetoothState {
  UNKNOWN,
  UNSUPPORTED,
  UNAUTHORIZED,
  POWERED_ON,
  POWERED_OFF,
  RESETTING,
}
