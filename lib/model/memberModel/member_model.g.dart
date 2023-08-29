// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      json['id'],
      json['image'] as String?,
      json['nom'] as String?,
      json['prenoms'] as String?,
      json['departement'] as String?,
      json['baptise'] as String?,
      json['birthdate'] as String?,
      json['contact'] as String?,
      json['fonction'] as String?,
      json['imageurl'] as String?,
      json['binomeId'] as String?,
      json['membretype'] as String?,
      json['sex'] as String?,
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'nom': instance.nom,
      'prenoms': instance.prenoms,
      'departement': instance.departement,
      'baptise': instance.baptise,
      'birthdate': instance.birthdate,
      'contact': instance.contact,
      'fonction': instance.fonction,
      'imageurl': instance.imageurl,
      'binomeId': instance.binomeId,
      'membretype': instance.membretype,
      'sex': instance.sex,
    };
