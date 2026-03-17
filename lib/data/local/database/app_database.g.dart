// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SensorDataTableTable extends SensorDataTable
    with TableInfo<$SensorDataTableTable, SensorData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SensorDataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sensorTypeMeta = const VerificationMeta(
    'sensorType',
  );
  @override
  late final GeneratedColumn<String> sensorType = GeneratedColumn<String>(
    'sensor_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    sessionId,
    sensorType,
    value,
    timestamp,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sensor_data_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SensorData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('sensor_type')) {
      context.handle(
        _sensorTypeMeta,
        sensorType.isAcceptableOrUnknown(data['sensor_type']!, _sensorTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sensorTypeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      sensorType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sensor_type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $SensorDataTableTable createAlias(String alias) {
    return $SensorDataTableTable(attachedDatabase, alias);
  }
}

class SensorData extends DataClass implements Insertable<SensorData> {
  final int id;
  final String userId;
  final String sessionId;
  final String sensorType;
  final String value;
  final DateTime timestamp;
  final bool isSynced;
  const SensorData({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.sensorType,
    required this.value,
    required this.timestamp,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['session_id'] = Variable<String>(sessionId);
    map['sensor_type'] = Variable<String>(sensorType);
    map['value'] = Variable<String>(value);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  SensorDataTableCompanion toCompanion(bool nullToAbsent) {
    return SensorDataTableCompanion(
      id: Value(id),
      userId: Value(userId),
      sessionId: Value(sessionId),
      sensorType: Value(sensorType),
      value: Value(value),
      timestamp: Value(timestamp),
      isSynced: Value(isSynced),
    );
  }

  factory SensorData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      sensorType: serializer.fromJson<String>(json['sensorType']),
      value: serializer.fromJson<String>(json['value']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'sessionId': serializer.toJson<String>(sessionId),
      'sensorType': serializer.toJson<String>(sensorType),
      'value': serializer.toJson<String>(value),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  SensorData copyWith({
    int? id,
    String? userId,
    String? sessionId,
    String? sensorType,
    String? value,
    DateTime? timestamp,
    bool? isSynced,
  }) => SensorData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    sessionId: sessionId ?? this.sessionId,
    sensorType: sensorType ?? this.sensorType,
    value: value ?? this.value,
    timestamp: timestamp ?? this.timestamp,
    isSynced: isSynced ?? this.isSynced,
  );
  SensorData copyWithCompanion(SensorDataTableCompanion data) {
    return SensorData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      sensorType: data.sensorType.present
          ? data.sensorType.value
          : this.sensorType,
      value: data.value.present ? data.value.value : this.value,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SensorData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sessionId: $sessionId, ')
          ..write('sensorType: $sensorType, ')
          ..write('value: $value, ')
          ..write('timestamp: $timestamp, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    sessionId,
    sensorType,
    value,
    timestamp,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.sessionId == this.sessionId &&
          other.sensorType == this.sensorType &&
          other.value == this.value &&
          other.timestamp == this.timestamp &&
          other.isSynced == this.isSynced);
}

class SensorDataTableCompanion extends UpdateCompanion<SensorData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> sessionId;
  final Value<String> sensorType;
  final Value<String> value;
  final Value<DateTime> timestamp;
  final Value<bool> isSynced;
  const SensorDataTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.sensorType = const Value.absent(),
    this.value = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  SensorDataTableCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String sessionId,
    required String sensorType,
    required String value,
    required DateTime timestamp,
    this.isSynced = const Value.absent(),
  }) : userId = Value(userId),
       sessionId = Value(sessionId),
       sensorType = Value(sensorType),
       value = Value(value),
       timestamp = Value(timestamp);
  static Insertable<SensorData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? sessionId,
    Expression<String>? sensorType,
    Expression<String>? value,
    Expression<DateTime>? timestamp,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (sessionId != null) 'session_id': sessionId,
      if (sensorType != null) 'sensor_type': sensorType,
      if (value != null) 'value': value,
      if (timestamp != null) 'timestamp': timestamp,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  SensorDataTableCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? sessionId,
    Value<String>? sensorType,
    Value<String>? value,
    Value<DateTime>? timestamp,
    Value<bool>? isSynced,
  }) {
    return SensorDataTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      sensorType: sensorType ?? this.sensorType,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (sensorType.present) {
      map['sensor_type'] = Variable<String>(sensorType.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorDataTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sessionId: $sessionId, ')
          ..write('sensorType: $sensorType, ')
          ..write('value: $value, ')
          ..write('timestamp: $timestamp, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $EmaResponseTableTable extends EmaResponseTable
    with TableInfo<$EmaResponseTableTable, EmaResponse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmaResponseTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bandoIdMeta = const VerificationMeta(
    'bandoId',
  );
  @override
  late final GeneratedColumn<String> bandoId = GeneratedColumn<String>(
    'bando_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
    'answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bandoId,
    questionId,
    answer,
    timestamp,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ema_response_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmaResponse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bando_id')) {
      context.handle(
        _bandoIdMeta,
        bandoId.isAcceptableOrUnknown(data['bando_id']!, _bandoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bandoIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('answer')) {
      context.handle(
        _answerMeta,
        answer.isAcceptableOrUnknown(data['answer']!, _answerMeta),
      );
    } else if (isInserting) {
      context.missing(_answerMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmaResponse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmaResponse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bandoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bando_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      answer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $EmaResponseTableTable createAlias(String alias) {
    return $EmaResponseTableTable(attachedDatabase, alias);
  }
}

class EmaResponse extends DataClass implements Insertable<EmaResponse> {
  final int id;
  final String bandoId;
  final String questionId;
  final String answer;
  final DateTime timestamp;
  final bool isSynced;
  const EmaResponse({
    required this.id,
    required this.bandoId,
    required this.questionId,
    required this.answer,
    required this.timestamp,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bando_id'] = Variable<String>(bandoId);
    map['question_id'] = Variable<String>(questionId);
    map['answer'] = Variable<String>(answer);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  EmaResponseTableCompanion toCompanion(bool nullToAbsent) {
    return EmaResponseTableCompanion(
      id: Value(id),
      bandoId: Value(bandoId),
      questionId: Value(questionId),
      answer: Value(answer),
      timestamp: Value(timestamp),
      isSynced: Value(isSynced),
    );
  }

  factory EmaResponse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmaResponse(
      id: serializer.fromJson<int>(json['id']),
      bandoId: serializer.fromJson<String>(json['bandoId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      answer: serializer.fromJson<String>(json['answer']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bandoId': serializer.toJson<String>(bandoId),
      'questionId': serializer.toJson<String>(questionId),
      'answer': serializer.toJson<String>(answer),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  EmaResponse copyWith({
    int? id,
    String? bandoId,
    String? questionId,
    String? answer,
    DateTime? timestamp,
    bool? isSynced,
  }) => EmaResponse(
    id: id ?? this.id,
    bandoId: bandoId ?? this.bandoId,
    questionId: questionId ?? this.questionId,
    answer: answer ?? this.answer,
    timestamp: timestamp ?? this.timestamp,
    isSynced: isSynced ?? this.isSynced,
  );
  EmaResponse copyWithCompanion(EmaResponseTableCompanion data) {
    return EmaResponse(
      id: data.id.present ? data.id.value : this.id,
      bandoId: data.bandoId.present ? data.bandoId.value : this.bandoId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      answer: data.answer.present ? data.answer.value : this.answer,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmaResponse(')
          ..write('id: $id, ')
          ..write('bandoId: $bandoId, ')
          ..write('questionId: $questionId, ')
          ..write('answer: $answer, ')
          ..write('timestamp: $timestamp, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bandoId, questionId, answer, timestamp, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmaResponse &&
          other.id == this.id &&
          other.bandoId == this.bandoId &&
          other.questionId == this.questionId &&
          other.answer == this.answer &&
          other.timestamp == this.timestamp &&
          other.isSynced == this.isSynced);
}

class EmaResponseTableCompanion extends UpdateCompanion<EmaResponse> {
  final Value<int> id;
  final Value<String> bandoId;
  final Value<String> questionId;
  final Value<String> answer;
  final Value<DateTime> timestamp;
  final Value<bool> isSynced;
  const EmaResponseTableCompanion({
    this.id = const Value.absent(),
    this.bandoId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.answer = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  EmaResponseTableCompanion.insert({
    this.id = const Value.absent(),
    required String bandoId,
    required String questionId,
    required String answer,
    required DateTime timestamp,
    this.isSynced = const Value.absent(),
  }) : bandoId = Value(bandoId),
       questionId = Value(questionId),
       answer = Value(answer),
       timestamp = Value(timestamp);
  static Insertable<EmaResponse> custom({
    Expression<int>? id,
    Expression<String>? bandoId,
    Expression<String>? questionId,
    Expression<String>? answer,
    Expression<DateTime>? timestamp,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bandoId != null) 'bando_id': bandoId,
      if (questionId != null) 'question_id': questionId,
      if (answer != null) 'answer': answer,
      if (timestamp != null) 'timestamp': timestamp,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  EmaResponseTableCompanion copyWith({
    Value<int>? id,
    Value<String>? bandoId,
    Value<String>? questionId,
    Value<String>? answer,
    Value<DateTime>? timestamp,
    Value<bool>? isSynced,
  }) {
    return EmaResponseTableCompanion(
      id: id ?? this.id,
      bandoId: bandoId ?? this.bandoId,
      questionId: questionId ?? this.questionId,
      answer: answer ?? this.answer,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bandoId.present) {
      map['bando_id'] = Variable<String>(bandoId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmaResponseTableCompanion(')
          ..write('id: $id, ')
          ..write('bandoId: $bandoId, ')
          ..write('questionId: $questionId, ')
          ..write('answer: $answer, ')
          ..write('timestamp: $timestamp, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $SessionRecordTableTable extends SessionRecordTable
    with TableInfo<$SessionRecordTableTable, SessionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionRecordTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bandoIdMeta = const VerificationMeta(
    'bandoId',
  );
  @override
  late final GeneratedColumn<String> bandoId = GeneratedColumn<String>(
    'bando_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bandoId, startTime, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_record_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bando_id')) {
      context.handle(
        _bandoIdMeta,
        bandoId.isAcceptableOrUnknown(data['bando_id']!, _bandoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bandoIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bandoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bando_id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $SessionRecordTableTable createAlias(String alias) {
    return $SessionRecordTableTable(attachedDatabase, alias);
  }
}

class SessionRecord extends DataClass implements Insertable<SessionRecord> {
  final String id;
  final String bandoId;
  final DateTime startTime;
  final String status;
  const SessionRecord({
    required this.id,
    required this.bandoId,
    required this.startTime,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bando_id'] = Variable<String>(bandoId);
    map['start_time'] = Variable<DateTime>(startTime);
    map['status'] = Variable<String>(status);
    return map;
  }

  SessionRecordTableCompanion toCompanion(bool nullToAbsent) {
    return SessionRecordTableCompanion(
      id: Value(id),
      bandoId: Value(bandoId),
      startTime: Value(startTime),
      status: Value(status),
    );
  }

  factory SessionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRecord(
      id: serializer.fromJson<String>(json['id']),
      bandoId: serializer.fromJson<String>(json['bandoId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bandoId': serializer.toJson<String>(bandoId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'status': serializer.toJson<String>(status),
    };
  }

  SessionRecord copyWith({
    String? id,
    String? bandoId,
    DateTime? startTime,
    String? status,
  }) => SessionRecord(
    id: id ?? this.id,
    bandoId: bandoId ?? this.bandoId,
    startTime: startTime ?? this.startTime,
    status: status ?? this.status,
  );
  SessionRecord copyWithCompanion(SessionRecordTableCompanion data) {
    return SessionRecord(
      id: data.id.present ? data.id.value : this.id,
      bandoId: data.bandoId.present ? data.bandoId.value : this.bandoId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRecord(')
          ..write('id: $id, ')
          ..write('bandoId: $bandoId, ')
          ..write('startTime: $startTime, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bandoId, startTime, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRecord &&
          other.id == this.id &&
          other.bandoId == this.bandoId &&
          other.startTime == this.startTime &&
          other.status == this.status);
}

class SessionRecordTableCompanion extends UpdateCompanion<SessionRecord> {
  final Value<String> id;
  final Value<String> bandoId;
  final Value<DateTime> startTime;
  final Value<String> status;
  final Value<int> rowid;
  const SessionRecordTableCompanion({
    this.id = const Value.absent(),
    this.bandoId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionRecordTableCompanion.insert({
    required String id,
    required String bandoId,
    required DateTime startTime,
    required String status,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bandoId = Value(bandoId),
       startTime = Value(startTime),
       status = Value(status);
  static Insertable<SessionRecord> custom({
    Expression<String>? id,
    Expression<String>? bandoId,
    Expression<DateTime>? startTime,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bandoId != null) 'bando_id': bandoId,
      if (startTime != null) 'start_time': startTime,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionRecordTableCompanion copyWith({
    Value<String>? id,
    Value<String>? bandoId,
    Value<DateTime>? startTime,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return SessionRecordTableCompanion(
      id: id ?? this.id,
      bandoId: bandoId ?? this.bandoId,
      startTime: startTime ?? this.startTime,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bandoId.present) {
      map['bando_id'] = Variable<String>(bandoId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionRecordTableCompanion(')
          ..write('id: $id, ')
          ..write('bandoId: $bandoId, ')
          ..write('startTime: $startTime, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SensorDataTableTable sensorDataTable = $SensorDataTableTable(
    this,
  );
  late final $EmaResponseTableTable emaResponseTable = $EmaResponseTableTable(
    this,
  );
  late final $SessionRecordTableTable sessionRecordTable =
      $SessionRecordTableTable(this);
  late final SensorDao sensorDao = SensorDao(this as AppDatabase);
  late final EmaDao emaDao = EmaDao(this as AppDatabase);
  late final SessionDao sessionDao = SessionDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sensorDataTable,
    emaResponseTable,
    sessionRecordTable,
  ];
}

typedef $$SensorDataTableTableCreateCompanionBuilder =
    SensorDataTableCompanion Function({
      Value<int> id,
      required String userId,
      required String sessionId,
      required String sensorType,
      required String value,
      required DateTime timestamp,
      Value<bool> isSynced,
    });
typedef $$SensorDataTableTableUpdateCompanionBuilder =
    SensorDataTableCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> sessionId,
      Value<String> sensorType,
      Value<String> value,
      Value<DateTime> timestamp,
      Value<bool> isSynced,
    });

class $$SensorDataTableTableFilterComposer
    extends Composer<_$AppDatabase, $SensorDataTableTable> {
  $$SensorDataTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sensorType => $composableBuilder(
    column: $table.sensorType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SensorDataTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SensorDataTableTable> {
  $$SensorDataTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sensorType => $composableBuilder(
    column: $table.sensorType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SensorDataTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SensorDataTableTable> {
  $$SensorDataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get sensorType => $composableBuilder(
    column: $table.sensorType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$SensorDataTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SensorDataTableTable,
          SensorData,
          $$SensorDataTableTableFilterComposer,
          $$SensorDataTableTableOrderingComposer,
          $$SensorDataTableTableAnnotationComposer,
          $$SensorDataTableTableCreateCompanionBuilder,
          $$SensorDataTableTableUpdateCompanionBuilder,
          (
            SensorData,
            BaseReferences<_$AppDatabase, $SensorDataTableTable, SensorData>,
          ),
          SensorData,
          PrefetchHooks Function()
        > {
  $$SensorDataTableTableTableManager(
    _$AppDatabase db,
    $SensorDataTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SensorDataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SensorDataTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SensorDataTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> sensorType = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => SensorDataTableCompanion(
                id: id,
                userId: userId,
                sessionId: sessionId,
                sensorType: sensorType,
                value: value,
                timestamp: timestamp,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String sessionId,
                required String sensorType,
                required String value,
                required DateTime timestamp,
                Value<bool> isSynced = const Value.absent(),
              }) => SensorDataTableCompanion.insert(
                id: id,
                userId: userId,
                sessionId: sessionId,
                sensorType: sensorType,
                value: value,
                timestamp: timestamp,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SensorDataTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SensorDataTableTable,
      SensorData,
      $$SensorDataTableTableFilterComposer,
      $$SensorDataTableTableOrderingComposer,
      $$SensorDataTableTableAnnotationComposer,
      $$SensorDataTableTableCreateCompanionBuilder,
      $$SensorDataTableTableUpdateCompanionBuilder,
      (
        SensorData,
        BaseReferences<_$AppDatabase, $SensorDataTableTable, SensorData>,
      ),
      SensorData,
      PrefetchHooks Function()
    >;
typedef $$EmaResponseTableTableCreateCompanionBuilder =
    EmaResponseTableCompanion Function({
      Value<int> id,
      required String bandoId,
      required String questionId,
      required String answer,
      required DateTime timestamp,
      Value<bool> isSynced,
    });
typedef $$EmaResponseTableTableUpdateCompanionBuilder =
    EmaResponseTableCompanion Function({
      Value<int> id,
      Value<String> bandoId,
      Value<String> questionId,
      Value<String> answer,
      Value<DateTime> timestamp,
      Value<bool> isSynced,
    });

class $$EmaResponseTableTableFilterComposer
    extends Composer<_$AppDatabase, $EmaResponseTableTable> {
  $$EmaResponseTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bandoId => $composableBuilder(
    column: $table.bandoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmaResponseTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EmaResponseTableTable> {
  $$EmaResponseTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bandoId => $composableBuilder(
    column: $table.bandoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmaResponseTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmaResponseTableTable> {
  $$EmaResponseTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bandoId =>
      $composableBuilder(column: $table.bandoId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$EmaResponseTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmaResponseTableTable,
          EmaResponse,
          $$EmaResponseTableTableFilterComposer,
          $$EmaResponseTableTableOrderingComposer,
          $$EmaResponseTableTableAnnotationComposer,
          $$EmaResponseTableTableCreateCompanionBuilder,
          $$EmaResponseTableTableUpdateCompanionBuilder,
          (
            EmaResponse,
            BaseReferences<_$AppDatabase, $EmaResponseTableTable, EmaResponse>,
          ),
          EmaResponse,
          PrefetchHooks Function()
        > {
  $$EmaResponseTableTableTableManager(
    _$AppDatabase db,
    $EmaResponseTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmaResponseTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmaResponseTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmaResponseTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bandoId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> answer = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => EmaResponseTableCompanion(
                id: id,
                bandoId: bandoId,
                questionId: questionId,
                answer: answer,
                timestamp: timestamp,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bandoId,
                required String questionId,
                required String answer,
                required DateTime timestamp,
                Value<bool> isSynced = const Value.absent(),
              }) => EmaResponseTableCompanion.insert(
                id: id,
                bandoId: bandoId,
                questionId: questionId,
                answer: answer,
                timestamp: timestamp,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmaResponseTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmaResponseTableTable,
      EmaResponse,
      $$EmaResponseTableTableFilterComposer,
      $$EmaResponseTableTableOrderingComposer,
      $$EmaResponseTableTableAnnotationComposer,
      $$EmaResponseTableTableCreateCompanionBuilder,
      $$EmaResponseTableTableUpdateCompanionBuilder,
      (
        EmaResponse,
        BaseReferences<_$AppDatabase, $EmaResponseTableTable, EmaResponse>,
      ),
      EmaResponse,
      PrefetchHooks Function()
    >;
typedef $$SessionRecordTableTableCreateCompanionBuilder =
    SessionRecordTableCompanion Function({
      required String id,
      required String bandoId,
      required DateTime startTime,
      required String status,
      Value<int> rowid,
    });
typedef $$SessionRecordTableTableUpdateCompanionBuilder =
    SessionRecordTableCompanion Function({
      Value<String> id,
      Value<String> bandoId,
      Value<DateTime> startTime,
      Value<String> status,
      Value<int> rowid,
    });

class $$SessionRecordTableTableFilterComposer
    extends Composer<_$AppDatabase, $SessionRecordTableTable> {
  $$SessionRecordTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bandoId => $composableBuilder(
    column: $table.bandoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionRecordTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionRecordTableTable> {
  $$SessionRecordTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bandoId => $composableBuilder(
    column: $table.bandoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionRecordTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionRecordTableTable> {
  $$SessionRecordTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bandoId =>
      $composableBuilder(column: $table.bandoId, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SessionRecordTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionRecordTableTable,
          SessionRecord,
          $$SessionRecordTableTableFilterComposer,
          $$SessionRecordTableTableOrderingComposer,
          $$SessionRecordTableTableAnnotationComposer,
          $$SessionRecordTableTableCreateCompanionBuilder,
          $$SessionRecordTableTableUpdateCompanionBuilder,
          (
            SessionRecord,
            BaseReferences<
              _$AppDatabase,
              $SessionRecordTableTable,
              SessionRecord
            >,
          ),
          SessionRecord,
          PrefetchHooks Function()
        > {
  $$SessionRecordTableTableTableManager(
    _$AppDatabase db,
    $SessionRecordTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionRecordTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionRecordTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionRecordTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bandoId = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionRecordTableCompanion(
                id: id,
                bandoId: bandoId,
                startTime: startTime,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bandoId,
                required DateTime startTime,
                required String status,
                Value<int> rowid = const Value.absent(),
              }) => SessionRecordTableCompanion.insert(
                id: id,
                bandoId: bandoId,
                startTime: startTime,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionRecordTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionRecordTableTable,
      SessionRecord,
      $$SessionRecordTableTableFilterComposer,
      $$SessionRecordTableTableOrderingComposer,
      $$SessionRecordTableTableAnnotationComposer,
      $$SessionRecordTableTableCreateCompanionBuilder,
      $$SessionRecordTableTableUpdateCompanionBuilder,
      (
        SessionRecord,
        BaseReferences<_$AppDatabase, $SessionRecordTableTable, SessionRecord>,
      ),
      SessionRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SensorDataTableTableTableManager get sensorDataTable =>
      $$SensorDataTableTableTableManager(_db, _db.sensorDataTable);
  $$EmaResponseTableTableTableManager get emaResponseTable =>
      $$EmaResponseTableTableTableManager(_db, _db.emaResponseTable);
  $$SessionRecordTableTableTableManager get sessionRecordTable =>
      $$SessionRecordTableTableTableManager(_db, _db.sessionRecordTable);
}
