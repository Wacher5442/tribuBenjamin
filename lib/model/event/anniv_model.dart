import 'package:json_annotation/json_annotation.dart';
part 'anniv_model.g.dart';

@JsonSerializable()
class AnnivModel {
  AnnivModel(this.id, this.nom);

  var id;
  final String? nom;

  factory AnnivModel.fromJson(Map<String, dynamic> json) =>
      _$AnnivModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnnivModelToJson(this);
}
