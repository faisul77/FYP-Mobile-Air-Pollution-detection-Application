import 'package:air_pollution_quality_monitor/stream.dart';
import 'package:air_pollution_quality_monitor/storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_background/flutter_background.dart';
final SecureStorage secureStorage = SecureStorage();
String finalEmail = 'testuser@upm.edu.my', finalPassword = 'zaq12wsx!';   //testuser credential

    void main() async{
      Hive.initFlutter();
      WidgetsFlutterBinding.ensureInitialized();
      final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "flutter_background example app",
        notificationText: "Background notification for keeping the example app running in the background",
        notificationImportance: AndroidNotificationImportance.Default,
        notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
      );
      bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
      bool success2 = await FlutterBackground.enableBackgroundExecution();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //initialize firebase
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return LoginScreen();
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool alreadyconnected = false;
  bool devicefound = false;
  var device;
  Stream<List<int>>? streamall;
  bool isReadyall = false;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  final SecureStorage secureStorage = SecureStorage();

  static Future<User?> LoginUsingEmailPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        print("No user found for that email");
      }
    }
    return user;
  }

  @override
  void initState() {
    super.initState();

    flutterBlue.startScan(timeout: Duration(seconds: 8));
// Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) async {
      // do something with scan results
      for (ScanResult r in results) {
        if (r.advertisementData.localName == "MyFlow" && devicefound == false) {
          print("1");
          if (alreadyconnected == false) {
            await r.device.connect();
            //r.device.requestMtu(40);
            device = r.device;
            alreadyconnected = true;
            devicefound = true;
          }
          break;
        }
      }

      final mtu = await device.mtu.first;
      print('mtu is $mtu');
      await device.requestMtu(512);
      //await Hive.initFlutter();

      BluetoothCharacteristic important_characteristic;

      List<BluetoothService> services = await device.discoverServices();
      services.forEach((service) {
        if (service.uuid.toString() == "4fafc201-1fb5-459e-8fcc-c5c9c331914b") {
          service.characteristics.forEach((characteristic) {
            //------------------------------------------------------------------------------------------------------------------------------
            if (characteristic.uuid.toString() ==
                "beb5483e-36e1-4688-b7f5-ea07361b26a8") {
              important_characteristic = characteristic;
              Future.delayed(Duration(milliseconds: 2000), () {
                important_characteristic.setNotifyValue(true);
              });

              streamall = characteristic.value;
            }
          });
          //----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        }

      });

    });

// Stop scanning
    flutterBlue.stopScan();

    //-----------------------------------------------------------------
    Future.delayed(const Duration(milliseconds: 5000)).then((_) {
      if (finalEmail != '1') {
        LoginUsingEmailPassword(
            email: finalEmail, password: finalPassword, context: context);
        secureStorage.writeSecureData('email', finalEmail);
        secureStorage.writeSecureData('password', finalPassword);
          String? id=user?.uid.toString();
          String x=id.toString();
        Future.delayed(const Duration(milliseconds: 100)).then((_) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => ProfileScreen(streamall: streamall?.asBroadcastStream(),uid: user?.uid,device: device,)));
        });
      }
    });
  }

  Widget build(BuildContext context) {
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/upm_logo.png',
              height: 200,
              width: 200,
            ),
            const Text("Air Quality Monitor"),
            const SizedBox(
              height: 22.0,
            ),
            const Text(
              "Mobile Application prototype by UPM",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 44.0,
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  hintText: "User Email",
                  prefixIcon: Icon(
                    Icons.mail,
                    color: Colors.black,
                  )),
            ),
            const SizedBox(
              height: 26.0,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  hintText: "User Password",
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.black,
                  )),
            ),
            const SizedBox(
              height: 22.0,
            ),
            const Text(
              "Dont remember your password?",
              style: TextStyle(color: Colors.blue),
            ),
            const SizedBox(
              height: 12.0,
            ),
            const Text(
              "Dont have account yet? Register here",
              style: TextStyle(color: Colors.blue),
            ),
            const SizedBox(
              height: 88.0,
            ),
            Container(
              width: double.infinity,
              child: RawMaterialButton(
                fillColor: const Color(0xFF0069FE),
                elevation: 0.0,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                onPressed: () async {
                  User? user = await LoginUsingEmailPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                      context: context);
                  print(user?.uid);
                  if (user != null) {
                    secureStorage.writeSecureData(
                        'email', _emailController.text);
                    secureStorage.writeSecureData(
                        'password', _passwordController.text);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => ProfileScreen(streamall: streamall?.asBroadcastStream(),uid: user?.uid,device: device)));
                  }
                },
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
