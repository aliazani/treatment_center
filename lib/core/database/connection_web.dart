import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

DatabaseConnection openConnection() =>
    DatabaseConnection.delayed(_openConnection());

Future<DatabaseConnection> _openConnection() async {
  final executor = await _openExecutor();
  return DatabaseConnection(executor);
}

Future<QueryExecutor> _openExecutor() async {
  final result = await WasmDatabase.open(
    databaseName: 'treatment_center_db',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );

  return result.resolvedExecutor;
}
