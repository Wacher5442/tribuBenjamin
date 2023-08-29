// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetModel _$BudgetModelFromJson(Map<String, dynamic> json) => BudgetModel(
      json['id'],
      json['annee'] as String?,
      json['montant'],
      json['atteint'],
    )..description = json['description'];

Map<String, dynamic> _$BudgetModelToJson(BudgetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'annee': instance.annee,
      'montant': instance.montant,
      'atteint': instance.atteint,
      'description': instance.description,
    };
