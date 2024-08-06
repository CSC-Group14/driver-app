import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logitrust_drivers/global/notification.dart';
import '../global/global.dart';
import '../widgets/progress_dialog.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = true;

  @override
  void initState() {
    super.initState();
    nameTextEditingController.addListener(() => setState(() {}));
    emailTextEditingController.addListener(() => setState(() {}));
    phoneTextEditingController.addListener(() => setState(() {}));
  }

  saveUserInfo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(message: "Processing, Please wait");
      },
    );

    try {
      final User? firebaseUser =
          (await firebaseAuth.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      ))
              .user;

      if (firebaseUser != null) {
        // Get device token
        String? token = await FirebaseMessaging.instance.getToken();

        // Create a map of user data
        Map<String, dynamic> userMap = {
          'id': firebaseUser.uid,
          'name': nameTextEditingController.text.trim(),
          'email': emailTextEditingController.text.trim(),
          'phone': phoneTextEditingController.text.trim(),
          'deviceToken': token,
        };

        // Save user data to Firebase Realtime Database
        DatabaseReference databaseReference =
            FirebaseDatabase.instance.ref().child('Drivers');
        await databaseReference.child(firebaseUser.uid).set(userMap);

        // Update global current user
        currentFirebaseUser = firebaseUser;

        Fluttertoast.showToast(msg: "Account has been created");
        Navigator.pushNamed(context, '/car_info_screen');
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Account creation failed");
      }
    } catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    NotificationService().setupFirebaseMessaging();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  Image.asset("images/logoo.png"),
                  const Text(
                    "Register as a Driver",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameTextEditingController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "Name",
                      prefixIcon: const Icon(Icons.person),
                      suffixIcon: nameTextEditingController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  nameTextEditingController.clear(),
                            ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 10),
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "The field is empty";
                      } else
                        return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      suffixIcon: emailTextEditingController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  emailTextEditingController.clear(),
                            ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 10),
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "The field is empty";
                      } else if (!value.contains('@')) {
                        return "Invalid Email Address";
                      } else
                        return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: phoneTextEditingController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Phone",
                      hintText: "Phone",
                      prefixIcon: const Icon(Icons.phone),
                      suffixIcon: phoneTextEditingController.text.isEmpty
                          ? Container(width: 0)
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  phoneTextEditingController.clear(),
                            ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 10),
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "The field is empty";
                      } else
                        return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordTextEditingController,
                    keyboardType: TextInputType.text,
                    obscureText: isPasswordVisible,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.password),
                      suffixIcon: IconButton(
                        icon: isPasswordVisible
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 10),
                      labelStyle:
                          const TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "The field is empty";
                      } else
                        return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveUserInfo();
                      }
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login_screen');
                    },
                    child: const Text(
                      "Already have an account? Login Now",
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
