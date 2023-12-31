import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:to_do_list/layout/home_layout.dart';
import 'package:to_do_list/modules/login_screen/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'shared/bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasError) {
            return Text('snap shot error:  ${snapshot.error.toString()}');
          }
          if (snapshot.connectionState==ConnectionState.active){
            if(snapshot.data==null){
              print('snap shot : $snapshot.data');
              return LoginScreen();
            }
            else{
              return Homelayout();
            }
          }
          return CircularProgressIndicator();
        },
      ),

    );
  }
}