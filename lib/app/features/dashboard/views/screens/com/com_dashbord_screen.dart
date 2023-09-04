// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:Benjamin/app/features/dashboard/models/profile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/custom_dialog.dart';
import 'package:Benjamin/app/features/dashboard/views/components/header.dart';
import 'package:Benjamin/app/features/dashboard/views/components/profile_tile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/sidebar.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/members_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/tresorerie/widgets/global.dart';
import 'package:Benjamin/app/features/network_utils/api.dart';
import 'package:Benjamin/app/shared_components/empty_card.dart';
import 'package:Benjamin/app/shared_components/get_premium_card.dart';
import 'package:Benjamin/app/shared_components/mycard/present_absence_card.dart';
import 'package:Benjamin/model/listepresence.dart';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:Benjamin/app/shared_components/responsive_builder.dart';
import 'package:Benjamin/app/shared_components/project_card.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../visite/visite_screen.dart';

class ComDashboardScreen extends StatefulWidget {
  const ComDashboardScreen({Key? key, this.isAdmin = false}) : super(key: key);
  final bool isAdmin;
  @override
  State<ComDashboardScreen> createState() => _ComDashboardScreenState();
}

class _ComDashboardScreenState extends State<ComDashboardScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    if (scaffoldKey.currentState != null) {
      scaffoldKey.currentState!.openDrawer();
    }
  }

  String dateOfWeek = "";

  @override
  void initState() {
    getProfil();
    getStats("null");
    getListeApi("Tous");
    fetchMember();
    dateOfWeek = DateFormat('EEEE').format(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback(_showOpenDialog);
    initializeDateFormatting('fr_FR', null);
    Intl.defaultLocale = "fr_FR";
    super.initState();
  }

  final NumberFormat usCurrency = NumberFormat('#,##0.00', 'en_US');

  _showOpenDialog(_) {
    return AwesomeDialog(
      context: context,
      keyboardAware: true,
      dismissOnBackKeyPress: false,
      dialogType: DialogType.INFO,
      animType: AnimType.BOTTOMSLIDE,
      dialogBackgroundColor: Colors.white,
      titleTextStyle: TextStyle(
          color: mainColor, fontWeight: FontWeight.bold, fontSize: 20),
      descTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      btnOkText: "OK, Commençons",
      title: 'Bienvenue à la tribu Benjamin (Communication)',
      // padding: const EdgeInsets.all(5.0),
      desc:
          'Benjamin est un loup qui déchire; Le matin, il dévore la proie, Et le soir, il partage le butin.',
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0XFF63272e),
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
            const SizedBox(height: kSpacing * (kIsWeb ? 1 : 2) + 20),
            _buildHeader(onPressedMenu: () => openDrawer()),
            const SizedBox(height: kSpacing / 2),
            const Divider(),
            _buildProfile(data: prof),
            const SizedBox(height: kSpacing),
            _buildAbsenceAndStatsCard(
                axis: Axis.vertical,
                absent: totalAbsent,
                present: totalPresent),
            const SizedBox(height: kSpacing * 2),
            _buildPresences(),
            const SizedBox(height: kSpacing * 2),
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
                    _buildAbsenceAndStatsCard(
                      axis: (constraints.maxWidth < 950)
                          ? Axis.vertical
                          : Axis.horizontal,
                    ),
                    const SizedBox(height: kSpacing * 2),
                    const SizedBox(height: kSpacing),
                  ],
                ),
              ),
              Flexible(
                flex: 4,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing * (kIsWeb ? 0.5 : 1.5)),
                    _buildProfile(data: prof),
                    const Divider(thickness: 1),
                    const SizedBox(height: kSpacing),
                    const Divider(thickness: 1),
                    const SizedBox(height: kSpacing),
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
                flex: (constraints.maxWidth < 1360) ? 4 : 3,
                child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(kBorderRadius),
                      bottomRight: Radius.circular(kBorderRadius),
                    ),
                    child: Sidebar(data: getSelectedProject())),
              ),
              Flexible(
                flex: 9,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing),
                    _buildHeader(),
                    // const SizedBox(height: kSpacing * 2),
                    _buildAbsenceAndStatsCard(),
                    const SizedBox(height: kSpacing * 2),
                    //_buildCaisses(),
                    const SizedBox(height: kSpacing),
                  ],
                ),
              ),
              Flexible(
                flex: 4,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing / 2),
                    _buildProfile(data: prof),
                    const Divider(thickness: 1),
                    const SizedBox(height: kSpacing),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
                      child: GetPremiumCard(onPressed: () {}),
                    ),
                    const SizedBox(height: kSpacing),
                    const Divider(thickness: 1),
                    const SizedBox(height: kSpacing),
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

  Widget _buildAbsenceAndStatsCard(
      {Axis axis = Axis.horizontal, absent, present}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: (axis == Axis.horizontal)
          ? Row(
              children: [
                if (dateOfWeek == "Sunday" || dateOfWeek == "dimanche")
                  Flexible(
                    flex: 5,
                    child: PresenceAbsenceCard(
                      data: const PresenceAbsenceCardData(
                        totalUndone: 10,
                        totalTaskInProress: 2,
                      ),
                      onPressedCheck: () {
                        if (dateOfWeek == "Sunday" ||
                            dateOfWeek == "dimanche") {
                          Get.to(const MembersScreen(
                            ispresence: true,
                          ));
                        } else {
                          Alerts(context: context).customDialog(
                              type: AlertType.warning,
                              message: "Aujourd'hui n'est pas un Dimanche",
                              description:
                                  'Veuillez patientez le dimanche prochain avant d\'etablir la liste de présence svp',
                              showButton: true,
                              onTap: () {
                                Navigator.of(context).pop();
                              });
                        }
                      },
                    ),
                  ),
                const SizedBox(width: kSpacing / 2),
              ],
            )
          : Column(
              children: [
                if (dateOfWeek != "Sunday" || dateOfWeek != "dimanche")
                  PresenceAbsenceCard(
                    data: const PresenceAbsenceCardData(
                      totalUndone: 10,
                      totalTaskInProress: 2,
                    ),
                    onPressedCheck: () {
                      if (dateOfWeek == "Sunday" || dateOfWeek == "dimanche") {
                        Get.to(const MembersScreen(
                          ispresence: true,
                        ));
                      } else {
                        Alerts(context: context).customDialog(
                            type: AlertType.warning,
                            message: "Aujourd'hui n'est pas un Dimanche",
                            description:
                                'Veuillez patientez le dimanche prochain avant d\'etablir la liste de présence svp',
                            showButton: true,
                            onTap: () {
                              Navigator.of(context).pop();
                            });
                      }
                    },
                  ),
                Container(
                  padding: const EdgeInsets.all(kSpacing),
                  height: widget.isAdmin ? 210 : 160,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.black,
                        Color.fromRGBO(157, 86, 248, 1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Statistiques",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      GestureDetector(
                        onTap: () {
                          bornDatePicker();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(dateSelected == ''
                                ? 'Pas de date chosie!'
                                : DateFormat.yMMMd().format(dateToSee)),
                            const Icon(
                              Icons.edit,
                              size: 18,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomRichText(
                          value1: absent != null ? '$absent' : "0",
                          value2: "Absences"),
                      const SizedBox(height: 3),
                      CustomRichText(
                          value1: present != null ? '$present' : "0",
                          value2: "Presences"),
                      const SizedBox(height: 10),
                      if (widget.isAdmin)
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Get.to(const VisiteScreen(
                                  menuType: 'visite',
                                  isAdmin: true,
                                ));
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.yellow.shade800),
                              ),
                              icon: const Icon(
                                Icons.person,
                                size: 20.0,
                              ),
                              label: const Text('Voir les visites',
                                  style: TextStyle(fontSize: 14)),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Get.to(const VisiteScreen(
                                  menuType: 'action',
                                  isAdmin: true,
                                ));
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.blue.shade800),
                              ),
                              icon: const Icon(
                                Icons.people,
                                size: 20.0,
                              ),
                              label: const Text('Actions sociales',
                                  style: TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  String dateSelected = DateTime.now().toString();
  DateTime dateToSee = DateTime.now();
  void bornDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1980),
            lastDate: DateTime(2030))
        .then((pickedDate) {
      if (pickedDate == null) {
        //if user tap cancel then this function will stop
        return;
      }
      setState(() {
        dateSelected = pickedDate.toString();
        dateToSee = pickedDate;
        getStats(pickedDate);
      });
    });
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

  Profile prof = const Profile(
      photo: AssetImage(ImageRasterPath.avatar1), name: "", email: "");

  ProjectCardData getSelectedProject() {
    return ProjectCardData(
      percent: .3,
      projectImage: const AssetImage(ImageRasterPath.logoTribu),
      projectName: "Tribu de benjamin",
      releaseTime: DateTime.now(),
    );
  }

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

  dynamic totalAbsent;
  dynamic totalPresent;
  void getStats(date) async {
    try {
      final response = await Network().getData('/get/stats/$date');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          totalAbsent = data['absent'];
          totalPresent = data['present'];
        });
      }
    } catch (e) {
      log("$e");
    }
  }

  Widget _buildPresences() {
    return Card(
      margin: const EdgeInsets.only(right: 20, left: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Padding(
          padding: const EdgeInsets.all(kSpacing),
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: kSpacing),
              child: Row(
                children: [
                  Text(
                    "Présences des membres",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Spacer(),
                  /*IconButton(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(Icons.add),
                    tooltip: "Ajouter",
                  )*/
                ],
              ),
            ),
            const Divider(
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /*Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () => pickDareRange(),
                          child: Text(
                              '${dateRange.start.day}/${dateRange.start.month}/${dateRange.start.year}'),
                        ),
                        const SizedBox(
                          width: 10,
                          child: Text("à"),
                        ),
                        TextButton(
                          onPressed: () => pickDareRange(),
                          child: Text(
                              '${dateRange.end.day}/${dateRange.end.month}/${dateRange.end.year}'),
                        ),
                      ],
                    ),
                  ),*/
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<String>(
                          isDense: true,
                          isExpanded: true,
                          value:
                              myFilterMember.isNotEmpty ? myFilterMember : null,
                          iconSize: 25,
                          icon: (null),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          hint: const Text("Membre"),
                          onChanged: (String? newValue) {
                            setState(() {
                              myFilterMember = newValue!;
                              getListeApi(myFilterMember.isEmpty
                                  ? "Tous"
                                  : myFilterMember);
                            });
                          },
                          items: memberList.map((item) {
                            return DropdownMenuItem(
                              value: item['id'].toString(),
                              child: Text(item['nom']),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
            ),
            liste.isNotEmpty
                ? ListView.separated(
                    padding: EdgeInsets.zero,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 4),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: liste.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {},
                        child: _buildList(liste[index]),
                      );
                    },
                  )
                : EmptyWidget(text: "Pas de données disponible"),
          ])),
    );
  }

  // Filter stats
  String dropdownValue = 'Tous';

  String myFilterMember = '';

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

  DateTimeRange dateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now());
  Future pickDareRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
        context: context,
        locale: const Locale("fr", "FR"),
        initialDateRange: dateRange,
        firstDate: DateTime(1900),
        lastDate: DateTime(2050));

    if (newDateRange == null) return;
    setState(() {
      dateRange = newDateRange;
      /*Provider.of<ClientDashboardProvider>(context, listen: false)
          .getWeekTransactions(dropdownValue, dateRange.start, dateRange.end);*/
    });
  }

  List liste = [];

  void getListeApi(membre) async {
    try {
      final response = await Network().getData('/get/presences/$membre');
      if (response.statusCode == 200) {
        var dataJson = jsonDecode(response.body);

        setState(() {
          /*dataJson.forEach((element) {
            liste.add(ListePresence.fromJson(element));
          });*/
          liste = dataJson
              .map((details) => ListePresence.fromJson(details))
              .toList();
        });
      } else {}
    } catch (e) {
      log("$e");
    }
  }

  Widget _buildList(ListePresence list) {
    if (list.stats.isEmpty) {
      return Builder(builder: (context) {
        return ListTile(
          title: Text(list.nom),
          subtitle: Text(
            list.id >= 2
                ? 'Présent ${list.id} dimanches sur 4'
                : 'Présent ${list.id} dimanche sur 4',
            style: const TextStyle(color: Colors.green),
          ),
        );
      });
    }
    return ListTileTheme(
      dense: true,
      contentPadding: const EdgeInsets.all(0),
      minVerticalPadding: 0,
      minLeadingWidth: 0,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(0),
        leading: const CircleAvatar(
            backgroundImage: AssetImage(ImageRasterPath.avatar1)),
        title: Text(
          '${list.nom} ${list.prenoms}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'Irrégulier',
          style: TextStyle(color: Colors.red),
        ),
        children: list.stats.map(_buildList).toList(),
      ),
    );
  }
}
