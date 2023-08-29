import 'package:json_annotation/json_annotation.dart';
part 'member_model.g.dart';

@JsonSerializable()
class Member {
  Member(
      this.id,
      this.image,
      this.nom,
      this.prenoms,
      this.departement,
      this.baptise,
      this.birthdate,
      this.contact,
      this.fonction,
      this.imageurl,
      this.binomeId,
      this.membretype,
      this.sex);

  var id;
  final String? image;

  final String? nom;
  final String? prenoms;
  final String? departement;
  final String? baptise;
  final String? birthdate;

  final String? contact;
  final String? fonction;
  final String? imageurl;
  final String? binomeId;
  final String? membretype;
  final String? sex;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);
}
