import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/memory_card.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  // 单例模式
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 初始化数据库
  Future<Database> _initDatabase() async {
    // 在Windows平台上初始化databaseFactory
    if (Platform.isWindows) {
      // 初始化FFI
      sqfliteFfiInit();
      // 使用sqflite_common_ffi初始化databaseFactory
      databaseFactory = databaseFactoryFfi;
    }
    
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'fleeting_light_journal.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE memory_cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        imagePaths TEXT NOT NULL,
        emotion TEXT NOT NULL,
        keywords TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        timeCapsuleDate TEXT,
        isTimeCapsule INTEGER NOT NULL,
        isLocked INTEGER NOT NULL
      )
    ''');
  }

  // 插入新的思慕卡片
  Future<int> insertMemoryCard(MemoryCard card) async {
    Database db = await database;
    return await db.insert('memory_cards', card.toMap());
  }

  // 获取所有非时光胶囊的卡片
  Future<List<MemoryCard>> getMemoryCards() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'memory_cards',
      where: 'isTimeCapsule = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => MemoryCard.fromMap(maps[i]));
  }

  // 获取所有时光胶囊卡片
  Future<List<MemoryCard>> getTimeCapsules() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'memory_cards',
      where: 'isTimeCapsule = ?',
      whereArgs: [1],
      orderBy: 'timeCapsuleDate ASC',
    );
    return List.generate(maps.length, (i) => MemoryCard.fromMap(maps[i]));
  }

  // 获取可以解锁的时光胶囊
  Future<List<MemoryCard>> getUnlockableTimeCapsules() async {
    Database db = await database;
    String now = DateTime.now().toIso8601String();
    List<Map<String, dynamic>> maps = await db.query(
      'memory_cards',
      where: 'isTimeCapsule = ? AND isLocked = ? AND timeCapsuleDate <= ?',
      whereArgs: [1, 1, now],
      orderBy: 'timeCapsuleDate ASC',
    );
    return List.generate(maps.length, (i) => MemoryCard.fromMap(maps[i]));
  }

  // 按情感标签查询卡片
  Future<List<MemoryCard>> getCardsByEmotion(String emotion) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'memory_cards',
      where: 'emotion = ? AND (isTimeCapsule = ? OR isLocked = ?)',
      whereArgs: [emotion, 0, 0],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => MemoryCard.fromMap(maps[i]));
  }

  // 按关键词查询卡片
  Future<List<MemoryCard>> getCardsByKeyword(String keyword) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'memory_cards',
      where: "keywords LIKE ? AND (isTimeCapsule = ? OR isLocked = ?)",
      whereArgs: ['%"$keyword"%', 0, 0],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => MemoryCard.fromMap(maps[i]));
  }

  // 更新卡片
  Future<int> updateMemoryCard(MemoryCard card) async {
    Database db = await database;
    return await db.update(
      'memory_cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  // 解锁时光胶囊
  Future<int> unlockTimeCapsule(int id) async {
    Database db = await database;
    return await db.update(
      'memory_cards',
      {'isLocked': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 删除卡片
  Future<int> deleteMemoryCard(int id) async {
    Database db = await database;
    return await db.delete(
      'memory_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}