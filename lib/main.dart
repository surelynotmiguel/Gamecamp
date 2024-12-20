import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gamecamp/view/screen/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:gamecamp/provider/CartProvider.dart';
import 'package:gamecamp/provider/UserProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA2gR5W1LKOVEq8Z5pdTTfsHIss3DTojGM",
      authDomain: "gamecamp-a1788.firebaseapp.com",
      databaseURL: "https://gamecamp-a1788-default-rtdb.firebaseio.com",
      projectId: "gamecamp-a1788",
      storageBucket: "gamecamp-a1788.firebasestorage.app",
      messagingSenderId: "282364525553",
      appId: "1:282364525553:web:63005d2ec02299f1416250",
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Gamecamp';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: _title,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return LoginScreen();
  }
}
