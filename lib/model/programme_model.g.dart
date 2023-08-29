// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programme_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgrammeModel _$ProgrammeModelFromJson(Map<String, dynamic> json) =>
    ProgrammeModel(
      json['id'],
      json['libelle'] as String?,
      json['responsable'] as String?,
      DateTime.parse(json['date'] as String),
      json['percent'],
      json['description'] as String?,
    );

Map<String, dynamic> _$ProgrammeModelToJson(ProgrammeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'libelle': instance.libelle,
      'date': instance.date.toIso8601String(),
      'responsable': instance.responsable,
      'description': instance.description,
      'percent': instance.percent,
    };
