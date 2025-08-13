import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  final int id;
  final String name;
  final String stateCode;

  const CityEntity({
    required this.id,
    required this.name,
    required this.stateCode,
  });

  @override
  List<Object?> get props => [id, name, stateCode];
}
