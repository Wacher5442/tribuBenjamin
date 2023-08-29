import 'dart:convert';
import 'dart:developer';

import 'package:Benjamin/app/features/network_utils/api.dart';
import 'package:Benjamin/model/event/anniv_model.dart';
import 'package:flutter/material.dart';
import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

class AnnivCard extends StatefulWidget {
  const AnnivCard({
    required this.onPressed,
    required this.backgroundColor,
    required this.isAdmin,
    Key? key,
  }) : super(key: key);

  final Color? backgroundColor;
  final bool isAdmin;
  final Function() onPressed;

  @override
  State<AnnivCard> createState() => _AnnivCardState();
}

class _AnnivCardState extends State<AnnivCard> {
  String members = "";
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(kBorderRadius),
      color: widget.backgroundColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(kBorderRadius),
        onTap: widget.onPressed,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 360,
            maxWidth: 370,
            minHeight: 180,
            maxHeight: 190,
          ),
          padding: const EdgeInsets.all(5),
          child: Stack(
            children: [
              widget.isAdmin
                  ? Align(
                      alignment: Alignment.topRight,
                      child: Image.asset(
                        ImageIcons.happy2,
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Transform.translate(
                          offset: const Offset(10, 30),
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: SvgPicture.asset(
                              ImageVectorPath.happy2,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(
                  left: kSpacing,
                  top: kSpacing,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Info(
                      onChange: (value) {
                        setState(() {
                          members = value;
                        });
                      },
                    ),
                    const SizedBox(height: kSpacing),
                    ElevatedButton(
                      onPressed: () {
                        modalUploadForm(members);
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green),
                      ),
                      child: const Text('Souhaiter un joyeux anniv',
                          style: TextStyle(fontSize: 12)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController messageController = TextEditingController();

  modalUploadForm(textMembers) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  right: -15.0,
                  top: -15.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.close,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                              color: Colors.green,
                              border: Border(
                                  bottom: BorderSide(color: Colors.green))),
                          child: const Center(
                              child: Text("Partager un message",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ))),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                          child: TextFormField(
                              controller: messageController,
                              minLines: 6,
                              maxLines: 10,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Veillez ajouter un message svp";
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Message",
                                isDense: true,
                                fillColor: Theme.of(context).cardColor,
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(30)),
                          child: TextButton.icon(
                              onPressed: () {
                                final isValidForm =
                                    _formKey.currentState!.validate();
                                if (isValidForm) {
                                  Share.share(
                                      '${messageController.text} \n\n Voici nos heureux anniversaireux du semestre : \n $textMembers');
                                  setState(() {
                                    Navigator.of(context).pop();
                                  });
                                } else {
                                  setState(() {});
                                }
                              },
                              icon: const Icon(
                                Icons.share,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Partager',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    )),
              ],
            ),
          );
        });
  }
}

class _Info extends StatefulWidget {
  const _Info({Key? key, required this.onChange}) : super(key: key);
  final ValueChanged<String> onChange;

  @override
  State<_Info> createState() => _InfoState();
}

class _InfoState extends State<_Info> {
  int month = 0;

  @override
  void initState() {
    DateTime now = DateTime.now();
    month = now.month;
    fetchAnniversaireux();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          month > 6
              ? "Nos anniversaireux du semestre 2"
              : "Nos anniversaireux du semestre 1",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        annivs.isNotEmpty
            ? Wrap(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Text(
                        "${annivs[index].nom},",
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                    itemCount: annivs.length,
                  ),
                ],
              )
            : const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Pas d'anniversaireux",
                  style: TextStyle(color: Colors.red),
                ),
              )
      ],
    );
  }

  List annivs = [];

  void fetchAnniversaireux() async {
    try {
      final response = await Network().getData('/get/anniversaireux');
      var data = jsonDecode(response.body);
      String membersString = "";
      List dataList =
          data.map((details) => AnnivModel.fromJson(details)).toList();

      data.asMap().forEach((index, el) {
        membersString =
            "$membersString ${index + 1}: ${el["nom"]} ${el["prenoms"]},";
      });
      setState(() {
        annivs = dataList;
        widget.onChange(membersString);
      });
    } catch (e) {
      log("$e");
    }
  }
}
