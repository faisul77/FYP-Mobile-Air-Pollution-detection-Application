import 'dart:async';
import 'package:air_pollution_quality_monitor/heatmap.dart';
import 'package:air_pollution_quality_monitor/track.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'graph.dart';
import 'home.dart';
import 'vibrate.dart';
final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
String? email = user?.email;

class ProfileScreen extends StatefulWidget {
  final Stream<List<int>>? streamall;
  final String? uid;
  final device;

  const ProfileScreen({
    Key? key,
    required this.streamall,required this.uid, required this.device,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  int counter =1;
  int co_val=0,co2_val=0,pm25_val=0,pm10_val=0,temp_val=0,humidity_val=0,pressure_val=0;
  String data="";
  final database = FirebaseDatabase.instance.refFromURL('https://airpollution-8fa78-default-rtdb.asia-southeast1.firebasedatabase.app');
  var currentIndex = 0;
  bool isReady = true;

  @override
  void initState() {
    super.initState();
    UpdateTrackcount();
    Timer(Duration(seconds: 3), () {
    });
    Timer.periodic(const Duration(seconds: 15), update);
    //EnableBackgroundService();
  }

  void update(Timer timer) async {
    if(data!=""){
      var currentDatetotrack = DateTime.now().millisecondsSinceEpoch;
      var currentDateinSecondsSinceEpochtotrack = currentDatetotrack/1000;
      int currentDateinSecondsSinceEpochinteger = currentDateinSecondsSinceEpochtotrack.toInt();
      getCurrentLocationAndUploadData(currentDateinSecondsSinceEpochinteger, data);
    }

  }

  @override
  void dispose(){
    super.dispose();
  }

  void UpdateTrackcount() async {
    //-----------------------------------------------------------------------------------------------
    //get track count
    var uidtotrack = await widget.uid.toString();
    final ref = FirebaseDatabase.instance.refFromURL(
        'https://airpollution-8fa78-default-rtdb.asia-southeast1.firebasedatabase.app');
    final snapshot = await ref
        .child('track')
        .child(uidtotrack)
        .child(DateTime.now().year.toString())
        .child(DateTime.now().month.toString())
        .child(DateTime.now().day.toString())
        .orderByKey()
        .limitToLast(1).get();

    //get currentimestamp
    var currentDatetotrack = DateTime.now().millisecondsSinceEpoch;
    var currentDateinSecondsSinceEpochtotrack = currentDatetotrack/1000;
    int currentDateinSecondsSinceEpochinteger = currentDateinSecondsSinceEpochtotrack.toInt();
    //-----------------------------------------------------------------------------------------------


    if(snapshot.exists){
      print("snapshot is");
      print(snapshot.value.toString());
      print(snapshot.key.toString());

      //---------------------------------------------------------------------------------------------
      String last_track_value = snapshot.value.toString().replaceAll(RegExp("{| |}"), "");
      print("lasttrack");
      print(last_track_value);
      var last_track = last_track_value.split(':');
      var last_track_number =last_track[0];
      var new_track_number = int.parse(last_track_number)+1;
      print('new tracknumber');
      print(new_track_number);
      //put new tracknumber
      database.child('track').child(widget.uid.toString()).child(DateTime.now().year.toString()).child(DateTime.now().month.toString()).child(DateTime.now().day.toString()).update({'$new_track_number': '$currentDateinSecondsSinceEpochinteger'});
    }
    else
      {
      //put track1
      database.child('track').child(widget.uid.toString()).child(DateTime.now().year.toString()).child(DateTime.now().month.toString()).child(DateTime.now().day.toString()).update({'2': '$currentDateinSecondsSinceEpochinteger'});
      }
    //-----------------------------------------------------------------------------------------------


  }


  Future<void> getCurrentLocationAndUploadData(int currentDateinSecondsSinceEpochinteger, String data_to_be_uploaded) async {
    var position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    print(position.latitude);
    print(position.longitude);
    String x_coordinate=position.latitude.toString();
    String y_coordinate=position.longitude.toString();
    String location_coordinate='$x_coordinate'':''$y_coordinate';
    String datapluslocation = '$location_coordinate'':''$data_to_be_uploaded';
    database.child(widget.uid.toString()).child(DateTime.now().year.toString()).child(DateTime.now().month.toString()).child(DateTime.now().day.toString()).update({'$currentDateinSecondsSinceEpochinteger': '$datapluslocation'});
  }

  @override
  ////currentIndex = 0;
  //}
  Widget build(BuildContext context) {

    //final databasereference = database.child(widget.uid.toString()).child(DateTime.now().year.toString()).child(DateTime.now().month.toString()).child(DateTime.now().day.toString());

    double displayWidth = MediaQuery.of(context).size.width;
    double displayheight = MediaQuery.of(context).size.height;
    double statusbarHeight = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: <Widget>[
          Container(
            height: statusbarHeight * 1.5,
          ),
          Container(
            width: displayWidth,
            height: displayheight * .875 - statusbarHeight * 1.5,
            margin: EdgeInsets.only(
                left: displayWidth * .025, right: displayWidth * .025),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25)),
            child: Center(
              child: StreamBuilder(
                stream: widget.streamall,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  } else {
                    print(snapshot.data.toString());
                    String removed_square_bracket = snapshot.data
                        .toString()
                        .replaceAll('[', '')
                        .replaceAll(']', '');
                    print(removed_square_bracket);
                    List<String>? stringList =
                        removed_square_bracket.split(",");
                    String decoded_ascii = "";
                    for (var ascii_code in stringList) {
                      var myInt = int.tryParse(ascii_code) ?? 0;
                      assert(myInt is int);
                      decoded_ascii += String.fromCharCode(myInt);
                    }
                    var currentDate = DateTime.now().millisecondsSinceEpoch;
                    var currentDateinSecondsSinceEpoch = currentDate/1000;
                    int currentDateinSecondsSinceEpochinteger = currentDateinSecondsSinceEpoch.toInt();
                    //--------------------------------
                    List<String>? splitted_once_decoded =
                        decoded_ascii.split(",");
                    String? coco2temp="0", humiditypressurepm25pm10="0";
                    String? co="0", co2temp="0", humidity="0", pressurepm25pm10="0";
                    String? co2="0",temp="0",pressure="0",pm25pm10="0";
                    String? pm25="0",pm10="0";
                    int i = 0;
                    for (var splitted_once in splitted_once_decoded) {
                      if (i == 0) {
                        coco2temp = splitted_once;
                        i++;
                      } else {
                        humiditypressurepm25pm10 = splitted_once;
                      }
                    }
                    List<String>? splitted_twice_1 = coco2temp?.split("a");
                    List<String>? splitted_twice_2 =
                        humiditypressurepm25pm10?.split("a");

                    if (splitted_twice_1 != null && splitted_twice_2 != null) {
                      int j1 = 0;
                      for (var x in splitted_twice_1) {
                        if (j1 == 0) {
                          co2 = x;
                          j1++;
                        } else {
                          co2temp = x;
                        }
                      }
                      int j2 = 0;
                      for (var x in splitted_twice_2) {
                        if (j2 == 0) {
                          humidity = x;
                          j2++;
                        } else {
                          pressurepm25pm10 = x;
                        }
                      }
                      List<String>? splitted_thrice1 = co2temp?.split("b");
                      List<String>? splitted_thrice2 = pressurepm25pm10?.split("b");


                      if (splitted_thrice1 != null && splitted_thrice2 != null) {
                        int j1 = 0;
                        for (var x in splitted_thrice1) {
                          if (j1 == 0) {
                            co=x;
                            j1++;
                          } else {
                            temp = x;
                          }
                        }
                        int j2 = 0;
                        for (var x in splitted_thrice2) {
                          if (j2 == 0) {
                            pressure=x;
                            j2++;
                          } else {
                            pm25pm10 = x;
                            List<String>? splitted_last = pm25pm10?.split("c");
                            if(splitted_last!=null){
                              int last=0;
                              for(var x in splitted_last){
                                if(last==0){
                                  pm25=x;
                                  last++;
                                }
                                else{
                                  pm10=x;
                                }
                              }
                            }
                          }
                        }
                      }
                    }

                    print(co);
                    print(co2);
                    print(temp);
                    print(humidity);
                    print(pressure);
                    print(pm25);
                    print(pm10);
                    print(widget.uid);
                    print("XX");
                    print('xxx');
                    widget.device.requestMtu(512);

                    if(decoded_ascii.contains('a')){
                      int co_value=int.parse(co!);
                      int co2_value=int.parse(co2!);
                      int temp_value=int.parse(temp!);
                      int humidity_value=int.parse(humidity!);
                      int pressure_value=int.parse(pressure!);
                      int pm25_value=int.parse(pm25!);
                      int pm10_value=int.parse(pm10!);

                      co_val=co_val+co_value;
                      co2_val=co2_val+co2_value;
                      temp_val=temp_val+temp_value;
                      humidity_val=humidity_val+humidity_value;
                      pressure_val=pressure_val+pressure_value;
                      pm25_val=pm25_val+pm25_value;
                      pm10_val=pm10_val+pm10_value;
                      counter++;

                      if(counter==4){
                        int co_val_avg_per_min = co_val~/3;
                        int co2_val_avg_per_min = co2_val~/3;
                        int temp_val_avg_per_min = temp_val~/3;
                        int humidity_val_avg_per_min = humidity_val~/3;
                        int pressure_val_avg_per_min = pressure_val~/3;
                        int pm25_val_avg_per_min = pm25_val~/3;
                        int pm10_val_avg_per_min = pm10_val~/3;
                        co_val=0; co2_val=0; temp_val=0; humidity_val=0; pressure_val=0; pm10_val=0; pm25_val=0;
                        if(co_val_avg_per_min>30 || co2_val_avg_per_min >2000 || pm10_val_avg_per_min > 255 || pm25_val_avg_per_min > 151){
                          print(co_value);
                          print(co2_value);
                          print(pm10_value);
                          print(pm25_value);
                          //Vibrate.vibrate();
                          print("VIBRATE");
                        }
                        String data_to_be_uploaded = '$co_val_avg_per_min'':''$co2_val_avg_per_min'':''$temp_val_avg_per_min'':''$humidity_val_avg_per_min'':''$pressure_val_avg_per_min'':''$pm25_val_avg_per_min'':''$pm10_val_avg_per_min';
                        data=data_to_be_uploaded;
                        counter=1;
                      }
                    }
                    return Center(
                      child: <Widget>[
                        Home(co2: co2,co:co,temp: temp,humidity: humidity,pressure: pressure,pm25: pm25,pm10: pm10,uid:widget.uid),
                        Graph( uid: widget.uid,),
                        Track(uid: widget.uid,),
                        HeatmapScreen(uid: widget.uid,),
                      ].elementAt(currentIndex),
                    );
                  }
                },
              ),
            ),
          ),
        ]),
        bottomNavigationBar: Container(
            margin: EdgeInsets.all(displayWidth * .025),
            height: displayWidth * .155,
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.1),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
                borderRadius: BorderRadius.circular(25)),
            child: ListView.builder(
                itemCount: 4,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
                itemBuilder: (context, index) => InkWell(
                      onTap: () {
                        setState(() {
                          currentIndex = index;
                          HapticFeedback.lightImpact();
                        });
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: Duration(seconds: 1),
                            curve: Curves.fastLinearToSlowEaseIn,
                            width: index == currentIndex
                                ? displayWidth * .32
                                : displayWidth * .18,
                            alignment: Alignment.center,
                            child: AnimatedContainer(
                              duration: Duration(seconds: 1),
                              curve: Curves.fastLinearToSlowEaseIn,
                              height: index == currentIndex
                                  ? displayWidth * .12
                                  : 0,
                              width: index == currentIndex
                                  ? displayWidth * .32
                                  : 0,
                              decoration: BoxDecoration(
                                  color: index == currentIndex
                                      ? Colors.lightBlueAccent.withOpacity(.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                          ),
                          AnimatedContainer(
                            duration: Duration(seconds: 1),
                            curve: Curves.fastLinearToSlowEaseIn,
                            width: index == currentIndex
                                ? displayWidth * .31
                                : displayWidth * .18,
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: Duration(seconds: 1),
                                      curve: Curves.fastLinearToSlowEaseIn,
                                      width: index == currentIndex
                                          ? displayWidth * .13
                                          : 0,
                                    ),
                                    AnimatedOpacity(
                                      opacity: index == currentIndex ? 1 : 0,
                                      duration: Duration(seconds: 1),
                                      curve: Curves.fastLinearToSlowEaseIn,
                                      child: Text(
                                        index == currentIndex
                                            ? '${listOfStrings[index]}'
                                            : '',
                                        style: TextStyle(
                                          color: Colors.lightBlueAccent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: Duration(seconds: 1),
                                      curve: Curves.fastLinearToSlowEaseIn,
                                      width: index == currentIndex
                                          ? displayWidth * .03
                                          : 20,
                                    ),
                                    Icon(
                                      listofIcons[index],
                                      size: displayWidth * .076,
                                      color: index == currentIndex
                                          ? Colors.lightBlueAccent
                                          : Colors.black26,
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ))));
  }

  List<String> listOfStrings = [
    'Home',
    'Graph',
    'Track',
    'HeatMap',
  ];

  List<IconData> listofIcons = [
    Icons.home_rounded,
    Icons.graphic_eq_sharp,
    Icons.person_pin_circle,
    Icons.track_changes_rounded,
  ];
}

