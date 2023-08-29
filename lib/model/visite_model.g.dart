// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visite_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisiteModel _$VisiteModelFromJson(Map<String, dynamic> json) => VisiteModel(
      json['id'],
      json['libelle'] as String?,
      json['type'] as String?,
      json['raison'] as String?,
      DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$VisiteModelToJson(VisiteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'libelle': instance.libelle,
      'type': instance.type,
      'raison': instance.raison,
      'date': instance.date.toIso8601String(),
    };
