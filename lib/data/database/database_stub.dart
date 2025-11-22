import 'package:drift/drift.dart';

// Stub implementation for platforms that don't support database
LazyDatabase _openConnection() {
  throw UnsupportedError('Database not supported on this platform');
}

