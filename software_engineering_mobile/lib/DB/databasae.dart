import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io' show Platform;

void main() async {
  var db = Db("mongodb://localhost:27017/mongo_dart-blog");
  await db.open();
  print("Connected to database");
}