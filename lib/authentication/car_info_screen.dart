// ignore_for_file: unnecessary_const, unnecessary_import, sort_child_properties_last, prefer_const_constructors, unused_import

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logitrust_drivers/authentication/login_screen.dart';
import 'package:logitrust_drivers/global/global.dart';
import 'package:logitrust_drivers/splashScreen/splash_screen.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> 
{

  TextEditingController truckModelTextEditingController = TextEditingController();
  TextEditingController truckNumberTextEditingController = TextEditingController();
  TextEditingController truckColorTextEditingController = TextEditingController();
  
  List<String> truckTypesList = ['Big Truck', 'Medium Truck', 'Small Truck'];
  String? selectedTruckType;

  saveCarInfo()
  {
    Map driverCarInfoMap = 
    {
      'Truck_color':truckColorTextEditingController.text.trim(),
      'Truck_number': truckNumberTextEditingController.text.trim(),
      'Truck_model': truckModelTextEditingController.text.trim(),
      'type': selectedTruckType,
    };

    DatabaseReference driversRef = FirebaseDatabase.instance.ref().child('drivers');
    driversRef.child(currentFirebaseUser!.uid).child('Truck_details').set(driverCarInfoMap);

    Fluttertoast.showToast(msg: 'Truck details have been saved,Congs!!!');
    Navigator.push(context, MaterialPageRoute(builder: (c)=> MySplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
          
               const SizedBox(height: 24,),
          
              Padding(
                padding:  const EdgeInsets.all(20.0),
                child: Image.asset("images/logo1.png"),
              ),
          
              const SizedBox(height: 10,),
            
              const Text(
                'Input Truck Details',
                style:TextStyle(
                  fontSize: 26,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
        
        
              TextField(
                controller: truckModelTextEditingController,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: 'Truck Model',
                  hintText: 'Enter the Truck Model',
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
                controller: truckNumberTextEditingController,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: 'Truck Number',
                  hintText: 'Enter your truck number',
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
                controller: truckColorTextEditingController,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  color: Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: 'Truck Color',
                  hintText: 'Enter your truck Color',
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

              const SizedBox(height: 10,),


              DropdownButton(
                iconSize: 20,
                dropdownColor: Colors.black54,
                hint: const Text(
                  'Please choose Truck Type',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
                value: selectedTruckType,
                onChanged: (newvalue)
                {
                  setState(() {
                    selectedTruckType = newvalue.toString();
                  });
                },
                items: truckTypesList.map((truck){
                  return DropdownMenuItem(
                    child: Text(
                      truck,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    value: truck,
                  );
                }).toList(),
              ),

              const SizedBox(height: 20,),

              ElevatedButton(
                onPressed:()
                {
                  if(truckColorTextEditingController.text.isNotEmpty
                   && truckNumberTextEditingController.text.isNotEmpty
                   && truckModelTextEditingController.text.isNotEmpty
                   && selectedTruckType != null)
                   {
                    saveCarInfo();
                   }
                  // Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ),

                
          
            ],
          
          ),
        ),
      ),
    );
  }
}