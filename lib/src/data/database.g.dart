// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SeizuresTable extends Seizures with TableInfo<$SeizuresTable, Seizure> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeizuresTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationKnownMeta = const VerificationMeta(
    'durationKnown',
  );
  @override
  late final GeneratedColumn<bool> durationKnown = GeneratedColumn<bool>(
    'duration_known',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("duration_known" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SeizureType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SeizureType.unknown.name),
      ).withConverter<SeizureType>($SeizuresTable.$convertertype);
  static const VerificationMeta _auraMeta = const VerificationMeta('aura');
  @override
  late final GeneratedColumn<bool> aura = GeneratedColumn<bool>(
    'aura',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aura" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _duringSleepMeta = const VerificationMeta(
    'duringSleep',
  );
  @override
  late final GeneratedColumn<bool> duringSleep = GeneratedColumn<bool>(
    'during_sleep',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("during_sleep" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _injuryMeta = const VerificationMeta('injury');
  @override
  late final GeneratedColumn<bool> injury = GeneratedColumn<bool>(
    'injury',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("injury" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _emergencyCareMeta = const VerificationMeta(
    'emergencyCare',
  );
  @override
  late final GeneratedColumn<bool> emergencyCare = GeneratedColumn<bool>(
    'emergency_care',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("emergency_care" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rescueGivenAtMeta = const VerificationMeta(
    'rescueGivenAt',
  );
  @override
  late final GeneratedColumn<DateTime> rescueGivenAt =
      GeneratedColumn<DateTime>(
        'rescue_given_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rescueMedicationMeta = const VerificationMeta(
    'rescueMedication',
  );
  @override
  late final GeneratedColumn<String> rescueMedication = GeneratedColumn<String>(
    'rescue_medication',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Reporter, String> loggedBy =
      GeneratedColumn<String>(
        'logged_by',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(Reporter.patient.name),
      ).withConverter<Reporter>($SeizuresTable.$converterloggedBy);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _detailsCompletedMeta = const VerificationMeta(
    'detailsCompleted',
  );
  @override
  late final GeneratedColumn<bool> detailsCompleted = GeneratedColumn<bool>(
    'details_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("details_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    durationKnown,
    type,
    aura,
    duringSleep,
    injury,
    emergencyCare,
    rescueGivenAt,
    rescueMedication,
    loggedBy,
    notes,
    detailsCompleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seizures';
  @override
  VerificationContext validateIntegrity(
    Insertable<Seizure> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_known')) {
      context.handle(
        _durationKnownMeta,
        durationKnown.isAcceptableOrUnknown(
          data['duration_known']!,
          _durationKnownMeta,
        ),
      );
    }
    if (data.containsKey('aura')) {
      context.handle(
        _auraMeta,
        aura.isAcceptableOrUnknown(data['aura']!, _auraMeta),
      );
    }
    if (data.containsKey('during_sleep')) {
      context.handle(
        _duringSleepMeta,
        duringSleep.isAcceptableOrUnknown(
          data['during_sleep']!,
          _duringSleepMeta,
        ),
      );
    }
    if (data.containsKey('injury')) {
      context.handle(
        _injuryMeta,
        injury.isAcceptableOrUnknown(data['injury']!, _injuryMeta),
      );
    }
    if (data.containsKey('emergency_care')) {
      context.handle(
        _emergencyCareMeta,
        emergencyCare.isAcceptableOrUnknown(
          data['emergency_care']!,
          _emergencyCareMeta,
        ),
      );
    }
    if (data.containsKey('rescue_given_at')) {
      context.handle(
        _rescueGivenAtMeta,
        rescueGivenAt.isAcceptableOrUnknown(
          data['rescue_given_at']!,
          _rescueGivenAtMeta,
        ),
      );
    }
    if (data.containsKey('rescue_medication')) {
      context.handle(
        _rescueMedicationMeta,
        rescueMedication.isAcceptableOrUnknown(
          data['rescue_medication']!,
          _rescueMedicationMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('details_completed')) {
      context.handle(
        _detailsCompletedMeta,
        detailsCompleted.isAcceptableOrUnknown(
          data['details_completed']!,
          _detailsCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Seizure map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Seizure(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      durationKnown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}duration_known'],
      )!,
      type: $SeizuresTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      aura: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aura'],
      )!,
      duringSleep: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}during_sleep'],
      )!,
      injury: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}injury'],
      )!,
      emergencyCare: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}emergency_care'],
      )!,
      rescueGivenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rescue_given_at'],
      ),
      rescueMedication: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rescue_medication'],
      ),
      loggedBy: $SeizuresTable.$converterloggedBy.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}logged_by'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      detailsCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}details_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SeizuresTable createAlias(String alias) {
    return $SeizuresTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SeizureType, String, String> $convertertype =
      const EnumNameConverter<SeizureType>(SeizureType.values);
  static JsonTypeConverter2<Reporter, String, String> $converterloggedBy =
      const EnumNameConverter<Reporter>(Reporter.values);
}

class Seizure extends DataClass implements Insertable<Seizure> {
  final int id;
  final DateTime startedAt;
  final DateTime? endedAt;

  /// False when nobody saw the start or the end (for example a seizure
  /// during sleep). Unknown durations are excluded from duration statistics.
  final bool durationKnown;
  final SeizureType type;
  final bool aura;
  final bool duringSleep;
  final bool injury;
  final bool emergencyCare;
  final DateTime? rescueGivenAt;
  final String? rescueMedication;
  final Reporter loggedBy;
  final String notes;

  /// Set once someone has reviewed the entry in the editor. Seizures logged
  /// with the one-tap timer start out incomplete so the app can gently ask
  /// for details later.
  final bool detailsCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Seizure({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.durationKnown,
    required this.type,
    required this.aura,
    required this.duringSleep,
    required this.injury,
    required this.emergencyCare,
    this.rescueGivenAt,
    this.rescueMedication,
    required this.loggedBy,
    required this.notes,
    required this.detailsCompleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['duration_known'] = Variable<bool>(durationKnown);
    {
      map['type'] = Variable<String>($SeizuresTable.$convertertype.toSql(type));
    }
    map['aura'] = Variable<bool>(aura);
    map['during_sleep'] = Variable<bool>(duringSleep);
    map['injury'] = Variable<bool>(injury);
    map['emergency_care'] = Variable<bool>(emergencyCare);
    if (!nullToAbsent || rescueGivenAt != null) {
      map['rescue_given_at'] = Variable<DateTime>(rescueGivenAt);
    }
    if (!nullToAbsent || rescueMedication != null) {
      map['rescue_medication'] = Variable<String>(rescueMedication);
    }
    {
      map['logged_by'] = Variable<String>(
        $SeizuresTable.$converterloggedBy.toSql(loggedBy),
      );
    }
    map['notes'] = Variable<String>(notes);
    map['details_completed'] = Variable<bool>(detailsCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SeizuresCompanion toCompanion(bool nullToAbsent) {
    return SeizuresCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationKnown: Value(durationKnown),
      type: Value(type),
      aura: Value(aura),
      duringSleep: Value(duringSleep),
      injury: Value(injury),
      emergencyCare: Value(emergencyCare),
      rescueGivenAt: rescueGivenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(rescueGivenAt),
      rescueMedication: rescueMedication == null && nullToAbsent
          ? const Value.absent()
          : Value(rescueMedication),
      loggedBy: Value(loggedBy),
      notes: Value(notes),
      detailsCompleted: Value(detailsCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Seizure.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Seizure(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationKnown: serializer.fromJson<bool>(json['durationKnown']),
      type: $SeizuresTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      aura: serializer.fromJson<bool>(json['aura']),
      duringSleep: serializer.fromJson<bool>(json['duringSleep']),
      injury: serializer.fromJson<bool>(json['injury']),
      emergencyCare: serializer.fromJson<bool>(json['emergencyCare']),
      rescueGivenAt: serializer.fromJson<DateTime?>(json['rescueGivenAt']),
      rescueMedication: serializer.fromJson<String?>(json['rescueMedication']),
      loggedBy: $SeizuresTable.$converterloggedBy.fromJson(
        serializer.fromJson<String>(json['loggedBy']),
      ),
      notes: serializer.fromJson<String>(json['notes']),
      detailsCompleted: serializer.fromJson<bool>(json['detailsCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationKnown': serializer.toJson<bool>(durationKnown),
      'type': serializer.toJson<String>(
        $SeizuresTable.$convertertype.toJson(type),
      ),
      'aura': serializer.toJson<bool>(aura),
      'duringSleep': serializer.toJson<bool>(duringSleep),
      'injury': serializer.toJson<bool>(injury),
      'emergencyCare': serializer.toJson<bool>(emergencyCare),
      'rescueGivenAt': serializer.toJson<DateTime?>(rescueGivenAt),
      'rescueMedication': serializer.toJson<String?>(rescueMedication),
      'loggedBy': serializer.toJson<String>(
        $SeizuresTable.$converterloggedBy.toJson(loggedBy),
      ),
      'notes': serializer.toJson<String>(notes),
      'detailsCompleted': serializer.toJson<bool>(detailsCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Seizure copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    bool? durationKnown,
    SeizureType? type,
    bool? aura,
    bool? duringSleep,
    bool? injury,
    bool? emergencyCare,
    Value<DateTime?> rescueGivenAt = const Value.absent(),
    Value<String?> rescueMedication = const Value.absent(),
    Reporter? loggedBy,
    String? notes,
    bool? detailsCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Seizure(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationKnown: durationKnown ?? this.durationKnown,
    type: type ?? this.type,
    aura: aura ?? this.aura,
    duringSleep: duringSleep ?? this.duringSleep,
    injury: injury ?? this.injury,
    emergencyCare: emergencyCare ?? this.emergencyCare,
    rescueGivenAt: rescueGivenAt.present
        ? rescueGivenAt.value
        : this.rescueGivenAt,
    rescueMedication: rescueMedication.present
        ? rescueMedication.value
        : this.rescueMedication,
    loggedBy: loggedBy ?? this.loggedBy,
    notes: notes ?? this.notes,
    detailsCompleted: detailsCompleted ?? this.detailsCompleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Seizure copyWithCompanion(SeizuresCompanion data) {
    return Seizure(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationKnown: data.durationKnown.present
          ? data.durationKnown.value
          : this.durationKnown,
      type: data.type.present ? data.type.value : this.type,
      aura: data.aura.present ? data.aura.value : this.aura,
      duringSleep: data.duringSleep.present
          ? data.duringSleep.value
          : this.duringSleep,
      injury: data.injury.present ? data.injury.value : this.injury,
      emergencyCare: data.emergencyCare.present
          ? data.emergencyCare.value
          : this.emergencyCare,
      rescueGivenAt: data.rescueGivenAt.present
          ? data.rescueGivenAt.value
          : this.rescueGivenAt,
      rescueMedication: data.rescueMedication.present
          ? data.rescueMedication.value
          : this.rescueMedication,
      loggedBy: data.loggedBy.present ? data.loggedBy.value : this.loggedBy,
      notes: data.notes.present ? data.notes.value : this.notes,
      detailsCompleted: data.detailsCompleted.present
          ? data.detailsCompleted.value
          : this.detailsCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Seizure(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationKnown: $durationKnown, ')
          ..write('type: $type, ')
          ..write('aura: $aura, ')
          ..write('duringSleep: $duringSleep, ')
          ..write('injury: $injury, ')
          ..write('emergencyCare: $emergencyCare, ')
          ..write('rescueGivenAt: $rescueGivenAt, ')
          ..write('rescueMedication: $rescueMedication, ')
          ..write('loggedBy: $loggedBy, ')
          ..write('notes: $notes, ')
          ..write('detailsCompleted: $detailsCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    endedAt,
    durationKnown,
    type,
    aura,
    duringSleep,
    injury,
    emergencyCare,
    rescueGivenAt,
    rescueMedication,
    loggedBy,
    notes,
    detailsCompleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Seizure &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationKnown == this.durationKnown &&
          other.type == this.type &&
          other.aura == this.aura &&
          other.duringSleep == this.duringSleep &&
          other.injury == this.injury &&
          other.emergencyCare == this.emergencyCare &&
          other.rescueGivenAt == this.rescueGivenAt &&
          other.rescueMedication == this.rescueMedication &&
          other.loggedBy == this.loggedBy &&
          other.notes == this.notes &&
          other.detailsCompleted == this.detailsCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SeizuresCompanion extends UpdateCompanion<Seizure> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<bool> durationKnown;
  final Value<SeizureType> type;
  final Value<bool> aura;
  final Value<bool> duringSleep;
  final Value<bool> injury;
  final Value<bool> emergencyCare;
  final Value<DateTime?> rescueGivenAt;
  final Value<String?> rescueMedication;
  final Value<Reporter> loggedBy;
  final Value<String> notes;
  final Value<bool> detailsCompleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SeizuresCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationKnown = const Value.absent(),
    this.type = const Value.absent(),
    this.aura = const Value.absent(),
    this.duringSleep = const Value.absent(),
    this.injury = const Value.absent(),
    this.emergencyCare = const Value.absent(),
    this.rescueGivenAt = const Value.absent(),
    this.rescueMedication = const Value.absent(),
    this.loggedBy = const Value.absent(),
    this.notes = const Value.absent(),
    this.detailsCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SeizuresCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.durationKnown = const Value.absent(),
    this.type = const Value.absent(),
    this.aura = const Value.absent(),
    this.duringSleep = const Value.absent(),
    this.injury = const Value.absent(),
    this.emergencyCare = const Value.absent(),
    this.rescueGivenAt = const Value.absent(),
    this.rescueMedication = const Value.absent(),
    this.loggedBy = const Value.absent(),
    this.notes = const Value.absent(),
    this.detailsCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<Seizure> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<bool>? durationKnown,
    Expression<String>? type,
    Expression<bool>? aura,
    Expression<bool>? duringSleep,
    Expression<bool>? injury,
    Expression<bool>? emergencyCare,
    Expression<DateTime>? rescueGivenAt,
    Expression<String>? rescueMedication,
    Expression<String>? loggedBy,
    Expression<String>? notes,
    Expression<bool>? detailsCompleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationKnown != null) 'duration_known': durationKnown,
      if (type != null) 'type': type,
      if (aura != null) 'aura': aura,
      if (duringSleep != null) 'during_sleep': duringSleep,
      if (injury != null) 'injury': injury,
      if (emergencyCare != null) 'emergency_care': emergencyCare,
      if (rescueGivenAt != null) 'rescue_given_at': rescueGivenAt,
      if (rescueMedication != null) 'rescue_medication': rescueMedication,
      if (loggedBy != null) 'logged_by': loggedBy,
      if (notes != null) 'notes': notes,
      if (detailsCompleted != null) 'details_completed': detailsCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SeizuresCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<bool>? durationKnown,
    Value<SeizureType>? type,
    Value<bool>? aura,
    Value<bool>? duringSleep,
    Value<bool>? injury,
    Value<bool>? emergencyCare,
    Value<DateTime?>? rescueGivenAt,
    Value<String?>? rescueMedication,
    Value<Reporter>? loggedBy,
    Value<String>? notes,
    Value<bool>? detailsCompleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SeizuresCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationKnown: durationKnown ?? this.durationKnown,
      type: type ?? this.type,
      aura: aura ?? this.aura,
      duringSleep: duringSleep ?? this.duringSleep,
      injury: injury ?? this.injury,
      emergencyCare: emergencyCare ?? this.emergencyCare,
      rescueGivenAt: rescueGivenAt ?? this.rescueGivenAt,
      rescueMedication: rescueMedication ?? this.rescueMedication,
      loggedBy: loggedBy ?? this.loggedBy,
      notes: notes ?? this.notes,
      detailsCompleted: detailsCompleted ?? this.detailsCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationKnown.present) {
      map['duration_known'] = Variable<bool>(durationKnown.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $SeizuresTable.$convertertype.toSql(type.value),
      );
    }
    if (aura.present) {
      map['aura'] = Variable<bool>(aura.value);
    }
    if (duringSleep.present) {
      map['during_sleep'] = Variable<bool>(duringSleep.value);
    }
    if (injury.present) {
      map['injury'] = Variable<bool>(injury.value);
    }
    if (emergencyCare.present) {
      map['emergency_care'] = Variable<bool>(emergencyCare.value);
    }
    if (rescueGivenAt.present) {
      map['rescue_given_at'] = Variable<DateTime>(rescueGivenAt.value);
    }
    if (rescueMedication.present) {
      map['rescue_medication'] = Variable<String>(rescueMedication.value);
    }
    if (loggedBy.present) {
      map['logged_by'] = Variable<String>(
        $SeizuresTable.$converterloggedBy.toSql(loggedBy.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (detailsCompleted.present) {
      map['details_completed'] = Variable<bool>(detailsCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeizuresCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationKnown: $durationKnown, ')
          ..write('type: $type, ')
          ..write('aura: $aura, ')
          ..write('duringSleep: $duringSleep, ')
          ..write('injury: $injury, ')
          ..write('emergencyCare: $emergencyCare, ')
          ..write('rescueGivenAt: $rescueGivenAt, ')
          ..write('rescueMedication: $rescueMedication, ')
          ..write('loggedBy: $loggedBy, ')
          ..write('notes: $notes, ')
          ..write('detailsCompleted: $detailsCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TriggersTable extends Triggers
    with TableInfo<$TriggersTable, TriggerTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TriggersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _builtInMeta = const VerificationMeta(
    'builtIn',
  );
  @override
  late final GeneratedColumn<bool> builtIn = GeneratedColumn<bool>(
    'built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    builtIn,
    archived,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'triggers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TriggerTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('built_in')) {
      context.handle(
        _builtInMeta,
        builtIn.isAcceptableOrUnknown(data['built_in']!, _builtInMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TriggerTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TriggerTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      builtIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}built_in'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $TriggersTable createAlias(String alias) {
    return $TriggersTable(attachedDatabase, alias);
  }
}

class TriggerTag extends DataClass implements Insertable<TriggerTag> {
  final int id;
  final String name;
  final bool builtIn;
  final bool archived;
  final int sortOrder;
  const TriggerTag({
    required this.id,
    required this.name,
    required this.builtIn,
    required this.archived,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['built_in'] = Variable<bool>(builtIn);
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TriggersCompanion toCompanion(bool nullToAbsent) {
    return TriggersCompanion(
      id: Value(id),
      name: Value(name),
      builtIn: Value(builtIn),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
    );
  }

  factory TriggerTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TriggerTag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      builtIn: serializer.fromJson<bool>(json['builtIn']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'builtIn': serializer.toJson<bool>(builtIn),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TriggerTag copyWith({
    int? id,
    String? name,
    bool? builtIn,
    bool? archived,
    int? sortOrder,
  }) => TriggerTag(
    id: id ?? this.id,
    name: name ?? this.name,
    builtIn: builtIn ?? this.builtIn,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  TriggerTag copyWithCompanion(TriggersCompanion data) {
    return TriggerTag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      builtIn: data.builtIn.present ? data.builtIn.value : this.builtIn,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TriggerTag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('builtIn: $builtIn, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, builtIn, archived, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TriggerTag &&
          other.id == this.id &&
          other.name == this.name &&
          other.builtIn == this.builtIn &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder);
}

class TriggersCompanion extends UpdateCompanion<TriggerTag> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> builtIn;
  final Value<bool> archived;
  final Value<int> sortOrder;
  const TriggersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.builtIn = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  TriggersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.builtIn = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<TriggerTag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? builtIn,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (builtIn != null) 'built_in': builtIn,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  TriggersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? builtIn,
    Value<bool>? archived,
    Value<int>? sortOrder,
  }) {
    return TriggersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      builtIn: builtIn ?? this.builtIn,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (builtIn.present) {
      map['built_in'] = Variable<bool>(builtIn.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TriggersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('builtIn: $builtIn, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $SeizureTriggersTable extends SeizureTriggers
    with TableInfo<$SeizureTriggersTable, SeizureTriggerLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeizureTriggersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seizureIdMeta = const VerificationMeta(
    'seizureId',
  );
  @override
  late final GeneratedColumn<int> seizureId = GeneratedColumn<int>(
    'seizure_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES seizures (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _triggerIdMeta = const VerificationMeta(
    'triggerId',
  );
  @override
  late final GeneratedColumn<int> triggerId = GeneratedColumn<int>(
    'trigger_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES triggers (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [seizureId, triggerId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seizure_triggers';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeizureTriggerLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seizure_id')) {
      context.handle(
        _seizureIdMeta,
        seizureId.isAcceptableOrUnknown(data['seizure_id']!, _seizureIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seizureIdMeta);
    }
    if (data.containsKey('trigger_id')) {
      context.handle(
        _triggerIdMeta,
        triggerId.isAcceptableOrUnknown(data['trigger_id']!, _triggerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_triggerIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seizureId, triggerId};
  @override
  SeizureTriggerLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeizureTriggerLink(
      seizureId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seizure_id'],
      )!,
      triggerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trigger_id'],
      )!,
    );
  }

  @override
  $SeizureTriggersTable createAlias(String alias) {
    return $SeizureTriggersTable(attachedDatabase, alias);
  }
}

class SeizureTriggerLink extends DataClass
    implements Insertable<SeizureTriggerLink> {
  final int seizureId;
  final int triggerId;
  const SeizureTriggerLink({required this.seizureId, required this.triggerId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seizure_id'] = Variable<int>(seizureId);
    map['trigger_id'] = Variable<int>(triggerId);
    return map;
  }

  SeizureTriggersCompanion toCompanion(bool nullToAbsent) {
    return SeizureTriggersCompanion(
      seizureId: Value(seizureId),
      triggerId: Value(triggerId),
    );
  }

  factory SeizureTriggerLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeizureTriggerLink(
      seizureId: serializer.fromJson<int>(json['seizureId']),
      triggerId: serializer.fromJson<int>(json['triggerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seizureId': serializer.toJson<int>(seizureId),
      'triggerId': serializer.toJson<int>(triggerId),
    };
  }

  SeizureTriggerLink copyWith({int? seizureId, int? triggerId}) =>
      SeizureTriggerLink(
        seizureId: seizureId ?? this.seizureId,
        triggerId: triggerId ?? this.triggerId,
      );
  SeizureTriggerLink copyWithCompanion(SeizureTriggersCompanion data) {
    return SeizureTriggerLink(
      seizureId: data.seizureId.present ? data.seizureId.value : this.seizureId,
      triggerId: data.triggerId.present ? data.triggerId.value : this.triggerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeizureTriggerLink(')
          ..write('seizureId: $seizureId, ')
          ..write('triggerId: $triggerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seizureId, triggerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeizureTriggerLink &&
          other.seizureId == this.seizureId &&
          other.triggerId == this.triggerId);
}

class SeizureTriggersCompanion extends UpdateCompanion<SeizureTriggerLink> {
  final Value<int> seizureId;
  final Value<int> triggerId;
  final Value<int> rowid;
  const SeizureTriggersCompanion({
    this.seizureId = const Value.absent(),
    this.triggerId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeizureTriggersCompanion.insert({
    required int seizureId,
    required int triggerId,
    this.rowid = const Value.absent(),
  }) : seizureId = Value(seizureId),
       triggerId = Value(triggerId);
  static Insertable<SeizureTriggerLink> custom({
    Expression<int>? seizureId,
    Expression<int>? triggerId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (seizureId != null) 'seizure_id': seizureId,
      if (triggerId != null) 'trigger_id': triggerId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeizureTriggersCompanion copyWith({
    Value<int>? seizureId,
    Value<int>? triggerId,
    Value<int>? rowid,
  }) {
    return SeizureTriggersCompanion(
      seizureId: seizureId ?? this.seizureId,
      triggerId: triggerId ?? this.triggerId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seizureId.present) {
      map['seizure_id'] = Variable<int>(seizureId.value);
    }
    if (triggerId.present) {
      map['trigger_id'] = Variable<int>(triggerId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeizureTriggersCompanion(')
          ..write('seizureId: $seizureId, ')
          ..write('triggerId: $triggerId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MedicationKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MedicationKind>($MedicationsTable.$converterkind);
  static const VerificationMeta _doseMeta = const VerificationMeta('dose');
  @override
  late final GeneratedColumn<String> dose = GeneratedColumn<String>(
    'dose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _scheduleMeta = const VerificationMeta(
    'schedule',
  );
  @override
  late final GeneratedColumn<String> schedule = GeneratedColumn<String>(
    'schedule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    dose,
    schedule,
    active,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dose')) {
      context.handle(
        _doseMeta,
        dose.isAcceptableOrUnknown(data['dose']!, _doseMeta),
      );
    }
    if (data.containsKey('schedule')) {
      context.handle(
        _scheduleMeta,
        schedule.isAcceptableOrUnknown(data['schedule']!, _scheduleMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $MedicationsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      dose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose'],
      )!,
      schedule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MedicationKind, String, String> $converterkind =
      const EnumNameConverter<MedicationKind>(MedicationKind.values);
}

class Medication extends DataClass implements Insertable<Medication> {
  final int id;
  final String name;
  final MedicationKind kind;
  final String dose;
  final String schedule;
  final bool active;
  final String notes;
  final DateTime createdAt;
  const Medication({
    required this.id,
    required this.name,
    required this.kind,
    required this.dose,
    required this.schedule,
    required this.active,
    required this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>(
        $MedicationsTable.$converterkind.toSql(kind),
      );
    }
    map['dose'] = Variable<String>(dose);
    map['schedule'] = Variable<String>(schedule);
    map['active'] = Variable<bool>(active);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      dose: Value(dose),
      schedule: Value(schedule),
      active: Value(active),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Medication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: $MedicationsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      dose: serializer.fromJson<String>(json['dose']),
      schedule: serializer.fromJson<String>(json['schedule']),
      active: serializer.fromJson<bool>(json['active']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(
        $MedicationsTable.$converterkind.toJson(kind),
      ),
      'dose': serializer.toJson<String>(dose),
      'schedule': serializer.toJson<String>(schedule),
      'active': serializer.toJson<bool>(active),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Medication copyWith({
    int? id,
    String? name,
    MedicationKind? kind,
    String? dose,
    String? schedule,
    bool? active,
    String? notes,
    DateTime? createdAt,
  }) => Medication(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    dose: dose ?? this.dose,
    schedule: schedule ?? this.schedule,
    active: active ?? this.active,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      dose: data.dose.present ? data.dose.value : this.dose,
      schedule: data.schedule.present ? data.schedule.value : this.schedule,
      active: data.active.present ? data.active.value : this.active,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('dose: $dose, ')
          ..write('schedule: $schedule, ')
          ..write('active: $active, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, kind, dose, schedule, active, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.dose == this.dose &&
          other.schedule == this.schedule &&
          other.active == this.active &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<int> id;
  final Value<String> name;
  final Value<MedicationKind> kind;
  final Value<String> dose;
  final Value<String> schedule;
  final Value<bool> active;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.dose = const Value.absent(),
    this.schedule = const Value.absent(),
    this.active = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required MedicationKind kind,
    this.dose = const Value.absent(),
    this.schedule = const Value.absent(),
    this.active = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       kind = Value(kind);
  static Insertable<Medication> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? dose,
    Expression<String>? schedule,
    Expression<bool>? active,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (dose != null) 'dose': dose,
      if (schedule != null) 'schedule': schedule,
      if (active != null) 'active': active,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MedicationsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<MedicationKind>? kind,
    Value<String>? dose,
    Value<String>? schedule,
    Value<bool>? active,
    Value<String>? notes,
    Value<DateTime>? createdAt,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      dose: dose ?? this.dose,
      schedule: schedule ?? this.schedule,
      active: active ?? this.active,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $MedicationsTable.$converterkind.toSql(kind.value),
      );
    }
    if (dose.present) {
      map['dose'] = Variable<String>(dose.value);
    }
    if (schedule.present) {
      map['schedule'] = Variable<String>(schedule.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('dose: $dose, ')
          ..write('schedule: $schedule, ')
          ..write('active: $active, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MedicationChangesTable extends MedicationChanges
    with TableInfo<$MedicationChangesTable, MedicationChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationChangesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($MedicationChangesTable.$converterdate);
  @override
  late final GeneratedColumnWithTypeConverter<MedicationChangeKind, String>
  kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MedicationChangeKind>($MedicationChangesTable.$converterkind);
  static const VerificationMeta _doseMeta = const VerificationMeta('dose');
  @override
  late final GeneratedColumn<String> dose = GeneratedColumn<String>(
    'dose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    date,
    kind,
    dose,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('dose')) {
      context.handle(
        _doseMeta,
        dose.isAcceptableOrUnknown(data['dose']!, _doseMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationChange(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      date: $MedicationChangesTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      kind: $MedicationChangesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      dose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $MedicationChangesTable createAlias(String alias) {
    return $MedicationChangesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdate =
      const DateOnlyConverter();
  static JsonTypeConverter2<MedicationChangeKind, String, String>
  $converterkind = const EnumNameConverter<MedicationChangeKind>(
    MedicationChangeKind.values,
  );
}

class MedicationChange extends DataClass
    implements Insertable<MedicationChange> {
  final int id;
  final int medicationId;
  final DateTime date;
  final MedicationChangeKind kind;
  final String dose;
  final String note;
  const MedicationChange({
    required this.id,
    required this.medicationId,
    required this.date,
    required this.kind,
    required this.dose,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medication_id'] = Variable<int>(medicationId);
    {
      map['date'] = Variable<String>(
        $MedicationChangesTable.$converterdate.toSql(date),
      );
    }
    {
      map['kind'] = Variable<String>(
        $MedicationChangesTable.$converterkind.toSql(kind),
      );
    }
    map['dose'] = Variable<String>(dose);
    map['note'] = Variable<String>(note);
    return map;
  }

  MedicationChangesCompanion toCompanion(bool nullToAbsent) {
    return MedicationChangesCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      date: Value(date),
      kind: Value(kind),
      dose: Value(dose),
      note: Value(note),
    );
  }

  factory MedicationChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationChange(
      id: serializer.fromJson<int>(json['id']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      date: serializer.fromJson<DateTime>(json['date']),
      kind: $MedicationChangesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      dose: serializer.fromJson<String>(json['dose']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicationId': serializer.toJson<int>(medicationId),
      'date': serializer.toJson<DateTime>(date),
      'kind': serializer.toJson<String>(
        $MedicationChangesTable.$converterkind.toJson(kind),
      ),
      'dose': serializer.toJson<String>(dose),
      'note': serializer.toJson<String>(note),
    };
  }

  MedicationChange copyWith({
    int? id,
    int? medicationId,
    DateTime? date,
    MedicationChangeKind? kind,
    String? dose,
    String? note,
  }) => MedicationChange(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    date: date ?? this.date,
    kind: kind ?? this.kind,
    dose: dose ?? this.dose,
    note: note ?? this.note,
  );
  MedicationChange copyWithCompanion(MedicationChangesCompanion data) {
    return MedicationChange(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      date: data.date.present ? data.date.value : this.date,
      kind: data.kind.present ? data.kind.value : this.kind,
      dose: data.dose.present ? data.dose.value : this.dose,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationChange(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('dose: $dose, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, medicationId, date, kind, dose, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationChange &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.date == this.date &&
          other.kind == this.kind &&
          other.dose == this.dose &&
          other.note == this.note);
}

class MedicationChangesCompanion extends UpdateCompanion<MedicationChange> {
  final Value<int> id;
  final Value<int> medicationId;
  final Value<DateTime> date;
  final Value<MedicationChangeKind> kind;
  final Value<String> dose;
  final Value<String> note;
  const MedicationChangesCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.date = const Value.absent(),
    this.kind = const Value.absent(),
    this.dose = const Value.absent(),
    this.note = const Value.absent(),
  });
  MedicationChangesCompanion.insert({
    this.id = const Value.absent(),
    required int medicationId,
    required DateTime date,
    required MedicationChangeKind kind,
    this.dose = const Value.absent(),
    this.note = const Value.absent(),
  }) : medicationId = Value(medicationId),
       date = Value(date),
       kind = Value(kind);
  static Insertable<MedicationChange> custom({
    Expression<int>? id,
    Expression<int>? medicationId,
    Expression<String>? date,
    Expression<String>? kind,
    Expression<String>? dose,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (date != null) 'date': date,
      if (kind != null) 'kind': kind,
      if (dose != null) 'dose': dose,
      if (note != null) 'note': note,
    });
  }

  MedicationChangesCompanion copyWith({
    Value<int>? id,
    Value<int>? medicationId,
    Value<DateTime>? date,
    Value<MedicationChangeKind>? kind,
    Value<String>? dose,
    Value<String>? note,
  }) {
    return MedicationChangesCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      date: date ?? this.date,
      kind: kind ?? this.kind,
      dose: dose ?? this.dose,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $MedicationChangesTable.$converterdate.toSql(date.value),
      );
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $MedicationChangesTable.$converterkind.toSql(kind.value),
      );
    }
    if (dose.present) {
      map['dose'] = Variable<String>(dose.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationChangesCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('dose: $dose, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $SleepLogsTable extends SleepLogs
    with TableInfo<$SleepLogsTable, SleepLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepLogsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> night =
      GeneratedColumn<String>(
        'night',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      ).withConverter<DateTime>($SleepLogsTable.$converternight);
  static const VerificationMeta _hoursMeta = const VerificationMeta('hours');
  @override
  late final GeneratedColumn<double> hours = GeneratedColumn<double>(
    'hours',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<int> quality = GeneratedColumn<int>(
    'quality',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, night, hours, quality, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hours')) {
      context.handle(
        _hoursMeta,
        hours.isAcceptableOrUnknown(data['hours']!, _hoursMeta),
      );
    } else if (isInserting) {
      context.missing(_hoursMeta);
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      night: $SleepLogsTable.$converternight.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}night'],
        )!,
      ),
      hours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hours'],
      )!,
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quality'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $SleepLogsTable createAlias(String alias) {
    return $SleepLogsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converternight =
      const DateOnlyConverter();
}

class SleepLog extends DataClass implements Insertable<SleepLog> {
  final int id;
  final DateTime night;
  final double hours;
  final int? quality;
  final String notes;
  const SleepLog({
    required this.id,
    required this.night,
    required this.hours,
    this.quality,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['night'] = Variable<String>(
        $SleepLogsTable.$converternight.toSql(night),
      );
    }
    map['hours'] = Variable<double>(hours);
    if (!nullToAbsent || quality != null) {
      map['quality'] = Variable<int>(quality);
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  SleepLogsCompanion toCompanion(bool nullToAbsent) {
    return SleepLogsCompanion(
      id: Value(id),
      night: Value(night),
      hours: Value(hours),
      quality: quality == null && nullToAbsent
          ? const Value.absent()
          : Value(quality),
      notes: Value(notes),
    );
  }

  factory SleepLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepLog(
      id: serializer.fromJson<int>(json['id']),
      night: serializer.fromJson<DateTime>(json['night']),
      hours: serializer.fromJson<double>(json['hours']),
      quality: serializer.fromJson<int?>(json['quality']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'night': serializer.toJson<DateTime>(night),
      'hours': serializer.toJson<double>(hours),
      'quality': serializer.toJson<int?>(quality),
      'notes': serializer.toJson<String>(notes),
    };
  }

  SleepLog copyWith({
    int? id,
    DateTime? night,
    double? hours,
    Value<int?> quality = const Value.absent(),
    String? notes,
  }) => SleepLog(
    id: id ?? this.id,
    night: night ?? this.night,
    hours: hours ?? this.hours,
    quality: quality.present ? quality.value : this.quality,
    notes: notes ?? this.notes,
  );
  SleepLog copyWithCompanion(SleepLogsCompanion data) {
    return SleepLog(
      id: data.id.present ? data.id.value : this.id,
      night: data.night.present ? data.night.value : this.night,
      hours: data.hours.present ? data.hours.value : this.hours,
      quality: data.quality.present ? data.quality.value : this.quality,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepLog(')
          ..write('id: $id, ')
          ..write('night: $night, ')
          ..write('hours: $hours, ')
          ..write('quality: $quality, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, night, hours, quality, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepLog &&
          other.id == this.id &&
          other.night == this.night &&
          other.hours == this.hours &&
          other.quality == this.quality &&
          other.notes == this.notes);
}

class SleepLogsCompanion extends UpdateCompanion<SleepLog> {
  final Value<int> id;
  final Value<DateTime> night;
  final Value<double> hours;
  final Value<int?> quality;
  final Value<String> notes;
  const SleepLogsCompanion({
    this.id = const Value.absent(),
    this.night = const Value.absent(),
    this.hours = const Value.absent(),
    this.quality = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SleepLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime night,
    required double hours,
    this.quality = const Value.absent(),
    this.notes = const Value.absent(),
  }) : night = Value(night),
       hours = Value(hours);
  static Insertable<SleepLog> custom({
    Expression<int>? id,
    Expression<String>? night,
    Expression<double>? hours,
    Expression<int>? quality,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (night != null) 'night': night,
      if (hours != null) 'hours': hours,
      if (quality != null) 'quality': quality,
      if (notes != null) 'notes': notes,
    });
  }

  SleepLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? night,
    Value<double>? hours,
    Value<int?>? quality,
    Value<String>? notes,
  }) {
    return SleepLogsCompanion(
      id: id ?? this.id,
      night: night ?? this.night,
      hours: hours ?? this.hours,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (night.present) {
      map['night'] = Variable<String>(
        $SleepLogsTable.$converternight.toSql(night.value),
      );
    }
    if (hours.present) {
      map['hours'] = Variable<double>(hours.value);
    }
    if (quality.present) {
      map['quality'] = Variable<int>(quality.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepLogsCompanion(')
          ..write('id: $id, ')
          ..write('night: $night, ')
          ..write('hours: $hours, ')
          ..write('quality: $quality, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
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
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SeizuresTable seizures = $SeizuresTable(this);
  late final $TriggersTable triggers = $TriggersTable(this);
  late final $SeizureTriggersTable seizureTriggers = $SeizureTriggersTable(
    this,
  );
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $MedicationChangesTable medicationChanges =
      $MedicationChangesTable(this);
  late final $SleepLogsTable sleepLogs = $SleepLogsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    seizures,
    triggers,
    seizureTriggers,
    medications,
    medicationChanges,
    sleepLogs,
    settings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'seizures',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('seizure_triggers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'triggers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('seizure_triggers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medications',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('medication_changes', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SeizuresTableCreateCompanionBuilder = SeizuresCompanion Function({
  Value<int> id,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<bool> durationKnown,
  Value<SeizureType> type,
  Value<bool> aura,
  Value<bool> duringSleep,
  Value<bool> injury,
  Value<bool> emergencyCare,
  Value<DateTime?> rescueGivenAt,
  Value<String?> rescueMedication,
  Value<Reporter> loggedBy,
  Value<String> notes,
  Value<bool> detailsCompleted,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$SeizuresTableUpdateCompanionBuilder = SeizuresCompanion Function({
  Value<int> id,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<bool> durationKnown,
  Value<SeizureType> type,
  Value<bool> aura,
  Value<bool> duringSleep,
  Value<bool> injury,
  Value<bool> emergencyCare,
  Value<DateTime?> rescueGivenAt,
  Value<String?> rescueMedication,
  Value<Reporter> loggedBy,
  Value<String> notes,
  Value<bool> detailsCompleted,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$SeizuresTableReferences
    extends BaseReferences<_$AppDatabase, $SeizuresTable, Seizure> {
  $$SeizuresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SeizureTriggersTable, List<SeizureTriggerLink>>
  _seizureTriggersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.seizureTriggers,
    aliasName: 'seizures__id__seizure_triggers__seizure_id',
  );

  $$SeizureTriggersTableProcessedTableManager get seizureTriggersRefs {
    final manager = $$SeizureTriggersTableTableManager(
      $_db,
      $_db.seizureTriggers,
    ).filter((f) => f.seizureId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _seizureTriggersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SeizuresTableFilterComposer
    extends Composer<_$AppDatabase, $SeizuresTable> {
  $$SeizuresTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get durationKnown => $composableBuilder(
    column: $table.durationKnown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SeizureType, SeizureType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get aura => $composableBuilder(
    column: $table.aura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get duringSleep => $composableBuilder(
    column: $table.duringSleep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get injury => $composableBuilder(
    column: $table.injury,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get emergencyCare => $composableBuilder(
    column: $table.emergencyCare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rescueGivenAt => $composableBuilder(
    column: $table.rescueGivenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rescueMedication => $composableBuilder(
    column: $table.rescueMedication,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Reporter, Reporter, String> get loggedBy =>
      $composableBuilder(
        column: $table.loggedBy,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get detailsCompleted => $composableBuilder(
    column: $table.detailsCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> seizureTriggersRefs(
    Expression<bool> Function($$SeizureTriggersTableFilterComposer f) f,
  ) {
    final $$SeizureTriggersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seizureTriggers,
      getReferencedColumn: (t) => t.seizureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeizureTriggersTableFilterComposer(
            $db: $db,
            $table: $db.seizureTriggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SeizuresTableOrderingComposer
    extends Composer<_$AppDatabase, $SeizuresTable> {
  $$SeizuresTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get durationKnown => $composableBuilder(
    column: $table.durationKnown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aura => $composableBuilder(
    column: $table.aura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get duringSleep => $composableBuilder(
    column: $table.duringSleep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get injury => $composableBuilder(
    column: $table.injury,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get emergencyCare => $composableBuilder(
    column: $table.emergencyCare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rescueGivenAt => $composableBuilder(
    column: $table.rescueGivenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rescueMedication => $composableBuilder(
    column: $table.rescueMedication,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loggedBy => $composableBuilder(
    column: $table.loggedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get detailsCompleted => $composableBuilder(
    column: $table.detailsCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeizuresTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeizuresTable> {
  $$SeizuresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<bool> get durationKnown => $composableBuilder(
    column: $table.durationKnown,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SeizureType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get aura =>
      $composableBuilder(column: $table.aura, builder: (column) => column);

  GeneratedColumn<bool> get duringSleep => $composableBuilder(
    column: $table.duringSleep,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get injury =>
      $composableBuilder(column: $table.injury, builder: (column) => column);

  GeneratedColumn<bool> get emergencyCare => $composableBuilder(
    column: $table.emergencyCare,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get rescueGivenAt => $composableBuilder(
    column: $table.rescueGivenAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rescueMedication => $composableBuilder(
    column: $table.rescueMedication,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Reporter, String> get loggedBy =>
      $composableBuilder(column: $table.loggedBy, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get detailsCompleted => $composableBuilder(
    column: $table.detailsCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> seizureTriggersRefs<T extends Object>(
    Expression<T> Function($$SeizureTriggersTableAnnotationComposer a) f,
  ) {
    final $$SeizureTriggersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seizureTriggers,
      getReferencedColumn: (t) => t.seizureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeizureTriggersTableAnnotationComposer(
            $db: $db,
            $table: $db.seizureTriggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SeizuresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeizuresTable,
          Seizure,
          $$SeizuresTableFilterComposer,
          $$SeizuresTableOrderingComposer,
          $$SeizuresTableAnnotationComposer,
          $$SeizuresTableCreateCompanionBuilder,
          $$SeizuresTableUpdateCompanionBuilder,
          (Seizure, $$SeizuresTableReferences),
          Seizure,
          PrefetchHooks Function({bool seizureTriggersRefs})
        > {
  $$SeizuresTableTableManager(_$AppDatabase db, $SeizuresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeizuresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeizuresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeizuresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<bool> durationKnown = const Value.absent(),
                Value<SeizureType> type = const Value.absent(),
                Value<bool> aura = const Value.absent(),
                Value<bool> duringSleep = const Value.absent(),
                Value<bool> injury = const Value.absent(),
                Value<bool> emergencyCare = const Value.absent(),
                Value<DateTime?> rescueGivenAt = const Value.absent(),
                Value<String?> rescueMedication = const Value.absent(),
                Value<Reporter> loggedBy = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> detailsCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SeizuresCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                durationKnown: durationKnown,
                type: type,
                aura: aura,
                duringSleep: duringSleep,
                injury: injury,
                emergencyCare: emergencyCare,
                rescueGivenAt: rescueGivenAt,
                rescueMedication: rescueMedication,
                loggedBy: loggedBy,
                notes: notes,
                detailsCompleted: detailsCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<bool> durationKnown = const Value.absent(),
                Value<SeizureType> type = const Value.absent(),
                Value<bool> aura = const Value.absent(),
                Value<bool> duringSleep = const Value.absent(),
                Value<bool> injury = const Value.absent(),
                Value<bool> emergencyCare = const Value.absent(),
                Value<DateTime?> rescueGivenAt = const Value.absent(),
                Value<String?> rescueMedication = const Value.absent(),
                Value<Reporter> loggedBy = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> detailsCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SeizuresCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                durationKnown: durationKnown,
                type: type,
                aura: aura,
                duringSleep: duringSleep,
                injury: injury,
                emergencyCare: emergencyCare,
                rescueGivenAt: rescueGivenAt,
                rescueMedication: rescueMedication,
                loggedBy: loggedBy,
                notes: notes,
                detailsCompleted: detailsCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeizuresTable, Seizure>(table),
                  $$SeizuresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seizureTriggersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (seizureTriggersRefs) db.seizureTriggers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (seizureTriggersRefs)
                    await $_getPrefetchedDataByColumns<
                      Seizure,
                      $SeizuresTable,
                      SeizureTriggerLink,
                      $SeizureTriggersTable
                    >(
                      currentTable: table,
                      referencedTable: $$SeizuresTableReferences
                          ._seizureTriggersRefsTable(db),
                      managerFromTypedResult: (p0) => $$SeizuresTableReferences(
                        db,
                        table,
                        p0,
                      ).seizureTriggersRefs,
                      currentColumn: 'id',
                      referencedColumn: 'seizure_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SeizuresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeizuresTable,
      Seizure,
      $$SeizuresTableFilterComposer,
      $$SeizuresTableOrderingComposer,
      $$SeizuresTableAnnotationComposer,
      $$SeizuresTableCreateCompanionBuilder,
      $$SeizuresTableUpdateCompanionBuilder,
      (Seizure, $$SeizuresTableReferences),
      Seizure,
      PrefetchHooks Function({bool seizureTriggersRefs})
    >;
typedef $$TriggersTableCreateCompanionBuilder = TriggersCompanion Function({
  Value<int> id,
  required String name,
  Value<bool> builtIn,
  Value<bool> archived,
  Value<int> sortOrder,
});
typedef $$TriggersTableUpdateCompanionBuilder = TriggersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<bool> builtIn,
  Value<bool> archived,
  Value<int> sortOrder,
});

final class $$TriggersTableReferences
    extends BaseReferences<_$AppDatabase, $TriggersTable, TriggerTag> {
  $$TriggersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SeizureTriggersTable, List<SeizureTriggerLink>>
  _seizureTriggersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.seizureTriggers,
    aliasName: 'triggers__id__seizure_triggers__trigger_id',
  );

  $$SeizureTriggersTableProcessedTableManager get seizureTriggersRefs {
    final manager = $$SeizureTriggersTableTableManager(
      $_db,
      $_db.seizureTriggers,
    ).filter((f) => f.triggerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _seizureTriggersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TriggersTableFilterComposer
    extends Composer<_$AppDatabase, $TriggersTable> {
  $$TriggersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> seizureTriggersRefs(
    Expression<bool> Function($$SeizureTriggersTableFilterComposer f) f,
  ) {
    final $$SeizureTriggersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seizureTriggers,
      getReferencedColumn: (t) => t.triggerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeizureTriggersTableFilterComposer(
            $db: $db,
            $table: $db.seizureTriggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TriggersTableOrderingComposer
    extends Composer<_$AppDatabase, $TriggersTable> {
  $$TriggersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get builtIn => $composableBuilder(
    column: $table.builtIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TriggersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TriggersTable> {
  $$TriggersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get builtIn =>
      $composableBuilder(column: $table.builtIn, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> seizureTriggersRefs<T extends Object>(
    Expression<T> Function($$SeizureTriggersTableAnnotationComposer a) f,
  ) {
    final $$SeizureTriggersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seizureTriggers,
      getReferencedColumn: (t) => t.triggerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeizureTriggersTableAnnotationComposer(
            $db: $db,
            $table: $db.seizureTriggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TriggersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TriggersTable,
          TriggerTag,
          $$TriggersTableFilterComposer,
          $$TriggersTableOrderingComposer,
          $$TriggersTableAnnotationComposer,
          $$TriggersTableCreateCompanionBuilder,
          $$TriggersTableUpdateCompanionBuilder,
          (TriggerTag, $$TriggersTableReferences),
          TriggerTag,
          PrefetchHooks Function({bool seizureTriggersRefs})
        > {
  $$TriggersTableTableManager(_$AppDatabase db, $TriggersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TriggersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TriggersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TriggersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> builtIn = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TriggersCompanion(
                id: id,
                name: name,
                builtIn: builtIn,
                archived: archived,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> builtIn = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TriggersCompanion.insert(
                id: id,
                name: name,
                builtIn: builtIn,
                archived: archived,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TriggersTable, TriggerTag>(table),
                  $$TriggersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seizureTriggersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (seizureTriggersRefs) db.seizureTriggers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (seizureTriggersRefs)
                    await $_getPrefetchedDataByColumns<
                      TriggerTag,
                      $TriggersTable,
                      SeizureTriggerLink,
                      $SeizureTriggersTable
                    >(
                      currentTable: table,
                      referencedTable: $$TriggersTableReferences
                          ._seizureTriggersRefsTable(db),
                      managerFromTypedResult: (p0) => $$TriggersTableReferences(
                        db,
                        table,
                        p0,
                      ).seizureTriggersRefs,
                      currentColumn: 'id',
                      referencedColumn: 'trigger_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TriggersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TriggersTable,
      TriggerTag,
      $$TriggersTableFilterComposer,
      $$TriggersTableOrderingComposer,
      $$TriggersTableAnnotationComposer,
      $$TriggersTableCreateCompanionBuilder,
      $$TriggersTableUpdateCompanionBuilder,
      (TriggerTag, $$TriggersTableReferences),
      TriggerTag,
      PrefetchHooks Function({bool seizureTriggersRefs})
    >;
typedef $$SeizureTriggersTableCreateCompanionBuilder =
    SeizureTriggersCompanion Function({
      required int seizureId,
      required int triggerId,
      Value<int> rowid,
    });
typedef $$SeizureTriggersTableUpdateCompanionBuilder =
    SeizureTriggersCompanion Function({
      Value<int> seizureId,
      Value<int> triggerId,
      Value<int> rowid,
    });

final class $$SeizureTriggersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SeizureTriggersTable,
          SeizureTriggerLink
        > {
  $$SeizureTriggersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SeizuresTable _seizureIdTable(_$AppDatabase db) =>
      db.seizures.createAlias('seizure_triggers__seizure_id__seizures__id');

  $$SeizuresTableProcessedTableManager get seizureId {
    final $_column = $_itemColumn<int>('seizure_id')!;

    final manager = $$SeizuresTableTableManager(
      $_db,
      $_db.seizures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seizureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TriggersTable _triggerIdTable(_$AppDatabase db) =>
      db.triggers.createAlias('seizure_triggers__trigger_id__triggers__id');

  $$TriggersTableProcessedTableManager get triggerId {
    final $_column = $_itemColumn<int>('trigger_id')!;

    final manager = $$TriggersTableTableManager(
      $_db,
      $_db.triggers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_triggerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SeizureTriggersTableFilterComposer
    extends Composer<_$AppDatabase, $SeizureTriggersTable> {
  $$SeizureTriggersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$SeizuresTableFilterComposer get seizureId {
    final $$SeizuresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seizureId,
      referencedTable: $db.seizures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeizuresTableFilterComposer(
            $db: $db,
            $table: $db.seizures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TriggersTableFilterComposer get triggerId {
    final $$TriggersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.triggerId,
      referencedTable: $db.triggers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TriggersTableFilterComposer(
            $db: $db,
            $table: $db.triggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeizureTriggersTableOrderingComposer
    extends Composer<_$AppDatabase, $SeizureTriggersTable> {
  $$SeizureTriggersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$SeizuresTableOrderingComposer get seizureId {
    final $$SeizuresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seizureId,
      referencedTable: $db.seizures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeizuresTableOrderingComposer(
            $db: $db,
            $table: $db.seizures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TriggersTableOrderingComposer get triggerId {
    final $$TriggersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.triggerId,
      referencedTable: $db.triggers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TriggersTableOrderingComposer(
            $db: $db,
            $table: $db.triggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeizureTriggersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeizureTriggersTable> {
  $$SeizureTriggersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$SeizuresTableAnnotationComposer get seizureId {
    final $$SeizuresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seizureId,
      referencedTable: $db.seizures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeizuresTableAnnotationComposer(
            $db: $db,
            $table: $db.seizures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TriggersTableAnnotationComposer get triggerId {
    final $$TriggersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.triggerId,
      referencedTable: $db.triggers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TriggersTableAnnotationComposer(
            $db: $db,
            $table: $db.triggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeizureTriggersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeizureTriggersTable,
          SeizureTriggerLink,
          $$SeizureTriggersTableFilterComposer,
          $$SeizureTriggersTableOrderingComposer,
          $$SeizureTriggersTableAnnotationComposer,
          $$SeizureTriggersTableCreateCompanionBuilder,
          $$SeizureTriggersTableUpdateCompanionBuilder,
          (SeizureTriggerLink, $$SeizureTriggersTableReferences),
          SeizureTriggerLink,
          PrefetchHooks Function({bool seizureId, bool triggerId})
        > {
  $$SeizureTriggersTableTableManager(
    _$AppDatabase db,
    $SeizureTriggersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeizureTriggersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeizureTriggersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeizureTriggersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seizureId = const Value.absent(),
                Value<int> triggerId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeizureTriggersCompanion(
                seizureId: seizureId,
                triggerId: triggerId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int seizureId,
                required int triggerId,
                Value<int> rowid = const Value.absent(),
              }) => SeizureTriggersCompanion.insert(
                seizureId: seizureId,
                triggerId: triggerId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeizureTriggersTable, SeizureTriggerLink>(table),
                  $$SeizureTriggersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seizureId = false, triggerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (seizureId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.seizureId,
                        referencedTable: $$SeizureTriggersTableReferences
                            ._seizureIdTable(db),
                        referencedColumn: $$SeizureTriggersTableReferences
                            ._seizureIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (triggerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.triggerId,
                        referencedTable: $$SeizureTriggersTableReferences
                            ._triggerIdTable(db),
                        referencedColumn: $$SeizureTriggersTableReferences
                            ._triggerIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SeizureTriggersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeizureTriggersTable,
      SeizureTriggerLink,
      $$SeizureTriggersTableFilterComposer,
      $$SeizureTriggersTableOrderingComposer,
      $$SeizureTriggersTableAnnotationComposer,
      $$SeizureTriggersTableCreateCompanionBuilder,
      $$SeizureTriggersTableUpdateCompanionBuilder,
      (SeizureTriggerLink, $$SeizureTriggersTableReferences),
      SeizureTriggerLink,
      PrefetchHooks Function({bool seizureId, bool triggerId})
    >;
typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      required String name,
      required MedicationKind kind,
      Value<String> dose,
      Value<String> schedule,
      Value<bool> active,
      Value<String> notes,
      Value<DateTime> createdAt,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<MedicationKind> kind,
      Value<String> dose,
      Value<String> schedule,
      Value<bool> active,
      Value<String> notes,
      Value<DateTime> createdAt,
    });

final class $$MedicationsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationsTable, Medication> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MedicationChangesTable, List<MedicationChange>>
  _medicationChangesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.medicationChanges,
        aliasName: 'medications__id__medication_changes__medication_id',
      );

  $$MedicationChangesTableProcessedTableManager get medicationChangesRefs {
    final manager = $$MedicationChangesTableTableManager(
      $_db,
      $_db.medicationChanges,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _medicationChangesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MedicationKind, MedicationKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get dose => $composableBuilder(
    column: $table.dose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schedule => $composableBuilder(
    column: $table.schedule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> medicationChangesRefs(
    Expression<bool> Function($$MedicationChangesTableFilterComposer f) f,
  ) {
    final $$MedicationChangesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationChanges,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationChangesTableFilterComposer(
            $db: $db,
            $table: $db.medicationChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dose => $composableBuilder(
    column: $table.dose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schedule => $composableBuilder(
    column: $table.schedule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MedicationKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get dose =>
      $composableBuilder(column: $table.dose, builder: (column) => column);

  GeneratedColumn<String> get schedule =>
      $composableBuilder(column: $table.schedule, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> medicationChangesRefs<T extends Object>(
    Expression<T> Function($$MedicationChangesTableAnnotationComposer a) f,
  ) {
    final $$MedicationChangesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.medicationChanges,
          getReferencedColumn: (t) => t.medicationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MedicationChangesTableAnnotationComposer(
                $db: $db,
                $table: $db.medicationChanges,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (Medication, $$MedicationsTableReferences),
          Medication,
          PrefetchHooks Function({bool medicationChangesRefs})
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<MedicationKind> kind = const Value.absent(),
                Value<String> dose = const Value.absent(),
                Value<String> schedule = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                name: name,
                kind: kind,
                dose: dose,
                schedule: schedule,
                active: active,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required MedicationKind kind,
                Value<String> dose = const Value.absent(),
                Value<String> schedule = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                dose: dose,
                schedule: schedule,
                active: active,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicationsTable, Medication>(table),
                  $$MedicationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationChangesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (medicationChangesRefs) db.medicationChanges,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (medicationChangesRefs)
                    await $_getPrefetchedDataByColumns<
                      Medication,
                      $MedicationsTable,
                      MedicationChange,
                      $MedicationChangesTable
                    >(
                      currentTable: table,
                      referencedTable: $$MedicationsTableReferences
                          ._medicationChangesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MedicationsTableReferences(
                            db,
                            table,
                            p0,
                          ).medicationChangesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'medication_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (Medication, $$MedicationsTableReferences),
      Medication,
      PrefetchHooks Function({bool medicationChangesRefs})
    >;
typedef $$MedicationChangesTableCreateCompanionBuilder =
    MedicationChangesCompanion Function({
      Value<int> id,
      required int medicationId,
      required DateTime date,
      required MedicationChangeKind kind,
      Value<String> dose,
      Value<String> note,
    });
typedef $$MedicationChangesTableUpdateCompanionBuilder =
    MedicationChangesCompanion Function({
      Value<int> id,
      Value<int> medicationId,
      Value<DateTime> date,
      Value<MedicationChangeKind> kind,
      Value<String> dose,
      Value<String> note,
    });

final class $$MedicationChangesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MedicationChangesTable,
          MedicationChange
        > {
  $$MedicationChangesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) => db
      .medications
      .createAlias('medication_changes__medication_id__medications__id');

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<int>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MedicationChangesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationChangesTable> {
  $$MedicationChangesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<
    MedicationChangeKind,
    MedicationChangeKind,
    String
  >
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get dose => $composableBuilder(
    column: $table.dose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationChangesTable> {
  $$MedicationChangesTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dose => $composableBuilder(
    column: $table.dose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationChangesTable> {
  $$MedicationChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MedicationChangeKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get dose =>
      $composableBuilder(column: $table.dose, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationChangesTable,
          MedicationChange,
          $$MedicationChangesTableFilterComposer,
          $$MedicationChangesTableOrderingComposer,
          $$MedicationChangesTableAnnotationComposer,
          $$MedicationChangesTableCreateCompanionBuilder,
          $$MedicationChangesTableUpdateCompanionBuilder,
          (MedicationChange, $$MedicationChangesTableReferences),
          MedicationChange,
          PrefetchHooks Function({bool medicationId})
        > {
  $$MedicationChangesTableTableManager(
    _$AppDatabase db,
    $MedicationChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationChangesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<MedicationChangeKind> kind = const Value.absent(),
                Value<String> dose = const Value.absent(),
                Value<String> note = const Value.absent(),
              }) => MedicationChangesCompanion(
                id: id,
                medicationId: medicationId,
                date: date,
                kind: kind,
                dose: dose,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicationId,
                required DateTime date,
                required MedicationChangeKind kind,
                Value<String> dose = const Value.absent(),
                Value<String> note = const Value.absent(),
              }) => MedicationChangesCompanion.insert(
                id: id,
                medicationId: medicationId,
                date: date,
                kind: kind,
                dose: dose,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicationChangesTable, MedicationChange>(table),
                  $$MedicationChangesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (medicationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.medicationId,
                        referencedTable: $$MedicationChangesTableReferences
                            ._medicationIdTable(db),
                        referencedColumn: $$MedicationChangesTableReferences
                            ._medicationIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MedicationChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationChangesTable,
      MedicationChange,
      $$MedicationChangesTableFilterComposer,
      $$MedicationChangesTableOrderingComposer,
      $$MedicationChangesTableAnnotationComposer,
      $$MedicationChangesTableCreateCompanionBuilder,
      $$MedicationChangesTableUpdateCompanionBuilder,
      (MedicationChange, $$MedicationChangesTableReferences),
      MedicationChange,
      PrefetchHooks Function({bool medicationId})
    >;
typedef $$SleepLogsTableCreateCompanionBuilder = SleepLogsCompanion Function({
  Value<int> id,
  required DateTime night,
  required double hours,
  Value<int?> quality,
  Value<String> notes,
});
typedef $$SleepLogsTableUpdateCompanionBuilder = SleepLogsCompanion Function({
  Value<int> id,
  Value<DateTime> night,
  Value<double> hours,
  Value<int?> quality,
  Value<String> notes,
});

class $$SleepLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepLogsTable> {
  $$SleepLogsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get night =>
      $composableBuilder(
        column: $table.night,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get hours => $composableBuilder(
    column: $table.hours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SleepLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepLogsTable> {
  $$SleepLogsTableOrderingComposer({
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

  ColumnOrderings<String> get night => $composableBuilder(
    column: $table.night,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hours => $composableBuilder(
    column: $table.hours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SleepLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepLogsTable> {
  $$SleepLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get night =>
      $composableBuilder(column: $table.night, builder: (column) => column);

  GeneratedColumn<double> get hours =>
      $composableBuilder(column: $table.hours, builder: (column) => column);

  GeneratedColumn<int> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$SleepLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SleepLogsTable,
          SleepLog,
          $$SleepLogsTableFilterComposer,
          $$SleepLogsTableOrderingComposer,
          $$SleepLogsTableAnnotationComposer,
          $$SleepLogsTableCreateCompanionBuilder,
          $$SleepLogsTableUpdateCompanionBuilder,
          (SleepLog, BaseReferences<_$AppDatabase, $SleepLogsTable, SleepLog>),
          SleepLog,
          PrefetchHooks Function()
        > {
  $$SleepLogsTableTableManager(_$AppDatabase db, $SleepLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> night = const Value.absent(),
                Value<double> hours = const Value.absent(),
                Value<int?> quality = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => SleepLogsCompanion(
                id: id,
                night: night,
                hours: hours,
                quality: quality,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime night,
                required double hours,
                Value<int?> quality = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => SleepLogsCompanion.insert(
                id: id,
                night: night,
                hours: hours,
                quality: quality,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SleepLogsTable, SleepLog>(table),
                  BaseReferences<_$AppDatabase, $SleepLogsTable, SleepLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SleepLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SleepLogsTable,
      SleepLog,
      $$SleepLogsTableFilterComposer,
      $$SleepLogsTableOrderingComposer,
      $$SleepLogsTableAnnotationComposer,
      $$SleepLogsTableCreateCompanionBuilder,
      $$SleepLogsTableUpdateCompanionBuilder,
      (SleepLog, BaseReferences<_$AppDatabase, $SleepLogsTable, SleepLog>),
      SleepLog,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SeizuresTableTableManager get seizures =>
      $$SeizuresTableTableManager(_db, _db.seizures);
  $$TriggersTableTableManager get triggers =>
      $$TriggersTableTableManager(_db, _db.triggers);
  $$SeizureTriggersTableTableManager get seizureTriggers =>
      $$SeizureTriggersTableTableManager(_db, _db.seizureTriggers);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$MedicationChangesTableTableManager get medicationChanges =>
      $$MedicationChangesTableTableManager(_db, _db.medicationChanges);
  $$SleepLogsTableTableManager get sleepLogs =>
      $$SleepLogsTableTableManager(_db, _db.sleepLogs);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
