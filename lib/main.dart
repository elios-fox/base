import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/supabase/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  setupDependencies();
  runApp(const App());
}
