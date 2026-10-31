import 'package:flutter/material.dart';

import 'package:ai_study_planner/bootstrap.dart';

Future<void> main() async {
  final scope = await bootstrap();
  runApp(scope);
}
