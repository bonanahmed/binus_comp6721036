import 'package:binus_mp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const MyApp());
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    // Penyebab Error
    // 'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign In',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleSignInAccount? _currentUser;

  void initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  void initState() {
    initFirebase();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
    super.initState();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-6.201529173726971, 106.78225469560772),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    if (_currentUser != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          elevation: 0.5,
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(_currentUser!.displayName ?? ''),
                accountEmail: Text(_currentUser!.email ?? ''),
                currentAccountPicture:
                    GoogleUserCircleAvatar(identity: _currentUser!),
              ),
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text('Logout'),
                onTap: () async {
                  await _googleSignIn.disconnect();
                },
              )
            ],
          ),
        ),
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            // _controller.complete(controller);
          },
        ),
      );
    } else {
      return Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 25),
                child: Image.asset("assets/binus.png", width: 200),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 25),
                child: const Text(
                  "Welcome to Binus Online Learning",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await _handleSignIn();
                },
                icon: Image.asset("assets/google.png", width: 20),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(300, 50),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
