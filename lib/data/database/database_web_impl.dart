import 'package:drift/drift.dart';
import 'package:drift/web.dart';

LazyDatabase createDatabaseConnection() {
  return LazyDatabase(() async {
    return WebDatabase('mamuka_erp');
  });
}


