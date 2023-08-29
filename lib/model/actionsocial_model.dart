import 'package:json_annotation/json_annotation.dart';
part 'actionsocial_model.g.dart';

@JsonSerializable()
class ActionSociale {
  ActionSociale(this.id, this.libelle, this.desc, this.montant, this.date);

  var id;
  final String? libelle;
  final String? desc;
  var montant;
  final DateTime date;

  factory ActionSociale.fromJson(Map<String, dynamic> json) =>
      _$ActionSocialeFromJson(json);

  Map<String, dynamic> toJson() => _$ActionSocialeToJson(this);
}
