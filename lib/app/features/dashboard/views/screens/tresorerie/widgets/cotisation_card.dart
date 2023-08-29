// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:Benjamin/app/features/network_utils/api.dart';
import 'package:Benjamin/model/cotisation_model.dart';
import 'package:Benjamin/model/cotisationdetails_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:intl/intl.dart';

class CotisationCard extends StatefulWidget {
  const CotisationCard({required this.data, Key? key}) : super(key: key);

  final CotisationModel data;

  @override
  State<CotisationCard> createState() => _CotisationCardState();
}

class _CotisationCardState extends State<CotisationCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: kSpacing),
          leading: GestureDetector(
            onTap: () {
              showMember(widget.data.nom, widget.data.prenoms, '');
            },
            child: const CircleAvatar(
                backgroundImage: AssetImage(ImageRasterPath.avatar1)),
          ),
          title: Text(
            '${widget.data.mois}',
            style: TextStyle(
              fontSize: 14,
              color: kFontColorPallets[0],
            ),
          ),
          subtitle: Text(
            widget.data.libelle == null ? '' : '${widget.data.libelle}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              montantWidget(widget.data.montant),
              GestureDetector(
                  onTap: () {
                    fetchCotisationDetails(widget.data.id);
                    showCotisationsDetails();
                  },
                  child: const Icon(Icons.remove_red_eye, color: Colors.blue))
            ],
          ),
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

  Future<void> showMember(nom, prenom, image) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$nom $prenom'),
          content: const SingleChildScrollView(
            child: CircleAvatar(
                radius: 150,
                backgroundImage: AssetImage(ImageRasterPath.avatar1)),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Ok', style: TextStyle(color: Colors.greenAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List cotisationDetails = [];
  void fetchCotisationDetails(cotisationid) async {
    try {
      final response =
          await Network().getData('/cotisation/get/details/$cotisationid');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          cotisationDetails = data
              .map((details) => CotisationDetailModel.fromJson(details))
              .toList();
        });
      }
    } catch (e) {
      log("$e");
    }
  }

  Future<void> showCotisationsDetails() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Détails de cotisations'),
          content: Column(
            children: [
              ...cotisationDetails.map((e) => details(
                    data: e,
                  )),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Ok', style: TextStyle(color: Colors.greenAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget details({required CotisationDetailModel data}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: kSpacing),
          title: Text(
            DateFormat.yMMMEd().format(data.createdAt),
            style: TextStyle(
              fontSize: 14,
              color: kFontColorPallets[0],
            ),
          ),
          trailing: montantWidget(data.montant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
