import 'package:json_annotation/json_annotation.dart';
part 'budget_model.g.dart';

@JsonSerializable()
class BudgetModel {
  BudgetModel(this.id, this.annee, this.montant, this.atteint);

  var id;
  final String? annee;

  var montant;
  var atteint;
  var description;

  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetModelToJson(this);
}
