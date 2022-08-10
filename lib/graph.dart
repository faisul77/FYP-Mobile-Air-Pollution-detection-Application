import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Graph extends StatefulWidget {
  final String? uid;
  const Graph({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  late List<String> alldatablistedbytime;
  late ZoomPanBehavior _zoomPanBehavior;
  late Future<int> dataFuture;
  late List<ChartData> chartData = [];
  late List<ChartData> chartData1 = [];
  late List<ChartData> chartData2 = [];
  late List<ChartData> chartData3 = [];
  late List<ChartData> chartData4 = [];
  late List<ChartData> chartData5 = [];
  late List<ChartData> chartData6 = [];

  @override
  void initState() {
    dataFuture=getDataSource();
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.x,
      enablePanning: true,
    );
    Timer.periodic(const Duration(seconds: 15), updateDataSource);
    //super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateDataSource(Timer timer) async {
    if(!mounted){
      timer.cancel();
    }


    var uid = await widget.uid.toString();
    final ref = FirebaseDatabase.instance.refFromURL(
        'https://airpollution-8fa78-default-rtdb.asia-southeast1.firebasedatabase.app');
    final snapshot = await ref
        .child(uid)
        .child(DateTime.now().year.toString())
        .child(DateTime.now().month.toString())
        .child(DateTime.now().day.toString())
        .orderByKey()
        .limitToLast(1)
        .get();
    if (snapshot.exists) {
      var latestreading =
          snapshot.value.toString().replaceAll(RegExp("{| |}"), "");
      List<String>? splitted_once = latestreading.split(':');
      var timestamp = splitted_once[0];
      var latitude = splitted_once[1];
      var longtitude = splitted_once[2];
      var co = splitted_once[3];
      var co2 = splitted_once[4];
      var temp = splitted_once[5];
      var humidity = splitted_once[6];
      var pressure = splitted_once[7];
      var pm25 = splitted_once[8];
      var pm10 = splitted_once[9];

      var datetime = await DateTime.fromMillisecondsSinceEpoch(
          double.parse(timestamp).toInt() * 1000);
      if (datetime.toString() != chartData.last.x.toString()) {
        chartData.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(co2)));
        chartData1.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(co)));
        chartData2.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(temp)));
        chartData3.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(humidity)));
        chartData4.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(pressure)));
        chartData5.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(pm25)));
        chartData6.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(pm10)));
/*        if (chartData.length > 60) {
          setState(() {});
        }*/
      }
    }
  }

  Future <int> getDataSource() async {
    var uid = await widget.uid.toString();
    final ref = FirebaseDatabase.instance.refFromURL(
        'https://airpollution-8fa78-default-rtdb.asia-southeast1.firebasedatabase.app');
    final snapshot = await ref
        .child(uid)
        .child(DateTime.now().year.toString())
        .child(DateTime.now().month.toString())
        .child(DateTime.now().day.toString())
        .orderByKey()
        .get();
    if (snapshot.exists) {
      //print(snapshot.value);
      String all_data =
          snapshot.value.toString().replaceAll(RegExp("{| |}"), "");
      //print(all_data);
      alldatablistedbytime = all_data.split(',');
      alldatablistedbytime.sort();
      for (var x in alldatablistedbytime) {
        print(x);
        List<String>? splitted_once = x.split(':');
        var timestamp = splitted_once[0];
        var latitude = splitted_once[1];
        var longtitude = splitted_once[2];
        var co = splitted_once[3];
        var co2 = splitted_once[4];
        var temp = splitted_once[5];
        var humidity = splitted_once[6];
        var pressure = splitted_once[7];
        var pm25 = splitted_once[8];
        var pm10 = splitted_once[9];
        var datetime = await DateTime.fromMillisecondsSinceEpoch(
            double.parse(timestamp).toInt() * 1000);
        print(datetime);
        print(datetime.year);
        chartData.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(co2)));
        chartData1.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(co)));
        chartData2.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(temp)));
        chartData3.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(humidity)));
        chartData4.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(pressure)));
        chartData5.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(pm25)));
        chartData6.add(ChartData(
            DateTime(datetime.year, datetime.month, datetime.day, datetime.hour,
                datetime.minute, datetime.second),
            double.parse(pm10)));
      }
      setState(() {

      });
    } else {
      print('No data available.');
    }

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: dataFuture,
      builder: (context,snapshot){
        if(snapshot.hasData){
          if(snapshot.data==1){
            return SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    SfCartesianChart(
                        zoomPanBehavior: _zoomPanBehavior,
                        enableAxisAnimation: true,
                        primaryXAxis: DateTimeAxis(
                          //intervalType: DateTimeIntervalType.hours,
                          //interval: 1,
                          //autoScrollingDelta:500
                        ),
                        primaryYAxis: NumericAxis(),
                        // Chart title
                        title: ChartTitle(text: 'CO2 concentration (ppm)'),
                        // Enable legend
                        legend: Legend(isVisible: false),
                        // Enable tooltip
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <ChartSeries<ChartData, DateTime>>[
                          LineSeries<ChartData, DateTime>(
                              dataSource: chartData,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y),
                        ]),
                    SfCartesianChart(
                        zoomPanBehavior: _zoomPanBehavior,
                        enableAxisAnimation: true,
                        primaryXAxis: DateTimeAxis(
                          //intervalType: DateTimeIntervalType.hours,
                          //interval: 1,
                        ),
                        primaryYAxis: NumericAxis(),
                        // Chart title
                        title: ChartTitle(text: 'CO concentration (ppm)'),
                        // Enable legend
                        legend: Legend(isVisible: false),
                        // Enable tooltip
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <ChartSeries<ChartData, DateTime>>[
                          LineSeries<ChartData, DateTime>(
                              dataSource: chartData1,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y),
                        ]),
                    SfCartesianChart(
                        zoomPanBehavior: _zoomPanBehavior,
                        enableAxisAnimation: true,
                        primaryXAxis: DateTimeAxis(
                          //intervalType: DateTimeIntervalType.hours,
                          //interval: 1,
                        ),
                        primaryYAxis: NumericAxis(),
                        // Chart title
                        title: ChartTitle(text: 'Temp (celcius)'),
                        // Enable legend
                        legend: Legend(isVisible: false),
                        // Enable tooltip
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <ChartSeries<ChartData, DateTime>>[
                          LineSeries<ChartData, DateTime>(
                              dataSource: chartData2,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y),
                        ]),
                    SfCartesianChart(
                        zoomPanBehavior: _zoomPanBehavior,
                        enableAxisAnimation: true,
                        primaryXAxis: DateTimeAxis(
                          //intervalType: DateTimeIntervalType.hours,
                          //interval: 1,
                        ),
                        primaryYAxis: NumericAxis(),
                        // Chart title
                        title: ChartTitle(text: 'Humidity (%)'),
                        // Enable legend
                        legend: Legend(isVisible: false),
                        // Enable tooltip
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <ChartSeries<ChartData, DateTime>>[
                          LineSeries<ChartData, DateTime>(
                              dataSource: chartData3,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y),
                        ]),
                    SfCartesianChart(
                        zoomPanBehavior: _zoomPanBehavior,
                        enableAxisAnimation: true,
                        primaryXAxis: DateTimeAxis(
                          //intervalType: DateTimeIntervalType.hours,
                          //interval: 1,
                        ),
                        primaryYAxis: NumericAxis(),
                        // Chart title
                        title: ChartTitle(text: 'Pressure (hPA)'),
                        // Enable legend
                        legend: Legend(isVisible: false),
                        // Enable tooltip
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <ChartSeries<ChartData, DateTime>>[
                          LineSeries<ChartData, DateTime>(
                              dataSource: chartData4,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y),
                        ]),
                    SfCartesianChart(
                        zoomPanBehavior: _zoomPanBehavior,
                        enableAxisAnimation: true,
                        primaryXAxis: DateTimeAxis(
                          //intervalType: DateTimeIntervalType.hours,
                          //interval: 1,
                        ),
                        primaryYAxis: NumericAxis(),
                        // Chart title
                        title: ChartTitle(text: 'PM2.5 concentration (ug/m3)'),
                        // Enable legend
                        legend: Legend(isVisible: false),
                        // Enable tooltip
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <ChartSeries<ChartData, DateTime>>[
                          LineSeries<ChartData, DateTime>(
                              dataSource: chartData5,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y),
                        ]),
                    SfCartesianChart(
                        zoomPanBehavior: _zoomPanBehavior,
                        enableAxisAnimation: true,
                        primaryXAxis: DateTimeAxis(
                          //intervalType: DateTimeIntervalType.hours,
                         // interval: 1,
                        ),
                        primaryYAxis: NumericAxis(),
                        // Chart title
                        title: ChartTitle(text: 'PM10 concentration (ug/m3)'),
                        // Enable legend
                        legend: Legend(isVisible: false),
                        // Enable tooltip
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <ChartSeries<ChartData, DateTime>>[
                          LineSeries<ChartData, DateTime>(
                              dataSource: chartData6,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y),
                        ])
                  ],
                ),
              ),
            );
          }
        }
        else{return CircularProgressIndicator();}
        return CircularProgressIndicator();

      }
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final DateTime x;
  final double y;
}
