// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthGuard extends StatelessWidget {
//   final Widget Function(BuildContext context) authenticatedBuilder;
//   final Widget Function(BuildContext context) unauthenticatedBuilder;

//   const AuthGuard({
//     super.key,
//     required this.authenticatedBuilder,
//     required this.unauthenticatedBuilder,
//   });

//   @override
//   Widget build(BuildContext context) {
//     SharedPreferences prefs =  SharedPreferences.getInstance();
//     String token = prefs.getString('token');
//     if (token != null) {
//       return authenticatedBuilder(context);
//     } else {
//       // Sinon, affiche la page non authentifiée
//       return unauthenticatedBuilder(context);
//     }
//   }  
//   }