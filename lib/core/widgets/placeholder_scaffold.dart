import 'package:flutter/material.dart';

/// Shared skeleton for screens that aren't built out yet — just an AppBar
/// with [title] and a centered label. Swap this for the real screen body
/// once a feature is implemented; the route stays the same.
class PlaceholderScaffold extends StatelessWidget {
  const PlaceholderScaffold({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title screen — coming soon',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
