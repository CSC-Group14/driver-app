// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:logitrust_drivers/authentication/car_info_screen.dart';
import 'package:logitrust_drivers/authentication/signup_screen.dart';
import 'package:logitrust_drivers/mainScreens/main_screen.dart';

class LoginScreen extends StatefulWidget 
{
  

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
{

  TextEditingController emailTextEditingController = TextEditingController();
  
  TextEditingController passwordTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(6, 14, 6, 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
          
              const SizedBox(height: 30,),
            
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset('images/logooo.png'),
              ),
          
              const SizedBox(height: 10,),
            
              const Text(
                'Login AS a Driver',
                style:TextStyle(
                  fontSize: 26,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
          
              TextField(
                  controller: emailTextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  
                  style: const TextStyle(
                    color: Colors.grey
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
          
              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(
                  color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),

              ElevatedButton(
              onPressed:()
              {
                 Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreenAccent,
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                ),
              ),
              ),
              TextButton(
                child: const Text(
                  "Don't have an Account? SignUp Here",
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> SignUpScreen()));

                },

              ),
            ],
          ),
        ),
        ),
    );
  }
}