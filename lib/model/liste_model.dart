import 'package:json_annotation/json_annotation.dart';
part 'liste_model.g.dart';

@JsonSerializable()
class ListePresenceModel {
  ListePresenceModel(this.id, this.nom, this.prenoms, this.stats);

  int id = 0;
  String nom = "";
  String prenoms = "";
  List<ListePresenceModel> stats = [];

  factory ListePresenceModel.fromJson(Map<String, dynamic> json) =>
      _$ListePresenceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ListePresenceModelToJson(this);
}
