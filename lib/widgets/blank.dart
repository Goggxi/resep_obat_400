import 'package:flutter/material.dart';

class BlankWidget extends StatelessWidget {
  const BlankWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: size.width * 0.3,
      height: size.width * 0.3,
      child: Image.asset('assets/blank.png'),
    );
  }
}
