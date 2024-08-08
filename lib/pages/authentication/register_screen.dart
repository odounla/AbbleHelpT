import 'package:abblehelptech/methodes/common_methods.dart';
import 'package:abblehelptech/pages/authentication/login_screen.dart';
import 'package:abblehelptech/pages/homes/home_screen.dart';
import 'package:abblehelptech/services/services_api.dart';
import 'package:abblehelptech/widgets/dialog_widget.dart';
import 'package:abblehelptech/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../widgets/my_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
TextEditingController fullNameControlller = TextEditingController();
TextEditingController confirmPasswordControlller = TextEditingController();
    TextEditingController emailController = TextEditingController();
  TextEditingController passwordControlller = TextEditingController();
  CommonMethod  cMethods = CommonMethod();
  final ApiService apiService = ApiService();

  checkIfNetworkIsAvailable(){
    cMethods.checkConnectivity(context);
    signUpFormValidation();

  }
  signUpFormValidation(){
    if(fullNameControlller.text.trim().length < 3){
      cMethods.displaySnackBar("your fullName must be atleast 4 or more characters", context);
    }else if(passwordControlller.text.trim().length < 7){
      cMethods.displaySnackBar("your password must be atleast 8 or more characters", context);
    }else if(!emailController.text.contains('@')){
      cMethods.displaySnackBar("please write valide email"+ emailController.text, context);
    }else if(passwordControlller.value != confirmPasswordControlller.value){
      cMethods.displaySnackBar("your password and confirmation password not match", context);
    }else{
      register();
    }

  }

  register() async{
    showDialog(context: context,
    barrierDismissible: false,
     builder: (BuildContext context)=> DialogWidget(message: "Registering and account..."),);

//methode avec firebase
 final User? userFirebase = (
  await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email:emailController.text.trim(),
    password: passwordControlller.text.trim()
    ).catchError((errorMsg){
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    })
 ).user;
      if(!context.mounted) return;
      Navigator.pop(context);

      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(userFirebase!.uid);
      Map userData={
        "name": fullNameControlller.text.trim(),
        "email": emailController.text.trim(),
        "id": userFirebase.uid,
        "blockStatus": false 
      };
      usersRef.set(userData);
      Navigator.push(context, MaterialPageRoute(builder: (c)=> HomeScreens()));








//methode avec notre api
  //  try {

      
  //   await apiService.register(fullNameControlller, emailControlller, passwordControlller);
    
  //   } catch (e) {
     
  //   }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Create an account,",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Let’s create account together",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                MyTextField(
                    controller: fullNameControlller,
                    hintText: "FullName",
                    obscureText: false),
                SizedBox(
                  height: 20,
                ),
                MyTextField(
                    controller: emailController,
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
                 MyTextField(
                    controller: confirmPasswordControlller,
                    hintText: "Confrim Password",
                    
                    obscureText: true),
                SizedBox(
                  height: 50,
                ),
                Padding(padding: EdgeInsets.only(left: 20, right: 20),
                child:  MyButton(onTap: (){checkIfNetworkIsAvailable();}, text: "Sign up"),
                ),
               
                  SizedBox(
                  height: 30,
                ),

                TextButton(onPressed: (){
                  
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                }, child: Text('Already have an account ? Login', style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 15,
                ),))
              ],
            )),
      ),
      ) 
       );
  
  
  }
}
