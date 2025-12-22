import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/energy_reading.dart';
import '../models/device.dart';
import '../models/recommendation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smart_home_energy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path,
        version: 1, onCreate: _createDB, onConfigure: _onConfigure);
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL';

    // 1. USERS Tablosu
    await db.execute('''
      CREATE TABLE Users (user_id $idType, name TEXT, email TEXT)
    ''');

    // Birden fazla kullanıcı ekle
    await db.insert('Users',
        {'user_id': 1, 'name': 'Emre Kaya', 'email': 'emre.kaya@email.com'},
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('Users',
        {'user_id': 2, 'name': 'Ayşe Yılmaz', 'email': 'ayse.yilmaz@email.com'},
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert(
        'Users',
        {
          'user_id': 3,
          'name': 'Mehmet Demir',
          'email': 'mehmet.demir@email.com'
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert(
        'Users',
        {
          'user_id': 4,
          'name': 'Zeynep Şahin',
          'email': 'zeynep.sahin@email.com'
        },
        conflictAlgorithm: ConflictAlgorithm.replace);

    // 2. BUILDINGS Tablosu
    await db.execute('''
      CREATE TABLE Buildings (
        building_id $idType,
        user_id INTEGER,
        name TEXT,
        address TEXT,
        FOREIGN KEY (user_id) REFERENCES Users (user_id)
      )
    ''');

    // Her kullanıcı için ev ekle
    await db.insert(
        'Buildings',
        {
          'building_id': 1,
          'user_id': 1,
          'name': 'Emre\'nin Evi',
          'address': 'İstanbul, Kadıköy'
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert(
        'Buildings',
        {
          'building_id': 2,
          'user_id': 2,
          'name': 'Ayşe\'nin Evi',
          'address': 'Ankara, Çankaya'
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert(
        'Buildings',
        {
          'building_id': 3,
          'user_id': 3,
          'name': 'Mehmet\'in Evi',
          'address': 'İzmir, Karşıyaka'
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert(
        'Buildings',
        {
          'building_id': 4,
          'user_id': 3,
          'name': 'Mehmet\'in Yazlık Evi',
          'address': 'Antalya, Belek'
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert(
        'Buildings',
        {
          'building_id': 5,
          'user_id': 4,
          'name': 'Zeynep\'in Dairesi',
          'address': 'Bursa, Nilüfer'
        },
        conflictAlgorithm: ConflictAlgorithm.replace);

    // 3. ENERGY_READINGS Tablosu
    await db.execute('''
      CREATE TABLE Energy_Readings (
        id $idType,
        building_id INTEGER,
        timestamp $textType,
        total_kwh $realType NOT NULL,
        sub_m3_hvac $realType,
        outdoor_temp $realType,
        comp_yesterday_pct $realType,
        ml_prediction_kwh $realType,
        FOREIGN KEY (building_id) REFERENCES Buildings (building_id)
      )
    ''');

    // 4. DEVICES Tablosu
    await db.execute('''
      CREATE TABLE Devices (
        device_id $idType,
        building_id INTEGER,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        installed_at TEXT,
        status TEXT,
        FOREIGN KEY (building_id) REFERENCES Buildings (building_id)
      )
    ''');

    // 5. RECOMMENDATIONS Tablosu
    await db.execute('''
      CREATE TABLE Recommendations (
        id $idType,
        building_id INTEGER,
        generated_at $textType,
        description $textType NOT NULL,
        estimated_savings_kwh $realType,
        applied_status INTEGER,
        FOREIGN KEY (building_id) REFERENCES Buildings (building_id)
      )
    ''');

    // 6. USER_PREFERENCES Tablosu
    await db.execute('''
      CREATE TABLE User_Preferences (
        id $idType,
        user_id INTEGER,
        preference_key $textType UNIQUE,
        value $textType,
        FOREIGN KEY (user_id) REFERENCES Users (user_id)
      )
    ''');
  }

  // --- VERİ EKLEME (CREATE) METOTLARI ---

  Future<EnergyReading> createReading(EnergyReading reading) async {
    final db = await instance.database;
    final id = await db.insert('Energy_Readings', reading.toMap());
    return EnergyReading.fromMap(reading.toMap()..['id'] = id);
  }

  Future<Device> createDevice(Device device) async {
    final db = await instance.database;
    // building_id'yi manuel olarak 1 veriyoruz, tek ev modeli için
    final deviceMap = device.toMap();
    deviceMap['building_id'] = 1;
    final id = await db.insert('Devices', deviceMap);
    return Device.fromMap(device.toMap()..['device_id'] = id);
  }

  Future<Recommendation> createRecommendation(
      Recommendation recommendation) async {
    final db = await instance.database;
    final id = await db.insert('Recommendations', recommendation.toMap());
    return Recommendation.fromMap(recommendation.toMap()..['id'] = id);
  }

  // --- VERİ OKUMA (READ) METOTLARI ---

  Future<List<EnergyReading>> readAllReadings() async {
    final db = await instance.database;
    final result = await db.query('Energy_Readings', orderBy: 'timestamp DESC');
    return result.map((json) => EnergyReading.fromMap(json)).toList();
  }

  Future<List<Device>> readAllDevices() async {
    final db = await instance.database;
    final result =
        await db.query('Devices', where: 'building_id = ?', whereArgs: [1]);
    return result.map((json) => Device.fromMap(json)).toList();
  }

  Future<List<Recommendation>> readAllRecommendations() async {
    final db = await instance.database;
    final result = await db.query('Recommendations',
        where: 'building_id = ?', whereArgs: [1], orderBy: 'generated_at DESC');
    return result.map((json) => Recommendation.fromMap(json)).toList();
  }

  // --- VERİ GÜNCELLEME (UPDATE) METOTLARI ---

  Future<int> updateDeviceStatus(int deviceId, String status) async {
    final db = await instance.database;
    return await db.update(
      'Devices',
      {'status': status},
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
  }

  Future<int> updateRecommendationStatus(
      int recommendationId, int appliedStatus) async {
    final db = await instance.database;
    return await db.update(
      'Recommendations',
      {'applied_status': appliedStatus},
      where: 'id = ?',
      whereArgs: [recommendationId],
    );
  }

  // --- VERİ SİLME (DELETE) METOTLARI ---

  Future<int> deleteDevice(int deviceId) async {
    final db = await instance.database;
    return await db.delete(
      'Devices',
      where: 'device_id = ?',
      whereArgs: [deviceId],
    );
  }

  Future<int> deleteRecommendation(int recommendationId) async {
    final db = await instance.database;
    return await db.delete(
      'Recommendations',
      where: 'id = ?',
      whereArgs: [recommendationId],
    );
  }

  // --- TOPLU İŞLEMLER ---

  /// Veritabanını temizle (tüm verileri sil)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('Energy_Readings');
    await db.delete('Devices');
    await db.delete('Recommendations');
  }

  /// Batch insert - Çok sayıda veri eklerken performanslı
  Future<void> batchInsertReadings(List<EnergyReading> readings) async {
    final db = await instance.database;
    final batch = db.batch();

    for (final reading in readings) {
      batch.insert('Energy_Readings', reading.toMap());
    }

    await batch.commit(noResult: true);
  }

  // Veritabanı bağlantısını kapatma
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
