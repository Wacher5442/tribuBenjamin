// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actionsocial_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionSociale _$ActionSocialeFromJson(Map<String, dynamic> json) =>
    ActionSociale(
      json['id'],
      json['libelle'] as String?,
      json['desc'] as String?,
      json['montant'],
      DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$ActionSocialeToJson(ActionSociale instance) =>
    <String, dynamic>{
      'id': instance.id,
      'libelle': instance.libelle,
      'desc': instance.desc,
      'montant': instance.montant,
      'date': instance.date.toIso8601String(),
    };
