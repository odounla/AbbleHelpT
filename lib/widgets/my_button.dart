import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function() ? onTap;
  final String text;
  const MyButton({super.key, required  this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Theme.of(context).colorScheme.background, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}