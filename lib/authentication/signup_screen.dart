// ignore_for_file: unnecessary_import, prefer_const_constructors, unused_import, await_only_futures, unused_local_variable, prefer_interpolation_to_compose_strings, body_might_complete_normally_catch_error, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logitrust_drivers/authentication/car_info_screen.dart';
import 'package:logitrust_drivers/authentication/login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logitrust_drivers/global/global.dart';
import 'package:logitrust_drivers/widgets/progress_dialog.dart';

class SignUpScreen extends StatefulWidget 
{
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> 
{ 

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm()
  {
    if(nameTextEditingController.text.length<3)
    {
      Fluttertoast.showToast(msg: 'name must be morethan 3 characters');

    }
    else if(!emailTextEditingController.text.contains('@'))
    {
      Fluttertoast.showToast(msg: 'email is not valid');

    }
    else if(phoneTextEditingController.text.isEmpty)
    {
      Fluttertoast.showToast(msg: 'Phone number is required');

    }
    else if(passwordTextEditingController.text.length<8)
    {
      Fluttertoast.showToast(msg: 'Password must be more than 8 characters');

    }
    else if(phoneTextEditingController.text.length<10)
    {
      Fluttertoast.showToast(msg: 'Invalid phone number');

    }
    else
    {
      saveDriverInfoNow();
    }
  }

  saveDriverInfoNow() async
  {
    showDialog(
      context:  context,
      barrierDismissible: false,
      builder: (BuildContext c)
      {
        return ProgressDialog(message: 'Processing, Please wait.....!',);
      }
    );

    final User? firebaseUser = (
      await fAuth.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(), 
        password: passwordTextEditingController.text.trim(),
        ).catchError((msg){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: 'Error: '+ msg.toString());
        })
      ).user;

      if(firebaseUser != null)
      {
        Map driverMap = 
        {
          'id': firebaseUser.uid,
          'name': nameTextEditingController.text.trim(),
          'email': emailTextEditingController.text.trim(),
          'phone': phoneTextEditingController.text.trim(),
        };

        DatabaseReference driversRef = FirebaseDatabase.instance.ref().child('drivers');
        driversRef.child(firebaseUser.uid).set(driverMap);

        currentFirebaseUser = firebaseUser;
        Fluttertoast.showToast(msg: 'Account has been created');
        Navigator.push(context, MaterialPageRoute(builder: (c)=> CarInfoScreen()));

      }
      else
      {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'Account has not been created');
      }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(6, 14, 6, 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
               
               const SizedBox(height: 10,),
          
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset('images/logooo.png'),
              ),
          
              const SizedBox(height: 10,),
          
              const Text(
                'Register AS a Driver',
                style:TextStyle(
                  fontSize: 26,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
          
              TextField(
                controller: nameTextEditingController,
                keyboardType: TextInputType.text,
                
                style: const TextStyle(
                  color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
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
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: 'Enter your digits',
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

              const SizedBox(height: 20,),

              ElevatedButton(
                onPressed:()
                {
                  validateForm();
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ),

               TextButton(
                child: Text(
                  "Already Have an Account? Login Here",
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));

                },

              ),
                
          
            ],
          ),
        ),
      ),
    );
  }
}