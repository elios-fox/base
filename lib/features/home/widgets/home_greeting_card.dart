import 'package:flutter/material.dart';

class HomeGreetingCard extends StatelessWidget {
  const HomeGreetingCard({super.key, required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          greeting,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
