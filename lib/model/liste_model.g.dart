// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liste_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListePresenceModel _$ListePresenceModelFromJson(Map<String, dynamic> json) =>
    ListePresenceModel(
      json['id'] as int,
      json['nom'] as String,
      json['prenoms'] as String,
      (json['stats'] as List<dynamic>)
          .map((e) => ListePresenceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ListePresenceModelToJson(ListePresenceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prenoms': instance.prenoms,
      'stats': instance.stats,
    };
