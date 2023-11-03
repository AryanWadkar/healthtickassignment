import 'package:flutter/material.dart';

class BorderedButton extends StatelessWidget {
  const BorderedButton({super.key, required this.label, required this.onPress});
  final String label;
  final void Function() onPress;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white)),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class GreenFilledButton extends StatelessWidget {
  const GreenFilledButton(
      {super.key, required this.label, required this.onPress});
  final String label;
  final void Function() onPress;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: const Color(0xffa4b9ab),
            borderRadius: BorderRadius.circular(10)),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }
}
