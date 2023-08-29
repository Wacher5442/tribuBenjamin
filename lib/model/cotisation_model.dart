import 'package:json_annotation/json_annotation.dart';
part 'cotisation_model.g.dart';

@JsonSerializable()
class CotisationModel {
  CotisationModel(this.id, this.libelle, this.date, this.mois, this.montant,
      this.membreId, this.nom, this.prenoms, this.createdAt);

  var id;
  final String? libelle;

  var date;
  var mois;
  var montant;
  @JsonKey(name: 'membre_id')
  final int? membreId;
  var nom;
  var prenoms;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  factory CotisationModel.fromJson(Map<String, dynamic> json) =>
      _$CotisationModelFromJson(json);

  Map<String, dynamic> toJson() => _$CotisationModelToJson(this);
}
