// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caisse_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaisseModel _$CaisseModelFromJson(Map<String, dynamic> json) => CaisseModel(
      json['id'],
      json['nom'] as String?,
      json['montant'],
      json['description'],
    );

Map<String, dynamic> _$CaisseModelToJson(CaisseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'montant': instance.montant,
      'description': instance.description,
    };
