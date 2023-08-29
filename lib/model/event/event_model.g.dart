// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
      json['id'],
      json['libelle'] as String?,
      json['type'] as String?,
      json['desc'] as String?,
      json['budget'],
      DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'libelle': instance.libelle,
      'desc': instance.desc,
      'type': instance.type,
      'budget': instance.budget,
      'date': instance.date.toIso8601String(),
    };
