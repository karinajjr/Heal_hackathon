import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:temirdaftar/screens/new_card.dart';

import 'screens/main_screen.dart';
import 'package:temirdaftar/screens/new_communal.dart';

void main() {
  runApp(const MyApp());
}

Color secondColorLight = const Color.fromRGBO(255, 180, 180, 1);
Color textColorLigth = const Color.fromRGBO(15, 40, 81, 1);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (ctx, snap) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Temir Daftar',
            theme: ThemeData(
                primarySwatch: Colors.deepPurple, fontFamily: 'Montserrat'),
            home:  const MainScreen(),
            routes: {
              NewCommunal.routeName: (context) => const NewCommunal(),
              NewCardScreen.routeName: (context) => const NewCardScreen(),
            },
          );
        });
  }
}
