import 'package:json_annotation/json_annotation.dart';
part 'visite_model.g.dart';

@JsonSerializable()
class VisiteModel {
  VisiteModel(this.id, this.libelle, this.type, this.raison, this.date);

  var id;
  final String? libelle;
  final String? type;
  final String? raison;
  final DateTime date;

  factory VisiteModel.fromJson(Map<String, dynamic> json) =>
      _$VisiteModelFromJson(json);

  Map<String, dynamic> toJson() => _$VisiteModelToJson(this);
}
