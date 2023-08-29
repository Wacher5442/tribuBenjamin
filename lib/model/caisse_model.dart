import 'package:json_annotation/json_annotation.dart';
part 'caisse_model.g.dart';

@JsonSerializable()
class CaisseModel {
  CaisseModel(this.id, this.nom, this.montant, this.description);

  var id;
  final String? nom;

  var montant;
  var description;

  factory CaisseModel.fromJson(Map<String, dynamic> json) =>
      _$CaisseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CaisseModelToJson(this);
}
