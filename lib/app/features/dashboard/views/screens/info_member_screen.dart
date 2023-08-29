// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:Benjamin/app/config/global.dart';
import 'package:Benjamin/app/features/dashboard/models/profile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/header.dart';
import 'package:Benjamin/app/features/dashboard/views/components/profile_tile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/sidebar.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/members_screen.dart';
import 'package:Benjamin/app/features/network_utils/api.dart';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:Benjamin/app/constans/app_constants.dart';

import 'package:Benjamin/app/shared_components/responsive_builder.dart';
import 'package:Benjamin/app/shared_components/project_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

import 'package:Benjamin/model/memberModel/member_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoMemberScreen extends StatefulWidget {
  const InfoMemberScreen({Key? key, required this.member}) : super(key: key);

  final Member member;

  @override
  State<InfoMemberScreen> createState() => _InfoMemberScreenState();
}

class _InfoMemberScreenState extends State<InfoMemberScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    if (scaffoldKey.currentState != null) {
      scaffoldKey.currentState!.openDrawer();
    }
  }

  @override
  void initState() {
    getProfil();
    fetchMember();
    getCurrentDate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0XFF63272e),
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 30,
            ),
          )),
      drawer: (ResponsiveBuilder.isDesktop(context))
          ? null
          : Drawer(
              child: Padding(
                padding: const EdgeInsets.only(top: kSpacing),
                child: Sidebar(data: getSelectedProject()),
              ),
            ),
      body: SingleChildScrollView(
          child: ResponsiveBuilder(
        mobileBuilder: (context, constraints) {
          return Column(children: [
            //const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2) + 20),
            _buildHeader(onPressedMenu: () => openDrawer()),
            const SizedBox(height: kSpacing / 2),
            _buildMemberProfilInfo(data: widget.member),
            const SizedBox(height: kSpacing / 2),
            _buildBinomes()
          ]);
        },
        tabletBuilder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: (constraints.maxWidth < 950) ? 6 : 9,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2)),
                    _buildHeader(onPressedMenu: () => openDrawer()),
                    const SizedBox(height: kSpacing * 2),
                  ],
                ),
              ),
              Flexible(
                flex: 4,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing * (kIsWeb ? 0.5 : 1.5)),
                    _buildProfile(data: prof),
                  ],
                ),
              )
            ],
          );
        },
        desktopBuilder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 9,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing),
                    _buildHeader(),
                    // const SizedBox(height: kSpacing * 2),
                    // _buildProgress(),
                    const SizedBox(height: kSpacing * 2),
                    _buildMemberProfilInfo(data: widget.member),
                  ],
                ),
              ),
              Flexible(
                flex: 4,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing / 2),
                    _buildProfile(data: prof),
                    const SizedBox(height: kSpacing / 2),
                    _buildBinomes()
                  ],
                ),
              )
            ],
          );
        },
      )),
    );
  }

  Widget _buildHeader({Function()? onPressedMenu}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Row(
        children: [
          if (onPressedMenu != null)
            Padding(
              padding: const EdgeInsets.only(right: kSpacing),
              child: IconButton(
                onPressed: onPressedMenu,
                icon: const Icon(EvaIcons.menu),
                tooltip: "menu",
              ),
            ),
          const Expanded(child: Header()),
        ],
      ),
    );
  }

  Profile prof = const Profile(
      photo: AssetImage(ImageRasterPath.avatar1), name: "", email: "");

  void getProfil() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var member = jsonDecode(localStorage.getString('member')!);

    setState(() {
      prof = Profile(
        photo: const AssetImage(ImageRasterPath.avatar1),
        name: member['nom'],
        email: member['contact'],
      );
    });
  }

  ProjectCardData getSelectedProject() {
    return ProjectCardData(
      percent: .3,
      projectImage: const AssetImage(ImageRasterPath.logo1),
      projectName: "Tribu de benjamin",
      releaseTime: DateTime.now(),
    );
  }

  Widget _buildProfile({required Profile data}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: ProfilTile(
        data: data,
        onPressedNotification: () {},
      ),
    );
  }

  Future<List> getBinomesApi(binomesId) async {
    try {
      final response = await Network().getData('/get/binomes/$binomesId');
      List data;
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        data = jsondata.map((details) => Member.fromJson(details)).toList();
      } else {
        data = [];
      }

      return data;
    } catch (e) {
      print(e);
      return [];
    }
  }

  DateTime today = DateTime.now();

  Widget _buildBinomes() {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 6,
      itemCount: 1,
      addAutomaticKeepAlives: false,
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return FutureBuilder<List>(
          future: getBinomesApi(widget.member.binomeId),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(kSpacing),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Les Binômes",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(
                          thickness: 1,
                          height: kSpacing,
                        ),
                        const SizedBox(height: kSpacing),
                        ...snapshot.data!.map((e) => binomeCard(mem: e)),
                        const SizedBox(
                          height: 20,
                        ),
                        if (addbinome == false)
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                addbinome = true;
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green),
                            ),
                            icon: const Icon(
                              Icons.person,
                              size: 20.0,
                            ),
                            label: const Text('Ajouter un binôme',
                                style: TextStyle(fontSize: 14)),
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (addbinome)
                          Container(
                            height: 55,
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                            decoration: BoxDecoration(
                                color: Colors.green.shade300,
                                borderRadius: BorderRadius.circular(20.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton<String>(
                                        value: myMember.isNotEmpty
                                            ? myMember
                                            : null,
                                        iconSize: 30,
                                        icon: (null),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        hint: const Text(
                                          "Membre",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            myMember = newValue!;
                                          });
                                        },
                                        items: memberList.map((item) {
                                          return DropdownMenuItem(
                                            value: item['id'].toString(),
                                            child: Text(
                                                '${item['nom']} ${item['prenoms']}'),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (addbinome)
                          ElevatedButton.icon(
                            onPressed: () {
                              addBinome(widget.member.id, myMember);
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green),
                            ),
                            icon: const Icon(
                              Icons.person,
                              size: 20.0,
                            ),
                            label: const Text('Enregister',
                                style: TextStyle(fontSize: 14)),
                          ),
                      ],
                    ),
                  ),
                );
              }
            } else {
              return const CircularProgressIndicator();
            }
          },
        );
      },
      staggeredTileBuilder: (int index) => const StaggeredTile.fit(6),
    );
  }

  Widget _buildMemberProfilInfo({
    required Member data,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(kSpacing),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Informations du membre",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const Divider(
                thickness: 1,
                height: kSpacing,
              ),
              const SizedBox(height: kSpacing),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        child: const CircleAvatar(
                          radius: 45,
                          backgroundImage:
                              AssetImage('assets/images/profile/yeo.png'),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(
                              text: 'Nom : ',
                              style: TextStyle(color: Colors.grey)),
                          TextSpan(
                            text: '${data.nom}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(
                              text: 'Prenom : ',
                              style: TextStyle(color: Colors.grey)),
                          TextSpan(
                            text: '${data.prenoms}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(
                              text: 'Contact : ',
                              style: TextStyle(color: Colors.grey)),
                          TextSpan(
                            text: '${data.contact}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(
                              text: 'Département : ',
                              style: TextStyle(color: Colors.grey)),
                          TextSpan(
                              text: '${data.departement}',
                              style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(
                              text: 'Baptisé ? : ',
                              style: TextStyle(color: Colors.grey)),
                          TextSpan(
                              text: '${data.baptise}',
                              style: TextStyle(
                                  color: data.baptise == 'Oui'
                                      ? Colors.green
                                      : Colors.red)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(
                              text: 'Date Anniversaire : ',
                              style: TextStyle(color: Colors.grey)),
                          TextSpan(
                              text: '${data.birthdate}',
                              style: TextStyle(
                                  color: int.parse(finalMonth) >
                                          int.parse(DateFormat.M().format(
                                              DateTime.parse(
                                                  '${data.birthdate}')))
                                      ? Colors.red
                                      : int.parse(finalMonth) <
                                              int.parse(DateFormat.M().format(
                                                  DateTime.parse(
                                                      '${data.birthdate}')))
                                          ? Colors.orange
                                          : int.parse(finalMonth) == int.parse(DateFormat.M().format(DateTime.parse('${data.birthdate}'))) ||
                                                  int.parse(finalDay) >
                                                      int.parse(DateFormat.d()
                                                          .format(
                                                              DateTime.parse('${data.birthdate}')))
                                              ? Colors.red
                                              : Colors.green)),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(
                              text: 'Fonction : ',
                              style: TextStyle(color: Colors.grey)),
                          TextSpan(
                            text: '${data.fonction}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.to(MembersScreen(
                          ispresence: false,
                          addEmployee: true,
                          member: widget.member,
                        ));
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 20.0,
                      ),
                      label: const Text('Modifier le membre',
                          style: TextStyle(fontSize: 14)), // <-- Text
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  binomeCard({required Member mem}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularPercentIndicator(
          radius: 55,
          lineWidth: 2.0,
          percent: 0.8,
          center: const CircleAvatar(
            backgroundImage: AssetImage("assets/images/profile/yeo.png"),
            radius: 150,
            backgroundColor: Colors.white,
          ),
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: Colors.blueGrey,
          progressColor: Theme.of(Get.context!).primaryColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${mem.nom} ${mem.prenoms}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kFontColorPallets[0],
                  letterSpacing: 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 0),
              Row(
                children: [
                  Text(
                    "Baptisé : ",
                    style: TextStyle(fontSize: 11, color: kFontColorPallets[2]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: mem.baptise == "Oui" ? kNotifColor : Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2.5),
                    child: Text(
                      "${mem.baptise}",
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Text(
                    "Contact : ",
                    style: TextStyle(fontSize: 14, color: kFontColorPallets[2]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${mem.contact}",
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  String finalMonth = '';
  String finalDay = '';

  getCurrentDate() {
    final now = DateTime.now();

    initializeDateFormatting('fr_FR', null);
    Intl.defaultLocale = "fr_FR"; //définit global,
    var dateParse = DateTime(now.year, now.month + 1, 0);
    var formattedDate = "${dateParse.month}";
    String dayOfWeek = DateFormat.d('fr_FR').format(now);

    setState(() {
      finalMonth = formattedDate.toString();
      finalDay = dayOfWeek;
    });
  }

  bool addbinome = false;
  String myMember = '';
  List memberList = [];
  void fetchMember() async {
    try {
      final response = await Network().getData('/get/members');

      var data = jsonDecode(response.body);
      setState(() {
        memberList = data;
      });
    } catch (e) {
      log("$e");
    }
  }

  void addBinome(member, binome) async {
    try {
      final response = await Network().getData('/add/binome/$member/$binome');
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['success']) {
          successToast(context, body['message']);
          setState(() {
            addbinome = false;
          });
        } else {
          successToast(context, body['message']);
        }
      } else {}
    } catch (e) {
      log("$e");
    }
  }
}
