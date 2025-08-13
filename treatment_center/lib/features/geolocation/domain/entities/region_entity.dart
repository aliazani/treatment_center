import 'package:equatable/equatable.dart';

class RegionEntity extends Equatable {
  final int id;
  final String name;
  final String countryCode;
  final String stateCode;

  const RegionEntity({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.stateCode,
  });

  @override
  List<Object?> get props => [id, name, countryCode, stateCode];
}
