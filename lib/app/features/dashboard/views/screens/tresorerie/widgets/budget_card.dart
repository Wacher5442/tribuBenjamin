// ignore_for_file: use_build_context_synchronously

import 'package:Benjamin/model/budget_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Benjamin/app/constans/app_constants.dart';

class BudgetCard extends StatefulWidget {
  const BudgetCard({required this.data, Key? key}) : super(key: key);

  final BudgetModel data;

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: kSpacing),
          leading: const CircleAvatar(
              backgroundImage: AssetImage(ImageRasterPath.avatar1)),
          title: Text(
            '${widget.data.annee}',
            style: TextStyle(
              fontSize: 14,
              color: kFontColorPallets[0],
            ),
          ),
          subtitle: Text(
            widget.data.description == null ? '' : '${widget.data.description}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
          onTap: () {},
          trailing: montantWidget(widget.data.montant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget montantWidget(total) {
    return Container(
      width: 100,
      height: 30,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).primaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Text(
        "$total FCFA",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
