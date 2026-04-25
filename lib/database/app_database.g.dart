// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, DbUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('user'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, email, password, phone, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<DbUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbUser(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class DbUser extends DataClass implements Insertable<DbUser> {
  final int id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String role;
  const DbUser(
      {required this.id,
      required this.name,
      required this.email,
      required this.password,
      required this.phone,
      required this.role});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['password'] = Variable<String>(password);
    map['phone'] = Variable<String>(phone);
    map['role'] = Variable<String>(role);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      password: Value(password),
      phone: Value(phone),
      role: Value(role),
    );
  }

  factory DbUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbUser(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      password: serializer.fromJson<String>(json['password']),
      phone: serializer.fromJson<String>(json['phone']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'password': serializer.toJson<String>(password),
      'phone': serializer.toJson<String>(phone),
      'role': serializer.toJson<String>(role),
    };
  }

  DbUser copyWith(
          {int? id,
          String? name,
          String? email,
          String? password,
          String? phone,
          String? role}) =>
      DbUser(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        phone: phone ?? this.phone,
        role: role ?? this.role,
      );
  DbUser copyWithCompanion(UsersCompanion data) {
    return DbUser(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      password: data.password.present ? data.password.value : this.password,
      phone: data.phone.present ? data.phone.value : this.phone,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbUser(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('phone: $phone, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, password, phone, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbUser &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.password == this.password &&
          other.phone == this.phone &&
          other.role == this.role);
}

class UsersCompanion extends UpdateCompanion<DbUser> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> password;
  final Value<String> phone;
  final Value<String> role;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.password = const Value.absent(),
    this.phone = const Value.absent(),
    this.role = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String email,
    required String password,
    this.phone = const Value.absent(),
    this.role = const Value.absent(),
  })  : name = Value(name),
        email = Value(email),
        password = Value(password);
  static Insertable<DbUser> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? password,
    Expression<String>? phone,
    Expression<String>? role,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
    });
  }

  UsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? email,
      Value<String>? password,
      Value<String>? phone,
      Value<String>? role}) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      role: role ?? this.role,
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
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('phone: $phone, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }
}

class $DoctorsTable extends Doctors with TableInfo<$DoctorsTable, DbDoctor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoctorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _specialtyMeta =
      const VerificationMeta('specialty');
  @override
  late final GeneratedColumn<String> specialty = GeneratedColumn<String>(
      'specialty', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _specializationsMeta =
      const VerificationMeta('specializations');
  @override
  late final GeneratedColumn<String> specializations = GeneratedColumn<String>(
      'specializations', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _experienceMeta =
      const VerificationMeta('experience');
  @override
  late final GeneratedColumn<int> experience = GeneratedColumn<int>(
      'experience', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, specialty, specializations, experience, description, image];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doctors';
  @override
  VerificationContext validateIntegrity(Insertable<DbDoctor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('specialty')) {
      context.handle(_specialtyMeta,
          specialty.isAcceptableOrUnknown(data['specialty']!, _specialtyMeta));
    } else if (isInserting) {
      context.missing(_specialtyMeta);
    }
    if (data.containsKey('specializations')) {
      context.handle(
          _specializationsMeta,
          specializations.isAcceptableOrUnknown(
              data['specializations']!, _specializationsMeta));
    }
    if (data.containsKey('experience')) {
      context.handle(
          _experienceMeta,
          experience.isAcceptableOrUnknown(
              data['experience']!, _experienceMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbDoctor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbDoctor(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      specialty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specialty'])!,
      specializations: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}specializations'])!,
      experience: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}experience'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image'])!,
    );
  }

  @override
  $DoctorsTable createAlias(String alias) {
    return $DoctorsTable(attachedDatabase, alias);
  }
}

class DbDoctor extends DataClass implements Insertable<DbDoctor> {
  final int id;
  final String name;
  final String specialty;

  /// Danh sách "chuyên môn khám bệnh" dạng chuỗi, ngăn cách bởi `|`.
  final String specializations;
  final int experience;
  final String description;
  final String image;
  const DbDoctor(
      {required this.id,
      required this.name,
      required this.specialty,
      required this.specializations,
      required this.experience,
      required this.description,
      required this.image});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['specialty'] = Variable<String>(specialty);
    map['specializations'] = Variable<String>(specializations);
    map['experience'] = Variable<int>(experience);
    map['description'] = Variable<String>(description);
    map['image'] = Variable<String>(image);
    return map;
  }

  DoctorsCompanion toCompanion(bool nullToAbsent) {
    return DoctorsCompanion(
      id: Value(id),
      name: Value(name),
      specialty: Value(specialty),
      specializations: Value(specializations),
      experience: Value(experience),
      description: Value(description),
      image: Value(image),
    );
  }

  factory DbDoctor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbDoctor(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      specialty: serializer.fromJson<String>(json['specialty']),
      specializations: serializer.fromJson<String>(json['specializations']),
      experience: serializer.fromJson<int>(json['experience']),
      description: serializer.fromJson<String>(json['description']),
      image: serializer.fromJson<String>(json['image']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'specialty': serializer.toJson<String>(specialty),
      'specializations': serializer.toJson<String>(specializations),
      'experience': serializer.toJson<int>(experience),
      'description': serializer.toJson<String>(description),
      'image': serializer.toJson<String>(image),
    };
  }

  DbDoctor copyWith(
          {int? id,
          String? name,
          String? specialty,
          String? specializations,
          int? experience,
          String? description,
          String? image}) =>
      DbDoctor(
        id: id ?? this.id,
        name: name ?? this.name,
        specialty: specialty ?? this.specialty,
        specializations: specializations ?? this.specializations,
        experience: experience ?? this.experience,
        description: description ?? this.description,
        image: image ?? this.image,
      );
  DbDoctor copyWithCompanion(DoctorsCompanion data) {
    return DbDoctor(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      specialty: data.specialty.present ? data.specialty.value : this.specialty,
      specializations: data.specializations.present
          ? data.specializations.value
          : this.specializations,
      experience:
          data.experience.present ? data.experience.value : this.experience,
      description:
          data.description.present ? data.description.value : this.description,
      image: data.image.present ? data.image.value : this.image,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbDoctor(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('specialty: $specialty, ')
          ..write('specializations: $specializations, ')
          ..write('experience: $experience, ')
          ..write('description: $description, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, specialty, specializations, experience, description, image);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbDoctor &&
          other.id == this.id &&
          other.name == this.name &&
          other.specialty == this.specialty &&
          other.specializations == this.specializations &&
          other.experience == this.experience &&
          other.description == this.description &&
          other.image == this.image);
}

class DoctorsCompanion extends UpdateCompanion<DbDoctor> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> specialty;
  final Value<String> specializations;
  final Value<int> experience;
  final Value<String> description;
  final Value<String> image;
  const DoctorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.specialty = const Value.absent(),
    this.specializations = const Value.absent(),
    this.experience = const Value.absent(),
    this.description = const Value.absent(),
    this.image = const Value.absent(),
  });
  DoctorsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String specialty,
    this.specializations = const Value.absent(),
    this.experience = const Value.absent(),
    this.description = const Value.absent(),
    this.image = const Value.absent(),
  })  : name = Value(name),
        specialty = Value(specialty);
  static Insertable<DbDoctor> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? specialty,
    Expression<String>? specializations,
    Expression<int>? experience,
    Expression<String>? description,
    Expression<String>? image,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (specialty != null) 'specialty': specialty,
      if (specializations != null) 'specializations': specializations,
      if (experience != null) 'experience': experience,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
    });
  }

  DoctorsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? specialty,
      Value<String>? specializations,
      Value<int>? experience,
      Value<String>? description,
      Value<String>? image}) {
    return DoctorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      specializations: specializations ?? this.specializations,
      experience: experience ?? this.experience,
      description: description ?? this.description,
      image: image ?? this.image,
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
    if (specialty.present) {
      map['specialty'] = Variable<String>(specialty.value);
    }
    if (specializations.present) {
      map['specializations'] = Variable<String>(specializations.value);
    }
    if (experience.present) {
      map['experience'] = Variable<int>(experience.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoctorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('specialty: $specialty, ')
          ..write('specializations: $specializations, ')
          ..write('experience: $experience, ')
          ..write('description: $description, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }
}

class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, DbSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _doctorIdMeta =
      const VerificationMeta('doctorId');
  @override
  late final GeneratedColumn<int> doctorId = GeneratedColumn<int>(
      'doctor_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES doctors (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
      'start_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
      'end_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isBookedMeta =
      const VerificationMeta('isBooked');
  @override
  late final GeneratedColumn<bool> isBooked = GeneratedColumn<bool>(
      'is_booked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_booked" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, doctorId, date, startTime, endTime, isBooked];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(Insertable<DbSchedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('doctor_id')) {
      context.handle(_doctorIdMeta,
          doctorId.isAcceptableOrUnknown(data['doctor_id']!, _doctorIdMeta));
    } else if (isInserting) {
      context.missing(_doctorIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('is_booked')) {
      context.handle(_isBookedMeta,
          isBooked.isAcceptableOrUnknown(data['is_booked']!, _isBookedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSchedule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      doctorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}doctor_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_time'])!,
      isBooked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_booked'])!,
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }
}

class DbSchedule extends DataClass implements Insertable<DbSchedule> {
  final int id;
  final int doctorId;
  final String date;
  final String startTime;
  final String endTime;
  final bool isBooked;
  const DbSchedule(
      {required this.id,
      required this.doctorId,
      required this.date,
      required this.startTime,
      required this.endTime,
      required this.isBooked});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['doctor_id'] = Variable<int>(doctorId);
    map['date'] = Variable<String>(date);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['is_booked'] = Variable<bool>(isBooked);
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      doctorId: Value(doctorId),
      date: Value(date),
      startTime: Value(startTime),
      endTime: Value(endTime),
      isBooked: Value(isBooked),
    );
  }

  factory DbSchedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSchedule(
      id: serializer.fromJson<int>(json['id']),
      doctorId: serializer.fromJson<int>(json['doctorId']),
      date: serializer.fromJson<String>(json['date']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      isBooked: serializer.fromJson<bool>(json['isBooked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'doctorId': serializer.toJson<int>(doctorId),
      'date': serializer.toJson<String>(date),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'isBooked': serializer.toJson<bool>(isBooked),
    };
  }

  DbSchedule copyWith(
          {int? id,
          int? doctorId,
          String? date,
          String? startTime,
          String? endTime,
          bool? isBooked}) =>
      DbSchedule(
        id: id ?? this.id,
        doctorId: doctorId ?? this.doctorId,
        date: date ?? this.date,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        isBooked: isBooked ?? this.isBooked,
      );
  DbSchedule copyWithCompanion(SchedulesCompanion data) {
    return DbSchedule(
      id: data.id.present ? data.id.value : this.id,
      doctorId: data.doctorId.present ? data.doctorId.value : this.doctorId,
      date: data.date.present ? data.date.value : this.date,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      isBooked: data.isBooked.present ? data.isBooked.value : this.isBooked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSchedule(')
          ..write('id: $id, ')
          ..write('doctorId: $doctorId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isBooked: $isBooked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, doctorId, date, startTime, endTime, isBooked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSchedule &&
          other.id == this.id &&
          other.doctorId == this.doctorId &&
          other.date == this.date &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.isBooked == this.isBooked);
}

class SchedulesCompanion extends UpdateCompanion<DbSchedule> {
  final Value<int> id;
  final Value<int> doctorId;
  final Value<String> date;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<bool> isBooked;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.doctorId = const Value.absent(),
    this.date = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.isBooked = const Value.absent(),
  });
  SchedulesCompanion.insert({
    this.id = const Value.absent(),
    required int doctorId,
    required String date,
    required String startTime,
    required String endTime,
    this.isBooked = const Value.absent(),
  })  : doctorId = Value(doctorId),
        date = Value(date),
        startTime = Value(startTime),
        endTime = Value(endTime);
  static Insertable<DbSchedule> custom({
    Expression<int>? id,
    Expression<int>? doctorId,
    Expression<String>? date,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<bool>? isBooked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (doctorId != null) 'doctor_id': doctorId,
      if (date != null) 'date': date,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (isBooked != null) 'is_booked': isBooked,
    });
  }

  SchedulesCompanion copyWith(
      {Value<int>? id,
      Value<int>? doctorId,
      Value<String>? date,
      Value<String>? startTime,
      Value<String>? endTime,
      Value<bool>? isBooked}) {
    return SchedulesCompanion(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBooked: isBooked ?? this.isBooked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (doctorId.present) {
      map['doctor_id'] = Variable<int>(doctorId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (isBooked.present) {
      map['is_booked'] = Variable<bool>(isBooked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('doctorId: $doctorId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isBooked: $isBooked')
          ..write(')'))
        .toString();
  }
}

class $AppointmentsTable extends Appointments
    with TableInfo<$AppointmentsTable, DbAppointment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _doctorIdMeta =
      const VerificationMeta('doctorId');
  @override
  late final GeneratedColumn<int> doctorId = GeneratedColumn<int>(
      'doctor_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES doctors (id)'));
  static const VerificationMeta _scheduleIdMeta =
      const VerificationMeta('scheduleId');
  @override
  late final GeneratedColumn<int> scheduleId = GeneratedColumn<int>(
      'schedule_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES schedules (id)'));
  static const VerificationMeta _symptomMeta =
      const VerificationMeta('symptom');
  @override
  late final GeneratedColumn<String> symptom = GeneratedColumn<String>(
      'symptom', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, doctorId, scheduleId, symptom, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(Insertable<DbAppointment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('doctor_id')) {
      context.handle(_doctorIdMeta,
          doctorId.isAcceptableOrUnknown(data['doctor_id']!, _doctorIdMeta));
    } else if (isInserting) {
      context.missing(_doctorIdMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
          _scheduleIdMeta,
          scheduleId.isAcceptableOrUnknown(
              data['schedule_id']!, _scheduleIdMeta));
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
    }
    if (data.containsKey('symptom')) {
      context.handle(_symptomMeta,
          symptom.isAcceptableOrUnknown(data['symptom']!, _symptomMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbAppointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbAppointment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      doctorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}doctor_id'])!,
      scheduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schedule_id'])!,
      symptom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symptom'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }
}

class DbAppointment extends DataClass implements Insertable<DbAppointment> {
  final int id;
  final int userId;
  final int doctorId;
  final int scheduleId;
  final String symptom;
  final String status;
  final String createdAt;
  const DbAppointment(
      {required this.id,
      required this.userId,
      required this.doctorId,
      required this.scheduleId,
      required this.symptom,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['doctor_id'] = Variable<int>(doctorId);
    map['schedule_id'] = Variable<int>(scheduleId);
    map['symptom'] = Variable<String>(symptom);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      userId: Value(userId),
      doctorId: Value(doctorId),
      scheduleId: Value(scheduleId),
      symptom: Value(symptom),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory DbAppointment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbAppointment(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      doctorId: serializer.fromJson<int>(json['doctorId']),
      scheduleId: serializer.fromJson<int>(json['scheduleId']),
      symptom: serializer.fromJson<String>(json['symptom']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'doctorId': serializer.toJson<int>(doctorId),
      'scheduleId': serializer.toJson<int>(scheduleId),
      'symptom': serializer.toJson<String>(symptom),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  DbAppointment copyWith(
          {int? id,
          int? userId,
          int? doctorId,
          int? scheduleId,
          String? symptom,
          String? status,
          String? createdAt}) =>
      DbAppointment(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        doctorId: doctorId ?? this.doctorId,
        scheduleId: scheduleId ?? this.scheduleId,
        symptom: symptom ?? this.symptom,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  DbAppointment copyWithCompanion(AppointmentsCompanion data) {
    return DbAppointment(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      doctorId: data.doctorId.present ? data.doctorId.value : this.doctorId,
      scheduleId:
          data.scheduleId.present ? data.scheduleId.value : this.scheduleId,
      symptom: data.symptom.present ? data.symptom.value : this.symptom,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbAppointment(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('doctorId: $doctorId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('symptom: $symptom, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, doctorId, scheduleId, symptom, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbAppointment &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.doctorId == this.doctorId &&
          other.scheduleId == this.scheduleId &&
          other.symptom == this.symptom &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class AppointmentsCompanion extends UpdateCompanion<DbAppointment> {
  final Value<int> id;
  final Value<int> userId;
  final Value<int> doctorId;
  final Value<int> scheduleId;
  final Value<String> symptom;
  final Value<String> status;
  final Value<String> createdAt;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.doctorId = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.symptom = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required int doctorId,
    required int scheduleId,
    this.symptom = const Value.absent(),
    this.status = const Value.absent(),
    required String createdAt,
  })  : userId = Value(userId),
        doctorId = Value(doctorId),
        scheduleId = Value(scheduleId),
        createdAt = Value(createdAt);
  static Insertable<DbAppointment> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<int>? doctorId,
    Expression<int>? scheduleId,
    Expression<String>? symptom,
    Expression<String>? status,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (doctorId != null) 'doctor_id': doctorId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (symptom != null) 'symptom': symptom,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AppointmentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<int>? doctorId,
      Value<int>? scheduleId,
      Value<String>? symptom,
      Value<String>? status,
      Value<String>? createdAt}) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      doctorId: doctorId ?? this.doctorId,
      scheduleId: scheduleId ?? this.scheduleId,
      symptom: symptom ?? this.symptom,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (doctorId.present) {
      map['doctor_id'] = Variable<int>(doctorId.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<int>(scheduleId.value);
    }
    if (symptom.present) {
      map['symptom'] = Variable<String>(symptom.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('doctorId: $doctorId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('symptom: $symptom, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $DoctorsTable doctors = $DoctorsTable(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, doctors, schedules, appointments];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  required String name,
  required String email,
  required String password,
  Value<String> phone,
  Value<String> role,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> email,
  Value<String> password,
  Value<String> phone,
  Value<String> role,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, DbUser> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AppointmentsTable, List<DbAppointment>>
      _appointmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.appointments,
          aliasName: $_aliasNameGenerator(db.users.id, db.appointments.userId));

  $$AppointmentsTableProcessedTableManager get appointmentsRefs {
    final manager = $$AppointmentsTableTableManager($_db, $_db.appointments)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_appointmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  Expression<bool> appointmentsRefs(
      Expression<bool> Function($$AppointmentsTableFilterComposer f) f) {
    final $$AppointmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.appointments,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AppointmentsTableFilterComposer(
              $db: $db,
              $table: $db.appointments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
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

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  Expression<T> appointmentsRefs<T extends Object>(
      Expression<T> Function($$AppointmentsTableAnnotationComposer a) f) {
    final $$AppointmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.appointments,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AppointmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.appointments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    DbUser,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (DbUser, $$UsersTableReferences),
    DbUser,
    PrefetchHooks Function({bool appointmentsRefs})> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> password = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> role = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            name: name,
            email: email,
            password: password,
            phone: phone,
            role: role,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String email,
            required String password,
            Value<String> phone = const Value.absent(),
            Value<String> role = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            name: name,
            email: email,
            password: password,
            phone: phone,
            role: role,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({appointmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (appointmentsRefs) db.appointments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (appointmentsRefs)
                    await $_getPrefetchedData<DbUser, $UsersTable,
                            DbAppointment>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._appointmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .appointmentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    DbUser,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (DbUser, $$UsersTableReferences),
    DbUser,
    PrefetchHooks Function({bool appointmentsRefs})>;
typedef $$DoctorsTableCreateCompanionBuilder = DoctorsCompanion Function({
  Value<int> id,
  required String name,
  required String specialty,
  Value<String> specializations,
  Value<int> experience,
  Value<String> description,
  Value<String> image,
});
typedef $$DoctorsTableUpdateCompanionBuilder = DoctorsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> specialty,
  Value<String> specializations,
  Value<int> experience,
  Value<String> description,
  Value<String> image,
});

final class $$DoctorsTableReferences
    extends BaseReferences<_$AppDatabase, $DoctorsTable, DbDoctor> {
  $$DoctorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SchedulesTable, List<DbSchedule>>
      _schedulesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.schedules,
              aliasName:
                  $_aliasNameGenerator(db.doctors.id, db.schedules.doctorId));

  $$SchedulesTableProcessedTableManager get schedulesRefs {
    final manager = $$SchedulesTableTableManager($_db, $_db.schedules)
        .filter((f) => f.doctorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_schedulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AppointmentsTable, List<DbAppointment>>
      _appointmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.appointments,
          aliasName:
              $_aliasNameGenerator(db.doctors.id, db.appointments.doctorId));

  $$AppointmentsTableProcessedTableManager get appointmentsRefs {
    final manager = $$AppointmentsTableTableManager($_db, $_db.appointments)
        .filter((f) => f.doctorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_appointmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DoctorsTableFilterComposer
    extends Composer<_$AppDatabase, $DoctorsTable> {
  $$DoctorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specialty => $composableBuilder(
      column: $table.specialty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specializations => $composableBuilder(
      column: $table.specializations,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get experience => $composableBuilder(
      column: $table.experience, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnFilters(column));

  Expression<bool> schedulesRefs(
      Expression<bool> Function($$SchedulesTableFilterComposer f) f) {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.doctorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableFilterComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> appointmentsRefs(
      Expression<bool> Function($$AppointmentsTableFilterComposer f) f) {
    final $$AppointmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.appointments,
        getReferencedColumn: (t) => t.doctorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AppointmentsTableFilterComposer(
              $db: $db,
              $table: $db.appointments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DoctorsTableOrderingComposer
    extends Composer<_$AppDatabase, $DoctorsTable> {
  $$DoctorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specialty => $composableBuilder(
      column: $table.specialty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specializations => $composableBuilder(
      column: $table.specializations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get experience => $composableBuilder(
      column: $table.experience, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnOrderings(column));
}

class $$DoctorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DoctorsTable> {
  $$DoctorsTableAnnotationComposer({
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

  GeneratedColumn<String> get specialty =>
      $composableBuilder(column: $table.specialty, builder: (column) => column);

  GeneratedColumn<String> get specializations => $composableBuilder(
      column: $table.specializations, builder: (column) => column);

  GeneratedColumn<int> get experience => $composableBuilder(
      column: $table.experience, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  Expression<T> schedulesRefs<T extends Object>(
      Expression<T> Function($$SchedulesTableAnnotationComposer a) f) {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.doctorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableAnnotationComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> appointmentsRefs<T extends Object>(
      Expression<T> Function($$AppointmentsTableAnnotationComposer a) f) {
    final $$AppointmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.appointments,
        getReferencedColumn: (t) => t.doctorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AppointmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.appointments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DoctorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DoctorsTable,
    DbDoctor,
    $$DoctorsTableFilterComposer,
    $$DoctorsTableOrderingComposer,
    $$DoctorsTableAnnotationComposer,
    $$DoctorsTableCreateCompanionBuilder,
    $$DoctorsTableUpdateCompanionBuilder,
    (DbDoctor, $$DoctorsTableReferences),
    DbDoctor,
    PrefetchHooks Function({bool schedulesRefs, bool appointmentsRefs})> {
  $$DoctorsTableTableManager(_$AppDatabase db, $DoctorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoctorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoctorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoctorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> specialty = const Value.absent(),
            Value<String> specializations = const Value.absent(),
            Value<int> experience = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> image = const Value.absent(),
          }) =>
              DoctorsCompanion(
            id: id,
            name: name,
            specialty: specialty,
            specializations: specializations,
            experience: experience,
            description: description,
            image: image,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String specialty,
            Value<String> specializations = const Value.absent(),
            Value<int> experience = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> image = const Value.absent(),
          }) =>
              DoctorsCompanion.insert(
            id: id,
            name: name,
            specialty: specialty,
            specializations: specializations,
            experience: experience,
            description: description,
            image: image,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$DoctorsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {schedulesRefs = false, appointmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (schedulesRefs) db.schedules,
                if (appointmentsRefs) db.appointments
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (schedulesRefs)
                    await $_getPrefetchedData<DbDoctor, $DoctorsTable,
                            DbSchedule>(
                        currentTable: table,
                        referencedTable:
                            $$DoctorsTableReferences._schedulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DoctorsTableReferences(db, table, p0)
                                .schedulesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.doctorId == item.id),
                        typedResults: items),
                  if (appointmentsRefs)
                    await $_getPrefetchedData<DbDoctor, $DoctorsTable,
                            DbAppointment>(
                        currentTable: table,
                        referencedTable:
                            $$DoctorsTableReferences._appointmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DoctorsTableReferences(db, table, p0)
                                .appointmentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.doctorId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DoctorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DoctorsTable,
    DbDoctor,
    $$DoctorsTableFilterComposer,
    $$DoctorsTableOrderingComposer,
    $$DoctorsTableAnnotationComposer,
    $$DoctorsTableCreateCompanionBuilder,
    $$DoctorsTableUpdateCompanionBuilder,
    (DbDoctor, $$DoctorsTableReferences),
    DbDoctor,
    PrefetchHooks Function({bool schedulesRefs, bool appointmentsRefs})>;
typedef $$SchedulesTableCreateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  required int doctorId,
  required String date,
  required String startTime,
  required String endTime,
  Value<bool> isBooked,
});
typedef $$SchedulesTableUpdateCompanionBuilder = SchedulesCompanion Function({
  Value<int> id,
  Value<int> doctorId,
  Value<String> date,
  Value<String> startTime,
  Value<String> endTime,
  Value<bool> isBooked,
});

final class $$SchedulesTableReferences
    extends BaseReferences<_$AppDatabase, $SchedulesTable, DbSchedule> {
  $$SchedulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DoctorsTable _doctorIdTable(_$AppDatabase db) => db.doctors
      .createAlias($_aliasNameGenerator(db.schedules.doctorId, db.doctors.id));

  $$DoctorsTableProcessedTableManager get doctorId {
    final $_column = $_itemColumn<int>('doctor_id')!;

    final manager = $$DoctorsTableTableManager($_db, $_db.doctors)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_doctorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$AppointmentsTable, List<DbAppointment>>
      _appointmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.appointments,
              aliasName: $_aliasNameGenerator(
                  db.schedules.id, db.appointments.scheduleId));

  $$AppointmentsTableProcessedTableManager get appointmentsRefs {
    final manager = $$AppointmentsTableTableManager($_db, $_db.appointments)
        .filter((f) => f.scheduleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_appointmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBooked => $composableBuilder(
      column: $table.isBooked, builder: (column) => ColumnFilters(column));

  $$DoctorsTableFilterComposer get doctorId {
    final $$DoctorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.doctorId,
        referencedTable: $db.doctors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DoctorsTableFilterComposer(
              $db: $db,
              $table: $db.doctors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> appointmentsRefs(
      Expression<bool> Function($$AppointmentsTableFilterComposer f) f) {
    final $$AppointmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.appointments,
        getReferencedColumn: (t) => t.scheduleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AppointmentsTableFilterComposer(
              $db: $db,
              $table: $db.appointments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBooked => $composableBuilder(
      column: $table.isBooked, builder: (column) => ColumnOrderings(column));

  $$DoctorsTableOrderingComposer get doctorId {
    final $$DoctorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.doctorId,
        referencedTable: $db.doctors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DoctorsTableOrderingComposer(
              $db: $db,
              $table: $db.doctors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<bool> get isBooked =>
      $composableBuilder(column: $table.isBooked, builder: (column) => column);

  $$DoctorsTableAnnotationComposer get doctorId {
    final $$DoctorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.doctorId,
        referencedTable: $db.doctors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DoctorsTableAnnotationComposer(
              $db: $db,
              $table: $db.doctors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> appointmentsRefs<T extends Object>(
      Expression<T> Function($$AppointmentsTableAnnotationComposer a) f) {
    final $$AppointmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.appointments,
        getReferencedColumn: (t) => t.scheduleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AppointmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.appointments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SchedulesTable,
    DbSchedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (DbSchedule, $$SchedulesTableReferences),
    DbSchedule,
    PrefetchHooks Function({bool doctorId, bool appointmentsRefs})> {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> doctorId = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> startTime = const Value.absent(),
            Value<String> endTime = const Value.absent(),
            Value<bool> isBooked = const Value.absent(),
          }) =>
              SchedulesCompanion(
            id: id,
            doctorId: doctorId,
            date: date,
            startTime: startTime,
            endTime: endTime,
            isBooked: isBooked,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int doctorId,
            required String date,
            required String startTime,
            required String endTime,
            Value<bool> isBooked = const Value.absent(),
          }) =>
              SchedulesCompanion.insert(
            id: id,
            doctorId: doctorId,
            date: date,
            startTime: startTime,
            endTime: endTime,
            isBooked: isBooked,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SchedulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {doctorId = false, appointmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (appointmentsRefs) db.appointments],
              addJoins: <
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
                      dynamic>>(state) {
                if (doctorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.doctorId,
                    referencedTable:
                        $$SchedulesTableReferences._doctorIdTable(db),
                    referencedColumn:
                        $$SchedulesTableReferences._doctorIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (appointmentsRefs)
                    await $_getPrefetchedData<DbSchedule, $SchedulesTable,
                            DbAppointment>(
                        currentTable: table,
                        referencedTable: $$SchedulesTableReferences
                            ._appointmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SchedulesTableReferences(db, table, p0)
                                .appointmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.scheduleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SchedulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SchedulesTable,
    DbSchedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableAnnotationComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder,
    (DbSchedule, $$SchedulesTableReferences),
    DbSchedule,
    PrefetchHooks Function({bool doctorId, bool appointmentsRefs})>;
typedef $$AppointmentsTableCreateCompanionBuilder = AppointmentsCompanion
    Function({
  Value<int> id,
  required int userId,
  required int doctorId,
  required int scheduleId,
  Value<String> symptom,
  Value<String> status,
  required String createdAt,
});
typedef $$AppointmentsTableUpdateCompanionBuilder = AppointmentsCompanion
    Function({
  Value<int> id,
  Value<int> userId,
  Value<int> doctorId,
  Value<int> scheduleId,
  Value<String> symptom,
  Value<String> status,
  Value<String> createdAt,
});

final class $$AppointmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AppointmentsTable, DbAppointment> {
  $$AppointmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users
      .createAlias($_aliasNameGenerator(db.appointments.userId, db.users.id));

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $DoctorsTable _doctorIdTable(_$AppDatabase db) =>
      db.doctors.createAlias(
          $_aliasNameGenerator(db.appointments.doctorId, db.doctors.id));

  $$DoctorsTableProcessedTableManager get doctorId {
    final $_column = $_itemColumn<int>('doctor_id')!;

    final manager = $$DoctorsTableTableManager($_db, $_db.doctors)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_doctorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SchedulesTable _scheduleIdTable(_$AppDatabase db) =>
      db.schedules.createAlias(
          $_aliasNameGenerator(db.appointments.scheduleId, db.schedules.id));

  $$SchedulesTableProcessedTableManager get scheduleId {
    final $_column = $_itemColumn<int>('schedule_id')!;

    final manager = $$SchedulesTableTableManager($_db, $_db.schedules)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symptom => $composableBuilder(
      column: $table.symptom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DoctorsTableFilterComposer get doctorId {
    final $$DoctorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.doctorId,
        referencedTable: $db.doctors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DoctorsTableFilterComposer(
              $db: $db,
              $table: $db.doctors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SchedulesTableFilterComposer get scheduleId {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleId,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableFilterComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symptom => $composableBuilder(
      column: $table.symptom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DoctorsTableOrderingComposer get doctorId {
    final $$DoctorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.doctorId,
        referencedTable: $db.doctors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DoctorsTableOrderingComposer(
              $db: $db,
              $table: $db.doctors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SchedulesTableOrderingComposer get scheduleId {
    final $$SchedulesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleId,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableOrderingComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symptom =>
      $composableBuilder(column: $table.symptom, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DoctorsTableAnnotationComposer get doctorId {
    final $$DoctorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.doctorId,
        referencedTable: $db.doctors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DoctorsTableAnnotationComposer(
              $db: $db,
              $table: $db.doctors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SchedulesTableAnnotationComposer get scheduleId {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleId,
        referencedTable: $db.schedules,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SchedulesTableAnnotationComposer(
              $db: $db,
              $table: $db.schedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AppointmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppointmentsTable,
    DbAppointment,
    $$AppointmentsTableFilterComposer,
    $$AppointmentsTableOrderingComposer,
    $$AppointmentsTableAnnotationComposer,
    $$AppointmentsTableCreateCompanionBuilder,
    $$AppointmentsTableUpdateCompanionBuilder,
    (DbAppointment, $$AppointmentsTableReferences),
    DbAppointment,
    PrefetchHooks Function({bool userId, bool doctorId, bool scheduleId})> {
  $$AppointmentsTableTableManager(_$AppDatabase db, $AppointmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<int> doctorId = const Value.absent(),
            Value<int> scheduleId = const Value.absent(),
            Value<String> symptom = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
          }) =>
              AppointmentsCompanion(
            id: id,
            userId: userId,
            doctorId: doctorId,
            scheduleId: scheduleId,
            symptom: symptom,
            status: status,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            required int doctorId,
            required int scheduleId,
            Value<String> symptom = const Value.absent(),
            Value<String> status = const Value.absent(),
            required String createdAt,
          }) =>
              AppointmentsCompanion.insert(
            id: id,
            userId: userId,
            doctorId: doctorId,
            scheduleId: scheduleId,
            symptom: symptom,
            status: status,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AppointmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {userId = false, doctorId = false, scheduleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$AppointmentsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$AppointmentsTableReferences._userIdTable(db).id,
                  ) as T;
                }
                if (doctorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.doctorId,
                    referencedTable:
                        $$AppointmentsTableReferences._doctorIdTable(db),
                    referencedColumn:
                        $$AppointmentsTableReferences._doctorIdTable(db).id,
                  ) as T;
                }
                if (scheduleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.scheduleId,
                    referencedTable:
                        $$AppointmentsTableReferences._scheduleIdTable(db),
                    referencedColumn:
                        $$AppointmentsTableReferences._scheduleIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AppointmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppointmentsTable,
    DbAppointment,
    $$AppointmentsTableFilterComposer,
    $$AppointmentsTableOrderingComposer,
    $$AppointmentsTableAnnotationComposer,
    $$AppointmentsTableCreateCompanionBuilder,
    $$AppointmentsTableUpdateCompanionBuilder,
    (DbAppointment, $$AppointmentsTableReferences),
    DbAppointment,
    PrefetchHooks Function({bool userId, bool doctorId, bool scheduleId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$DoctorsTableTableManager get doctors =>
      $$DoctorsTableTableManager(_db, _db.doctors);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db, _db.appointments);
}
