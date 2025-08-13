import 'package:equatable/equatable.dart';

class CountryEntity extends Equatable {
  final int id;
  final String name;
  final String iso2;
  final String emoji;
  final String phonecode;

  const CountryEntity({
    required this.id,
    required this.name,
    required this.iso2,
    required this.emoji,
    required this.phonecode,
  });

  @override
  List<Object?> get props => [id, name, iso2, emoji, phonecode];
}
