// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cotisationdetails_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CotisationDetailModel _$CotisationDetailModelFromJson(
        Map<String, dynamic> json) =>
    CotisationDetailModel(
      json['id'],
      json['montant'],
      DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CotisationDetailModelToJson(
        CotisationDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'montant': instance.montant,
      'created_at': instance.createdAt.toIso8601String(),
    };
