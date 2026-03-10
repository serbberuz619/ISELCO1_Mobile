import 'package:flutter/material.dart';

class PayTab extends StatelessWidget {
  const PayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Pay / Scan QR Screen',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
