import 'dart:async';
import 'package:chat_drop/features/chat/data/message_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  final Map<String, StreamController<List<MessageModel>>> _controllers = {};

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chatdrop.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        senderId TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isSent INTEGER NOT NULL,
        isRead INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insertMessage(MessageModel message, String sessionId) async {
    final db = await instance.database;
    final messageMap = message.toDb();
    await db.insert(
      'messages',
      messageMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _emitMessages(sessionId);
  }

  //new
  Future<void> cacheMessage(MessageModel message, String sessionId) async {
    await insertMessage(message, sessionId);
  }

  Future<void> updateMessageStatus(
    String messageId, {
    bool? isSent,
    bool? isRead,
  }) async {
    final db = await instance.database;
    final Map<String, dynamic> data = {};
    if (isSent != null) data['isSent'] = isSent ? 1 : 0;
    if (isRead != null) data['isRead'] = isRead ? 1 : 0;

    if (data.isNotEmpty) {
      await db.update(
        'messages',
        data,
        where: 'id = ?',
        whereArgs: [messageId],
      );

      // Find which session this message belongs to and emit updates
      final result = await db.query(
        'messages',
        columns: ['sessionId'],
        where: 'id = ?',
        whereArgs: [messageId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final sessionId = result.first['sessionId'] as String;
        _emitMessages(sessionId);
      }
    }
  }

  Future<void> _emitMessages(String sessionId) async {
    final db = await instance.database;
    final maps = await db.query(
      'messages',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC', // Fixed typo: was 'timestamps'
    );
    final messages = maps.map((json) => MessageModel.fromDb(json)).toList();

    if (_controllers[sessionId] != null) {
      _controllers[sessionId]!.add(messages);
    }
  }

  Stream<List<MessageModel>> getMessages(String sessionId) {
    if (_controllers[sessionId] == null) {
      _controllers[sessionId] =
          StreamController<List<MessageModel>>.broadcast();
    }

    _emitMessages(sessionId);
    return _controllers[sessionId]!.stream;
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  // Add/update these methods in your DatabaseHelper:

  Future<void> markAllMessagesAsRead(String sessionId, String userId) async {
    final db = await instance.database;
    await db.update(
      'messages',
      {'isRead': 1},
      where: 'sessionId = ? AND senderId != ?',
      whereArgs: [sessionId, userId],
    );
  }

  Future<void> markMessageAsRead(String messageId) async {
    final db = await instance.database;
    await db.update(
      'messages',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<List<MessageModel>> getLastMessage(String sessionId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    return List.generate(maps.length, (i) {
      return MessageModel.fromDb(maps[i]);
    });
  }

  // Clear local chat history
  Future<void> clearChatHistory(String sessionId) async {
    try {
      final db = await database;

      // Delete all messages for this session from local DB
      final deletedCount = await db.delete(
        'messages',
        where: 'sessionId=?',
        whereArgs: [sessionId],
      );

      print(
        'Deleted $deletedCount messages from local database for session: $sessionId',
      );

      // Trigger stream update by refreshing the cache
      await Future.delayed(const Duration(milliseconds: 50));
      _emitMessages(sessionId);
    } catch (e) {
      print("Error clearing local chat history: $e");
      rethrow;
    }
  }
}
