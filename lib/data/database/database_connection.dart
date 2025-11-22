import 'package:drift/drift.dart';

// Import platform-specific implementations using conditional imports
// For web: imports database_web_impl.dart
// For native (mobile/desktop): imports database_native_impl.dart
import 'database_web_impl.dart'
    if (dart.library.io) 'database_native_impl.dart';

LazyDatabase openDatabaseConnection() {
  return createDatabaseConnection();
}

