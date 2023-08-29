import 'package:json_annotation/json_annotation.dart';
part 'cotisationdetails_model.g.dart';

@JsonSerializable()
class CotisationDetailModel {
  CotisationDetailModel(this.id, this.montant, this.createdAt);

  var id;
  var montant;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  factory CotisationDetailModel.fromJson(Map<String, dynamic> json) =>
      _$CotisationDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$CotisationDetailModelToJson(this);
}
