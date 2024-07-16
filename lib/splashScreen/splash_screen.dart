// ignore_for_file: prefer_const_constructors, unused_import

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logitrust_drivers/authentication/signup_screen.dart';

import 'package:logitrust_drivers/mainScreens/main_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> 
{

  startTimer()
  {
    Timer(const Duration(seconds: 3), () async 
    {
      //send user to home screen
      Navigator.push(context, MaterialPageRoute(builder: (c)=> SignUpScreen()));
    });
  }
  @override
  void initState() {
    
    super.initState();
    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/logooo.png'),
              const SizedBox(height: 10,),
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}