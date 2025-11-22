import 'package:drift/drift.dart';
import 'package:drift/web.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    return WebDatabase('mamuka_erp');
  });
}

