  
import 'package:abblehelptech/global/global_var.dart';
import 'package:abblehelptech/methodes/common_methods.dart';
import 'package:abblehelptech/pages/authentication/register_screen.dart';
import 'package:abblehelptech/pages/homes/home_screen.dart';
import 'package:abblehelptech/widgets/dialog_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../widgets/my_button.dart';
import '../../widgets/my_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailControlller = TextEditingController();
  TextEditingController passwordControlller = TextEditingController();
  CommonMethod cMethods = CommonMethod();

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);
    this.signUpFormValidation();
  }

  signUpFormValidation() {
    if (!emailControlller.text.contains("@")) {
      cMethods.displaySnackBar("please write valide email", context);
    } else if (passwordControlller.text.trim().length < 7) {
      cMethods.displaySnackBar(
          "your password must be atleast 8 or more characters", context);
    } else {
      login();
    }
  }

  login() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          DialogWidget(message: "Please wait a moment..."),
    );

    final User? userFirebase = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailControlller.text.trim(),
                password: passwordControlller.text.trim())
            .catchError((errorMsg) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    })).user;
   if(!context.mounted) return;
      Navigator.pop(context);
      if(userFirebase != null){
              DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(userFirebase!.uid);
              usersRef.once().then((snap){
                if(snap.snapshot.value != null){
                  if((snap.snapshot.value as Map)["blockStatus"] == false){
                   // userName = (snap.snapshot.value as Map)["name"];
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> HomeScreens()));
                  }else{
                     FirebaseAuth.instance.signOut();
                  cMethods.displaySnackBar("you are blocked. please contact administrator", context);
                  }


                }else{
                  Navigator.pop(context);
                  FirebaseAuth.instance.signOut();
                  cMethods.displaySnackBar("invalid credidentials", context);

                }
              }
        );
      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      
      body: Center(
        child:    SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(20),
            
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome back,",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Sign in your account",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                MyTextField(
                    controller: emailControlller,
                    hintText: "Email",
                    obscureText: false),
                SizedBox(
                  height: 20,
                ),
                MyTextField(
                    controller: passwordControlller,
                    hintText: "Password",
                    obscureText: true),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: MyButton(
                      onTap: () {
                        checkIfNetworkIsAvailable();
                      },
                      text: "Sign in"),
                ),
                SizedBox(
                  height: 30,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => RegisterScreen()));
                    },
                    child: Text(
                      'Don’t have an account ? Signup',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 15,
                      ),
                    ))
              ],
            )),
      ),
    
      )
      
   );
  }
}
