/// This library contains the app's primary entrypoint.
library;

import 'package:flutter/widgets.dart';

import 'src/app/app.dart';
import 'src/app/bootstrap.dart';

/// The primary entrypoint of the app.
///
/// This uses [Bootstrap] to launch [App].
Future<void> main() async {
  await const App().bootstrap((runApp: runApp));
}
