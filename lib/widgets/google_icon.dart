import 'package:flutter/material.dart';

class GoogleGIcon extends StatelessWidget {
  const GoogleGIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              'G',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.red[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
