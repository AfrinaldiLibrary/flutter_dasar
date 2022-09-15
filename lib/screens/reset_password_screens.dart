import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  String? errorMessage;

  @override
  Widget build(BuildContext context) {
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

    final resetButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.greenAccent,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          resetEmail(emailController.text);
        },
        child: const Text(
          "Send Verification",
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
                    emailField,
                    const SizedBox(height: 24.0),
                    resetButton,
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void resetEmail(String email) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .sendPasswordResetEmail(email: email)
            .then((value) => {
          Fluttertoast.showToast(msg: "Berhasil, cek email"),
          Navigator.of(context).pop(),
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Email tidak valid";
            break;
          case "user-not-found":
            errorMessage = "User tidak ditemukan";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          default:
            errorMessage = "Gagal, silahkan coba lagi";
        }
        Fluttertoast.showToast(msg: errorMessage!);
      }
    }
  }
}
