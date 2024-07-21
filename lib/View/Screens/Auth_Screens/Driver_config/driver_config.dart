import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logitrust_drivers/View/Components/all_components.dart';
import 'package:logitrust_drivers/View/Screens/Auth_Screens/Driver_config/driver_logics.dart';
import 'package:logitrust_drivers/View/Screens/Auth_Screens/Driver_config/driver_providers.dart';

class DriverConfigsScreen extends StatefulWidget {
  const DriverConfigsScreen({Key? key}) : super(key: key);

  @override
  State<DriverConfigsScreen> createState() => _DriverConfigsScreenState();
}

class _DriverConfigsScreenState extends State<DriverConfigsScreen> {
  final TextEditingController truckNameController = TextEditingController();
  final TextEditingController plateNumController = TextEditingController();
  File? _frontImageFile;
  File? _backImageFile;

  Future<void> _pickImage(ImageSource source, bool isFront) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _frontImageFile = File(pickedFile.path);
        } else {
          _backImageFile = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Driver Config",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontFamily: "bold", fontSize: 20),
                ),
                SizedBox(height: 20),
                Components().returnTextField(
                  truckNameController,
                  context,
                  false,
                  "Please Enter Truck Name",
                ),
                SizedBox(height: 20),
                Components().returnTextField(
                  plateNumController,
                  context,
                  false,
                  "Please Enter Truck Plate Number",
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add Front Image:",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontFamily: "bold", fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery, true),
                      child: _frontImageFile == null
                          ? Container(
                              width: size.width * 0.7,
                              height: size.width * 0.5,
                              color: Colors.grey.withOpacity(0.3),
                              child: Center(
                                child: Text(
                                  "Insert the front image of your truck",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : Image.file(
                              _frontImageFile!,
                              width: size.width * 0.7,
                              height: size.width * 0.5,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add Back Image:",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontFamily: "bold", fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery, false),
                      child: _backImageFile == null
                          ? Container(
                              width: size.width * 0.7,
                              height: size.width * 0.5,
                              color: Colors.grey.withOpacity(0.3),
                              child: Center(
                                child: Text(
                                  "Insert the back image of your truck",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : Image.file(
                              _backImageFile!,
                              width: size.width * 0.7,
                              height: size.width * 0.5,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Consumer(
                  builder: (context, ref, child) {
                    return InkWell(
                      onTap: ref.watch(driverConfigIsLoadingProvider)
                          ? null
                          : () => DriverLogics().sendDataToFirestore(
                                context,
                                ref,
                                truckNameController,
                                plateNumController,
                                _frontImageFile,
                                _backImageFile,
                              ),
                      child: Components().mainButton(
                        size,
                        ref.watch(driverConfigIsLoadingProvider)
                            ? "Loading ..."
                            : "Submit Data",
                        context,
                        ref.watch(driverConfigIsLoadingProvider)
                            ? Colors.grey
                            : Colors.blue,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
