import "package:sqflite/sqflite.dart";
import "../database/database_helper.dart";

Future<Database> accessDatabase() async {
  final db = await DatabaseHelper.instance.database;

  return db;
}