// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cotisation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CotisationModel _$CotisationModelFromJson(Map<String, dynamic> json) =>
    CotisationModel(
      json['id'],
      json['libelle'] as String?,
      json['date'],
      json['mois'],
      json['montant'],
      json['membre_id'] as int?,
      json['nom'],
      json['prenoms'],
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CotisationModelToJson(CotisationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'libelle': instance.libelle,
      'date': instance.date,
      'mois': instance.mois,
      'montant': instance.montant,
      'membre_id': instance.membreId,
      'nom': instance.nom,
      'prenoms': instance.prenoms,
      'created_at': instance.createdAt?.toIso8601String(),
    };
