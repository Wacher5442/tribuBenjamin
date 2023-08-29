// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:Benjamin/app/config/global.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/info_member_screen.dart';
import 'package:Benjamin/app/features/network_utils/api.dart';
import 'package:Benjamin/model/memberModel/member_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Benjamin/app/constans/app_constants.dart';

class ChattingCard extends StatefulWidget {
  const ChattingCard(
      {required this.data,
      required this.ispresence,
      this.culte = "",
      this.date = "",
      Key? key})
      : super(key: key);

  final Member data;
  final bool ispresence;
  final String culte;
  final String date;

  @override
  State<ChattingCard> createState() => _ChattingCardState();
}

class _ChattingCardState extends State<ChattingCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: kSpacing),
          leading: Stack(
            children: [
              CircleAvatar(
                  backgroundImage: widget.data.sex == "F"
                      ? const AssetImage(ImageRasterPath.avatar6)
                      : const AssetImage(ImageRasterPath.avatar1)),
              CircleAvatar(
                backgroundColor:
                    widget.data.baptise == "Oui" ? Colors.green : Colors.red,
                radius: 5,
              ),
            ],
          ),
          title: Text(
            '${widget.data.nom}',
            style: TextStyle(
              fontSize: 14,
              color: kFontColorPallets[0],
            ),
          ),
          subtitle: Text(
            widget.data.departement == null
                ? 'Ce membre n\'a pas de departement'
                : '${widget.data.departement}',
            style: TextStyle(
              fontSize: 12,
              color:
                  widget.data.departement == null ? Colors.red : Colors.green,
            ),
          ),
          onTap: () {
            if (!widget.ispresence) {
              Get.to(InfoMemberScreen(
                member: widget.data,
              ));
            } else {
              showAlertPresence(widget.data.nom, widget.data.prenoms,
                  widget.data.sex, widget.data.id, widget.culte, widget.date);
            }
          },
          trailing: widget.ispresence
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /*const Text(
                      "Présent",
                      style: TextStyle(color: Colors.green, fontSize: 15),
                    ),*/
                    const SizedBox(
                      width: 30,
                    ),
                    Text(
                      "${widget.data.contact}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Text(
                  "${widget.data.contact}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _notif(int total) {
    return Container(
      width: 30,
      height: 30,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).primaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Text(
        (total >= 100) ? "99+" : "$total",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> showAlertPresence(nom, prenom, sex, member, culte, date) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Présence et absence'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(sex == "H"
                    ? 'M. $nom $prenom est-il présent ce dimanche?'
                    : 'Mme $nom $prenom est-elle présente ce dimanche?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Non',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                savePresence('non', member, culte, date);
              },
            ),
            TextButton(
              child: const Text('Oui',
                  style: TextStyle(color: Colors.greenAccent)),
              onPressed: () {
                savePresence('oui', member, culte, date);
              },
            ),
          ],
        );
      },
    );
  }

  void savePresence(ispresence, memberId, culte, date) async {
    try {
      var data = {
        'date': date,
        'membre': memberId,
        'ispresent': ispresence,
        'culte': culte
      };
      var res = await Network().storeData(data, '/membre/listepresence');
      var body = json.decode(res.body);
      if (body['success']) {
        Navigator.of(context).pop();
        successToast(context, body['message']);

        setState(() {});
      } else {
        print(body['message']);
        errorSnackBar(context, body['message']);
      }
    } catch (e) {
      print(e);
    }
  }
}
