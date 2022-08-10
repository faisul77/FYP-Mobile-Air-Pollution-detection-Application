import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';

class HeatmapScreen extends StatefulWidget {
  final String? uid;

  const HeatmapScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<HeatmapScreen> createState() => HeatmapScreenState();
}

//initstate

class HeatmapScreenState extends State<HeatmapScreen> {
  DateTime date = DateTime(2022, 1, 1);
  //var lat,long,currentlocation;
  late List<String> alldatablistedbytime;
  var timestamp,
      latitude,
      longtitude,
      co,
      co2,
      temp,
      humidity,
      pressure,
      pm25,
      pm10,
      datetime;

  //var currentparameter="PM2.5";
  var currentparameterindex = 0;
  List<String> Parameters = [
    'PM2.5',
    'PM10',
    'CO2',
    'CO',
    'NotUsedjusttoavoid error'
  ];

  @override
  void initState() {
    super.initState();
    date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _goTocurrentlocation();
    getDataSourceForHeatmap(0);
  }

  Future<LatLng> getCurrentLocation() async {
    var position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    return LatLng(position.latitude, position.longitude);
  }

  Completer<GoogleMapController> _controller = Completer();
  final Set<Heatmap> _heatmaps = {};

  static final CameraPosition _kLake =
      CameraPosition(target: LatLng(37.43296265331129, -122.08832357078792));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: GoogleMap(
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              initialCameraPosition: _kLake,
              heatmaps: _heatmaps,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
ElevatedButton(
                onPressed: () {
                  currentparameterindex += 1;
                  if (currentparameterindex == 4) {
                    currentparameterindex=0;
                  }
                  setState(() {
                    alldatablistedbytime.clear();
                    _heatmaps.clear();
                    switch(currentparameterindex){
                      case 0: {
                        getDataSourceForHeatmap(currentparameterindex);
                      }
                      break;

                      case 1: {
                        getDataSourceForHeatmap(currentparameterindex);
                      }
                      break;

                      case 2: {
                        getDataSourceForHeatmap(currentparameterindex);
                      }
                      break;

                      case 3: {
                        getDataSourceForHeatmap(currentparameterindex);
                      }
                      break;

                      default: {

                      }
                      break;
                    }
                  });
                },
                child: Text(Parameters[currentparameterindex]),
              ),
              ElevatedButton(
                onPressed: () async {
                  DateTime? newDate = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100));
                  if (newDate == null) {
                    return;
                  }

                  setState(() {
                    alldatablistedbytime.clear();
                    _heatmaps.clear();
                    date = newDate;
                    getDataSourceForHeatmap(currentparameterindex);
                  });
                },
                child: Text('Select Date'),
              ),const SizedBox(
                height: 22.0,
                width: 22.0,
              ),
              ElevatedButton(
                  onPressed: (){                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Pollutants Scale"),
                        content: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("PM2.5(ug/m3)",style: TextStyle(fontSize: 15),),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("0 to 12",style: TextStyle(color: Colors.green),),
                                Text("Good",style: TextStyle(color: Colors.green)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("12 to 75",style: TextStyle(color: Colors.yellow)),
                                Text("Moderate",style: TextStyle(color: Colors.yellow)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("76 to 150",style: TextStyle(color: Colors.deepOrange)),
                                Text("Unhealthy for some",style: TextStyle(color: Colors.deepOrange)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("151-250",style: TextStyle(color: Colors.red)),
                                Text("Unhealthy",style: TextStyle(color: Colors.red)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("251-350",style: TextStyle(color: Colors.purple)),
                                Text("Very Unhealthy",style: TextStyle(color: Colors.purple)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("350+",style: TextStyle(color: Colors.brown)),
                                Text("Hazardous",style: TextStyle(color: Colors.brown))
                              ],),SizedBox(height: 22,),



                            Text("PM10(ug/m3)",style: TextStyle(fontSize: 15),),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("0 to 54",style: TextStyle(color: Colors.green),),
                                Text("Good",style: TextStyle(color: Colors.green)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("55 to 154",style: TextStyle(color: Colors.yellow)),
                                Text("Moderate",style: TextStyle(color: Colors.yellow)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("155 to 254",style: TextStyle(color: Colors.deepOrange)),
                                Text("Unhealthy for some",style: TextStyle(color: Colors.deepOrange)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("255-354",style: TextStyle(color: Colors.red)),
                                Text("Unhealthy",style: TextStyle(color: Colors.red)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("355-504",style: TextStyle(color: Colors.purple)),
                                Text("Very Unhealthy",style: TextStyle(color: Colors.purple)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("504+",style: TextStyle(color: Colors.brown)),
                                Text("Hazardous",style: TextStyle(color: Colors.brown))
                              ],),SizedBox(height: 22,),



                            Text("CO2(ppm)",style: TextStyle(fontSize: 15),),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("0 to 400",style: TextStyle(color: Colors.green),),
                                Text("Good",style: TextStyle(color: Colors.green)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("401 to 1000",style: TextStyle(color: Colors.yellow)),
                                Text("Moderate",style: TextStyle(color: Colors.yellow)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("1001 to 2000",style: TextStyle(color: Colors.deepOrange)),
                                Text("Unhealthy for some",style: TextStyle(color: Colors.deepOrange)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("2001-5000",style: TextStyle(color: Colors.red)),
                                Text("Unhealthy",style: TextStyle(color: Colors.red)),
                              ],),SizedBox(height: 22,),



                            Text("CO(ppm)",style: TextStyle(fontSize: 15),),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("0 to 4.4",style: TextStyle(color: Colors.green),),
                                Text("Good",style: TextStyle(color: Colors.green)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("4.5 to 9.4",style: TextStyle(color: Colors.yellow)),
                                Text("Moderate",style: TextStyle(color: Colors.yellow)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("9.5 to 12.4",style: TextStyle(color: Colors.deepOrange)),
                                Text("Unhealthy for some",style: TextStyle(color: Colors.deepOrange)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("12.5-15.4",style: TextStyle(color: Colors.red)),
                                Text("Unhealthy",style: TextStyle(color: Colors.red)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("15.5-30.4",style: TextStyle(color: Colors.purple)),
                                Text("Very Unhealthy",style: TextStyle(color: Colors.purple)),
                              ],),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("30.5+",style: TextStyle(color: Colors.brown)),
                                Text("Hazardous",style: TextStyle(color: Colors.brown))
                              ],),SizedBox(height: 22,),
                          ],
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("OK"))
                        ],
                      ));}, child: Text("Info")),
            ],
          ),
        ],
      ),
    );
  }

  void _addHeatmap(color1, color2, location) {
    setState(() {
      _heatmaps.add(Heatmap(
          heatmapId: HeatmapId(location.toString()),
          points: _createPoints(location),
          radius: 30,
          visible: true,
          opacity: 0.5,
          gradient: HeatmapGradient(
              colors: <Color>[color1, color2],
              startPoints: <double>[0.2, 0.8])));
    });
  }

  //heatmap generation helper functions
  List<WeightedLatLng> _createPoints(LatLng location) {
    final List<WeightedLatLng> points = <WeightedLatLng>[];
    //Can create multiple points here
    points.add(_createWeightedLatLng(location.latitude, location.longitude, 1));
    points.add(
        _createWeightedLatLng(location.latitude - 1, location.longitude, 1));
    return points;
  }

  WeightedLatLng _createWeightedLatLng(double lat, double lng, int weight) {
    return WeightedLatLng(point: LatLng(lat, lng), intensity: weight);
  }

  Future<void> _goTocurrentlocation() async {
    final GoogleMapController controller = await _controller.future;
    var position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 19));
  }

  void getDataSourceForHeatmap(thecurrentindex) async {
    var uid = await widget.uid.toString();
    final ref = FirebaseDatabase.instance.refFromURL(
        'https://airpollution-8fa78-default-rtdb.asia-southeast1.firebasedatabase.app');

      final snapshot = await ref
          .child(uid)
          .child(date.year.toString())
          .child(date.month.toString())
          .child(date.day.toString())
          .orderByKey()
          .get();

      if (snapshot.exists) {
      print("data found");
      //print(snapshot.value);
      String all_data =
      snapshot.value.toString().replaceAll(RegExp("{| |}"), "");
      //print(all_data);
      alldatablistedbytime = all_data.split(',');
      alldatablistedbytime.sort();
      //bool firstround=true;
      //int x1=0;
      int snapshotdatalength = snapshot.children.length;
      //print("snapshot length is $snapshotdatalength");
      //List<List<LatLng>> polylineCoordinatess = new List.generate(snapshotdatalength-1, (i) => []);
      for (var x in alldatablistedbytime) {
      //print(x);
      List<String>? splitted_once = x.split(':');
      timestamp = splitted_once[0];
      latitude = splitted_once[1];
      longtitude = splitted_once[2];
      co = splitted_once[3];
      co2 = splitted_once[4];
      temp = splitted_once[5];
      humidity = splitted_once[6];
      pressure = splitted_once[7];
      pm25 = splitted_once[8];
      pm10 = splitted_once[9];
      datetime = await DateTime.fromMillisecondsSinceEpoch(double.parse(timestamp).toInt() * 1000);
      LatLng _heatmapLocationIteration = LatLng(double.parse(latitude), double.parse(longtitude));

      switch(thecurrentindex) {
      case 0: {
      //plot pm2.5
      var pm25_double = double.parse(pm25);

      if(pm25_double<12.0){
      _addHeatmap(Colors.green, Colors.green, _heatmapLocationIteration);
      }
      else if(12.1<=pm25_double && pm25_double<=75.4){
      _addHeatmap(Colors.yellow, Colors.yellow, _heatmapLocationIteration);
      }
      else if(75.5<=pm25_double && pm25_double<=150.4){
      _addHeatmap(Colors.deepOrange, Colors.deepOrange, _heatmapLocationIteration);
      }
      else if(150.5<=pm25_double && pm25_double<=250.4){
      _addHeatmap(Colors.red, Colors.red, _heatmapLocationIteration);
      }
      else if(250.5<=pm25_double && pm25_double<=350.4){
      _addHeatmap(Colors.purple, Colors.purple, _heatmapLocationIteration);
      }
      else if(350.5<=pm25_double && pm25_double<=500.4){
      _addHeatmap(Colors.brown, Colors.brown, _heatmapLocationIteration);
      }
      }
      break;

      case 1: {
      //plot pm10
      var pm10_double = double.parse(pm10);

      if(pm10_double<54){
      _addHeatmap(Colors.green, Colors.green, _heatmapLocationIteration);
      }
      else if(55<=pm10_double && pm10_double<=154){
      _addHeatmap(Colors.yellow, Colors.yellow, _heatmapLocationIteration);
      }
      else if(155<=pm10_double && pm10_double<=254){
      _addHeatmap(Colors.orange, Colors.orange, _heatmapLocationIteration);
      }
      else if(255<=pm10_double && pm10_double<=354){
      _addHeatmap(Colors.red, Colors.red, _heatmapLocationIteration);
      }
      else if(355<=pm10_double && pm10_double<=424){
      _addHeatmap(Colors.purple, Colors.purple, _heatmapLocationIteration);
      }
      else if(425<=pm10_double && pm10_double<=504){
      _addHeatmap(Colors.brown, Colors.brown, _heatmapLocationIteration);
      }
      else if(505<=pm10_double && pm10_double<=604){
      _addHeatmap(Colors.brown, Colors.brown, _heatmapLocationIteration);
      }
      }
      break;

      case 2: {
      //plot co2
      //_addHeatmap(Colors.yellow, Colors.yellow, _heatmapLocationIteration);
        var co2_double = double.parse(co2);

        if (co2_double < 400) {
          _addHeatmap(Colors.green, Colors.green, _heatmapLocationIteration);
        } else if (400 <= co2_double && co2_double < 1000) {
          _addHeatmap(Colors.yellow, Colors.yellow, _heatmapLocationIteration);
        } else if (1000 <= co2_double && co2_double < 2000) {
          _addHeatmap(Colors.orange, Colors.orange, _heatmapLocationIteration);
        } else if (2000 <= co2_double && co2_double < 5000) {
          _addHeatmap(Colors.red, Colors.red, _heatmapLocationIteration);
        }
      }
      break;

      case 3: {
      //plot co
      var co_double = double.parse(co);

      if(co_double<4.4){
      _addHeatmap(Colors.green, Colors.green, _heatmapLocationIteration);
      }
      else if(4.5<=co_double && co_double<=9.4){
      _addHeatmap(Colors.yellow, Colors.yellow, _heatmapLocationIteration);
      }
      else if(9.5<=co_double && co_double<=12.4){
      _addHeatmap(Colors.orange, Colors.orange, _heatmapLocationIteration);
      }
      else if(12.5<=co_double && co_double<=15.4){
      _addHeatmap(Colors.red, Colors.red, _heatmapLocationIteration);
      }
      else if(15.5<=co_double && co_double<=30.4){
      _addHeatmap(Colors.purple, Colors.purple, _heatmapLocationIteration);
      print("COISHI${co_double}");
      }
      else if(30.5<=co_double && co_double<=40.4){
      _addHeatmap(Colors.brown, Colors.brown, _heatmapLocationIteration);
      }
      else if(40.5<=co_double){
      _addHeatmap(Colors.brown, Colors.brown, _heatmapLocationIteration);
      }
      break;
      }
      default: {
      //statements;
      }
      break;
      }
      }
      } else {
      print('No data available.');
      }



  }
}
