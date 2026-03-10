import 'package:flutter/material.dart';

class GlobalBackground extends StatelessWidget {
  final Widget child;

  const GlobalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Kukunin natin ang screen size
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      // Dito na nakalagay ng permanente yung background image
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/iselco1_background.jpg'),
          fit: BoxFit.cover, // Para laging sakto
        ),
      ),
      // At ipapasa niya ang child (ilalaman natin) sa loob
      child: child,
    );
  }
}
