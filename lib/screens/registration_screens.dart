import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../model/user_model.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _auth = FirebaseAuth.instance;

  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      autofocus: false,
      controller: nameController,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (!RegExp("^.{3,50}").hasMatch(value!)) {
          return ("Min 3, max 50 character");
        }
        return null;
      },
      onSaved: (value) {
        nameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person),
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 20.0),
        hintText: "Name",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );

    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
            .hasMatch(value!)) {
          return ("Email tidak valid");
        }
        return null;
      },
      onSaved: (value) {
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.mail),
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 20.0),
        hintText: "Email",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );

    final passowrdField = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: true,
      validator: (value) {
        if (!RegExp("^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{8,}")
            .hasMatch(value!)) {
          return ("Min 8 character dari angka, huruf kecil dan besar");
        }
        return null;
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.key),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
        hintText: "Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    final confirmPasswordField = TextFormField(
      autofocus: false,
      controller: confirmPasswordController,
      obscureText: true,
      validator: (value) {
        if (confirmPasswordController.text != passwordController.text) {
          return "Password tidak sama";
        }
        return null;
      },
      onSaved: (value) {
        confirmPasswordController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.key),
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 20.0),
        hintText: "Confirm password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );

    final registerButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.greenAccent,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          signUp(emailController.text, passwordController.text);
        },
        child: const Text(
          "Sign Up",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.green,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Cafants",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 48.0,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    nameField,
                    const SizedBox(height: 24.0),
                    emailField,
                    const SizedBox(height: 24.0),
                    passowrdField,
                    const SizedBox(height: 24.0),
                    confirmPasswordField,
                    const SizedBox(height: 24.0),
                    registerButton,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) => {sendData()})
            .catchError((e) {
          Fluttertoast.showToast(msg: e!.message);
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Email tidak valid";
            break;
          default:
            errorMessage = "Register gagal, coba lagi";
        }
        Fluttertoast.showToast(msg: errorMessage!);
      }
    }
  }

  sendData() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.name = nameController.text;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        user.updateDisplayName(nameController.text);
        user.sendEmailVerification();
        Fluttertoast.showToast(msg: "Register berhasil");
        Navigator.of(context).pop();
      }
    });
  }
}
