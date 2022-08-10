import 'dart:convert';


import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';

class Track extends StatefulWidget {
  final String? uid;
  //final List<String> timestamp;
  //final List<int> co2value;
  const Track({
    Key? key,
    required this.uid,
    /*required this.timestamp,required this.co2value*/
  }) : super(key: key);

  @override
  _TrackState createState() => _TrackState();
}

class _TrackState extends State<Track> {
  DateTime date = DateTime(2022, 1, 1);
  late GoogleMapController mapController;
  var colour = Colors.red;
  double _originLatitude = 5.3021841, _originLongitude = 103.1009257;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  String googleAPiKey = "AIzaSyApxUlMujqzuRexHCBYjlYTq4QrU6qw1TE";
  var currentparameterindex = 0;
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
  var previous_timestamp,
      previous_latitude,
      previous_longtitude,
      previous_co,
      previous_co2,
      previous_temp,
      previous_humidity,
      previous_pressure,
      previous_pm25,
      previous_pm10,
      previous_datetime;

  List<String> Parameters = [
    'PM2.5',
    'PM10',
    'CO2',
    'CO',
    'NotUsedjusttoavoid error'
  ];

  String selectedValue = '1656052596';
  late List<String> alldatablistedbytime = ['Track1'];
  //String dropdownvalue = 'Item 1';

  List<DropdownMenuItem<String>> menuItems = [];

  // List of items in our dropdown menu
  List<DropdownMenuItem<String>> get dropdownItems {
    return menuItems;
  }

  @override
  void initState() {
    //super.initState();
    date =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    FindAllTrack();
  }

  void getDataFromFIrebase() async {
    var selectedtrackvalue = selectedValue;
    var selectedtrackvaluenumber = selectedtrackvalue.replaceAll('Track', '');
    print('selectedtrackvaluenumber');
    print(selectedtrackvaluenumber);

    var uid = await widget.uid.toString();
    final ref = FirebaseDatabase.instance.refFromURL(
        'https://airpollution-8fa78-default-rtdb.asia-southeast1.firebasedatabase.app');

    //-------------------------------------------------------------------------
    //check if next track exist in database
    final tracksnapshot = await ref
        .child('track')
        .child(uid)
        .child(date.year.toString())
        .child(date.month.toString())
        .child(date.day.toString())
        .child((int.parse(selectedtrackvaluenumber) + 1).toString())
        .get();
    final tracksnapshot1 = await ref
        .child('track')
        .child(uid)
        .child(date.year.toString())
        .child(date.month.toString())
        .child(date.day.toString())
        .child((int.parse(selectedtrackvaluenumber) + 2).toString())
        .get();
    if (tracksnapshot.exists) {
      print(tracksnapshot.value.toString());
    }
    if (tracksnapshot1.exists) {
      //-if exist
      print(tracksnapshot1.value.toString());
      final snapshot = await ref
          .child(uid)
          .child(date.year.toString())
          .child(date.month.toString())
          .child(date.day.toString())
          .orderByKey()
          .startAfter(tracksnapshot.value.toString())
          .endBefore(tracksnapshot1.value.toString())
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
        }

        polylines.clear();
        bool firstround = true;
        int x1 = 0;
        int snapshotdatalength = snapshot.children.length;
        print("snapshot length is $snapshotdatalength");
        List<List<LatLng>> polylineCoordinatess =
            new List.generate(snapshotdatalength - 1, (i) => []);
        for (var x in alldatablistedbytime) {
          if (firstround == false) {
            previous_timestamp = timestamp;
            previous_latitude = latitude;
            previous_longtitude = longtitude;
            previous_co = co;
            previous_co2 = co2;
            previous_temp = temp;
            previous_humidity = humidity;
            previous_pressure = previous_pressure;
            previous_pm25 = pm25;
            previous_pm10 = pm10;
            previous_datetime = datetime;
          }
          print(x);
          List<String>? splitted_once = x.split(':');
          print("the value is");
          print(splitted_once[0]);
          print(splitted_once[1]);
          print(splitted_once[2]);
          print(splitted_once[3]);
          print(splitted_once[4]);
          print(splitted_once[5]);
          print(splitted_once[6]);
          print(splitted_once[7]);
          print(splitted_once[8]);
          print(splitted_once[9]);
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
          datetime = await DateTime.fromMillisecondsSinceEpoch(
              double.parse(timestamp).toInt() * 1000);
          if (firstround == false) {
            //polylineCoordinatess[x1].clear();
            polylineCoordinatess[x1].add(LatLng(double.parse(previous_latitude),
                double.parse(previous_longtitude)));
            polylineCoordinatess[x1]
                .add(LatLng(double.parse(latitude), double.parse(longtitude)));
            if (currentparameterindex == 0) {
              var pm25_double = double.parse(pm25);

              if (pm25_double < 12.0) {
                colour = Colors.green;
              } else if (12.1 <= pm25_double && pm25_double <= 75.4) {
                colour = Colors.yellow;
              } else if (75.5 <= pm25_double && pm25_double <= 150.4) {
                colour = Colors.deepOrange;
              } else if (150.5 <= pm25_double && pm25_double <= 250.4) {
                colour = Colors.red;
              } else if (250.5 <= pm25_double && pm25_double <= 350.4) {
                colour = Colors.purple;
              } else if (350.5 <= pm25_double && pm25_double <= 500.4) {
                colour = Colors.brown;
              }
              print(polylineCoordinatess[x1]);
              if (int.parse(timestamp) - int.parse(previous_timestamp) < 20) {
                _addPolyLine(
                    colour, polylineCoordinatess[x1] as List, "$timestamp");
              }
              print("polylineadded $x1 times");
              print(pm25_double);
              x1++;
            } else if (currentparameterindex == 1) {
              var pm10_double = double.parse(pm10);

              if (pm10_double < 54) {
                colour = Colors.green;
              } else if (55 <= pm10_double && pm10_double <= 154) {
                colour = Colors.yellow;
              } else if (155 <= pm10_double && pm10_double <= 254) {
                colour = Colors.deepOrange;
              } else if (255 <= pm10_double && pm10_double <= 354) {
                colour = Colors.red;
              } else if (355 <= pm10_double && pm10_double <= 424) {
                colour = Colors.purple;
              } else if (425 <= pm10_double && pm10_double <= 504) {
                colour = Colors.brown;
              } else if (505 <= pm10_double && pm10_double <= 604) {
                colour = Colors.brown;
              }

              print(polylineCoordinatess[x1]);
              if (int.parse(timestamp) - int.parse(previous_timestamp) < 20) {
                _addPolyLine(
                    colour, polylineCoordinatess[x1] as List, "$timestamp");
              }
              print("polylineadded $x1 times");
              print(pm10_double);
              x1++;
            } else if (currentparameterindex == 2) {
              var co2_double = double.parse(co2);

              if (co2_double < 400) {
                colour = Colors.green;
              } else if (400 <= co2_double && co2_double < 1000) {
                colour = Colors.yellow;
              } else if (1000 <= co2_double && co2_double < 2000) {
                colour = Colors.orange;
              } else if (2000 <= co2_double && co2_double < 5000) {
                colour = Colors.red;
              }

              print(polylineCoordinatess[x1]);
              if (int.parse(timestamp) - int.parse(previous_timestamp) < 20) {
                _addPolyLine(
                    colour, polylineCoordinatess[x1] as List, "$timestamp");
              }
              print("polylineadded $x1 times");
              print(co2_double);
              x1++;
            } else if (currentparameterindex == 3) {
              var co_double = double.parse(co);

              if (co_double < 4.4) {
                colour = Colors.green;
              } else if (4.5 <= co_double && co_double <= 9.4) {
                colour = Colors.yellow;
              } else if (9.5 <= co_double && co_double <= 12.4) {
                colour = Colors.orange;
              } else if (12.5 <= co_double && co_double <= 15.4) {
                colour = Colors.red;
              } else if (15.5 <= co_double && co_double <= 30.4) {
                colour = Colors.purple;
              } else if (30.5 <= co_double && co_double <= 40.4) {
                colour = Colors.brown;
              } else if (40.5 <= co_double) {
                colour = Colors.brown;
              }

              print(polylineCoordinatess[x1]);
              if (int.parse(timestamp) - int.parse(previous_timestamp) < 20) {
                _addPolyLine(
                    colour, polylineCoordinatess[x1] as List, "$timestamp");
              }
              print("polylineadded $x1 times");
              print(co_double);
              x1++;
            }
          }
          firstround = false;
        }
      } else {
        print('No data available.');
      }
    }

    //------------------------------------------------------------------------------------------------------------------------------------------
    else {
      //if not exist
      print("Nodata");
      final snapshot = await ref
          .child(uid)
          .child(date.year.toString())
          .child(date.month.toString())
          .child(date.day.toString())
          .orderByKey()
          .startAfter(tracksnapshot.value.toString())
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
        }

        polylines.clear();
        bool firstround = true;
        int x1 = 0;
        int snapshotdatalength = snapshot.children.length;
        print("snapshot length is $snapshotdatalength");
        List<List<LatLng>> polylineCoordinatess =
            new List.generate(snapshotdatalength - 1, (i) => []);
        for (var x in alldatablistedbytime) {
          if (firstround == false) {
            previous_timestamp = timestamp;
            previous_latitude = latitude;
            previous_longtitude = longtitude;
            previous_co = co;
            previous_co2 = co2;
            previous_temp = temp;
            previous_humidity = humidity;
            previous_pressure = previous_pressure;
            previous_pm25 = pm25;
            previous_pm10 = pm10;
            previous_datetime = datetime;
          }
          print(x);
          List<String>? splitted_once = x.split(':');
          print("the value is");
          print(splitted_once[0]);
          print(splitted_once[1]);
          print(splitted_once[2]);
          print(splitted_once[3]);
          print(splitted_once[4]);
          print(splitted_once[5]);
          print(splitted_once[6]);
          print(splitted_once[7]);
          print(splitted_once[8]);
          print(splitted_once[9]);
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
          datetime = await DateTime.fromMillisecondsSinceEpoch(
              double.parse(timestamp).toInt() * 1000);
          if (firstround == false) {
            //polylineCoordinatess[x1].clear();
            polylineCoordinatess[x1].add(LatLng(double.parse(previous_latitude),
                double.parse(previous_longtitude)));
            polylineCoordinatess[x1]
                .add(LatLng(double.parse(latitude), double.parse(longtitude)));
            if (currentparameterindex == 0) {
              var pm25_double = double.parse(pm25);

              if (pm25_double < 12.0) {
                colour = Colors.green;
              } else if (12.1 <= pm25_double && pm25_double <= 75.4) {
                colour = Colors.yellow;
              } else if (75.5 <= pm25_double && pm25_double <= 150.4) {
                colour = Colors.deepOrange;
              } else if (150.5 <= pm25_double && pm25_double <= 250.4) {
                colour = Colors.red;
              } else if (250.5 <= pm25_double && pm25_double <= 350.4) {
                colour = Colors.purple;
              } else if (350.5 <= pm25_double && pm25_double <= 500.4) {
                colour = Colors.brown;
              }
              print(polylineCoordinatess[x1]);
              if (int.parse(timestamp) - int.parse(previous_timestamp) < 20) {
                _addPolyLine(
                    colour, polylineCoordinatess[x1] as List, "$timestamp");
              }
              print("polylineadded $x1 times");
              print(pm25_double);
              x1++;
            } else if (currentparameterindex == 1) {
              var pm10_double = double.parse(pm10);

              if (pm10_double < 54) {
                colour = Colors.green;
              } else if (55 <= pm10_double && pm10_double <= 154) {
                colour = Colors.yellow;
              } else if (155 <= pm10_double && pm10_double <= 254) {
                colour = Colors.deepOrange;
              } else if (255 <= pm10_double && pm10_double <= 354) {
                colour = Colors.red;
              } else if (355 <= pm10_double && pm10_double <= 424) {
                colour = Colors.purple;
              } else if (425 <= pm10_double && pm10_double <= 504) {
                colour = Colors.brown;
              } else if (505 <= pm10_double && pm10_double <= 604) {
                colour = Colors.brown;
              }

              print(polylineCoordinatess[x1]);
              if (int.parse(timestamp) - int.parse(previous_timestamp) < 20) {
                _addPolyLine(
                    colour, polylineCoordinatess[x1] as List, "$timestamp");
              }
              print("polylineadded $x1 times");
              print(pm10_double);
              x1++;
            } else if (currentparameterindex == 2) {
              var co2_double = double.parse(co2);

              if (co2_double < 400) {
                colour = Colors.green;
              } else if (400 <= co2_double && co2_double < 1000) {
                colour = Colors.yellow;
              } else if (1000 <= co2_double && co2_double < 2000) {
                colour = Colors.orange;
              } else if (2000 <= co2_double && co2_double < 5000) {
                colour = Colors.red;
              }

              print(polylineCoordinatess[x1]);
              if (int.parse(timestamp) - int.parse(previous_timestamp) < 20) {
                _addPolyLine(
                    colour, polylineCoordinatess[x1] as List, "$timestamp");
              }
              print("polylineadded $x1 times");
              print(co2_double);
              x1++;
            } else if (currentparameterindex == 3) {
              var co_double = double.parse(co);

              if (co_double < 4.4) {
                colour = Colors.green;
              } else if (4.5 <= co_double && co_double <= 9.4) {
                colour = Colors.yellow;
              } else if (9.5 <= co_double && co_double <= 12.4) {
                colour = Colors.orange;
              } else if (12.5 <= co_double && co_double <= 15.4) {
                colour = Colors.red;
              } else if (15.5 <= co_double && co_double <= 30.4) {
                colour = Colors.purple;
              } else if (30.5 <= co_double && co_double <= 40.4) {
                colour = Colors.brown;
              } else if (40.5 <= co_double) {
                colour = Colors.brown;
              }

              print(polylineCoordinatess[x1]);
              if (int.parse(timestamp) - int.parse(previous_timestamp) < 20) {
                _addPolyLine(
                    colour, polylineCoordinatess[x1] as List, "$timestamp");
              }
              print("polylineadded $x1 times");
              print(co_double);
              x1++;
            }
          }
          firstround = false;
        }
      } else {
        print('No data available.');
      }
    }
    //------------------------------------------------------------------------
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void FindAllTrack() async {
    var uidtotrack = await widget.uid.toString();
    final ref = FirebaseDatabase.instance.refFromURL(
        'https://airpollution-8fa78-default-rtdb.asia-southeast1.firebasedatabase.app');
    final snapshot = await ref
        .child('track')
        .child(uidtotrack)
        .child(date.year.toString())
        .child(date.month.toString())
        .child(date.day.toString())
        .orderByKey()
        .get();

    if (snapshot.exists) {
      int i = 1;
      alldatablistedbytime.clear();
      snapshot.children.forEach((element) {
        print(element.key.toString());
        print(element.value.toString());
        String track_number = element.key.toString();
        int trackid = int.parse(track_number) - 1;
        String track_timestamp = element.key.toString();
        menuItems.add(DropdownMenuItem(
            child: Text('Track' '$trackid'), value: 'Track' '$trackid'));
        if (i == 1) {
          selectedValue = 'Track' '$trackid';
          i++;
        }
      });
    } else {
      print('nothing to track');
    }
  }

  _addPolyLine(colours, coordinate, the_id) {
    //var colours;
    PolylineId id = PolylineId("$the_id");
    Polyline polyline =
        Polyline(polylineId: id, color: colours, points: coordinate);
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropdownButton(
                  value: selectedValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue!;
                    });
                  },
                  items: dropdownItems),
              Text('${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(
                    fontSize: 20,
                  )),
            ],
          ),
          const SizedBox(
            height: 22.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentparameterindex += 1;
                    if (currentparameterindex == 4) {
                      currentparameterindex = 0;
                    }
                  });
                },
                child: Text(Parameters[currentparameterindex]),
              ),
              const SizedBox(
                height: 22.0,
                width: 22.0,
              ),
              ElevatedButton(
                  onPressed: getDataFromFIrebase, child: Text("Plot Route")),
              const SizedBox(
                height: 22.0,
                width: 22.00,
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
                    date = newDate;
                    menuItems.clear();
                    alldatablistedbytime.clear();
                    FindAllTrack();
                  });
                },
                child: Text('Select date'),
              ),
              const SizedBox(
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
          const SizedBox(
            height: 22.0,
          ),
          Container(
            height: 500,
            color: Colors.white,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(_originLatitude, _originLongitude), zoom: 1),
              myLocationEnabled: true,
              tiltGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              onMapCreated: _onMapCreated,
              markers: Set<Marker>.of(markers.values),
              polylines: Set<Polyline>.of(polylines.values),
            ),
          )
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _goTocurrentlocation(controller);
  }

  Future<void> _goTocurrentlocation(x) async {
    var position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    x.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 19));
  }
}
