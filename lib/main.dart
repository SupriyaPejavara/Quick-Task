import 'package:flutter/material.dart';
import 'routing/app_router.dart';

//Parse Server Configuration
const applicationId = 'YUMZgHmOOWmdsSxT1YCtuRj7djjjlgabUxk9vtOO';
const clientKey = 'Z2pbWe02lBasgl5X7k5VRVXpXzfsRYXDknsSDvg6';
const parseURL = 'https://parseapi.back4app.com';

void main() {
  runApp(MyApp(router: AppRouter()));
}

class MyApp extends StatelessWidget {
  final AppRouter router;

  const MyApp({super.key, required this.router});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Task',
      onGenerateRoute: router.generateRoute,
      routes: router.routes,
    );
  }
}

