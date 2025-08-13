// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AssessorInfosTable extends AssessorInfos
    with TableInfo<$AssessorInfosTable, AssessorInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssessorInfosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessmentDateMeta = const VerificationMeta(
    'assessmentDate',
  );
  @override
  late final GeneratedColumn<DateTime> assessmentDate =
      GeneratedColumn<DateTime>(
        'assessment_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    phoneNumber,
    assessmentDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessor_infos';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssessorInfoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('assessment_date')) {
      context.handle(
        _assessmentDateMeta,
        assessmentDate.isAcceptableOrUnknown(
          data['assessment_date']!,
          _assessmentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssessorInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssessorInfoData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      email:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}email'],
          )!,
      phoneNumber:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}phone_number'],
          )!,
      assessmentDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}assessment_date'],
          )!,
    );
  }

  @override
  $AssessorInfosTable createAlias(String alias) {
    return $AssessorInfosTable(attachedDatabase, alias);
  }
}

class AssessorInfoData extends DataClass
    implements Insertable<AssessorInfoData> {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final DateTime assessmentDate;
  const AssessorInfoData({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.assessmentDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['assessment_date'] = Variable<DateTime>(assessmentDate);
    return map;
  }

  AssessorInfosCompanion toCompanion(bool nullToAbsent) {
    return AssessorInfosCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      phoneNumber: Value(phoneNumber),
      assessmentDate: Value(assessmentDate),
    );
  }

  factory AssessorInfoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssessorInfoData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      assessmentDate: serializer.fromJson<DateTime>(json['assessmentDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'assessmentDate': serializer.toJson<DateTime>(assessmentDate),
    };
  }

  AssessorInfoData copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    DateTime? assessmentDate,
  }) => AssessorInfoData(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    assessmentDate: assessmentDate ?? this.assessmentDate,
  );
  AssessorInfoData copyWithCompanion(AssessorInfosCompanion data) {
    return AssessorInfoData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      assessmentDate:
          data.assessmentDate.present
              ? data.assessmentDate.value
              : this.assessmentDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssessorInfoData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('assessmentDate: $assessmentDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, phoneNumber, assessmentDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssessorInfoData &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.phoneNumber == this.phoneNumber &&
          other.assessmentDate == this.assessmentDate);
}

class AssessorInfosCompanion extends UpdateCompanion<AssessorInfoData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> phoneNumber;
  final Value<DateTime> assessmentDate;
  final Value<int> rowid;
  const AssessorInfosCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.assessmentDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssessorInfosCompanion.insert({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    required DateTime assessmentDate,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       email = Value(email),
       phoneNumber = Value(phoneNumber),
       assessmentDate = Value(assessmentDate);
  static Insertable<AssessorInfoData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? phoneNumber,
    Expression<DateTime>? assessmentDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (assessmentDate != null) 'assessment_date': assessmentDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssessorInfosCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String>? phoneNumber,
    Value<DateTime>? assessmentDate,
    Value<int>? rowid,
  }) {
    return AssessorInfosCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      assessmentDate: assessmentDate ?? this.assessmentDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (assessmentDate.present) {
      map['assessment_date'] = Variable<DateTime>(assessmentDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessorInfosCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('assessmentDate: $assessmentDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeoLocationsTable extends GeoLocations
    with TableInfo<$GeoLocationsTable, GeoLocationData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeoLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionProvinceMeta = const VerificationMeta(
    'regionProvince',
  );
  @override
  late final GeneratedColumn<String> regionProvince = GeneratedColumn<String>(
    'region_province',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cityVillageMeta = const VerificationMeta(
    'cityVillage',
  );
  @override
  late final GeneratedColumn<String> cityVillage = GeneratedColumn<String>(
    'city_village',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressOrCoordinatesMeta =
      const VerificationMeta('addressOrCoordinates');
  @override
  late final GeneratedColumn<String> addressOrCoordinates =
      GeneratedColumn<String>(
        'address_or_coordinates',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _locationTypeMeta = const VerificationMeta(
    'locationType',
  );
  @override
  late final GeneratedColumn<String> locationType = GeneratedColumn<String>(
    'location_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    country,
    regionProvince,
    district,
    cityVillage,
    addressOrCoordinates,
    locationType,
    latitude,
    longitude,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'geo_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeoLocationData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('region_province')) {
      context.handle(
        _regionProvinceMeta,
        regionProvince.isAcceptableOrUnknown(
          data['region_province']!,
          _regionProvinceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_regionProvinceMeta);
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    } else if (isInserting) {
      context.missing(_districtMeta);
    }
    if (data.containsKey('city_village')) {
      context.handle(
        _cityVillageMeta,
        cityVillage.isAcceptableOrUnknown(
          data['city_village']!,
          _cityVillageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cityVillageMeta);
    }
    if (data.containsKey('address_or_coordinates')) {
      context.handle(
        _addressOrCoordinatesMeta,
        addressOrCoordinates.isAcceptableOrUnknown(
          data['address_or_coordinates']!,
          _addressOrCoordinatesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_addressOrCoordinatesMeta);
    }
    if (data.containsKey('location_type')) {
      context.handle(
        _locationTypeMeta,
        locationType.isAcceptableOrUnknown(
          data['location_type']!,
          _locationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationTypeMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeoLocationData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeoLocationData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      country:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}country'],
          )!,
      regionProvince:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}region_province'],
          )!,
      district:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}district'],
          )!,
      cityVillage:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}city_village'],
          )!,
      addressOrCoordinates:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}address_or_coordinates'],
          )!,
      locationType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}location_type'],
          )!,
      latitude:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}latitude'],
          )!,
      longitude:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}longitude'],
          )!,
    );
  }

  @override
  $GeoLocationsTable createAlias(String alias) {
    return $GeoLocationsTable(attachedDatabase, alias);
  }
}

class GeoLocationData extends DataClass implements Insertable<GeoLocationData> {
  final String id;
  final String country;
  final String regionProvince;
  final String district;
  final String cityVillage;
  final String addressOrCoordinates;
  final String locationType;
  final double latitude;
  final double longitude;
  const GeoLocationData({
    required this.id,
    required this.country,
    required this.regionProvince,
    required this.district,
    required this.cityVillage,
    required this.addressOrCoordinates,
    required this.locationType,
    required this.latitude,
    required this.longitude,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['country'] = Variable<String>(country);
    map['region_province'] = Variable<String>(regionProvince);
    map['district'] = Variable<String>(district);
    map['city_village'] = Variable<String>(cityVillage);
    map['address_or_coordinates'] = Variable<String>(addressOrCoordinates);
    map['location_type'] = Variable<String>(locationType);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    return map;
  }

  GeoLocationsCompanion toCompanion(bool nullToAbsent) {
    return GeoLocationsCompanion(
      id: Value(id),
      country: Value(country),
      regionProvince: Value(regionProvince),
      district: Value(district),
      cityVillage: Value(cityVillage),
      addressOrCoordinates: Value(addressOrCoordinates),
      locationType: Value(locationType),
      latitude: Value(latitude),
      longitude: Value(longitude),
    );
  }

  factory GeoLocationData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeoLocationData(
      id: serializer.fromJson<String>(json['id']),
      country: serializer.fromJson<String>(json['country']),
      regionProvince: serializer.fromJson<String>(json['regionProvince']),
      district: serializer.fromJson<String>(json['district']),
      cityVillage: serializer.fromJson<String>(json['cityVillage']),
      addressOrCoordinates: serializer.fromJson<String>(
        json['addressOrCoordinates'],
      ),
      locationType: serializer.fromJson<String>(json['locationType']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'country': serializer.toJson<String>(country),
      'regionProvince': serializer.toJson<String>(regionProvince),
      'district': serializer.toJson<String>(district),
      'cityVillage': serializer.toJson<String>(cityVillage),
      'addressOrCoordinates': serializer.toJson<String>(addressOrCoordinates),
      'locationType': serializer.toJson<String>(locationType),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
    };
  }

  GeoLocationData copyWith({
    String? id,
    String? country,
    String? regionProvince,
    String? district,
    String? cityVillage,
    String? addressOrCoordinates,
    String? locationType,
    double? latitude,
    double? longitude,
  }) => GeoLocationData(
    id: id ?? this.id,
    country: country ?? this.country,
    regionProvince: regionProvince ?? this.regionProvince,
    district: district ?? this.district,
    cityVillage: cityVillage ?? this.cityVillage,
    addressOrCoordinates: addressOrCoordinates ?? this.addressOrCoordinates,
    locationType: locationType ?? this.locationType,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
  );
  GeoLocationData copyWithCompanion(GeoLocationsCompanion data) {
    return GeoLocationData(
      id: data.id.present ? data.id.value : this.id,
      country: data.country.present ? data.country.value : this.country,
      regionProvince:
          data.regionProvince.present
              ? data.regionProvince.value
              : this.regionProvince,
      district: data.district.present ? data.district.value : this.district,
      cityVillage:
          data.cityVillage.present ? data.cityVillage.value : this.cityVillage,
      addressOrCoordinates:
          data.addressOrCoordinates.present
              ? data.addressOrCoordinates.value
              : this.addressOrCoordinates,
      locationType:
          data.locationType.present
              ? data.locationType.value
              : this.locationType,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeoLocationData(')
          ..write('id: $id, ')
          ..write('country: $country, ')
          ..write('regionProvince: $regionProvince, ')
          ..write('district: $district, ')
          ..write('cityVillage: $cityVillage, ')
          ..write('addressOrCoordinates: $addressOrCoordinates, ')
          ..write('locationType: $locationType, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    country,
    regionProvince,
    district,
    cityVillage,
    addressOrCoordinates,
    locationType,
    latitude,
    longitude,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeoLocationData &&
          other.id == this.id &&
          other.country == this.country &&
          other.regionProvince == this.regionProvince &&
          other.district == this.district &&
          other.cityVillage == this.cityVillage &&
          other.addressOrCoordinates == this.addressOrCoordinates &&
          other.locationType == this.locationType &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class GeoLocationsCompanion extends UpdateCompanion<GeoLocationData> {
  final Value<String> id;
  final Value<String> country;
  final Value<String> regionProvince;
  final Value<String> district;
  final Value<String> cityVillage;
  final Value<String> addressOrCoordinates;
  final Value<String> locationType;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<int> rowid;
  const GeoLocationsCompanion({
    this.id = const Value.absent(),
    this.country = const Value.absent(),
    this.regionProvince = const Value.absent(),
    this.district = const Value.absent(),
    this.cityVillage = const Value.absent(),
    this.addressOrCoordinates = const Value.absent(),
    this.locationType = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeoLocationsCompanion.insert({
    required String id,
    required String country,
    required String regionProvince,
    required String district,
    required String cityVillage,
    required String addressOrCoordinates,
    required String locationType,
    required double latitude,
    required double longitude,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       country = Value(country),
       regionProvince = Value(regionProvince),
       district = Value(district),
       cityVillage = Value(cityVillage),
       addressOrCoordinates = Value(addressOrCoordinates),
       locationType = Value(locationType),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<GeoLocationData> custom({
    Expression<String>? id,
    Expression<String>? country,
    Expression<String>? regionProvince,
    Expression<String>? district,
    Expression<String>? cityVillage,
    Expression<String>? addressOrCoordinates,
    Expression<String>? locationType,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (country != null) 'country': country,
      if (regionProvince != null) 'region_province': regionProvince,
      if (district != null) 'district': district,
      if (cityVillage != null) 'city_village': cityVillage,
      if (addressOrCoordinates != null)
        'address_or_coordinates': addressOrCoordinates,
      if (locationType != null) 'location_type': locationType,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeoLocationsCompanion copyWith({
    Value<String>? id,
    Value<String>? country,
    Value<String>? regionProvince,
    Value<String>? district,
    Value<String>? cityVillage,
    Value<String>? addressOrCoordinates,
    Value<String>? locationType,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<int>? rowid,
  }) {
    return GeoLocationsCompanion(
      id: id ?? this.id,
      country: country ?? this.country,
      regionProvince: regionProvince ?? this.regionProvince,
      district: district ?? this.district,
      cityVillage: cityVillage ?? this.cityVillage,
      addressOrCoordinates: addressOrCoordinates ?? this.addressOrCoordinates,
      locationType: locationType ?? this.locationType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (regionProvince.present) {
      map['region_province'] = Variable<String>(regionProvince.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (cityVillage.present) {
      map['city_village'] = Variable<String>(cityVillage.value);
    }
    if (addressOrCoordinates.present) {
      map['address_or_coordinates'] = Variable<String>(
        addressOrCoordinates.value,
      );
    }
    if (locationType.present) {
      map['location_type'] = Variable<String>(locationType.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeoLocationsCompanion(')
          ..write('id: $id, ')
          ..write('country: $country, ')
          ..write('regionProvince: $regionProvince, ')
          ..write('district: $district, ')
          ..write('cityVillage: $cityVillage, ')
          ..write('addressOrCoordinates: $addressOrCoordinates, ')
          ..write('locationType: $locationType, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FacilityIdentificationsTable extends FacilityIdentifications
    with TableInfo<$FacilityIdentificationsTable, FacilityIdentificationData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FacilityIdentificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facilityCodeMeta = const VerificationMeta(
    'facilityCode',
  );
  @override
  late final GeneratedColumn<String> facilityCode = GeneratedColumn<String>(
    'facility_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facilityNameMeta = const VerificationMeta(
    'facilityName',
  );
  @override
  late final GeneratedColumn<String> facilityName = GeneratedColumn<String>(
    'facility_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _managingAuthorityMeta = const VerificationMeta(
    'managingAuthority',
  );
  @override
  late final GeneratedColumn<String> managingAuthority =
      GeneratedColumn<String>(
        'managing_authority',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _directorNameMeta = const VerificationMeta(
    'directorName',
  );
  @override
  late final GeneratedColumn<String> directorName = GeneratedColumn<String>(
    'director_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directorPhoneMeta = const VerificationMeta(
    'directorPhone',
  );
  @override
  late final GeneratedColumn<String> directorPhone = GeneratedColumn<String>(
    'director_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directorEmailMeta = const VerificationMeta(
    'directorEmail',
  );
  @override
  late final GeneratedColumn<String> directorEmail = GeneratedColumn<String>(
    'director_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respondentNameMeta = const VerificationMeta(
    'respondentName',
  );
  @override
  late final GeneratedColumn<String> respondentName = GeneratedColumn<String>(
    'respondent_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respondentPositionMeta =
      const VerificationMeta('respondentPosition');
  @override
  late final GeneratedColumn<String> respondentPosition =
      GeneratedColumn<String>(
        'respondent_position',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _structureTypeMeta = const VerificationMeta(
    'structureType',
  );
  @override
  late final GeneratedColumn<String> structureType = GeneratedColumn<String>(
    'structure_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facilityTypeMeta = const VerificationMeta(
    'facilityType',
  );
  @override
  late final GeneratedColumn<String> facilityType = GeneratedColumn<String>(
    'facility_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _existingFacilityTypeMeta =
      const VerificationMeta('existingFacilityType');
  @override
  late final GeneratedColumn<String> existingFacilityType =
      GeneratedColumn<String>(
        'existing_facility_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _otherExistingFacitlityTypeMeta =
      const VerificationMeta('otherExistingFacitlityType');
  @override
  late final GeneratedColumn<String> otherExistingFacitlityType =
      GeneratedColumn<String>(
        'other_existing_facitlity_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    facilityCode,
    facilityName,
    managingAuthority,
    directorName,
    directorPhone,
    directorEmail,
    respondentName,
    respondentPosition,
    structureType,
    facilityType,
    existingFacilityType,
    otherExistingFacitlityType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'facility_identifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<FacilityIdentificationData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('facility_code')) {
      context.handle(
        _facilityCodeMeta,
        facilityCode.isAcceptableOrUnknown(
          data['facility_code']!,
          _facilityCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_facilityCodeMeta);
    }
    if (data.containsKey('facility_name')) {
      context.handle(
        _facilityNameMeta,
        facilityName.isAcceptableOrUnknown(
          data['facility_name']!,
          _facilityNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_facilityNameMeta);
    }
    if (data.containsKey('managing_authority')) {
      context.handle(
        _managingAuthorityMeta,
        managingAuthority.isAcceptableOrUnknown(
          data['managing_authority']!,
          _managingAuthorityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_managingAuthorityMeta);
    }
    if (data.containsKey('director_name')) {
      context.handle(
        _directorNameMeta,
        directorName.isAcceptableOrUnknown(
          data['director_name']!,
          _directorNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directorNameMeta);
    }
    if (data.containsKey('director_phone')) {
      context.handle(
        _directorPhoneMeta,
        directorPhone.isAcceptableOrUnknown(
          data['director_phone']!,
          _directorPhoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directorPhoneMeta);
    }
    if (data.containsKey('director_email')) {
      context.handle(
        _directorEmailMeta,
        directorEmail.isAcceptableOrUnknown(
          data['director_email']!,
          _directorEmailMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directorEmailMeta);
    }
    if (data.containsKey('respondent_name')) {
      context.handle(
        _respondentNameMeta,
        respondentName.isAcceptableOrUnknown(
          data['respondent_name']!,
          _respondentNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_respondentNameMeta);
    }
    if (data.containsKey('respondent_position')) {
      context.handle(
        _respondentPositionMeta,
        respondentPosition.isAcceptableOrUnknown(
          data['respondent_position']!,
          _respondentPositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_respondentPositionMeta);
    }
    if (data.containsKey('structure_type')) {
      context.handle(
        _structureTypeMeta,
        structureType.isAcceptableOrUnknown(
          data['structure_type']!,
          _structureTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_structureTypeMeta);
    }
    if (data.containsKey('facility_type')) {
      context.handle(
        _facilityTypeMeta,
        facilityType.isAcceptableOrUnknown(
          data['facility_type']!,
          _facilityTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_facilityTypeMeta);
    }
    if (data.containsKey('existing_facility_type')) {
      context.handle(
        _existingFacilityTypeMeta,
        existingFacilityType.isAcceptableOrUnknown(
          data['existing_facility_type']!,
          _existingFacilityTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_existingFacilityTypeMeta);
    }
    if (data.containsKey('other_existing_facitlity_type')) {
      context.handle(
        _otherExistingFacitlityTypeMeta,
        otherExistingFacitlityType.isAcceptableOrUnknown(
          data['other_existing_facitlity_type']!,
          _otherExistingFacitlityTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FacilityIdentificationData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FacilityIdentificationData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      facilityCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}facility_code'],
          )!,
      facilityName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}facility_name'],
          )!,
      managingAuthority:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}managing_authority'],
          )!,
      directorName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}director_name'],
          )!,
      directorPhone:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}director_phone'],
          )!,
      directorEmail:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}director_email'],
          )!,
      respondentName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}respondent_name'],
          )!,
      respondentPosition:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}respondent_position'],
          )!,
      structureType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}structure_type'],
          )!,
      facilityType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}facility_type'],
          )!,
      existingFacilityType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}existing_facility_type'],
          )!,
      otherExistingFacitlityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}other_existing_facitlity_type'],
      ),
    );
  }

  @override
  $FacilityIdentificationsTable createAlias(String alias) {
    return $FacilityIdentificationsTable(attachedDatabase, alias);
  }
}

class FacilityIdentificationData extends DataClass
    implements Insertable<FacilityIdentificationData> {
  final String id;
  final String facilityCode;
  final String facilityName;
  final String managingAuthority;
  final String directorName;
  final String directorPhone;
  final String directorEmail;
  final String respondentName;
  final String respondentPosition;
  final String structureType;
  final String facilityType;
  final String existingFacilityType;
  final String? otherExistingFacitlityType;
  const FacilityIdentificationData({
    required this.id,
    required this.facilityCode,
    required this.facilityName,
    required this.managingAuthority,
    required this.directorName,
    required this.directorPhone,
    required this.directorEmail,
    required this.respondentName,
    required this.respondentPosition,
    required this.structureType,
    required this.facilityType,
    required this.existingFacilityType,
    this.otherExistingFacitlityType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['facility_code'] = Variable<String>(facilityCode);
    map['facility_name'] = Variable<String>(facilityName);
    map['managing_authority'] = Variable<String>(managingAuthority);
    map['director_name'] = Variable<String>(directorName);
    map['director_phone'] = Variable<String>(directorPhone);
    map['director_email'] = Variable<String>(directorEmail);
    map['respondent_name'] = Variable<String>(respondentName);
    map['respondent_position'] = Variable<String>(respondentPosition);
    map['structure_type'] = Variable<String>(structureType);
    map['facility_type'] = Variable<String>(facilityType);
    map['existing_facility_type'] = Variable<String>(existingFacilityType);
    if (!nullToAbsent || otherExistingFacitlityType != null) {
      map['other_existing_facitlity_type'] = Variable<String>(
        otherExistingFacitlityType,
      );
    }
    return map;
  }

  FacilityIdentificationsCompanion toCompanion(bool nullToAbsent) {
    return FacilityIdentificationsCompanion(
      id: Value(id),
      facilityCode: Value(facilityCode),
      facilityName: Value(facilityName),
      managingAuthority: Value(managingAuthority),
      directorName: Value(directorName),
      directorPhone: Value(directorPhone),
      directorEmail: Value(directorEmail),
      respondentName: Value(respondentName),
      respondentPosition: Value(respondentPosition),
      structureType: Value(structureType),
      facilityType: Value(facilityType),
      existingFacilityType: Value(existingFacilityType),
      otherExistingFacitlityType:
          otherExistingFacitlityType == null && nullToAbsent
              ? const Value.absent()
              : Value(otherExistingFacitlityType),
    );
  }

  factory FacilityIdentificationData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FacilityIdentificationData(
      id: serializer.fromJson<String>(json['id']),
      facilityCode: serializer.fromJson<String>(json['facilityCode']),
      facilityName: serializer.fromJson<String>(json['facilityName']),
      managingAuthority: serializer.fromJson<String>(json['managingAuthority']),
      directorName: serializer.fromJson<String>(json['directorName']),
      directorPhone: serializer.fromJson<String>(json['directorPhone']),
      directorEmail: serializer.fromJson<String>(json['directorEmail']),
      respondentName: serializer.fromJson<String>(json['respondentName']),
      respondentPosition: serializer.fromJson<String>(
        json['respondentPosition'],
      ),
      structureType: serializer.fromJson<String>(json['structureType']),
      facilityType: serializer.fromJson<String>(json['facilityType']),
      existingFacilityType: serializer.fromJson<String>(
        json['existingFacilityType'],
      ),
      otherExistingFacitlityType: serializer.fromJson<String?>(
        json['otherExistingFacitlityType'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'facilityCode': serializer.toJson<String>(facilityCode),
      'facilityName': serializer.toJson<String>(facilityName),
      'managingAuthority': serializer.toJson<String>(managingAuthority),
      'directorName': serializer.toJson<String>(directorName),
      'directorPhone': serializer.toJson<String>(directorPhone),
      'directorEmail': serializer.toJson<String>(directorEmail),
      'respondentName': serializer.toJson<String>(respondentName),
      'respondentPosition': serializer.toJson<String>(respondentPosition),
      'structureType': serializer.toJson<String>(structureType),
      'facilityType': serializer.toJson<String>(facilityType),
      'existingFacilityType': serializer.toJson<String>(existingFacilityType),
      'otherExistingFacitlityType': serializer.toJson<String?>(
        otherExistingFacitlityType,
      ),
    };
  }

  FacilityIdentificationData copyWith({
    String? id,
    String? facilityCode,
    String? facilityName,
    String? managingAuthority,
    String? directorName,
    String? directorPhone,
    String? directorEmail,
    String? respondentName,
    String? respondentPosition,
    String? structureType,
    String? facilityType,
    String? existingFacilityType,
    Value<String?> otherExistingFacitlityType = const Value.absent(),
  }) => FacilityIdentificationData(
    id: id ?? this.id,
    facilityCode: facilityCode ?? this.facilityCode,
    facilityName: facilityName ?? this.facilityName,
    managingAuthority: managingAuthority ?? this.managingAuthority,
    directorName: directorName ?? this.directorName,
    directorPhone: directorPhone ?? this.directorPhone,
    directorEmail: directorEmail ?? this.directorEmail,
    respondentName: respondentName ?? this.respondentName,
    respondentPosition: respondentPosition ?? this.respondentPosition,
    structureType: structureType ?? this.structureType,
    facilityType: facilityType ?? this.facilityType,
    existingFacilityType: existingFacilityType ?? this.existingFacilityType,
    otherExistingFacitlityType:
        otherExistingFacitlityType.present
            ? otherExistingFacitlityType.value
            : this.otherExistingFacitlityType,
  );
  FacilityIdentificationData copyWithCompanion(
    FacilityIdentificationsCompanion data,
  ) {
    return FacilityIdentificationData(
      id: data.id.present ? data.id.value : this.id,
      facilityCode:
          data.facilityCode.present
              ? data.facilityCode.value
              : this.facilityCode,
      facilityName:
          data.facilityName.present
              ? data.facilityName.value
              : this.facilityName,
      managingAuthority:
          data.managingAuthority.present
              ? data.managingAuthority.value
              : this.managingAuthority,
      directorName:
          data.directorName.present
              ? data.directorName.value
              : this.directorName,
      directorPhone:
          data.directorPhone.present
              ? data.directorPhone.value
              : this.directorPhone,
      directorEmail:
          data.directorEmail.present
              ? data.directorEmail.value
              : this.directorEmail,
      respondentName:
          data.respondentName.present
              ? data.respondentName.value
              : this.respondentName,
      respondentPosition:
          data.respondentPosition.present
              ? data.respondentPosition.value
              : this.respondentPosition,
      structureType:
          data.structureType.present
              ? data.structureType.value
              : this.structureType,
      facilityType:
          data.facilityType.present
              ? data.facilityType.value
              : this.facilityType,
      existingFacilityType:
          data.existingFacilityType.present
              ? data.existingFacilityType.value
              : this.existingFacilityType,
      otherExistingFacitlityType:
          data.otherExistingFacitlityType.present
              ? data.otherExistingFacitlityType.value
              : this.otherExistingFacitlityType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FacilityIdentificationData(')
          ..write('id: $id, ')
          ..write('facilityCode: $facilityCode, ')
          ..write('facilityName: $facilityName, ')
          ..write('managingAuthority: $managingAuthority, ')
          ..write('directorName: $directorName, ')
          ..write('directorPhone: $directorPhone, ')
          ..write('directorEmail: $directorEmail, ')
          ..write('respondentName: $respondentName, ')
          ..write('respondentPosition: $respondentPosition, ')
          ..write('structureType: $structureType, ')
          ..write('facilityType: $facilityType, ')
          ..write('existingFacilityType: $existingFacilityType, ')
          ..write('otherExistingFacitlityType: $otherExistingFacitlityType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    facilityCode,
    facilityName,
    managingAuthority,
    directorName,
    directorPhone,
    directorEmail,
    respondentName,
    respondentPosition,
    structureType,
    facilityType,
    existingFacilityType,
    otherExistingFacitlityType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FacilityIdentificationData &&
          other.id == this.id &&
          other.facilityCode == this.facilityCode &&
          other.facilityName == this.facilityName &&
          other.managingAuthority == this.managingAuthority &&
          other.directorName == this.directorName &&
          other.directorPhone == this.directorPhone &&
          other.directorEmail == this.directorEmail &&
          other.respondentName == this.respondentName &&
          other.respondentPosition == this.respondentPosition &&
          other.structureType == this.structureType &&
          other.facilityType == this.facilityType &&
          other.existingFacilityType == this.existingFacilityType &&
          other.otherExistingFacitlityType == this.otherExistingFacitlityType);
}

class FacilityIdentificationsCompanion
    extends UpdateCompanion<FacilityIdentificationData> {
  final Value<String> id;
  final Value<String> facilityCode;
  final Value<String> facilityName;
  final Value<String> managingAuthority;
  final Value<String> directorName;
  final Value<String> directorPhone;
  final Value<String> directorEmail;
  final Value<String> respondentName;
  final Value<String> respondentPosition;
  final Value<String> structureType;
  final Value<String> facilityType;
  final Value<String> existingFacilityType;
  final Value<String?> otherExistingFacitlityType;
  final Value<int> rowid;
  const FacilityIdentificationsCompanion({
    this.id = const Value.absent(),
    this.facilityCode = const Value.absent(),
    this.facilityName = const Value.absent(),
    this.managingAuthority = const Value.absent(),
    this.directorName = const Value.absent(),
    this.directorPhone = const Value.absent(),
    this.directorEmail = const Value.absent(),
    this.respondentName = const Value.absent(),
    this.respondentPosition = const Value.absent(),
    this.structureType = const Value.absent(),
    this.facilityType = const Value.absent(),
    this.existingFacilityType = const Value.absent(),
    this.otherExistingFacitlityType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FacilityIdentificationsCompanion.insert({
    required String id,
    required String facilityCode,
    required String facilityName,
    required String managingAuthority,
    required String directorName,
    required String directorPhone,
    required String directorEmail,
    required String respondentName,
    required String respondentPosition,
    required String structureType,
    required String facilityType,
    required String existingFacilityType,
    this.otherExistingFacitlityType = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       facilityCode = Value(facilityCode),
       facilityName = Value(facilityName),
       managingAuthority = Value(managingAuthority),
       directorName = Value(directorName),
       directorPhone = Value(directorPhone),
       directorEmail = Value(directorEmail),
       respondentName = Value(respondentName),
       respondentPosition = Value(respondentPosition),
       structureType = Value(structureType),
       facilityType = Value(facilityType),
       existingFacilityType = Value(existingFacilityType);
  static Insertable<FacilityIdentificationData> custom({
    Expression<String>? id,
    Expression<String>? facilityCode,
    Expression<String>? facilityName,
    Expression<String>? managingAuthority,
    Expression<String>? directorName,
    Expression<String>? directorPhone,
    Expression<String>? directorEmail,
    Expression<String>? respondentName,
    Expression<String>? respondentPosition,
    Expression<String>? structureType,
    Expression<String>? facilityType,
    Expression<String>? existingFacilityType,
    Expression<String>? otherExistingFacitlityType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (facilityCode != null) 'facility_code': facilityCode,
      if (facilityName != null) 'facility_name': facilityName,
      if (managingAuthority != null) 'managing_authority': managingAuthority,
      if (directorName != null) 'director_name': directorName,
      if (directorPhone != null) 'director_phone': directorPhone,
      if (directorEmail != null) 'director_email': directorEmail,
      if (respondentName != null) 'respondent_name': respondentName,
      if (respondentPosition != null) 'respondent_position': respondentPosition,
      if (structureType != null) 'structure_type': structureType,
      if (facilityType != null) 'facility_type': facilityType,
      if (existingFacilityType != null)
        'existing_facility_type': existingFacilityType,
      if (otherExistingFacitlityType != null)
        'other_existing_facitlity_type': otherExistingFacitlityType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FacilityIdentificationsCompanion copyWith({
    Value<String>? id,
    Value<String>? facilityCode,
    Value<String>? facilityName,
    Value<String>? managingAuthority,
    Value<String>? directorName,
    Value<String>? directorPhone,
    Value<String>? directorEmail,
    Value<String>? respondentName,
    Value<String>? respondentPosition,
    Value<String>? structureType,
    Value<String>? facilityType,
    Value<String>? existingFacilityType,
    Value<String?>? otherExistingFacitlityType,
    Value<int>? rowid,
  }) {
    return FacilityIdentificationsCompanion(
      id: id ?? this.id,
      facilityCode: facilityCode ?? this.facilityCode,
      facilityName: facilityName ?? this.facilityName,
      managingAuthority: managingAuthority ?? this.managingAuthority,
      directorName: directorName ?? this.directorName,
      directorPhone: directorPhone ?? this.directorPhone,
      directorEmail: directorEmail ?? this.directorEmail,
      respondentName: respondentName ?? this.respondentName,
      respondentPosition: respondentPosition ?? this.respondentPosition,
      structureType: structureType ?? this.structureType,
      facilityType: facilityType ?? this.facilityType,
      existingFacilityType: existingFacilityType ?? this.existingFacilityType,
      otherExistingFacitlityType:
          otherExistingFacitlityType ?? this.otherExistingFacitlityType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (facilityCode.present) {
      map['facility_code'] = Variable<String>(facilityCode.value);
    }
    if (facilityName.present) {
      map['facility_name'] = Variable<String>(facilityName.value);
    }
    if (managingAuthority.present) {
      map['managing_authority'] = Variable<String>(managingAuthority.value);
    }
    if (directorName.present) {
      map['director_name'] = Variable<String>(directorName.value);
    }
    if (directorPhone.present) {
      map['director_phone'] = Variable<String>(directorPhone.value);
    }
    if (directorEmail.present) {
      map['director_email'] = Variable<String>(directorEmail.value);
    }
    if (respondentName.present) {
      map['respondent_name'] = Variable<String>(respondentName.value);
    }
    if (respondentPosition.present) {
      map['respondent_position'] = Variable<String>(respondentPosition.value);
    }
    if (structureType.present) {
      map['structure_type'] = Variable<String>(structureType.value);
    }
    if (facilityType.present) {
      map['facility_type'] = Variable<String>(facilityType.value);
    }
    if (existingFacilityType.present) {
      map['existing_facility_type'] = Variable<String>(
        existingFacilityType.value,
      );
    }
    if (otherExistingFacitlityType.present) {
      map['other_existing_facitlity_type'] = Variable<String>(
        otherExistingFacitlityType.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FacilityIdentificationsCompanion(')
          ..write('id: $id, ')
          ..write('facilityCode: $facilityCode, ')
          ..write('facilityName: $facilityName, ')
          ..write('managingAuthority: $managingAuthority, ')
          ..write('directorName: $directorName, ')
          ..write('directorPhone: $directorPhone, ')
          ..write('directorEmail: $directorEmail, ')
          ..write('respondentName: $respondentName, ')
          ..write('respondentPosition: $respondentPosition, ')
          ..write('structureType: $structureType, ')
          ..write('facilityType: $facilityType, ')
          ..write('existingFacilityType: $existingFacilityType, ')
          ..write('otherExistingFacitlityType: $otherExistingFacitlityType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FacilityServicesTable extends FacilityServices
    with TableInfo<$FacilityServicesTable, FacilityServicesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FacilityServicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasOutpatientServicesMeta =
      const VerificationMeta('hasOutpatientServices');
  @override
  late final GeneratedColumn<bool> hasOutpatientServices =
      GeneratedColumn<bool>(
        'has_outpatient_services',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_outpatient_services" IN (0, 1))',
        ),
      );
  static const VerificationMeta _hasInpatientServicesMeta =
      const VerificationMeta('hasInpatientServices');
  @override
  late final GeneratedColumn<bool> hasInpatientServices = GeneratedColumn<bool>(
    'has_inpatient_services',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_inpatient_services" IN (0, 1))',
    ),
  );
  static const VerificationMeta _totalInpatientBedsMeta =
      const VerificationMeta('totalInpatientBeds');
  @override
  late final GeneratedColumn<int> totalInpatientBeds = GeneratedColumn<int>(
    'total_inpatient_beds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _icuBedsMeta = const VerificationMeta(
    'icuBeds',
  );
  @override
  late final GeneratedColumn<int> icuBeds = GeneratedColumn<int>(
    'icu_beds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasEmergencyUnitMeta = const VerificationMeta(
    'hasEmergencyUnit',
  );
  @override
  late final GeneratedColumn<bool> hasEmergencyUnit = GeneratedColumn<bool>(
    'has_emergency_unit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_emergency_unit" IN (0, 1))',
    ),
  );
  static const VerificationMeta _hasIcuOrHighDependencyUnitMeta =
      const VerificationMeta('hasIcuOrHighDependencyUnit');
  @override
  late final GeneratedColumn<bool> hasIcuOrHighDependencyUnit =
      GeneratedColumn<bool>(
        'has_icu_or_high_dependency_unit',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_icu_or_high_dependency_unit" IN (0, 1))',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hasOutpatientServices,
    hasInpatientServices,
    totalInpatientBeds,
    icuBeds,
    hasEmergencyUnit,
    hasIcuOrHighDependencyUnit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'facility_services';
  @override
  VerificationContext validateIntegrity(
    Insertable<FacilityServicesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('has_outpatient_services')) {
      context.handle(
        _hasOutpatientServicesMeta,
        hasOutpatientServices.isAcceptableOrUnknown(
          data['has_outpatient_services']!,
          _hasOutpatientServicesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hasOutpatientServicesMeta);
    }
    if (data.containsKey('has_inpatient_services')) {
      context.handle(
        _hasInpatientServicesMeta,
        hasInpatientServices.isAcceptableOrUnknown(
          data['has_inpatient_services']!,
          _hasInpatientServicesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hasInpatientServicesMeta);
    }
    if (data.containsKey('total_inpatient_beds')) {
      context.handle(
        _totalInpatientBedsMeta,
        totalInpatientBeds.isAcceptableOrUnknown(
          data['total_inpatient_beds']!,
          _totalInpatientBedsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalInpatientBedsMeta);
    }
    if (data.containsKey('icu_beds')) {
      context.handle(
        _icuBedsMeta,
        icuBeds.isAcceptableOrUnknown(data['icu_beds']!, _icuBedsMeta),
      );
    } else if (isInserting) {
      context.missing(_icuBedsMeta);
    }
    if (data.containsKey('has_emergency_unit')) {
      context.handle(
        _hasEmergencyUnitMeta,
        hasEmergencyUnit.isAcceptableOrUnknown(
          data['has_emergency_unit']!,
          _hasEmergencyUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hasEmergencyUnitMeta);
    }
    if (data.containsKey('has_icu_or_high_dependency_unit')) {
      context.handle(
        _hasIcuOrHighDependencyUnitMeta,
        hasIcuOrHighDependencyUnit.isAcceptableOrUnknown(
          data['has_icu_or_high_dependency_unit']!,
          _hasIcuOrHighDependencyUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hasIcuOrHighDependencyUnitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FacilityServicesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FacilityServicesData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      hasOutpatientServices:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}has_outpatient_services'],
          )!,
      hasInpatientServices:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}has_inpatient_services'],
          )!,
      totalInpatientBeds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}total_inpatient_beds'],
          )!,
      icuBeds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}icu_beds'],
          )!,
      hasEmergencyUnit:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}has_emergency_unit'],
          )!,
      hasIcuOrHighDependencyUnit:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}has_icu_or_high_dependency_unit'],
          )!,
    );
  }

  @override
  $FacilityServicesTable createAlias(String alias) {
    return $FacilityServicesTable(attachedDatabase, alias);
  }
}

class FacilityServicesData extends DataClass
    implements Insertable<FacilityServicesData> {
  final String id;
  final bool hasOutpatientServices;
  final bool hasInpatientServices;
  final int totalInpatientBeds;
  final int icuBeds;
  final bool hasEmergencyUnit;
  final bool hasIcuOrHighDependencyUnit;
  const FacilityServicesData({
    required this.id,
    required this.hasOutpatientServices,
    required this.hasInpatientServices,
    required this.totalInpatientBeds,
    required this.icuBeds,
    required this.hasEmergencyUnit,
    required this.hasIcuOrHighDependencyUnit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['has_outpatient_services'] = Variable<bool>(hasOutpatientServices);
    map['has_inpatient_services'] = Variable<bool>(hasInpatientServices);
    map['total_inpatient_beds'] = Variable<int>(totalInpatientBeds);
    map['icu_beds'] = Variable<int>(icuBeds);
    map['has_emergency_unit'] = Variable<bool>(hasEmergencyUnit);
    map['has_icu_or_high_dependency_unit'] = Variable<bool>(
      hasIcuOrHighDependencyUnit,
    );
    return map;
  }

  FacilityServicesCompanion toCompanion(bool nullToAbsent) {
    return FacilityServicesCompanion(
      id: Value(id),
      hasOutpatientServices: Value(hasOutpatientServices),
      hasInpatientServices: Value(hasInpatientServices),
      totalInpatientBeds: Value(totalInpatientBeds),
      icuBeds: Value(icuBeds),
      hasEmergencyUnit: Value(hasEmergencyUnit),
      hasIcuOrHighDependencyUnit: Value(hasIcuOrHighDependencyUnit),
    );
  }

  factory FacilityServicesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FacilityServicesData(
      id: serializer.fromJson<String>(json['id']),
      hasOutpatientServices: serializer.fromJson<bool>(
        json['hasOutpatientServices'],
      ),
      hasInpatientServices: serializer.fromJson<bool>(
        json['hasInpatientServices'],
      ),
      totalInpatientBeds: serializer.fromJson<int>(json['totalInpatientBeds']),
      icuBeds: serializer.fromJson<int>(json['icuBeds']),
      hasEmergencyUnit: serializer.fromJson<bool>(json['hasEmergencyUnit']),
      hasIcuOrHighDependencyUnit: serializer.fromJson<bool>(
        json['hasIcuOrHighDependencyUnit'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hasOutpatientServices': serializer.toJson<bool>(hasOutpatientServices),
      'hasInpatientServices': serializer.toJson<bool>(hasInpatientServices),
      'totalInpatientBeds': serializer.toJson<int>(totalInpatientBeds),
      'icuBeds': serializer.toJson<int>(icuBeds),
      'hasEmergencyUnit': serializer.toJson<bool>(hasEmergencyUnit),
      'hasIcuOrHighDependencyUnit': serializer.toJson<bool>(
        hasIcuOrHighDependencyUnit,
      ),
    };
  }

  FacilityServicesData copyWith({
    String? id,
    bool? hasOutpatientServices,
    bool? hasInpatientServices,
    int? totalInpatientBeds,
    int? icuBeds,
    bool? hasEmergencyUnit,
    bool? hasIcuOrHighDependencyUnit,
  }) => FacilityServicesData(
    id: id ?? this.id,
    hasOutpatientServices: hasOutpatientServices ?? this.hasOutpatientServices,
    hasInpatientServices: hasInpatientServices ?? this.hasInpatientServices,
    totalInpatientBeds: totalInpatientBeds ?? this.totalInpatientBeds,
    icuBeds: icuBeds ?? this.icuBeds,
    hasEmergencyUnit: hasEmergencyUnit ?? this.hasEmergencyUnit,
    hasIcuOrHighDependencyUnit:
        hasIcuOrHighDependencyUnit ?? this.hasIcuOrHighDependencyUnit,
  );
  FacilityServicesData copyWithCompanion(FacilityServicesCompanion data) {
    return FacilityServicesData(
      id: data.id.present ? data.id.value : this.id,
      hasOutpatientServices:
          data.hasOutpatientServices.present
              ? data.hasOutpatientServices.value
              : this.hasOutpatientServices,
      hasInpatientServices:
          data.hasInpatientServices.present
              ? data.hasInpatientServices.value
              : this.hasInpatientServices,
      totalInpatientBeds:
          data.totalInpatientBeds.present
              ? data.totalInpatientBeds.value
              : this.totalInpatientBeds,
      icuBeds: data.icuBeds.present ? data.icuBeds.value : this.icuBeds,
      hasEmergencyUnit:
          data.hasEmergencyUnit.present
              ? data.hasEmergencyUnit.value
              : this.hasEmergencyUnit,
      hasIcuOrHighDependencyUnit:
          data.hasIcuOrHighDependencyUnit.present
              ? data.hasIcuOrHighDependencyUnit.value
              : this.hasIcuOrHighDependencyUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FacilityServicesData(')
          ..write('id: $id, ')
          ..write('hasOutpatientServices: $hasOutpatientServices, ')
          ..write('hasInpatientServices: $hasInpatientServices, ')
          ..write('totalInpatientBeds: $totalInpatientBeds, ')
          ..write('icuBeds: $icuBeds, ')
          ..write('hasEmergencyUnit: $hasEmergencyUnit, ')
          ..write('hasIcuOrHighDependencyUnit: $hasIcuOrHighDependencyUnit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hasOutpatientServices,
    hasInpatientServices,
    totalInpatientBeds,
    icuBeds,
    hasEmergencyUnit,
    hasIcuOrHighDependencyUnit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FacilityServicesData &&
          other.id == this.id &&
          other.hasOutpatientServices == this.hasOutpatientServices &&
          other.hasInpatientServices == this.hasInpatientServices &&
          other.totalInpatientBeds == this.totalInpatientBeds &&
          other.icuBeds == this.icuBeds &&
          other.hasEmergencyUnit == this.hasEmergencyUnit &&
          other.hasIcuOrHighDependencyUnit == this.hasIcuOrHighDependencyUnit);
}

class FacilityServicesCompanion extends UpdateCompanion<FacilityServicesData> {
  final Value<String> id;
  final Value<bool> hasOutpatientServices;
  final Value<bool> hasInpatientServices;
  final Value<int> totalInpatientBeds;
  final Value<int> icuBeds;
  final Value<bool> hasEmergencyUnit;
  final Value<bool> hasIcuOrHighDependencyUnit;
  final Value<int> rowid;
  const FacilityServicesCompanion({
    this.id = const Value.absent(),
    this.hasOutpatientServices = const Value.absent(),
    this.hasInpatientServices = const Value.absent(),
    this.totalInpatientBeds = const Value.absent(),
    this.icuBeds = const Value.absent(),
    this.hasEmergencyUnit = const Value.absent(),
    this.hasIcuOrHighDependencyUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FacilityServicesCompanion.insert({
    required String id,
    required bool hasOutpatientServices,
    required bool hasInpatientServices,
    required int totalInpatientBeds,
    required int icuBeds,
    required bool hasEmergencyUnit,
    required bool hasIcuOrHighDependencyUnit,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hasOutpatientServices = Value(hasOutpatientServices),
       hasInpatientServices = Value(hasInpatientServices),
       totalInpatientBeds = Value(totalInpatientBeds),
       icuBeds = Value(icuBeds),
       hasEmergencyUnit = Value(hasEmergencyUnit),
       hasIcuOrHighDependencyUnit = Value(hasIcuOrHighDependencyUnit);
  static Insertable<FacilityServicesData> custom({
    Expression<String>? id,
    Expression<bool>? hasOutpatientServices,
    Expression<bool>? hasInpatientServices,
    Expression<int>? totalInpatientBeds,
    Expression<int>? icuBeds,
    Expression<bool>? hasEmergencyUnit,
    Expression<bool>? hasIcuOrHighDependencyUnit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hasOutpatientServices != null)
        'has_outpatient_services': hasOutpatientServices,
      if (hasInpatientServices != null)
        'has_inpatient_services': hasInpatientServices,
      if (totalInpatientBeds != null)
        'total_inpatient_beds': totalInpatientBeds,
      if (icuBeds != null) 'icu_beds': icuBeds,
      if (hasEmergencyUnit != null) 'has_emergency_unit': hasEmergencyUnit,
      if (hasIcuOrHighDependencyUnit != null)
        'has_icu_or_high_dependency_unit': hasIcuOrHighDependencyUnit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FacilityServicesCompanion copyWith({
    Value<String>? id,
    Value<bool>? hasOutpatientServices,
    Value<bool>? hasInpatientServices,
    Value<int>? totalInpatientBeds,
    Value<int>? icuBeds,
    Value<bool>? hasEmergencyUnit,
    Value<bool>? hasIcuOrHighDependencyUnit,
    Value<int>? rowid,
  }) {
    return FacilityServicesCompanion(
      id: id ?? this.id,
      hasOutpatientServices:
          hasOutpatientServices ?? this.hasOutpatientServices,
      hasInpatientServices: hasInpatientServices ?? this.hasInpatientServices,
      totalInpatientBeds: totalInpatientBeds ?? this.totalInpatientBeds,
      icuBeds: icuBeds ?? this.icuBeds,
      hasEmergencyUnit: hasEmergencyUnit ?? this.hasEmergencyUnit,
      hasIcuOrHighDependencyUnit:
          hasIcuOrHighDependencyUnit ?? this.hasIcuOrHighDependencyUnit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hasOutpatientServices.present) {
      map['has_outpatient_services'] = Variable<bool>(
        hasOutpatientServices.value,
      );
    }
    if (hasInpatientServices.present) {
      map['has_inpatient_services'] = Variable<bool>(
        hasInpatientServices.value,
      );
    }
    if (totalInpatientBeds.present) {
      map['total_inpatient_beds'] = Variable<int>(totalInpatientBeds.value);
    }
    if (icuBeds.present) {
      map['icu_beds'] = Variable<int>(icuBeds.value);
    }
    if (hasEmergencyUnit.present) {
      map['has_emergency_unit'] = Variable<bool>(hasEmergencyUnit.value);
    }
    if (hasIcuOrHighDependencyUnit.present) {
      map['has_icu_or_high_dependency_unit'] = Variable<bool>(
        hasIcuOrHighDependencyUnit.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FacilityServicesCompanion(')
          ..write('id: $id, ')
          ..write('hasOutpatientServices: $hasOutpatientServices, ')
          ..write('hasInpatientServices: $hasInpatientServices, ')
          ..write('totalInpatientBeds: $totalInpatientBeds, ')
          ..write('icuBeds: $icuBeds, ')
          ..write('hasEmergencyUnit: $hasEmergencyUnit, ')
          ..write('hasIcuOrHighDependencyUnit: $hasIcuOrHighDependencyUnit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssessmentFormsTable extends AssessmentForms
    with TableInfo<$AssessmentFormsTable, AssessmentFormData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssessmentFormsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessorInfoIdMeta = const VerificationMeta(
    'assessorInfoId',
  );
  @override
  late final GeneratedColumn<String> assessorInfoId = GeneratedColumn<String>(
    'assessor_info_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assessor_infos (id)',
    ),
  );
  static const VerificationMeta _geoLocationIdMeta = const VerificationMeta(
    'geoLocationId',
  );
  @override
  late final GeneratedColumn<String> geoLocationId = GeneratedColumn<String>(
    'geo_location_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES geo_locations (id)',
    ),
  );
  static const VerificationMeta _facilityIdentificationIdMeta =
      const VerificationMeta('facilityIdentificationId');
  @override
  late final GeneratedColumn<String> facilityIdentificationId =
      GeneratedColumn<String>(
        'facility_identification_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES facility_identifications (id)',
        ),
      );
  static const VerificationMeta _facilityServicesIdMeta =
      const VerificationMeta('facilityServicesId');
  @override
  late final GeneratedColumn<String> facilityServicesId =
      GeneratedColumn<String>(
        'facility_services_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES facility_services (id)',
        ),
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSubmittedMeta = const VerificationMeta(
    'isSubmitted',
  );
  @override
  late final GeneratedColumn<bool> isSubmitted = GeneratedColumn<bool>(
    'is_submitted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_submitted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _submissionDateMeta = const VerificationMeta(
    'submissionDate',
  );
  @override
  late final GeneratedColumn<DateTime> submissionDate =
      GeneratedColumn<DateTime>(
        'submission_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assessorInfoId,
    geoLocationId,
    facilityIdentificationId,
    facilityServicesId,
    notes,
    isSubmitted,
    submissionDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessment_forms';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssessmentFormData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('assessor_info_id')) {
      context.handle(
        _assessorInfoIdMeta,
        assessorInfoId.isAcceptableOrUnknown(
          data['assessor_info_id']!,
          _assessorInfoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessorInfoIdMeta);
    }
    if (data.containsKey('geo_location_id')) {
      context.handle(
        _geoLocationIdMeta,
        geoLocationId.isAcceptableOrUnknown(
          data['geo_location_id']!,
          _geoLocationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_geoLocationIdMeta);
    }
    if (data.containsKey('facility_identification_id')) {
      context.handle(
        _facilityIdentificationIdMeta,
        facilityIdentificationId.isAcceptableOrUnknown(
          data['facility_identification_id']!,
          _facilityIdentificationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_facilityIdentificationIdMeta);
    }
    if (data.containsKey('facility_services_id')) {
      context.handle(
        _facilityServicesIdMeta,
        facilityServicesId.isAcceptableOrUnknown(
          data['facility_services_id']!,
          _facilityServicesIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_facilityServicesIdMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_submitted')) {
      context.handle(
        _isSubmittedMeta,
        isSubmitted.isAcceptableOrUnknown(
          data['is_submitted']!,
          _isSubmittedMeta,
        ),
      );
    }
    if (data.containsKey('submission_date')) {
      context.handle(
        _submissionDateMeta,
        submissionDate.isAcceptableOrUnknown(
          data['submission_date']!,
          _submissionDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssessmentFormData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssessmentFormData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      assessorInfoId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}assessor_info_id'],
          )!,
      geoLocationId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}geo_location_id'],
          )!,
      facilityIdentificationId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}facility_identification_id'],
          )!,
      facilityServicesId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}facility_services_id'],
          )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isSubmitted:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_submitted'],
          )!,
      submissionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}submission_date'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $AssessmentFormsTable createAlias(String alias) {
    return $AssessmentFormsTable(attachedDatabase, alias);
  }
}

class AssessmentFormData extends DataClass
    implements Insertable<AssessmentFormData> {
  final String id;
  final String assessorInfoId;
  final String geoLocationId;
  final String facilityIdentificationId;
  final String facilityServicesId;
  final String? notes;
  final bool isSubmitted;
  final DateTime? submissionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AssessmentFormData({
    required this.id,
    required this.assessorInfoId,
    required this.geoLocationId,
    required this.facilityIdentificationId,
    required this.facilityServicesId,
    this.notes,
    required this.isSubmitted,
    this.submissionDate,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['assessor_info_id'] = Variable<String>(assessorInfoId);
    map['geo_location_id'] = Variable<String>(geoLocationId);
    map['facility_identification_id'] = Variable<String>(
      facilityIdentificationId,
    );
    map['facility_services_id'] = Variable<String>(facilityServicesId);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_submitted'] = Variable<bool>(isSubmitted);
    if (!nullToAbsent || submissionDate != null) {
      map['submission_date'] = Variable<DateTime>(submissionDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AssessmentFormsCompanion toCompanion(bool nullToAbsent) {
    return AssessmentFormsCompanion(
      id: Value(id),
      assessorInfoId: Value(assessorInfoId),
      geoLocationId: Value(geoLocationId),
      facilityIdentificationId: Value(facilityIdentificationId),
      facilityServicesId: Value(facilityServicesId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isSubmitted: Value(isSubmitted),
      submissionDate:
          submissionDate == null && nullToAbsent
              ? const Value.absent()
              : Value(submissionDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AssessmentFormData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssessmentFormData(
      id: serializer.fromJson<String>(json['id']),
      assessorInfoId: serializer.fromJson<String>(json['assessorInfoId']),
      geoLocationId: serializer.fromJson<String>(json['geoLocationId']),
      facilityIdentificationId: serializer.fromJson<String>(
        json['facilityIdentificationId'],
      ),
      facilityServicesId: serializer.fromJson<String>(
        json['facilityServicesId'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      isSubmitted: serializer.fromJson<bool>(json['isSubmitted']),
      submissionDate: serializer.fromJson<DateTime?>(json['submissionDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assessorInfoId': serializer.toJson<String>(assessorInfoId),
      'geoLocationId': serializer.toJson<String>(geoLocationId),
      'facilityIdentificationId': serializer.toJson<String>(
        facilityIdentificationId,
      ),
      'facilityServicesId': serializer.toJson<String>(facilityServicesId),
      'notes': serializer.toJson<String?>(notes),
      'isSubmitted': serializer.toJson<bool>(isSubmitted),
      'submissionDate': serializer.toJson<DateTime?>(submissionDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AssessmentFormData copyWith({
    String? id,
    String? assessorInfoId,
    String? geoLocationId,
    String? facilityIdentificationId,
    String? facilityServicesId,
    Value<String?> notes = const Value.absent(),
    bool? isSubmitted,
    Value<DateTime?> submissionDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AssessmentFormData(
    id: id ?? this.id,
    assessorInfoId: assessorInfoId ?? this.assessorInfoId,
    geoLocationId: geoLocationId ?? this.geoLocationId,
    facilityIdentificationId:
        facilityIdentificationId ?? this.facilityIdentificationId,
    facilityServicesId: facilityServicesId ?? this.facilityServicesId,
    notes: notes.present ? notes.value : this.notes,
    isSubmitted: isSubmitted ?? this.isSubmitted,
    submissionDate:
        submissionDate.present ? submissionDate.value : this.submissionDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AssessmentFormData copyWithCompanion(AssessmentFormsCompanion data) {
    return AssessmentFormData(
      id: data.id.present ? data.id.value : this.id,
      assessorInfoId:
          data.assessorInfoId.present
              ? data.assessorInfoId.value
              : this.assessorInfoId,
      geoLocationId:
          data.geoLocationId.present
              ? data.geoLocationId.value
              : this.geoLocationId,
      facilityIdentificationId:
          data.facilityIdentificationId.present
              ? data.facilityIdentificationId.value
              : this.facilityIdentificationId,
      facilityServicesId:
          data.facilityServicesId.present
              ? data.facilityServicesId.value
              : this.facilityServicesId,
      notes: data.notes.present ? data.notes.value : this.notes,
      isSubmitted:
          data.isSubmitted.present ? data.isSubmitted.value : this.isSubmitted,
      submissionDate:
          data.submissionDate.present
              ? data.submissionDate.value
              : this.submissionDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentFormData(')
          ..write('id: $id, ')
          ..write('assessorInfoId: $assessorInfoId, ')
          ..write('geoLocationId: $geoLocationId, ')
          ..write('facilityIdentificationId: $facilityIdentificationId, ')
          ..write('facilityServicesId: $facilityServicesId, ')
          ..write('notes: $notes, ')
          ..write('isSubmitted: $isSubmitted, ')
          ..write('submissionDate: $submissionDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assessorInfoId,
    geoLocationId,
    facilityIdentificationId,
    facilityServicesId,
    notes,
    isSubmitted,
    submissionDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssessmentFormData &&
          other.id == this.id &&
          other.assessorInfoId == this.assessorInfoId &&
          other.geoLocationId == this.geoLocationId &&
          other.facilityIdentificationId == this.facilityIdentificationId &&
          other.facilityServicesId == this.facilityServicesId &&
          other.notes == this.notes &&
          other.isSubmitted == this.isSubmitted &&
          other.submissionDate == this.submissionDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AssessmentFormsCompanion extends UpdateCompanion<AssessmentFormData> {
  final Value<String> id;
  final Value<String> assessorInfoId;
  final Value<String> geoLocationId;
  final Value<String> facilityIdentificationId;
  final Value<String> facilityServicesId;
  final Value<String?> notes;
  final Value<bool> isSubmitted;
  final Value<DateTime?> submissionDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AssessmentFormsCompanion({
    this.id = const Value.absent(),
    this.assessorInfoId = const Value.absent(),
    this.geoLocationId = const Value.absent(),
    this.facilityIdentificationId = const Value.absent(),
    this.facilityServicesId = const Value.absent(),
    this.notes = const Value.absent(),
    this.isSubmitted = const Value.absent(),
    this.submissionDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssessmentFormsCompanion.insert({
    required String id,
    required String assessorInfoId,
    required String geoLocationId,
    required String facilityIdentificationId,
    required String facilityServicesId,
    this.notes = const Value.absent(),
    this.isSubmitted = const Value.absent(),
    this.submissionDate = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       assessorInfoId = Value(assessorInfoId),
       geoLocationId = Value(geoLocationId),
       facilityIdentificationId = Value(facilityIdentificationId),
       facilityServicesId = Value(facilityServicesId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AssessmentFormData> custom({
    Expression<String>? id,
    Expression<String>? assessorInfoId,
    Expression<String>? geoLocationId,
    Expression<String>? facilityIdentificationId,
    Expression<String>? facilityServicesId,
    Expression<String>? notes,
    Expression<bool>? isSubmitted,
    Expression<DateTime>? submissionDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assessorInfoId != null) 'assessor_info_id': assessorInfoId,
      if (geoLocationId != null) 'geo_location_id': geoLocationId,
      if (facilityIdentificationId != null)
        'facility_identification_id': facilityIdentificationId,
      if (facilityServicesId != null)
        'facility_services_id': facilityServicesId,
      if (notes != null) 'notes': notes,
      if (isSubmitted != null) 'is_submitted': isSubmitted,
      if (submissionDate != null) 'submission_date': submissionDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssessmentFormsCompanion copyWith({
    Value<String>? id,
    Value<String>? assessorInfoId,
    Value<String>? geoLocationId,
    Value<String>? facilityIdentificationId,
    Value<String>? facilityServicesId,
    Value<String?>? notes,
    Value<bool>? isSubmitted,
    Value<DateTime?>? submissionDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AssessmentFormsCompanion(
      id: id ?? this.id,
      assessorInfoId: assessorInfoId ?? this.assessorInfoId,
      geoLocationId: geoLocationId ?? this.geoLocationId,
      facilityIdentificationId:
          facilityIdentificationId ?? this.facilityIdentificationId,
      facilityServicesId: facilityServicesId ?? this.facilityServicesId,
      notes: notes ?? this.notes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submissionDate: submissionDate ?? this.submissionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assessorInfoId.present) {
      map['assessor_info_id'] = Variable<String>(assessorInfoId.value);
    }
    if (geoLocationId.present) {
      map['geo_location_id'] = Variable<String>(geoLocationId.value);
    }
    if (facilityIdentificationId.present) {
      map['facility_identification_id'] = Variable<String>(
        facilityIdentificationId.value,
      );
    }
    if (facilityServicesId.present) {
      map['facility_services_id'] = Variable<String>(facilityServicesId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isSubmitted.present) {
      map['is_submitted'] = Variable<bool>(isSubmitted.value);
    }
    if (submissionDate.present) {
      map['submission_date'] = Variable<DateTime>(submissionDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentFormsCompanion(')
          ..write('id: $id, ')
          ..write('assessorInfoId: $assessorInfoId, ')
          ..write('geoLocationId: $geoLocationId, ')
          ..write('facilityIdentificationId: $facilityIdentificationId, ')
          ..write('facilityServicesId: $facilityServicesId, ')
          ..write('notes: $notes, ')
          ..write('isSubmitted: $isSubmitted, ')
          ..write('submissionDate: $submissionDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssessmentSectionsTable extends AssessmentSections
    with TableInfo<$AssessmentSectionsTable, AssessmentSectionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssessmentSectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessmentFormIdMeta = const VerificationMeta(
    'assessmentFormId',
  );
  @override
  late final GeneratedColumn<String> assessmentFormId = GeneratedColumn<String>(
    'assessment_form_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assessment_forms (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sectionNumberMeta = const VerificationMeta(
    'sectionNumber',
  );
  @override
  late final GeneratedColumn<String> sectionNumber = GeneratedColumn<String>(
    'section_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assessmentFormId,
    sectionNumber,
    title,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessment_sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssessmentSectionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('assessment_form_id')) {
      context.handle(
        _assessmentFormIdMeta,
        assessmentFormId.isAcceptableOrUnknown(
          data['assessment_form_id']!,
          _assessmentFormIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentFormIdMeta);
    }
    if (data.containsKey('section_number')) {
      context.handle(
        _sectionNumberMeta,
        sectionNumber.isAcceptableOrUnknown(
          data['section_number']!,
          _sectionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sectionNumberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssessmentSectionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssessmentSectionData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      assessmentFormId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}assessment_form_id'],
          )!,
      sectionNumber:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}section_number'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      description:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}description'],
          )!,
    );
  }

  @override
  $AssessmentSectionsTable createAlias(String alias) {
    return $AssessmentSectionsTable(attachedDatabase, alias);
  }
}

class AssessmentSectionData extends DataClass
    implements Insertable<AssessmentSectionData> {
  final String id;
  final String assessmentFormId;
  final String sectionNumber;
  final String title;
  final String description;
  const AssessmentSectionData({
    required this.id,
    required this.assessmentFormId,
    required this.sectionNumber,
    required this.title,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['assessment_form_id'] = Variable<String>(assessmentFormId);
    map['section_number'] = Variable<String>(sectionNumber);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    return map;
  }

  AssessmentSectionsCompanion toCompanion(bool nullToAbsent) {
    return AssessmentSectionsCompanion(
      id: Value(id),
      assessmentFormId: Value(assessmentFormId),
      sectionNumber: Value(sectionNumber),
      title: Value(title),
      description: Value(description),
    );
  }

  factory AssessmentSectionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssessmentSectionData(
      id: serializer.fromJson<String>(json['id']),
      assessmentFormId: serializer.fromJson<String>(json['assessmentFormId']),
      sectionNumber: serializer.fromJson<String>(json['sectionNumber']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assessmentFormId': serializer.toJson<String>(assessmentFormId),
      'sectionNumber': serializer.toJson<String>(sectionNumber),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
    };
  }

  AssessmentSectionData copyWith({
    String? id,
    String? assessmentFormId,
    String? sectionNumber,
    String? title,
    String? description,
  }) => AssessmentSectionData(
    id: id ?? this.id,
    assessmentFormId: assessmentFormId ?? this.assessmentFormId,
    sectionNumber: sectionNumber ?? this.sectionNumber,
    title: title ?? this.title,
    description: description ?? this.description,
  );
  AssessmentSectionData copyWithCompanion(AssessmentSectionsCompanion data) {
    return AssessmentSectionData(
      id: data.id.present ? data.id.value : this.id,
      assessmentFormId:
          data.assessmentFormId.present
              ? data.assessmentFormId.value
              : this.assessmentFormId,
      sectionNumber:
          data.sectionNumber.present
              ? data.sectionNumber.value
              : this.sectionNumber,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentSectionData(')
          ..write('id: $id, ')
          ..write('assessmentFormId: $assessmentFormId, ')
          ..write('sectionNumber: $sectionNumber, ')
          ..write('title: $title, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, assessmentFormId, sectionNumber, title, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssessmentSectionData &&
          other.id == this.id &&
          other.assessmentFormId == this.assessmentFormId &&
          other.sectionNumber == this.sectionNumber &&
          other.title == this.title &&
          other.description == this.description);
}

class AssessmentSectionsCompanion
    extends UpdateCompanion<AssessmentSectionData> {
  final Value<String> id;
  final Value<String> assessmentFormId;
  final Value<String> sectionNumber;
  final Value<String> title;
  final Value<String> description;
  final Value<int> rowid;
  const AssessmentSectionsCompanion({
    this.id = const Value.absent(),
    this.assessmentFormId = const Value.absent(),
    this.sectionNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssessmentSectionsCompanion.insert({
    required String id,
    required String assessmentFormId,
    required String sectionNumber,
    required String title,
    required String description,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       assessmentFormId = Value(assessmentFormId),
       sectionNumber = Value(sectionNumber),
       title = Value(title),
       description = Value(description);
  static Insertable<AssessmentSectionData> custom({
    Expression<String>? id,
    Expression<String>? assessmentFormId,
    Expression<String>? sectionNumber,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assessmentFormId != null) 'assessment_form_id': assessmentFormId,
      if (sectionNumber != null) 'section_number': sectionNumber,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssessmentSectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? assessmentFormId,
    Value<String>? sectionNumber,
    Value<String>? title,
    Value<String>? description,
    Value<int>? rowid,
  }) {
    return AssessmentSectionsCompanion(
      id: id ?? this.id,
      assessmentFormId: assessmentFormId ?? this.assessmentFormId,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assessmentFormId.present) {
      map['assessment_form_id'] = Variable<String>(assessmentFormId.value);
    }
    if (sectionNumber.present) {
      map['section_number'] = Variable<String>(sectionNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentSectionsCompanion(')
          ..write('id: $id, ')
          ..write('assessmentFormId: $assessmentFormId, ')
          ..write('sectionNumber: $sectionNumber, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssessmentRatingsTable extends AssessmentRatings
    with TableInfo<$AssessmentRatingsTable, AssessmentRatingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssessmentRatingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, value, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessment_ratings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssessmentRatingData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssessmentRatingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssessmentRatingData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}value'],
          )!,
      label:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}label'],
          )!,
    );
  }

  @override
  $AssessmentRatingsTable createAlias(String alias) {
    return $AssessmentRatingsTable(attachedDatabase, alias);
  }
}

class AssessmentRatingData extends DataClass
    implements Insertable<AssessmentRatingData> {
  final String id;
  final int value;
  final String label;
  const AssessmentRatingData({
    required this.id,
    required this.value,
    required this.label,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['value'] = Variable<int>(value);
    map['label'] = Variable<String>(label);
    return map;
  }

  AssessmentRatingsCompanion toCompanion(bool nullToAbsent) {
    return AssessmentRatingsCompanion(
      id: Value(id),
      value: Value(value),
      label: Value(label),
    );
  }

  factory AssessmentRatingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssessmentRatingData(
      id: serializer.fromJson<String>(json['id']),
      value: serializer.fromJson<int>(json['value']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'value': serializer.toJson<int>(value),
      'label': serializer.toJson<String>(label),
    };
  }

  AssessmentRatingData copyWith({String? id, int? value, String? label}) =>
      AssessmentRatingData(
        id: id ?? this.id,
        value: value ?? this.value,
        label: label ?? this.label,
      );
  AssessmentRatingData copyWithCompanion(AssessmentRatingsCompanion data) {
    return AssessmentRatingData(
      id: data.id.present ? data.id.value : this.id,
      value: data.value.present ? data.value.value : this.value,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentRatingData(')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, value, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssessmentRatingData &&
          other.id == this.id &&
          other.value == this.value &&
          other.label == this.label);
}

class AssessmentRatingsCompanion extends UpdateCompanion<AssessmentRatingData> {
  final Value<String> id;
  final Value<int> value;
  final Value<String> label;
  final Value<int> rowid;
  const AssessmentRatingsCompanion({
    this.id = const Value.absent(),
    this.value = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssessmentRatingsCompanion.insert({
    required String id,
    required int value,
    required String label,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       value = Value(value),
       label = Value(label);
  static Insertable<AssessmentRatingData> custom({
    Expression<String>? id,
    Expression<int>? value,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (value != null) 'value': value,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssessmentRatingsCompanion copyWith({
    Value<String>? id,
    Value<int>? value,
    Value<String>? label,
    Value<int>? rowid,
  }) {
    return AssessmentRatingsCompanion(
      id: id ?? this.id,
      value: value ?? this.value,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentRatingsCompanion(')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssessmentItemsTable extends AssessmentItems
    with TableInfo<$AssessmentItemsTable, AssessmentItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssessmentItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _itemNumberMeta = const VerificationMeta(
    'itemNumber',
  );
  @override
  late final GeneratedColumn<String> itemNumber = GeneratedColumn<String>(
    'item_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assessment_sections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sectionNumberMeta = const VerificationMeta(
    'sectionNumber',
  );
  @override
  late final GeneratedColumn<String> sectionNumber = GeneratedColumn<String>(
    'section_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<String> area = GeneratedColumn<String>(
    'area',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meetsTargetDescriptionMeta =
      const VerificationMeta('meetsTargetDescription');
  @override
  late final GeneratedColumn<String> meetsTargetDescription =
      GeneratedColumn<String>(
        'meets_target_description',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _partiallyMeetsDescriptionMeta =
      const VerificationMeta('partiallyMeetsDescription');
  @override
  late final GeneratedColumn<String> partiallyMeetsDescription =
      GeneratedColumn<String>(
        'partially_meets_description',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _doesNotMeetDescriptionMeta =
      const VerificationMeta('doesNotMeetDescription');
  @override
  late final GeneratedColumn<String> doesNotMeetDescription =
      GeneratedColumn<String>(
        'does_not_meet_description',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _selectedRatingIdMeta = const VerificationMeta(
    'selectedRatingId',
  );
  @override
  late final GeneratedColumn<String> selectedRatingId = GeneratedColumn<String>(
    'selected_rating_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assessment_ratings (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemNumber,
    sectionId,
    sectionNumber,
    area,
    meetsTargetDescription,
    partiallyMeetsDescription,
    doesNotMeetDescription,
    selectedRatingId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessment_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssessmentItemData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_number')) {
      context.handle(
        _itemNumberMeta,
        itemNumber.isAcceptableOrUnknown(data['item_number']!, _itemNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_itemNumberMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('section_number')) {
      context.handle(
        _sectionNumberMeta,
        sectionNumber.isAcceptableOrUnknown(
          data['section_number']!,
          _sectionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sectionNumberMeta);
    }
    if (data.containsKey('area')) {
      context.handle(
        _areaMeta,
        area.isAcceptableOrUnknown(data['area']!, _areaMeta),
      );
    } else if (isInserting) {
      context.missing(_areaMeta);
    }
    if (data.containsKey('meets_target_description')) {
      context.handle(
        _meetsTargetDescriptionMeta,
        meetsTargetDescription.isAcceptableOrUnknown(
          data['meets_target_description']!,
          _meetsTargetDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_meetsTargetDescriptionMeta);
    }
    if (data.containsKey('partially_meets_description')) {
      context.handle(
        _partiallyMeetsDescriptionMeta,
        partiallyMeetsDescription.isAcceptableOrUnknown(
          data['partially_meets_description']!,
          _partiallyMeetsDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partiallyMeetsDescriptionMeta);
    }
    if (data.containsKey('does_not_meet_description')) {
      context.handle(
        _doesNotMeetDescriptionMeta,
        doesNotMeetDescription.isAcceptableOrUnknown(
          data['does_not_meet_description']!,
          _doesNotMeetDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_doesNotMeetDescriptionMeta);
    }
    if (data.containsKey('selected_rating_id')) {
      context.handle(
        _selectedRatingIdMeta,
        selectedRatingId.isAcceptableOrUnknown(
          data['selected_rating_id']!,
          _selectedRatingIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssessmentItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssessmentItemData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      itemNumber:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}item_number'],
          )!,
      sectionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}section_id'],
          )!,
      sectionNumber:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}section_number'],
          )!,
      area:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}area'],
          )!,
      meetsTargetDescription:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}meets_target_description'],
          )!,
      partiallyMeetsDescription:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}partially_meets_description'],
          )!,
      doesNotMeetDescription:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}does_not_meet_description'],
          )!,
      selectedRatingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_rating_id'],
      ),
    );
  }

  @override
  $AssessmentItemsTable createAlias(String alias) {
    return $AssessmentItemsTable(attachedDatabase, alias);
  }
}

class AssessmentItemData extends DataClass
    implements Insertable<AssessmentItemData> {
  final int id;
  final String itemNumber;
  final String sectionId;
  final String sectionNumber;
  final String area;
  final String meetsTargetDescription;
  final String partiallyMeetsDescription;
  final String doesNotMeetDescription;
  final String? selectedRatingId;
  const AssessmentItemData({
    required this.id,
    required this.itemNumber,
    required this.sectionId,
    required this.sectionNumber,
    required this.area,
    required this.meetsTargetDescription,
    required this.partiallyMeetsDescription,
    required this.doesNotMeetDescription,
    this.selectedRatingId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_number'] = Variable<String>(itemNumber);
    map['section_id'] = Variable<String>(sectionId);
    map['section_number'] = Variable<String>(sectionNumber);
    map['area'] = Variable<String>(area);
    map['meets_target_description'] = Variable<String>(meetsTargetDescription);
    map['partially_meets_description'] = Variable<String>(
      partiallyMeetsDescription,
    );
    map['does_not_meet_description'] = Variable<String>(doesNotMeetDescription);
    if (!nullToAbsent || selectedRatingId != null) {
      map['selected_rating_id'] = Variable<String>(selectedRatingId);
    }
    return map;
  }

  AssessmentItemsCompanion toCompanion(bool nullToAbsent) {
    return AssessmentItemsCompanion(
      id: Value(id),
      itemNumber: Value(itemNumber),
      sectionId: Value(sectionId),
      sectionNumber: Value(sectionNumber),
      area: Value(area),
      meetsTargetDescription: Value(meetsTargetDescription),
      partiallyMeetsDescription: Value(partiallyMeetsDescription),
      doesNotMeetDescription: Value(doesNotMeetDescription),
      selectedRatingId:
          selectedRatingId == null && nullToAbsent
              ? const Value.absent()
              : Value(selectedRatingId),
    );
  }

  factory AssessmentItemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssessmentItemData(
      id: serializer.fromJson<int>(json['id']),
      itemNumber: serializer.fromJson<String>(json['itemNumber']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      sectionNumber: serializer.fromJson<String>(json['sectionNumber']),
      area: serializer.fromJson<String>(json['area']),
      meetsTargetDescription: serializer.fromJson<String>(
        json['meetsTargetDescription'],
      ),
      partiallyMeetsDescription: serializer.fromJson<String>(
        json['partiallyMeetsDescription'],
      ),
      doesNotMeetDescription: serializer.fromJson<String>(
        json['doesNotMeetDescription'],
      ),
      selectedRatingId: serializer.fromJson<String?>(json['selectedRatingId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemNumber': serializer.toJson<String>(itemNumber),
      'sectionId': serializer.toJson<String>(sectionId),
      'sectionNumber': serializer.toJson<String>(sectionNumber),
      'area': serializer.toJson<String>(area),
      'meetsTargetDescription': serializer.toJson<String>(
        meetsTargetDescription,
      ),
      'partiallyMeetsDescription': serializer.toJson<String>(
        partiallyMeetsDescription,
      ),
      'doesNotMeetDescription': serializer.toJson<String>(
        doesNotMeetDescription,
      ),
      'selectedRatingId': serializer.toJson<String?>(selectedRatingId),
    };
  }

  AssessmentItemData copyWith({
    int? id,
    String? itemNumber,
    String? sectionId,
    String? sectionNumber,
    String? area,
    String? meetsTargetDescription,
    String? partiallyMeetsDescription,
    String? doesNotMeetDescription,
    Value<String?> selectedRatingId = const Value.absent(),
  }) => AssessmentItemData(
    id: id ?? this.id,
    itemNumber: itemNumber ?? this.itemNumber,
    sectionId: sectionId ?? this.sectionId,
    sectionNumber: sectionNumber ?? this.sectionNumber,
    area: area ?? this.area,
    meetsTargetDescription:
        meetsTargetDescription ?? this.meetsTargetDescription,
    partiallyMeetsDescription:
        partiallyMeetsDescription ?? this.partiallyMeetsDescription,
    doesNotMeetDescription:
        doesNotMeetDescription ?? this.doesNotMeetDescription,
    selectedRatingId:
        selectedRatingId.present
            ? selectedRatingId.value
            : this.selectedRatingId,
  );
  AssessmentItemData copyWithCompanion(AssessmentItemsCompanion data) {
    return AssessmentItemData(
      id: data.id.present ? data.id.value : this.id,
      itemNumber:
          data.itemNumber.present ? data.itemNumber.value : this.itemNumber,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      sectionNumber:
          data.sectionNumber.present
              ? data.sectionNumber.value
              : this.sectionNumber,
      area: data.area.present ? data.area.value : this.area,
      meetsTargetDescription:
          data.meetsTargetDescription.present
              ? data.meetsTargetDescription.value
              : this.meetsTargetDescription,
      partiallyMeetsDescription:
          data.partiallyMeetsDescription.present
              ? data.partiallyMeetsDescription.value
              : this.partiallyMeetsDescription,
      doesNotMeetDescription:
          data.doesNotMeetDescription.present
              ? data.doesNotMeetDescription.value
              : this.doesNotMeetDescription,
      selectedRatingId:
          data.selectedRatingId.present
              ? data.selectedRatingId.value
              : this.selectedRatingId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentItemData(')
          ..write('id: $id, ')
          ..write('itemNumber: $itemNumber, ')
          ..write('sectionId: $sectionId, ')
          ..write('sectionNumber: $sectionNumber, ')
          ..write('area: $area, ')
          ..write('meetsTargetDescription: $meetsTargetDescription, ')
          ..write('partiallyMeetsDescription: $partiallyMeetsDescription, ')
          ..write('doesNotMeetDescription: $doesNotMeetDescription, ')
          ..write('selectedRatingId: $selectedRatingId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemNumber,
    sectionId,
    sectionNumber,
    area,
    meetsTargetDescription,
    partiallyMeetsDescription,
    doesNotMeetDescription,
    selectedRatingId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssessmentItemData &&
          other.id == this.id &&
          other.itemNumber == this.itemNumber &&
          other.sectionId == this.sectionId &&
          other.sectionNumber == this.sectionNumber &&
          other.area == this.area &&
          other.meetsTargetDescription == this.meetsTargetDescription &&
          other.partiallyMeetsDescription == this.partiallyMeetsDescription &&
          other.doesNotMeetDescription == this.doesNotMeetDescription &&
          other.selectedRatingId == this.selectedRatingId);
}

class AssessmentItemsCompanion extends UpdateCompanion<AssessmentItemData> {
  final Value<int> id;
  final Value<String> itemNumber;
  final Value<String> sectionId;
  final Value<String> sectionNumber;
  final Value<String> area;
  final Value<String> meetsTargetDescription;
  final Value<String> partiallyMeetsDescription;
  final Value<String> doesNotMeetDescription;
  final Value<String?> selectedRatingId;
  const AssessmentItemsCompanion({
    this.id = const Value.absent(),
    this.itemNumber = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.sectionNumber = const Value.absent(),
    this.area = const Value.absent(),
    this.meetsTargetDescription = const Value.absent(),
    this.partiallyMeetsDescription = const Value.absent(),
    this.doesNotMeetDescription = const Value.absent(),
    this.selectedRatingId = const Value.absent(),
  });
  AssessmentItemsCompanion.insert({
    this.id = const Value.absent(),
    required String itemNumber,
    required String sectionId,
    required String sectionNumber,
    required String area,
    required String meetsTargetDescription,
    required String partiallyMeetsDescription,
    required String doesNotMeetDescription,
    this.selectedRatingId = const Value.absent(),
  }) : itemNumber = Value(itemNumber),
       sectionId = Value(sectionId),
       sectionNumber = Value(sectionNumber),
       area = Value(area),
       meetsTargetDescription = Value(meetsTargetDescription),
       partiallyMeetsDescription = Value(partiallyMeetsDescription),
       doesNotMeetDescription = Value(doesNotMeetDescription);
  static Insertable<AssessmentItemData> custom({
    Expression<int>? id,
    Expression<String>? itemNumber,
    Expression<String>? sectionId,
    Expression<String>? sectionNumber,
    Expression<String>? area,
    Expression<String>? meetsTargetDescription,
    Expression<String>? partiallyMeetsDescription,
    Expression<String>? doesNotMeetDescription,
    Expression<String>? selectedRatingId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemNumber != null) 'item_number': itemNumber,
      if (sectionId != null) 'section_id': sectionId,
      if (sectionNumber != null) 'section_number': sectionNumber,
      if (area != null) 'area': area,
      if (meetsTargetDescription != null)
        'meets_target_description': meetsTargetDescription,
      if (partiallyMeetsDescription != null)
        'partially_meets_description': partiallyMeetsDescription,
      if (doesNotMeetDescription != null)
        'does_not_meet_description': doesNotMeetDescription,
      if (selectedRatingId != null) 'selected_rating_id': selectedRatingId,
    });
  }

  AssessmentItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? itemNumber,
    Value<String>? sectionId,
    Value<String>? sectionNumber,
    Value<String>? area,
    Value<String>? meetsTargetDescription,
    Value<String>? partiallyMeetsDescription,
    Value<String>? doesNotMeetDescription,
    Value<String?>? selectedRatingId,
  }) {
    return AssessmentItemsCompanion(
      id: id ?? this.id,
      itemNumber: itemNumber ?? this.itemNumber,
      sectionId: sectionId ?? this.sectionId,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      area: area ?? this.area,
      meetsTargetDescription:
          meetsTargetDescription ?? this.meetsTargetDescription,
      partiallyMeetsDescription:
          partiallyMeetsDescription ?? this.partiallyMeetsDescription,
      doesNotMeetDescription:
          doesNotMeetDescription ?? this.doesNotMeetDescription,
      selectedRatingId: selectedRatingId ?? this.selectedRatingId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemNumber.present) {
      map['item_number'] = Variable<String>(itemNumber.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (sectionNumber.present) {
      map['section_number'] = Variable<String>(sectionNumber.value);
    }
    if (area.present) {
      map['area'] = Variable<String>(area.value);
    }
    if (meetsTargetDescription.present) {
      map['meets_target_description'] = Variable<String>(
        meetsTargetDescription.value,
      );
    }
    if (partiallyMeetsDescription.present) {
      map['partially_meets_description'] = Variable<String>(
        partiallyMeetsDescription.value,
      );
    }
    if (doesNotMeetDescription.present) {
      map['does_not_meet_description'] = Variable<String>(
        doesNotMeetDescription.value,
      );
    }
    if (selectedRatingId.present) {
      map['selected_rating_id'] = Variable<String>(selectedRatingId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentItemsCompanion(')
          ..write('id: $id, ')
          ..write('itemNumber: $itemNumber, ')
          ..write('sectionId: $sectionId, ')
          ..write('sectionNumber: $sectionNumber, ')
          ..write('area: $area, ')
          ..write('meetsTargetDescription: $meetsTargetDescription, ')
          ..write('partiallyMeetsDescription: $partiallyMeetsDescription, ')
          ..write('doesNotMeetDescription: $doesNotMeetDescription, ')
          ..write('selectedRatingId: $selectedRatingId')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessmentFormIdMeta = const VerificationMeta(
    'assessmentFormId',
  );
  @override
  late final GeneratedColumn<String> assessmentFormId = GeneratedColumn<String>(
    'assessment_form_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assessment_forms (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    assessmentFormId,
    fileName,
    filePath,
    source,
    fileSizeBytes,
    capturedAt,
    description,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Photo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('assessment_form_id')) {
      context.handle(
        _assessmentFormIdMeta,
        assessmentFormId.isAcceptableOrUnknown(
          data['assessment_form_id']!,
          _assessmentFormIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentFormIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileSizeBytesMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
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
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      assessmentFormId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}assessment_form_id'],
          )!,
      fileName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_name'],
          )!,
      filePath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_path'],
          )!,
      source:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}source'],
          )!,
      fileSizeBytes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}file_size_bytes'],
          )!,
      capturedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}captured_at'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class Photo extends DataClass implements Insertable<Photo> {
  final String id;
  final String assessmentFormId;
  final String fileName;
  final String filePath;
  final String source;
  final int fileSizeBytes;
  final DateTime capturedAt;
  final String? description;
  final DateTime createdAt;
  const Photo({
    required this.id,
    required this.assessmentFormId,
    required this.fileName,
    required this.filePath,
    required this.source,
    required this.fileSizeBytes,
    required this.capturedAt,
    this.description,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['assessment_form_id'] = Variable<String>(assessmentFormId);
    map['file_name'] = Variable<String>(fileName);
    map['file_path'] = Variable<String>(filePath);
    map['source'] = Variable<String>(source);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      assessmentFormId: Value(assessmentFormId),
      fileName: Value(fileName),
      filePath: Value(filePath),
      source: Value(source),
      fileSizeBytes: Value(fileSizeBytes),
      capturedAt: Value(capturedAt),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      createdAt: Value(createdAt),
    );
  }

  factory Photo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<String>(json['id']),
      assessmentFormId: serializer.fromJson<String>(json['assessmentFormId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String>(json['filePath']),
      source: serializer.fromJson<String>(json['source']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assessmentFormId': serializer.toJson<String>(assessmentFormId),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String>(filePath),
      'source': serializer.toJson<String>(source),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Photo copyWith({
    String? id,
    String? assessmentFormId,
    String? fileName,
    String? filePath,
    String? source,
    int? fileSizeBytes,
    DateTime? capturedAt,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
  }) => Photo(
    id: id ?? this.id,
    assessmentFormId: assessmentFormId ?? this.assessmentFormId,
    fileName: fileName ?? this.fileName,
    filePath: filePath ?? this.filePath,
    source: source ?? this.source,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    capturedAt: capturedAt ?? this.capturedAt,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
  );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      id: data.id.present ? data.id.value : this.id,
      assessmentFormId:
          data.assessmentFormId.present
              ? data.assessmentFormId.value
              : this.assessmentFormId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      source: data.source.present ? data.source.value : this.source,
      fileSizeBytes:
          data.fileSizeBytes.present
              ? data.fileSizeBytes.value
              : this.fileSizeBytes,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('assessmentFormId: $assessmentFormId, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('source: $source, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assessmentFormId,
    fileName,
    filePath,
    source,
    fileSizeBytes,
    capturedAt,
    description,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.assessmentFormId == this.assessmentFormId &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.source == this.source &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.capturedAt == this.capturedAt &&
          other.description == this.description &&
          other.createdAt == this.createdAt);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<String> id;
  final Value<String> assessmentFormId;
  final Value<String> fileName;
  final Value<String> filePath;
  final Value<String> source;
  final Value<int> fileSizeBytes;
  final Value<DateTime> capturedAt;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.assessmentFormId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.source = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    required String assessmentFormId,
    required String fileName,
    required String filePath,
    required String source,
    required int fileSizeBytes,
    required DateTime capturedAt,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       assessmentFormId = Value(assessmentFormId),
       fileName = Value(fileName),
       filePath = Value(filePath),
       source = Value(source),
       fileSizeBytes = Value(fileSizeBytes),
       capturedAt = Value(capturedAt);
  static Insertable<Photo> custom({
    Expression<String>? id,
    Expression<String>? assessmentFormId,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<String>? source,
    Expression<int>? fileSizeBytes,
    Expression<DateTime>? capturedAt,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assessmentFormId != null) 'assessment_form_id': assessmentFormId,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (source != null) 'source': source,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? assessmentFormId,
    Value<String>? fileName,
    Value<String>? filePath,
    Value<String>? source,
    Value<int>? fileSizeBytes,
    Value<DateTime>? capturedAt,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      assessmentFormId: assessmentFormId ?? this.assessmentFormId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      source: source ?? this.source,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      capturedAt: capturedAt ?? this.capturedAt,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assessmentFormId.present) {
      map['assessment_form_id'] = Variable<String>(assessmentFormId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('assessmentFormId: $assessmentFormId, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('source: $source, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AssessorInfosTable assessorInfos = $AssessorInfosTable(this);
  late final $GeoLocationsTable geoLocations = $GeoLocationsTable(this);
  late final $FacilityIdentificationsTable facilityIdentifications =
      $FacilityIdentificationsTable(this);
  late final $FacilityServicesTable facilityServices = $FacilityServicesTable(
    this,
  );
  late final $AssessmentFormsTable assessmentForms = $AssessmentFormsTable(
    this,
  );
  late final $AssessmentSectionsTable assessmentSections =
      $AssessmentSectionsTable(this);
  late final $AssessmentRatingsTable assessmentRatings =
      $AssessmentRatingsTable(this);
  late final $AssessmentItemsTable assessmentItems = $AssessmentItemsTable(
    this,
  );
  late final $PhotosTable photos = $PhotosTable(this);
  late final AssessmentDao assessmentDao = AssessmentDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    assessorInfos,
    geoLocations,
    facilityIdentifications,
    facilityServices,
    assessmentForms,
    assessmentSections,
    assessmentRatings,
    assessmentItems,
    photos,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assessment_forms',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('assessment_sections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assessment_sections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('assessment_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assessment_forms',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('photos', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AssessorInfosTableCreateCompanionBuilder =
    AssessorInfosCompanion Function({
      required String id,
      required String name,
      required String email,
      required String phoneNumber,
      required DateTime assessmentDate,
      Value<int> rowid,
    });
typedef $$AssessorInfosTableUpdateCompanionBuilder =
    AssessorInfosCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> email,
      Value<String> phoneNumber,
      Value<DateTime> assessmentDate,
      Value<int> rowid,
    });

final class $$AssessorInfosTableReferences
    extends
        BaseReferences<_$AppDatabase, $AssessorInfosTable, AssessorInfoData> {
  $$AssessorInfosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AssessmentFormsTable, List<AssessmentFormData>>
  _assessmentFormsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessmentForms,
    aliasName: $_aliasNameGenerator(
      db.assessorInfos.id,
      db.assessmentForms.assessorInfoId,
    ),
  );

  $$AssessmentFormsTableProcessedTableManager get assessmentFormsRefs {
    final manager = $$AssessmentFormsTableTableManager(
      $_db,
      $_db.assessmentForms,
    ).filter((f) => f.assessorInfoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assessmentFormsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssessorInfosTableFilterComposer
    extends Composer<_$AppDatabase, $AssessorInfosTable> {
  $$AssessorInfosTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get assessmentDate => $composableBuilder(
    column: $table.assessmentDate,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assessmentFormsRefs(
    Expression<bool> Function($$AssessmentFormsTableFilterComposer f) f,
  ) {
    final $$AssessmentFormsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.assessorInfoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableFilterComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssessorInfosTableOrderingComposer
    extends Composer<_$AppDatabase, $AssessorInfosTable> {
  $$AssessorInfosTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get assessmentDate => $composableBuilder(
    column: $table.assessmentDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssessorInfosTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssessorInfosTable> {
  $$AssessorInfosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get assessmentDate => $composableBuilder(
    column: $table.assessmentDate,
    builder: (column) => column,
  );

  Expression<T> assessmentFormsRefs<T extends Object>(
    Expression<T> Function($$AssessmentFormsTableAnnotationComposer a) f,
  ) {
    final $$AssessmentFormsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.assessorInfoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableAnnotationComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssessorInfosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssessorInfosTable,
          AssessorInfoData,
          $$AssessorInfosTableFilterComposer,
          $$AssessorInfosTableOrderingComposer,
          $$AssessorInfosTableAnnotationComposer,
          $$AssessorInfosTableCreateCompanionBuilder,
          $$AssessorInfosTableUpdateCompanionBuilder,
          (AssessorInfoData, $$AssessorInfosTableReferences),
          AssessorInfoData,
          PrefetchHooks Function({bool assessmentFormsRefs})
        > {
  $$AssessorInfosTableTableManager(_$AppDatabase db, $AssessorInfosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AssessorInfosTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$AssessorInfosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$AssessorInfosTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<DateTime> assessmentDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssessorInfosCompanion(
                id: id,
                name: name,
                email: email,
                phoneNumber: phoneNumber,
                assessmentDate: assessmentDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String email,
                required String phoneNumber,
                required DateTime assessmentDate,
                Value<int> rowid = const Value.absent(),
              }) => AssessorInfosCompanion.insert(
                id: id,
                name: name,
                email: email,
                phoneNumber: phoneNumber,
                assessmentDate: assessmentDate,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$AssessorInfosTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({assessmentFormsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assessmentFormsRefs) db.assessmentForms,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assessmentFormsRefs)
                    await $_getPrefetchedData<
                      AssessorInfoData,
                      $AssessorInfosTable,
                      AssessmentFormData
                    >(
                      currentTable: table,
                      referencedTable: $$AssessorInfosTableReferences
                          ._assessmentFormsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AssessorInfosTableReferences(
                                db,
                                table,
                                p0,
                              ).assessmentFormsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.assessorInfoId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AssessorInfosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssessorInfosTable,
      AssessorInfoData,
      $$AssessorInfosTableFilterComposer,
      $$AssessorInfosTableOrderingComposer,
      $$AssessorInfosTableAnnotationComposer,
      $$AssessorInfosTableCreateCompanionBuilder,
      $$AssessorInfosTableUpdateCompanionBuilder,
      (AssessorInfoData, $$AssessorInfosTableReferences),
      AssessorInfoData,
      PrefetchHooks Function({bool assessmentFormsRefs})
    >;
typedef $$GeoLocationsTableCreateCompanionBuilder =
    GeoLocationsCompanion Function({
      required String id,
      required String country,
      required String regionProvince,
      required String district,
      required String cityVillage,
      required String addressOrCoordinates,
      required String locationType,
      required double latitude,
      required double longitude,
      Value<int> rowid,
    });
typedef $$GeoLocationsTableUpdateCompanionBuilder =
    GeoLocationsCompanion Function({
      Value<String> id,
      Value<String> country,
      Value<String> regionProvince,
      Value<String> district,
      Value<String> cityVillage,
      Value<String> addressOrCoordinates,
      Value<String> locationType,
      Value<double> latitude,
      Value<double> longitude,
      Value<int> rowid,
    });

final class $$GeoLocationsTableReferences
    extends BaseReferences<_$AppDatabase, $GeoLocationsTable, GeoLocationData> {
  $$GeoLocationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AssessmentFormsTable, List<AssessmentFormData>>
  _assessmentFormsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessmentForms,
    aliasName: $_aliasNameGenerator(
      db.geoLocations.id,
      db.assessmentForms.geoLocationId,
    ),
  );

  $$AssessmentFormsTableProcessedTableManager get assessmentFormsRefs {
    final manager = $$AssessmentFormsTableTableManager(
      $_db,
      $_db.assessmentForms,
    ).filter((f) => f.geoLocationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assessmentFormsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GeoLocationsTableFilterComposer
    extends Composer<_$AppDatabase, $GeoLocationsTable> {
  $$GeoLocationsTableFilterComposer({
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

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionProvince => $composableBuilder(
    column: $table.regionProvince,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cityVillage => $composableBuilder(
    column: $table.cityVillage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressOrCoordinates => $composableBuilder(
    column: $table.addressOrCoordinates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationType => $composableBuilder(
    column: $table.locationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assessmentFormsRefs(
    Expression<bool> Function($$AssessmentFormsTableFilterComposer f) f,
  ) {
    final $$AssessmentFormsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.geoLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableFilterComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GeoLocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $GeoLocationsTable> {
  $$GeoLocationsTableOrderingComposer({
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

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionProvince => $composableBuilder(
    column: $table.regionProvince,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cityVillage => $composableBuilder(
    column: $table.cityVillage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressOrCoordinates => $composableBuilder(
    column: $table.addressOrCoordinates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationType => $composableBuilder(
    column: $table.locationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GeoLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeoLocationsTable> {
  $$GeoLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get regionProvince => $composableBuilder(
    column: $table.regionProvince,
    builder: (column) => column,
  );

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get cityVillage => $composableBuilder(
    column: $table.cityVillage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressOrCoordinates => $composableBuilder(
    column: $table.addressOrCoordinates,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationType => $composableBuilder(
    column: $table.locationType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  Expression<T> assessmentFormsRefs<T extends Object>(
    Expression<T> Function($$AssessmentFormsTableAnnotationComposer a) f,
  ) {
    final $$AssessmentFormsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.geoLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableAnnotationComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GeoLocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GeoLocationsTable,
          GeoLocationData,
          $$GeoLocationsTableFilterComposer,
          $$GeoLocationsTableOrderingComposer,
          $$GeoLocationsTableAnnotationComposer,
          $$GeoLocationsTableCreateCompanionBuilder,
          $$GeoLocationsTableUpdateCompanionBuilder,
          (GeoLocationData, $$GeoLocationsTableReferences),
          GeoLocationData,
          PrefetchHooks Function({bool assessmentFormsRefs})
        > {
  $$GeoLocationsTableTableManager(_$AppDatabase db, $GeoLocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$GeoLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$GeoLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$GeoLocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> regionProvince = const Value.absent(),
                Value<String> district = const Value.absent(),
                Value<String> cityVillage = const Value.absent(),
                Value<String> addressOrCoordinates = const Value.absent(),
                Value<String> locationType = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeoLocationsCompanion(
                id: id,
                country: country,
                regionProvince: regionProvince,
                district: district,
                cityVillage: cityVillage,
                addressOrCoordinates: addressOrCoordinates,
                locationType: locationType,
                latitude: latitude,
                longitude: longitude,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String country,
                required String regionProvince,
                required String district,
                required String cityVillage,
                required String addressOrCoordinates,
                required String locationType,
                required double latitude,
                required double longitude,
                Value<int> rowid = const Value.absent(),
              }) => GeoLocationsCompanion.insert(
                id: id,
                country: country,
                regionProvince: regionProvince,
                district: district,
                cityVillage: cityVillage,
                addressOrCoordinates: addressOrCoordinates,
                locationType: locationType,
                latitude: latitude,
                longitude: longitude,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$GeoLocationsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({assessmentFormsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assessmentFormsRefs) db.assessmentForms,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assessmentFormsRefs)
                    await $_getPrefetchedData<
                      GeoLocationData,
                      $GeoLocationsTable,
                      AssessmentFormData
                    >(
                      currentTable: table,
                      referencedTable: $$GeoLocationsTableReferences
                          ._assessmentFormsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$GeoLocationsTableReferences(
                                db,
                                table,
                                p0,
                              ).assessmentFormsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.geoLocationId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GeoLocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GeoLocationsTable,
      GeoLocationData,
      $$GeoLocationsTableFilterComposer,
      $$GeoLocationsTableOrderingComposer,
      $$GeoLocationsTableAnnotationComposer,
      $$GeoLocationsTableCreateCompanionBuilder,
      $$GeoLocationsTableUpdateCompanionBuilder,
      (GeoLocationData, $$GeoLocationsTableReferences),
      GeoLocationData,
      PrefetchHooks Function({bool assessmentFormsRefs})
    >;
typedef $$FacilityIdentificationsTableCreateCompanionBuilder =
    FacilityIdentificationsCompanion Function({
      required String id,
      required String facilityCode,
      required String facilityName,
      required String managingAuthority,
      required String directorName,
      required String directorPhone,
      required String directorEmail,
      required String respondentName,
      required String respondentPosition,
      required String structureType,
      required String facilityType,
      required String existingFacilityType,
      Value<String?> otherExistingFacitlityType,
      Value<int> rowid,
    });
typedef $$FacilityIdentificationsTableUpdateCompanionBuilder =
    FacilityIdentificationsCompanion Function({
      Value<String> id,
      Value<String> facilityCode,
      Value<String> facilityName,
      Value<String> managingAuthority,
      Value<String> directorName,
      Value<String> directorPhone,
      Value<String> directorEmail,
      Value<String> respondentName,
      Value<String> respondentPosition,
      Value<String> structureType,
      Value<String> facilityType,
      Value<String> existingFacilityType,
      Value<String?> otherExistingFacitlityType,
      Value<int> rowid,
    });

final class $$FacilityIdentificationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FacilityIdentificationsTable,
          FacilityIdentificationData
        > {
  $$FacilityIdentificationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AssessmentFormsTable, List<AssessmentFormData>>
  _assessmentFormsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessmentForms,
    aliasName: $_aliasNameGenerator(
      db.facilityIdentifications.id,
      db.assessmentForms.facilityIdentificationId,
    ),
  );

  $$AssessmentFormsTableProcessedTableManager get assessmentFormsRefs {
    final manager = $$AssessmentFormsTableTableManager(
      $_db,
      $_db.assessmentForms,
    ).filter(
      (f) =>
          f.facilityIdentificationId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(
      _assessmentFormsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FacilityIdentificationsTableFilterComposer
    extends Composer<_$AppDatabase, $FacilityIdentificationsTable> {
  $$FacilityIdentificationsTableFilterComposer({
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

  ColumnFilters<String> get facilityCode => $composableBuilder(
    column: $table.facilityCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facilityName => $composableBuilder(
    column: $table.facilityName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get managingAuthority => $composableBuilder(
    column: $table.managingAuthority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get directorName => $composableBuilder(
    column: $table.directorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get directorPhone => $composableBuilder(
    column: $table.directorPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get directorEmail => $composableBuilder(
    column: $table.directorEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get respondentName => $composableBuilder(
    column: $table.respondentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get respondentPosition => $composableBuilder(
    column: $table.respondentPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get structureType => $composableBuilder(
    column: $table.structureType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facilityType => $composableBuilder(
    column: $table.facilityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get existingFacilityType => $composableBuilder(
    column: $table.existingFacilityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otherExistingFacitlityType => $composableBuilder(
    column: $table.otherExistingFacitlityType,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assessmentFormsRefs(
    Expression<bool> Function($$AssessmentFormsTableFilterComposer f) f,
  ) {
    final $$AssessmentFormsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.facilityIdentificationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableFilterComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FacilityIdentificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $FacilityIdentificationsTable> {
  $$FacilityIdentificationsTableOrderingComposer({
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

  ColumnOrderings<String> get facilityCode => $composableBuilder(
    column: $table.facilityCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facilityName => $composableBuilder(
    column: $table.facilityName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get managingAuthority => $composableBuilder(
    column: $table.managingAuthority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get directorName => $composableBuilder(
    column: $table.directorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get directorPhone => $composableBuilder(
    column: $table.directorPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get directorEmail => $composableBuilder(
    column: $table.directorEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get respondentName => $composableBuilder(
    column: $table.respondentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get respondentPosition => $composableBuilder(
    column: $table.respondentPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get structureType => $composableBuilder(
    column: $table.structureType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facilityType => $composableBuilder(
    column: $table.facilityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get existingFacilityType => $composableBuilder(
    column: $table.existingFacilityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otherExistingFacitlityType => $composableBuilder(
    column: $table.otherExistingFacitlityType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FacilityIdentificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FacilityIdentificationsTable> {
  $$FacilityIdentificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get facilityCode => $composableBuilder(
    column: $table.facilityCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get facilityName => $composableBuilder(
    column: $table.facilityName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get managingAuthority => $composableBuilder(
    column: $table.managingAuthority,
    builder: (column) => column,
  );

  GeneratedColumn<String> get directorName => $composableBuilder(
    column: $table.directorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get directorPhone => $composableBuilder(
    column: $table.directorPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get directorEmail => $composableBuilder(
    column: $table.directorEmail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get respondentName => $composableBuilder(
    column: $table.respondentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get respondentPosition => $composableBuilder(
    column: $table.respondentPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get structureType => $composableBuilder(
    column: $table.structureType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get facilityType => $composableBuilder(
    column: $table.facilityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get existingFacilityType => $composableBuilder(
    column: $table.existingFacilityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get otherExistingFacitlityType => $composableBuilder(
    column: $table.otherExistingFacitlityType,
    builder: (column) => column,
  );

  Expression<T> assessmentFormsRefs<T extends Object>(
    Expression<T> Function($$AssessmentFormsTableAnnotationComposer a) f,
  ) {
    final $$AssessmentFormsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.facilityIdentificationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableAnnotationComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FacilityIdentificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FacilityIdentificationsTable,
          FacilityIdentificationData,
          $$FacilityIdentificationsTableFilterComposer,
          $$FacilityIdentificationsTableOrderingComposer,
          $$FacilityIdentificationsTableAnnotationComposer,
          $$FacilityIdentificationsTableCreateCompanionBuilder,
          $$FacilityIdentificationsTableUpdateCompanionBuilder,
          (
            FacilityIdentificationData,
            $$FacilityIdentificationsTableReferences,
          ),
          FacilityIdentificationData,
          PrefetchHooks Function({bool assessmentFormsRefs})
        > {
  $$FacilityIdentificationsTableTableManager(
    _$AppDatabase db,
    $FacilityIdentificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FacilityIdentificationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$FacilityIdentificationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$FacilityIdentificationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> facilityCode = const Value.absent(),
                Value<String> facilityName = const Value.absent(),
                Value<String> managingAuthority = const Value.absent(),
                Value<String> directorName = const Value.absent(),
                Value<String> directorPhone = const Value.absent(),
                Value<String> directorEmail = const Value.absent(),
                Value<String> respondentName = const Value.absent(),
                Value<String> respondentPosition = const Value.absent(),
                Value<String> structureType = const Value.absent(),
                Value<String> facilityType = const Value.absent(),
                Value<String> existingFacilityType = const Value.absent(),
                Value<String?> otherExistingFacitlityType =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FacilityIdentificationsCompanion(
                id: id,
                facilityCode: facilityCode,
                facilityName: facilityName,
                managingAuthority: managingAuthority,
                directorName: directorName,
                directorPhone: directorPhone,
                directorEmail: directorEmail,
                respondentName: respondentName,
                respondentPosition: respondentPosition,
                structureType: structureType,
                facilityType: facilityType,
                existingFacilityType: existingFacilityType,
                otherExistingFacitlityType: otherExistingFacitlityType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String facilityCode,
                required String facilityName,
                required String managingAuthority,
                required String directorName,
                required String directorPhone,
                required String directorEmail,
                required String respondentName,
                required String respondentPosition,
                required String structureType,
                required String facilityType,
                required String existingFacilityType,
                Value<String?> otherExistingFacitlityType =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FacilityIdentificationsCompanion.insert(
                id: id,
                facilityCode: facilityCode,
                facilityName: facilityName,
                managingAuthority: managingAuthority,
                directorName: directorName,
                directorPhone: directorPhone,
                directorEmail: directorEmail,
                respondentName: respondentName,
                respondentPosition: respondentPosition,
                structureType: structureType,
                facilityType: facilityType,
                existingFacilityType: existingFacilityType,
                otherExistingFacitlityType: otherExistingFacitlityType,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$FacilityIdentificationsTableReferences(
                            db,
                            table,
                            e,
                          ),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({assessmentFormsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assessmentFormsRefs) db.assessmentForms,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assessmentFormsRefs)
                    await $_getPrefetchedData<
                      FacilityIdentificationData,
                      $FacilityIdentificationsTable,
                      AssessmentFormData
                    >(
                      currentTable: table,
                      referencedTable: $$FacilityIdentificationsTableReferences
                          ._assessmentFormsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$FacilityIdentificationsTableReferences(
                                db,
                                table,
                                p0,
                              ).assessmentFormsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.facilityIdentificationId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FacilityIdentificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FacilityIdentificationsTable,
      FacilityIdentificationData,
      $$FacilityIdentificationsTableFilterComposer,
      $$FacilityIdentificationsTableOrderingComposer,
      $$FacilityIdentificationsTableAnnotationComposer,
      $$FacilityIdentificationsTableCreateCompanionBuilder,
      $$FacilityIdentificationsTableUpdateCompanionBuilder,
      (FacilityIdentificationData, $$FacilityIdentificationsTableReferences),
      FacilityIdentificationData,
      PrefetchHooks Function({bool assessmentFormsRefs})
    >;
typedef $$FacilityServicesTableCreateCompanionBuilder =
    FacilityServicesCompanion Function({
      required String id,
      required bool hasOutpatientServices,
      required bool hasInpatientServices,
      required int totalInpatientBeds,
      required int icuBeds,
      required bool hasEmergencyUnit,
      required bool hasIcuOrHighDependencyUnit,
      Value<int> rowid,
    });
typedef $$FacilityServicesTableUpdateCompanionBuilder =
    FacilityServicesCompanion Function({
      Value<String> id,
      Value<bool> hasOutpatientServices,
      Value<bool> hasInpatientServices,
      Value<int> totalInpatientBeds,
      Value<int> icuBeds,
      Value<bool> hasEmergencyUnit,
      Value<bool> hasIcuOrHighDependencyUnit,
      Value<int> rowid,
    });

final class $$FacilityServicesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FacilityServicesTable,
          FacilityServicesData
        > {
  $$FacilityServicesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AssessmentFormsTable, List<AssessmentFormData>>
  _assessmentFormsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessmentForms,
    aliasName: $_aliasNameGenerator(
      db.facilityServices.id,
      db.assessmentForms.facilityServicesId,
    ),
  );

  $$AssessmentFormsTableProcessedTableManager get assessmentFormsRefs {
    final manager = $$AssessmentFormsTableTableManager(
      $_db,
      $_db.assessmentForms,
    ).filter(
      (f) => f.facilityServicesId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(
      _assessmentFormsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FacilityServicesTableFilterComposer
    extends Composer<_$AppDatabase, $FacilityServicesTable> {
  $$FacilityServicesTableFilterComposer({
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

  ColumnFilters<bool> get hasOutpatientServices => $composableBuilder(
    column: $table.hasOutpatientServices,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasInpatientServices => $composableBuilder(
    column: $table.hasInpatientServices,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalInpatientBeds => $composableBuilder(
    column: $table.totalInpatientBeds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get icuBeds => $composableBuilder(
    column: $table.icuBeds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasEmergencyUnit => $composableBuilder(
    column: $table.hasEmergencyUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasIcuOrHighDependencyUnit => $composableBuilder(
    column: $table.hasIcuOrHighDependencyUnit,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assessmentFormsRefs(
    Expression<bool> Function($$AssessmentFormsTableFilterComposer f) f,
  ) {
    final $$AssessmentFormsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.facilityServicesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableFilterComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FacilityServicesTableOrderingComposer
    extends Composer<_$AppDatabase, $FacilityServicesTable> {
  $$FacilityServicesTableOrderingComposer({
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

  ColumnOrderings<bool> get hasOutpatientServices => $composableBuilder(
    column: $table.hasOutpatientServices,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasInpatientServices => $composableBuilder(
    column: $table.hasInpatientServices,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalInpatientBeds => $composableBuilder(
    column: $table.totalInpatientBeds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get icuBeds => $composableBuilder(
    column: $table.icuBeds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasEmergencyUnit => $composableBuilder(
    column: $table.hasEmergencyUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasIcuOrHighDependencyUnit => $composableBuilder(
    column: $table.hasIcuOrHighDependencyUnit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FacilityServicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FacilityServicesTable> {
  $$FacilityServicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get hasOutpatientServices => $composableBuilder(
    column: $table.hasOutpatientServices,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasInpatientServices => $composableBuilder(
    column: $table.hasInpatientServices,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalInpatientBeds => $composableBuilder(
    column: $table.totalInpatientBeds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get icuBeds =>
      $composableBuilder(column: $table.icuBeds, builder: (column) => column);

  GeneratedColumn<bool> get hasEmergencyUnit => $composableBuilder(
    column: $table.hasEmergencyUnit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasIcuOrHighDependencyUnit => $composableBuilder(
    column: $table.hasIcuOrHighDependencyUnit,
    builder: (column) => column,
  );

  Expression<T> assessmentFormsRefs<T extends Object>(
    Expression<T> Function($$AssessmentFormsTableAnnotationComposer a) f,
  ) {
    final $$AssessmentFormsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.facilityServicesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableAnnotationComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FacilityServicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FacilityServicesTable,
          FacilityServicesData,
          $$FacilityServicesTableFilterComposer,
          $$FacilityServicesTableOrderingComposer,
          $$FacilityServicesTableAnnotationComposer,
          $$FacilityServicesTableCreateCompanionBuilder,
          $$FacilityServicesTableUpdateCompanionBuilder,
          (FacilityServicesData, $$FacilityServicesTableReferences),
          FacilityServicesData,
          PrefetchHooks Function({bool assessmentFormsRefs})
        > {
  $$FacilityServicesTableTableManager(
    _$AppDatabase db,
    $FacilityServicesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$FacilityServicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$FacilityServicesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$FacilityServicesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> hasOutpatientServices = const Value.absent(),
                Value<bool> hasInpatientServices = const Value.absent(),
                Value<int> totalInpatientBeds = const Value.absent(),
                Value<int> icuBeds = const Value.absent(),
                Value<bool> hasEmergencyUnit = const Value.absent(),
                Value<bool> hasIcuOrHighDependencyUnit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FacilityServicesCompanion(
                id: id,
                hasOutpatientServices: hasOutpatientServices,
                hasInpatientServices: hasInpatientServices,
                totalInpatientBeds: totalInpatientBeds,
                icuBeds: icuBeds,
                hasEmergencyUnit: hasEmergencyUnit,
                hasIcuOrHighDependencyUnit: hasIcuOrHighDependencyUnit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required bool hasOutpatientServices,
                required bool hasInpatientServices,
                required int totalInpatientBeds,
                required int icuBeds,
                required bool hasEmergencyUnit,
                required bool hasIcuOrHighDependencyUnit,
                Value<int> rowid = const Value.absent(),
              }) => FacilityServicesCompanion.insert(
                id: id,
                hasOutpatientServices: hasOutpatientServices,
                hasInpatientServices: hasInpatientServices,
                totalInpatientBeds: totalInpatientBeds,
                icuBeds: icuBeds,
                hasEmergencyUnit: hasEmergencyUnit,
                hasIcuOrHighDependencyUnit: hasIcuOrHighDependencyUnit,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$FacilityServicesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({assessmentFormsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assessmentFormsRefs) db.assessmentForms,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assessmentFormsRefs)
                    await $_getPrefetchedData<
                      FacilityServicesData,
                      $FacilityServicesTable,
                      AssessmentFormData
                    >(
                      currentTable: table,
                      referencedTable: $$FacilityServicesTableReferences
                          ._assessmentFormsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$FacilityServicesTableReferences(
                                db,
                                table,
                                p0,
                              ).assessmentFormsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.facilityServicesId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FacilityServicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FacilityServicesTable,
      FacilityServicesData,
      $$FacilityServicesTableFilterComposer,
      $$FacilityServicesTableOrderingComposer,
      $$FacilityServicesTableAnnotationComposer,
      $$FacilityServicesTableCreateCompanionBuilder,
      $$FacilityServicesTableUpdateCompanionBuilder,
      (FacilityServicesData, $$FacilityServicesTableReferences),
      FacilityServicesData,
      PrefetchHooks Function({bool assessmentFormsRefs})
    >;
typedef $$AssessmentFormsTableCreateCompanionBuilder =
    AssessmentFormsCompanion Function({
      required String id,
      required String assessorInfoId,
      required String geoLocationId,
      required String facilityIdentificationId,
      required String facilityServicesId,
      Value<String?> notes,
      Value<bool> isSubmitted,
      Value<DateTime?> submissionDate,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AssessmentFormsTableUpdateCompanionBuilder =
    AssessmentFormsCompanion Function({
      Value<String> id,
      Value<String> assessorInfoId,
      Value<String> geoLocationId,
      Value<String> facilityIdentificationId,
      Value<String> facilityServicesId,
      Value<String?> notes,
      Value<bool> isSubmitted,
      Value<DateTime?> submissionDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$AssessmentFormsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AssessmentFormsTable,
          AssessmentFormData
        > {
  $$AssessmentFormsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssessorInfosTable _assessorInfoIdTable(_$AppDatabase db) =>
      db.assessorInfos.createAlias(
        $_aliasNameGenerator(
          db.assessmentForms.assessorInfoId,
          db.assessorInfos.id,
        ),
      );

  $$AssessorInfosTableProcessedTableManager get assessorInfoId {
    final $_column = $_itemColumn<String>('assessor_info_id')!;

    final manager = $$AssessorInfosTableTableManager(
      $_db,
      $_db.assessorInfos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assessorInfoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GeoLocationsTable _geoLocationIdTable(_$AppDatabase db) =>
      db.geoLocations.createAlias(
        $_aliasNameGenerator(
          db.assessmentForms.geoLocationId,
          db.geoLocations.id,
        ),
      );

  $$GeoLocationsTableProcessedTableManager get geoLocationId {
    final $_column = $_itemColumn<String>('geo_location_id')!;

    final manager = $$GeoLocationsTableTableManager(
      $_db,
      $_db.geoLocations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_geoLocationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FacilityIdentificationsTable _facilityIdentificationIdTable(
    _$AppDatabase db,
  ) => db.facilityIdentifications.createAlias(
    $_aliasNameGenerator(
      db.assessmentForms.facilityIdentificationId,
      db.facilityIdentifications.id,
    ),
  );

  $$FacilityIdentificationsTableProcessedTableManager
  get facilityIdentificationId {
    final $_column = $_itemColumn<String>('facility_identification_id')!;

    final manager = $$FacilityIdentificationsTableTableManager(
      $_db,
      $_db.facilityIdentifications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _facilityIdentificationIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FacilityServicesTable _facilityServicesIdTable(_$AppDatabase db) =>
      db.facilityServices.createAlias(
        $_aliasNameGenerator(
          db.assessmentForms.facilityServicesId,
          db.facilityServices.id,
        ),
      );

  $$FacilityServicesTableProcessedTableManager get facilityServicesId {
    final $_column = $_itemColumn<String>('facility_services_id')!;

    final manager = $$FacilityServicesTableTableManager(
      $_db,
      $_db.facilityServices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_facilityServicesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $AssessmentSectionsTable,
    List<AssessmentSectionData>
  >
  _assessmentSectionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.assessmentSections,
        aliasName: $_aliasNameGenerator(
          db.assessmentForms.id,
          db.assessmentSections.assessmentFormId,
        ),
      );

  $$AssessmentSectionsTableProcessedTableManager get assessmentSectionsRefs {
    final manager = $$AssessmentSectionsTableTableManager(
      $_db,
      $_db.assessmentSections,
    ).filter(
      (f) => f.assessmentFormId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(
      _assessmentSectionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PhotosTable, List<Photo>> _photosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.photos,
    aliasName: $_aliasNameGenerator(
      db.assessmentForms.id,
      db.photos.assessmentFormId,
    ),
  );

  $$PhotosTableProcessedTableManager get photosRefs {
    final manager = $$PhotosTableTableManager($_db, $_db.photos).filter(
      (f) => f.assessmentFormId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_photosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssessmentFormsTableFilterComposer
    extends Composer<_$AppDatabase, $AssessmentFormsTable> {
  $$AssessmentFormsTableFilterComposer({
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

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSubmitted => $composableBuilder(
    column: $table.isSubmitted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get submissionDate => $composableBuilder(
    column: $table.submissionDate,
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

  $$AssessorInfosTableFilterComposer get assessorInfoId {
    final $$AssessorInfosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessorInfoId,
      referencedTable: $db.assessorInfos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessorInfosTableFilterComposer(
            $db: $db,
            $table: $db.assessorInfos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GeoLocationsTableFilterComposer get geoLocationId {
    final $$GeoLocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.geoLocationId,
      referencedTable: $db.geoLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GeoLocationsTableFilterComposer(
            $db: $db,
            $table: $db.geoLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FacilityIdentificationsTableFilterComposer get facilityIdentificationId {
    final $$FacilityIdentificationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.facilityIdentificationId,
          referencedTable: $db.facilityIdentifications,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FacilityIdentificationsTableFilterComposer(
                $db: $db,
                $table: $db.facilityIdentifications,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$FacilityServicesTableFilterComposer get facilityServicesId {
    final $$FacilityServicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityServicesId,
      referencedTable: $db.facilityServices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilityServicesTableFilterComposer(
            $db: $db,
            $table: $db.facilityServices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> assessmentSectionsRefs(
    Expression<bool> Function($$AssessmentSectionsTableFilterComposer f) f,
  ) {
    final $$AssessmentSectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessmentSections,
      getReferencedColumn: (t) => t.assessmentFormId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentSectionsTableFilterComposer(
            $db: $db,
            $table: $db.assessmentSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> photosRefs(
    Expression<bool> Function($$PhotosTableFilterComposer f) f,
  ) {
    final $$PhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.assessmentFormId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableFilterComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssessmentFormsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssessmentFormsTable> {
  $$AssessmentFormsTableOrderingComposer({
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

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSubmitted => $composableBuilder(
    column: $table.isSubmitted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get submissionDate => $composableBuilder(
    column: $table.submissionDate,
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

  $$AssessorInfosTableOrderingComposer get assessorInfoId {
    final $$AssessorInfosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessorInfoId,
      referencedTable: $db.assessorInfos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessorInfosTableOrderingComposer(
            $db: $db,
            $table: $db.assessorInfos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GeoLocationsTableOrderingComposer get geoLocationId {
    final $$GeoLocationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.geoLocationId,
      referencedTable: $db.geoLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GeoLocationsTableOrderingComposer(
            $db: $db,
            $table: $db.geoLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FacilityIdentificationsTableOrderingComposer get facilityIdentificationId {
    final $$FacilityIdentificationsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.facilityIdentificationId,
          referencedTable: $db.facilityIdentifications,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FacilityIdentificationsTableOrderingComposer(
                $db: $db,
                $table: $db.facilityIdentifications,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$FacilityServicesTableOrderingComposer get facilityServicesId {
    final $$FacilityServicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityServicesId,
      referencedTable: $db.facilityServices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilityServicesTableOrderingComposer(
            $db: $db,
            $table: $db.facilityServices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssessmentFormsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssessmentFormsTable> {
  $$AssessmentFormsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isSubmitted => $composableBuilder(
    column: $table.isSubmitted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get submissionDate => $composableBuilder(
    column: $table.submissionDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AssessorInfosTableAnnotationComposer get assessorInfoId {
    final $$AssessorInfosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessorInfoId,
      referencedTable: $db.assessorInfos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessorInfosTableAnnotationComposer(
            $db: $db,
            $table: $db.assessorInfos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GeoLocationsTableAnnotationComposer get geoLocationId {
    final $$GeoLocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.geoLocationId,
      referencedTable: $db.geoLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GeoLocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.geoLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FacilityIdentificationsTableAnnotationComposer
  get facilityIdentificationId {
    final $$FacilityIdentificationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.facilityIdentificationId,
          referencedTable: $db.facilityIdentifications,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FacilityIdentificationsTableAnnotationComposer(
                $db: $db,
                $table: $db.facilityIdentifications,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$FacilityServicesTableAnnotationComposer get facilityServicesId {
    final $$FacilityServicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityServicesId,
      referencedTable: $db.facilityServices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilityServicesTableAnnotationComposer(
            $db: $db,
            $table: $db.facilityServices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> assessmentSectionsRefs<T extends Object>(
    Expression<T> Function($$AssessmentSectionsTableAnnotationComposer a) f,
  ) {
    final $$AssessmentSectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.assessmentSections,
          getReferencedColumn: (t) => t.assessmentFormId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssessmentSectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.assessmentSections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> photosRefs<T extends Object>(
    Expression<T> Function($$PhotosTableAnnotationComposer a) f,
  ) {
    final $$PhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.assessmentFormId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssessmentFormsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssessmentFormsTable,
          AssessmentFormData,
          $$AssessmentFormsTableFilterComposer,
          $$AssessmentFormsTableOrderingComposer,
          $$AssessmentFormsTableAnnotationComposer,
          $$AssessmentFormsTableCreateCompanionBuilder,
          $$AssessmentFormsTableUpdateCompanionBuilder,
          (AssessmentFormData, $$AssessmentFormsTableReferences),
          AssessmentFormData,
          PrefetchHooks Function({
            bool assessorInfoId,
            bool geoLocationId,
            bool facilityIdentificationId,
            bool facilityServicesId,
            bool assessmentSectionsRefs,
            bool photosRefs,
          })
        > {
  $$AssessmentFormsTableTableManager(
    _$AppDatabase db,
    $AssessmentFormsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$AssessmentFormsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AssessmentFormsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$AssessmentFormsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> assessorInfoId = const Value.absent(),
                Value<String> geoLocationId = const Value.absent(),
                Value<String> facilityIdentificationId = const Value.absent(),
                Value<String> facilityServicesId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isSubmitted = const Value.absent(),
                Value<DateTime?> submissionDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssessmentFormsCompanion(
                id: id,
                assessorInfoId: assessorInfoId,
                geoLocationId: geoLocationId,
                facilityIdentificationId: facilityIdentificationId,
                facilityServicesId: facilityServicesId,
                notes: notes,
                isSubmitted: isSubmitted,
                submissionDate: submissionDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String assessorInfoId,
                required String geoLocationId,
                required String facilityIdentificationId,
                required String facilityServicesId,
                Value<String?> notes = const Value.absent(),
                Value<bool> isSubmitted = const Value.absent(),
                Value<DateTime?> submissionDate = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AssessmentFormsCompanion.insert(
                id: id,
                assessorInfoId: assessorInfoId,
                geoLocationId: geoLocationId,
                facilityIdentificationId: facilityIdentificationId,
                facilityServicesId: facilityServicesId,
                notes: notes,
                isSubmitted: isSubmitted,
                submissionDate: submissionDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$AssessmentFormsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            assessorInfoId = false,
            geoLocationId = false,
            facilityIdentificationId = false,
            facilityServicesId = false,
            assessmentSectionsRefs = false,
            photosRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assessmentSectionsRefs) db.assessmentSections,
                if (photosRefs) db.photos,
              ],
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
                  dynamic
                >
              >(state) {
                if (assessorInfoId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.assessorInfoId,
                            referencedTable: $$AssessmentFormsTableReferences
                                ._assessorInfoIdTable(db),
                            referencedColumn:
                                $$AssessmentFormsTableReferences
                                    ._assessorInfoIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (geoLocationId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.geoLocationId,
                            referencedTable: $$AssessmentFormsTableReferences
                                ._geoLocationIdTable(db),
                            referencedColumn:
                                $$AssessmentFormsTableReferences
                                    ._geoLocationIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (facilityIdentificationId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.facilityIdentificationId,
                            referencedTable: $$AssessmentFormsTableReferences
                                ._facilityIdentificationIdTable(db),
                            referencedColumn:
                                $$AssessmentFormsTableReferences
                                    ._facilityIdentificationIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (facilityServicesId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.facilityServicesId,
                            referencedTable: $$AssessmentFormsTableReferences
                                ._facilityServicesIdTable(db),
                            referencedColumn:
                                $$AssessmentFormsTableReferences
                                    ._facilityServicesIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assessmentSectionsRefs)
                    await $_getPrefetchedData<
                      AssessmentFormData,
                      $AssessmentFormsTable,
                      AssessmentSectionData
                    >(
                      currentTable: table,
                      referencedTable: $$AssessmentFormsTableReferences
                          ._assessmentSectionsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AssessmentFormsTableReferences(
                                db,
                                table,
                                p0,
                              ).assessmentSectionsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.assessmentFormId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (photosRefs)
                    await $_getPrefetchedData<
                      AssessmentFormData,
                      $AssessmentFormsTable,
                      Photo
                    >(
                      currentTable: table,
                      referencedTable: $$AssessmentFormsTableReferences
                          ._photosRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AssessmentFormsTableReferences(
                                db,
                                table,
                                p0,
                              ).photosRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.assessmentFormId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AssessmentFormsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssessmentFormsTable,
      AssessmentFormData,
      $$AssessmentFormsTableFilterComposer,
      $$AssessmentFormsTableOrderingComposer,
      $$AssessmentFormsTableAnnotationComposer,
      $$AssessmentFormsTableCreateCompanionBuilder,
      $$AssessmentFormsTableUpdateCompanionBuilder,
      (AssessmentFormData, $$AssessmentFormsTableReferences),
      AssessmentFormData,
      PrefetchHooks Function({
        bool assessorInfoId,
        bool geoLocationId,
        bool facilityIdentificationId,
        bool facilityServicesId,
        bool assessmentSectionsRefs,
        bool photosRefs,
      })
    >;
typedef $$AssessmentSectionsTableCreateCompanionBuilder =
    AssessmentSectionsCompanion Function({
      required String id,
      required String assessmentFormId,
      required String sectionNumber,
      required String title,
      required String description,
      Value<int> rowid,
    });
typedef $$AssessmentSectionsTableUpdateCompanionBuilder =
    AssessmentSectionsCompanion Function({
      Value<String> id,
      Value<String> assessmentFormId,
      Value<String> sectionNumber,
      Value<String> title,
      Value<String> description,
      Value<int> rowid,
    });

final class $$AssessmentSectionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AssessmentSectionsTable,
          AssessmentSectionData
        > {
  $$AssessmentSectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssessmentFormsTable _assessmentFormIdTable(_$AppDatabase db) =>
      db.assessmentForms.createAlias(
        $_aliasNameGenerator(
          db.assessmentSections.assessmentFormId,
          db.assessmentForms.id,
        ),
      );

  $$AssessmentFormsTableProcessedTableManager get assessmentFormId {
    final $_column = $_itemColumn<String>('assessment_form_id')!;

    final manager = $$AssessmentFormsTableTableManager(
      $_db,
      $_db.assessmentForms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assessmentFormIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AssessmentItemsTable, List<AssessmentItemData>>
  _assessmentItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessmentItems,
    aliasName: $_aliasNameGenerator(
      db.assessmentSections.id,
      db.assessmentItems.sectionId,
    ),
  );

  $$AssessmentItemsTableProcessedTableManager get assessmentItemsRefs {
    final manager = $$AssessmentItemsTableTableManager(
      $_db,
      $_db.assessmentItems,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assessmentItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssessmentSectionsTableFilterComposer
    extends Composer<_$AppDatabase, $AssessmentSectionsTable> {
  $$AssessmentSectionsTableFilterComposer({
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

  ColumnFilters<String> get sectionNumber => $composableBuilder(
    column: $table.sectionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  $$AssessmentFormsTableFilterComposer get assessmentFormId {
    final $$AssessmentFormsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentFormId,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableFilterComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> assessmentItemsRefs(
    Expression<bool> Function($$AssessmentItemsTableFilterComposer f) f,
  ) {
    final $$AssessmentItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessmentItems,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentItemsTableFilterComposer(
            $db: $db,
            $table: $db.assessmentItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssessmentSectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssessmentSectionsTable> {
  $$AssessmentSectionsTableOrderingComposer({
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

  ColumnOrderings<String> get sectionNumber => $composableBuilder(
    column: $table.sectionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssessmentFormsTableOrderingComposer get assessmentFormId {
    final $$AssessmentFormsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentFormId,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableOrderingComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssessmentSectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssessmentSectionsTable> {
  $$AssessmentSectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sectionNumber => $composableBuilder(
    column: $table.sectionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  $$AssessmentFormsTableAnnotationComposer get assessmentFormId {
    final $$AssessmentFormsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentFormId,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableAnnotationComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> assessmentItemsRefs<T extends Object>(
    Expression<T> Function($$AssessmentItemsTableAnnotationComposer a) f,
  ) {
    final $$AssessmentItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessmentItems,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.assessmentItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssessmentSectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssessmentSectionsTable,
          AssessmentSectionData,
          $$AssessmentSectionsTableFilterComposer,
          $$AssessmentSectionsTableOrderingComposer,
          $$AssessmentSectionsTableAnnotationComposer,
          $$AssessmentSectionsTableCreateCompanionBuilder,
          $$AssessmentSectionsTableUpdateCompanionBuilder,
          (AssessmentSectionData, $$AssessmentSectionsTableReferences),
          AssessmentSectionData,
          PrefetchHooks Function({
            bool assessmentFormId,
            bool assessmentItemsRefs,
          })
        > {
  $$AssessmentSectionsTableTableManager(
    _$AppDatabase db,
    $AssessmentSectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AssessmentSectionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$AssessmentSectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$AssessmentSectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> assessmentFormId = const Value.absent(),
                Value<String> sectionNumber = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssessmentSectionsCompanion(
                id: id,
                assessmentFormId: assessmentFormId,
                sectionNumber: sectionNumber,
                title: title,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String assessmentFormId,
                required String sectionNumber,
                required String title,
                required String description,
                Value<int> rowid = const Value.absent(),
              }) => AssessmentSectionsCompanion.insert(
                id: id,
                assessmentFormId: assessmentFormId,
                sectionNumber: sectionNumber,
                title: title,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$AssessmentSectionsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            assessmentFormId = false,
            assessmentItemsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assessmentItemsRefs) db.assessmentItems,
              ],
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
                  dynamic
                >
              >(state) {
                if (assessmentFormId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.assessmentFormId,
                            referencedTable: $$AssessmentSectionsTableReferences
                                ._assessmentFormIdTable(db),
                            referencedColumn:
                                $$AssessmentSectionsTableReferences
                                    ._assessmentFormIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assessmentItemsRefs)
                    await $_getPrefetchedData<
                      AssessmentSectionData,
                      $AssessmentSectionsTable,
                      AssessmentItemData
                    >(
                      currentTable: table,
                      referencedTable: $$AssessmentSectionsTableReferences
                          ._assessmentItemsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AssessmentSectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).assessmentItemsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.sectionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AssessmentSectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssessmentSectionsTable,
      AssessmentSectionData,
      $$AssessmentSectionsTableFilterComposer,
      $$AssessmentSectionsTableOrderingComposer,
      $$AssessmentSectionsTableAnnotationComposer,
      $$AssessmentSectionsTableCreateCompanionBuilder,
      $$AssessmentSectionsTableUpdateCompanionBuilder,
      (AssessmentSectionData, $$AssessmentSectionsTableReferences),
      AssessmentSectionData,
      PrefetchHooks Function({bool assessmentFormId, bool assessmentItemsRefs})
    >;
typedef $$AssessmentRatingsTableCreateCompanionBuilder =
    AssessmentRatingsCompanion Function({
      required String id,
      required int value,
      required String label,
      Value<int> rowid,
    });
typedef $$AssessmentRatingsTableUpdateCompanionBuilder =
    AssessmentRatingsCompanion Function({
      Value<String> id,
      Value<int> value,
      Value<String> label,
      Value<int> rowid,
    });

final class $$AssessmentRatingsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AssessmentRatingsTable,
          AssessmentRatingData
        > {
  $$AssessmentRatingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AssessmentItemsTable, List<AssessmentItemData>>
  _assessmentItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessmentItems,
    aliasName: $_aliasNameGenerator(
      db.assessmentRatings.id,
      db.assessmentItems.selectedRatingId,
    ),
  );

  $$AssessmentItemsTableProcessedTableManager get assessmentItemsRefs {
    final manager = $$AssessmentItemsTableTableManager(
      $_db,
      $_db.assessmentItems,
    ).filter(
      (f) => f.selectedRatingId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(
      _assessmentItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssessmentRatingsTableFilterComposer
    extends Composer<_$AppDatabase, $AssessmentRatingsTable> {
  $$AssessmentRatingsTableFilterComposer({
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

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assessmentItemsRefs(
    Expression<bool> Function($$AssessmentItemsTableFilterComposer f) f,
  ) {
    final $$AssessmentItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessmentItems,
      getReferencedColumn: (t) => t.selectedRatingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentItemsTableFilterComposer(
            $db: $db,
            $table: $db.assessmentItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssessmentRatingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssessmentRatingsTable> {
  $$AssessmentRatingsTableOrderingComposer({
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

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssessmentRatingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssessmentRatingsTable> {
  $$AssessmentRatingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  Expression<T> assessmentItemsRefs<T extends Object>(
    Expression<T> Function($$AssessmentItemsTableAnnotationComposer a) f,
  ) {
    final $$AssessmentItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessmentItems,
      getReferencedColumn: (t) => t.selectedRatingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.assessmentItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssessmentRatingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssessmentRatingsTable,
          AssessmentRatingData,
          $$AssessmentRatingsTableFilterComposer,
          $$AssessmentRatingsTableOrderingComposer,
          $$AssessmentRatingsTableAnnotationComposer,
          $$AssessmentRatingsTableCreateCompanionBuilder,
          $$AssessmentRatingsTableUpdateCompanionBuilder,
          (AssessmentRatingData, $$AssessmentRatingsTableReferences),
          AssessmentRatingData,
          PrefetchHooks Function({bool assessmentItemsRefs})
        > {
  $$AssessmentRatingsTableTableManager(
    _$AppDatabase db,
    $AssessmentRatingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AssessmentRatingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$AssessmentRatingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$AssessmentRatingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssessmentRatingsCompanion(
                id: id,
                value: value,
                label: label,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int value,
                required String label,
                Value<int> rowid = const Value.absent(),
              }) => AssessmentRatingsCompanion.insert(
                id: id,
                value: value,
                label: label,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$AssessmentRatingsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({assessmentItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assessmentItemsRefs) db.assessmentItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assessmentItemsRefs)
                    await $_getPrefetchedData<
                      AssessmentRatingData,
                      $AssessmentRatingsTable,
                      AssessmentItemData
                    >(
                      currentTable: table,
                      referencedTable: $$AssessmentRatingsTableReferences
                          ._assessmentItemsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$AssessmentRatingsTableReferences(
                                db,
                                table,
                                p0,
                              ).assessmentItemsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.selectedRatingId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AssessmentRatingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssessmentRatingsTable,
      AssessmentRatingData,
      $$AssessmentRatingsTableFilterComposer,
      $$AssessmentRatingsTableOrderingComposer,
      $$AssessmentRatingsTableAnnotationComposer,
      $$AssessmentRatingsTableCreateCompanionBuilder,
      $$AssessmentRatingsTableUpdateCompanionBuilder,
      (AssessmentRatingData, $$AssessmentRatingsTableReferences),
      AssessmentRatingData,
      PrefetchHooks Function({bool assessmentItemsRefs})
    >;
typedef $$AssessmentItemsTableCreateCompanionBuilder =
    AssessmentItemsCompanion Function({
      Value<int> id,
      required String itemNumber,
      required String sectionId,
      required String sectionNumber,
      required String area,
      required String meetsTargetDescription,
      required String partiallyMeetsDescription,
      required String doesNotMeetDescription,
      Value<String?> selectedRatingId,
    });
typedef $$AssessmentItemsTableUpdateCompanionBuilder =
    AssessmentItemsCompanion Function({
      Value<int> id,
      Value<String> itemNumber,
      Value<String> sectionId,
      Value<String> sectionNumber,
      Value<String> area,
      Value<String> meetsTargetDescription,
      Value<String> partiallyMeetsDescription,
      Value<String> doesNotMeetDescription,
      Value<String?> selectedRatingId,
    });

final class $$AssessmentItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AssessmentItemsTable,
          AssessmentItemData
        > {
  $$AssessmentItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssessmentSectionsTable _sectionIdTable(_$AppDatabase db) =>
      db.assessmentSections.createAlias(
        $_aliasNameGenerator(
          db.assessmentItems.sectionId,
          db.assessmentSections.id,
        ),
      );

  $$AssessmentSectionsTableProcessedTableManager get sectionId {
    final $_column = $_itemColumn<String>('section_id')!;

    final manager = $$AssessmentSectionsTableTableManager(
      $_db,
      $_db.assessmentSections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AssessmentRatingsTable _selectedRatingIdTable(_$AppDatabase db) =>
      db.assessmentRatings.createAlias(
        $_aliasNameGenerator(
          db.assessmentItems.selectedRatingId,
          db.assessmentRatings.id,
        ),
      );

  $$AssessmentRatingsTableProcessedTableManager? get selectedRatingId {
    final $_column = $_itemColumn<String>('selected_rating_id');
    if ($_column == null) return null;
    final manager = $$AssessmentRatingsTableTableManager(
      $_db,
      $_db.assessmentRatings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_selectedRatingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssessmentItemsTableFilterComposer
    extends Composer<_$AppDatabase, $AssessmentItemsTable> {
  $$AssessmentItemsTableFilterComposer({
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

  ColumnFilters<String> get itemNumber => $composableBuilder(
    column: $table.itemNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectionNumber => $composableBuilder(
    column: $table.sectionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meetsTargetDescription => $composableBuilder(
    column: $table.meetsTargetDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partiallyMeetsDescription => $composableBuilder(
    column: $table.partiallyMeetsDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doesNotMeetDescription => $composableBuilder(
    column: $table.doesNotMeetDescription,
    builder: (column) => ColumnFilters(column),
  );

  $$AssessmentSectionsTableFilterComposer get sectionId {
    final $$AssessmentSectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.assessmentSections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentSectionsTableFilterComposer(
            $db: $db,
            $table: $db.assessmentSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssessmentRatingsTableFilterComposer get selectedRatingId {
    final $$AssessmentRatingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.selectedRatingId,
      referencedTable: $db.assessmentRatings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentRatingsTableFilterComposer(
            $db: $db,
            $table: $db.assessmentRatings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssessmentItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssessmentItemsTable> {
  $$AssessmentItemsTableOrderingComposer({
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

  ColumnOrderings<String> get itemNumber => $composableBuilder(
    column: $table.itemNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectionNumber => $composableBuilder(
    column: $table.sectionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meetsTargetDescription => $composableBuilder(
    column: $table.meetsTargetDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partiallyMeetsDescription => $composableBuilder(
    column: $table.partiallyMeetsDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doesNotMeetDescription => $composableBuilder(
    column: $table.doesNotMeetDescription,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssessmentSectionsTableOrderingComposer get sectionId {
    final $$AssessmentSectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.assessmentSections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentSectionsTableOrderingComposer(
            $db: $db,
            $table: $db.assessmentSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssessmentRatingsTableOrderingComposer get selectedRatingId {
    final $$AssessmentRatingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.selectedRatingId,
      referencedTable: $db.assessmentRatings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentRatingsTableOrderingComposer(
            $db: $db,
            $table: $db.assessmentRatings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssessmentItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssessmentItemsTable> {
  $$AssessmentItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemNumber => $composableBuilder(
    column: $table.itemNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sectionNumber => $composableBuilder(
    column: $table.sectionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<String> get meetsTargetDescription => $composableBuilder(
    column: $table.meetsTargetDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partiallyMeetsDescription => $composableBuilder(
    column: $table.partiallyMeetsDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doesNotMeetDescription => $composableBuilder(
    column: $table.doesNotMeetDescription,
    builder: (column) => column,
  );

  $$AssessmentSectionsTableAnnotationComposer get sectionId {
    final $$AssessmentSectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sectionId,
          referencedTable: $db.assessmentSections,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssessmentSectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.assessmentSections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$AssessmentRatingsTableAnnotationComposer get selectedRatingId {
    final $$AssessmentRatingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.selectedRatingId,
          referencedTable: $db.assessmentRatings,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssessmentRatingsTableAnnotationComposer(
                $db: $db,
                $table: $db.assessmentRatings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AssessmentItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssessmentItemsTable,
          AssessmentItemData,
          $$AssessmentItemsTableFilterComposer,
          $$AssessmentItemsTableOrderingComposer,
          $$AssessmentItemsTableAnnotationComposer,
          $$AssessmentItemsTableCreateCompanionBuilder,
          $$AssessmentItemsTableUpdateCompanionBuilder,
          (AssessmentItemData, $$AssessmentItemsTableReferences),
          AssessmentItemData,
          PrefetchHooks Function({bool sectionId, bool selectedRatingId})
        > {
  $$AssessmentItemsTableTableManager(
    _$AppDatabase db,
    $AssessmentItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$AssessmentItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AssessmentItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$AssessmentItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> itemNumber = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<String> sectionNumber = const Value.absent(),
                Value<String> area = const Value.absent(),
                Value<String> meetsTargetDescription = const Value.absent(),
                Value<String> partiallyMeetsDescription = const Value.absent(),
                Value<String> doesNotMeetDescription = const Value.absent(),
                Value<String?> selectedRatingId = const Value.absent(),
              }) => AssessmentItemsCompanion(
                id: id,
                itemNumber: itemNumber,
                sectionId: sectionId,
                sectionNumber: sectionNumber,
                area: area,
                meetsTargetDescription: meetsTargetDescription,
                partiallyMeetsDescription: partiallyMeetsDescription,
                doesNotMeetDescription: doesNotMeetDescription,
                selectedRatingId: selectedRatingId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String itemNumber,
                required String sectionId,
                required String sectionNumber,
                required String area,
                required String meetsTargetDescription,
                required String partiallyMeetsDescription,
                required String doesNotMeetDescription,
                Value<String?> selectedRatingId = const Value.absent(),
              }) => AssessmentItemsCompanion.insert(
                id: id,
                itemNumber: itemNumber,
                sectionId: sectionId,
                sectionNumber: sectionNumber,
                area: area,
                meetsTargetDescription: meetsTargetDescription,
                partiallyMeetsDescription: partiallyMeetsDescription,
                doesNotMeetDescription: doesNotMeetDescription,
                selectedRatingId: selectedRatingId,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$AssessmentItemsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            sectionId = false,
            selectedRatingId = false,
          }) {
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
                  dynamic
                >
              >(state) {
                if (sectionId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.sectionId,
                            referencedTable: $$AssessmentItemsTableReferences
                                ._sectionIdTable(db),
                            referencedColumn:
                                $$AssessmentItemsTableReferences
                                    ._sectionIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (selectedRatingId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.selectedRatingId,
                            referencedTable: $$AssessmentItemsTableReferences
                                ._selectedRatingIdTable(db),
                            referencedColumn:
                                $$AssessmentItemsTableReferences
                                    ._selectedRatingIdTable(db)
                                    .id,
                          )
                          as T;
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

typedef $$AssessmentItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssessmentItemsTable,
      AssessmentItemData,
      $$AssessmentItemsTableFilterComposer,
      $$AssessmentItemsTableOrderingComposer,
      $$AssessmentItemsTableAnnotationComposer,
      $$AssessmentItemsTableCreateCompanionBuilder,
      $$AssessmentItemsTableUpdateCompanionBuilder,
      (AssessmentItemData, $$AssessmentItemsTableReferences),
      AssessmentItemData,
      PrefetchHooks Function({bool sectionId, bool selectedRatingId})
    >;
typedef $$PhotosTableCreateCompanionBuilder =
    PhotosCompanion Function({
      required String id,
      required String assessmentFormId,
      required String fileName,
      required String filePath,
      required String source,
      required int fileSizeBytes,
      required DateTime capturedAt,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PhotosTableUpdateCompanionBuilder =
    PhotosCompanion Function({
      Value<String> id,
      Value<String> assessmentFormId,
      Value<String> fileName,
      Value<String> filePath,
      Value<String> source,
      Value<int> fileSizeBytes,
      Value<DateTime> capturedAt,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PhotosTableReferences
    extends BaseReferences<_$AppDatabase, $PhotosTable, Photo> {
  $$PhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AssessmentFormsTable _assessmentFormIdTable(_$AppDatabase db) =>
      db.assessmentForms.createAlias(
        $_aliasNameGenerator(db.photos.assessmentFormId, db.assessmentForms.id),
      );

  $$AssessmentFormsTableProcessedTableManager get assessmentFormId {
    final $_column = $_itemColumn<String>('assessment_form_id')!;

    final manager = $$AssessmentFormsTableTableManager(
      $_db,
      $_db.assessmentForms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assessmentFormIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
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

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AssessmentFormsTableFilterComposer get assessmentFormId {
    final $$AssessmentFormsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentFormId,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableFilterComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
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

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssessmentFormsTableOrderingComposer get assessmentFormId {
    final $$AssessmentFormsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentFormId,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableOrderingComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AssessmentFormsTableAnnotationComposer get assessmentFormId {
    final $$AssessmentFormsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentFormId,
      referencedTable: $db.assessmentForms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentFormsTableAnnotationComposer(
            $db: $db,
            $table: $db.assessmentForms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          Photo,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (Photo, $$PhotosTableReferences),
          Photo,
          PrefetchHooks Function({bool assessmentFormId})
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> assessmentFormId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion(
                id: id,
                assessmentFormId: assessmentFormId,
                fileName: fileName,
                filePath: filePath,
                source: source,
                fileSizeBytes: fileSizeBytes,
                capturedAt: capturedAt,
                description: description,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String assessmentFormId,
                required String fileName,
                required String filePath,
                required String source,
                required int fileSizeBytes,
                required DateTime capturedAt,
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion.insert(
                id: id,
                assessmentFormId: assessmentFormId,
                fileName: fileName,
                filePath: filePath,
                source: source,
                fileSizeBytes: fileSizeBytes,
                capturedAt: capturedAt,
                description: description,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$PhotosTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({assessmentFormId = false}) {
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
                  dynamic
                >
              >(state) {
                if (assessmentFormId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.assessmentFormId,
                            referencedTable: $$PhotosTableReferences
                                ._assessmentFormIdTable(db),
                            referencedColumn:
                                $$PhotosTableReferences
                                    ._assessmentFormIdTable(db)
                                    .id,
                          )
                          as T;
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

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      Photo,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (Photo, $$PhotosTableReferences),
      Photo,
      PrefetchHooks Function({bool assessmentFormId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AssessorInfosTableTableManager get assessorInfos =>
      $$AssessorInfosTableTableManager(_db, _db.assessorInfos);
  $$GeoLocationsTableTableManager get geoLocations =>
      $$GeoLocationsTableTableManager(_db, _db.geoLocations);
  $$FacilityIdentificationsTableTableManager get facilityIdentifications =>
      $$FacilityIdentificationsTableTableManager(
        _db,
        _db.facilityIdentifications,
      );
  $$FacilityServicesTableTableManager get facilityServices =>
      $$FacilityServicesTableTableManager(_db, _db.facilityServices);
  $$AssessmentFormsTableTableManager get assessmentForms =>
      $$AssessmentFormsTableTableManager(_db, _db.assessmentForms);
  $$AssessmentSectionsTableTableManager get assessmentSections =>
      $$AssessmentSectionsTableTableManager(_db, _db.assessmentSections);
  $$AssessmentRatingsTableTableManager get assessmentRatings =>
      $$AssessmentRatingsTableTableManager(_db, _db.assessmentRatings);
  $$AssessmentItemsTableTableManager get assessmentItems =>
      $$AssessmentItemsTableTableManager(_db, _db.assessmentItems);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
}
