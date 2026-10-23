import 'package:flutter/material.dart';

import 'app.dart';
import 'features/settings/domain/usecases/get_config.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  // load the saved settings before the first frame
  final config = await di.sl<GetConfig>()();

  runApp(EcoBalanceApp(config: config));
}
