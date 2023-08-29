import 'package:json_annotation/json_annotation.dart';
part 'programme_model.g.dart';

@JsonSerializable()
class ProgrammeModel {
  ProgrammeModel(this.id, this.libelle, this.responsable, this.date,
      this.percent, this.description);

  var id;
  final String? libelle;

  final DateTime date;
  final String? responsable;
  final String? description;
  var percent;

  factory ProgrammeModel.fromJson(Map<String, dynamic> json) =>
      _$ProgrammeModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProgrammeModelToJson(this);
}
