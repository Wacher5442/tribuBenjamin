import 'package:json_annotation/json_annotation.dart';
part 'event_model.g.dart';

@JsonSerializable()
class EventModel {
  EventModel(
      this.id, this.libelle, this.type, this.desc, this.budget, this.date);

  var id;
  final String? libelle;
  final String? desc;
  final String? type;

  var budget;
  final DateTime date;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventModelToJson(this);
}
