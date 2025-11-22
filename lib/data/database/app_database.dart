import 'package:drift/drift.dart';
import 'package:mamuka_erp/core/constants/gender.dart';
import 'package:mamuka_erp/core/constants/user_status.dart';
import '../models/user_model.dart';
import '../models/sale_model.dart';
import '../models/order_entry_model.dart';
import '../models/order_output_model.dart';
import '../models/order_detail_model.dart';
import '../models/customer_model.dart';
import '../models/session_model.dart';
import 'database_connection.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  UserModels,
  SaleModels,
  OrderEntryModels,
  OrderOutputModels,
  OrderDetailModels,
  CustomerModels,
  SessionModels,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabaseConnection());

  @override
  int get schemaVersion => 6;
}