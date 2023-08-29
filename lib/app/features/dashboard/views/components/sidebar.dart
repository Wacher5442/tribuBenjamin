import 'dart:convert';
import 'dart:developer';

import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/com/com_dashbord_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/dashboard_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/events/event_dashboard_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/members_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/priere/priere_dashboard_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/programmes_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/tresorerie/cotisations_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/tresorerie/treso_dashboard_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/visite/visite_screen.dart';
import 'package:Benjamin/app/features/network_utils/api.dart';
import 'package:Benjamin/app/shared_components/project_card.dart';
import 'package:Benjamin/app/shared_components/selection_button.dart';
import 'package:Benjamin/app/shared_components/upgrade_premium_card.dart';
import 'package:Benjamin/loginPage.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({
    required this.data,
    Key? key,
  }) : super(key: key);

  final ProjectCardData data;

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kSpacing),
              child: ProjectCard(
                data: widget.data,
              ),
            ),
            const Divider(thickness: 1),
            if (memberType == "Admin")
              SelectionButton(
                data: [
                  SelectionButtonData(
                    activeIcon: EvaIcons.grid,
                    icon: EvaIcons.gridOutline,
                    label: "Tableau de bord",
                  ),
                  SelectionButtonData(
                    activeIcon: EvaIcons.archive,
                    icon: EvaIcons.archiveOutline,
                    label: "Membres",
                    totalNotif: memberNumber,
                  ),
                  SelectionButtonData(
                    activeIcon: EvaIcons.calendar,
                    icon: EvaIcons.calendarOutline,
                    label: "Trésorerie",
                  ),
                  SelectionButtonData(
                    activeIcon: EvaIcons.email,
                    icon: EvaIcons.emailOutline,
                    label: "Programmes",
                    totalNotif: programmeNumber,
                  ),
                  SelectionButtonData(
                    activeIcon: EvaIcons.person,
                    icon: EvaIcons.personOutline,
                    label: "Com et visite",
                  ),
                  SelectionButtonData(
                    activeIcon: EvaIcons.heart,
                    icon: EvaIcons.heartOutline,
                    label: "Évènement",
                    totalNotif: eventNumber,
                  ),
                  SelectionButtonData(
                    activeIcon: EvaIcons.settings,
                    icon: EvaIcons.settingsOutline,
                    label: "Prière",
                  ),
                ],
                onSelected: (index, value) {
                  log("index : $index | label : ${value.label}");
                  if (index == 1 || value.label == "Membres") {
                    Get.to(const MembersScreen(
                      ispresence: false,
                    ));
                  }
                  if (index == 0 || value.label == "Tableau de bord") {
                    Get.to(const DashboardScreen());
                  }
                  if (index == 3 || value.label == "Programmes") {
                    Get.to(const ProgrammeScreen());
                  }
                  if (index == 2 || value.label == "Trésorerie") {
                    Get.to(const TresoDashboardScreen(isAdmin: true));
                  }
                  if (index == 4 || value.label == "Com et visite") {
                    Get.to(const ComDashboardScreen(isAdmin: true));
                  }
                  if (index == 5 || value.label == "Évènement") {
                    Get.to(const EventDashboardScreen(isAdmin: true));
                  }
                  if (index == 6 || value.label == "Prière") {
                    Get.to(const PriereDashboardScreen(isAdmin: true));
                  }
                },
              ),
            if (memberType == "Treso")
              SelectionButton(
                data: [
                  SelectionButtonData(
                    activeIcon: EvaIcons.grid,
                    icon: EvaIcons.gridOutline,
                    label: "Tableau de bord",
                  ),
                  SelectionButtonData(
                    activeIcon: EvaIcons.archive,
                    icon: EvaIcons.archiveOutline,
                    label: "Cotisations",
                  ),
                ],
                onSelected: (index, value) {
                  log("index : $index | label : ${value.label}");
                  if (index == 1 || value.label == "Cotisations") {
                    Get.to(const CotisationDashboardScreen());
                  }
                  if (index == 0 || value.label == "Tableau de bord") {
                    Get.to(const TresoDashboardScreen(isAdmin: false));
                  }
                },
              ),
            if (memberType == "Com" || memberType == "Visite")
              SelectionButton(
                data: [
                  if (memberType == "Com")
                    SelectionButtonData(
                      activeIcon: EvaIcons.grid,
                      icon: EvaIcons.gridOutline,
                      label: "Tableau de bord",
                    ),
                  if (memberType == "Visite")
                    SelectionButtonData(
                      activeIcon: EvaIcons.grid,
                      icon: EvaIcons.gridOutline,
                      label: "Visite",
                    ),
                  if (memberType == "Visite")
                    SelectionButtonData(
                      activeIcon: EvaIcons.grid,
                      icon: EvaIcons.gridOutline,
                      label: "Action Sociale",
                    ),
                ],
                onSelected: (index, value) {
                  log("index : $index | label : ${value.label}");
                  if (index == 0 || value.label == "Tableau de bord") {
                    Get.to(const ComDashboardScreen());
                  }
                  if (index == 1 || value.label == "Visite") {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const VisiteScreen(
                                  menuType: 'visite',
                                )),
                        (Route route) => false);
                  }
                  if (index == 2 || value.label == "Action Sociale") {
                    Get.to(const VisiteScreen(
                      menuType: 'action',
                    ));
                  }
                },
              ),
            if (memberType == "Event")
              SelectionButton(
                data: [
                  SelectionButtonData(
                    activeIcon: EvaIcons.grid,
                    icon: EvaIcons.gridOutline,
                    label: "Tableau de bord",
                  ),
                ],
                onSelected: (index, value) {
                  log("index : $index | label : ${value.label}");

                  if (index == 0 || value.label == "Tableau de bord") {
                    Get.to(const EventDashboardScreen());
                  }
                },
              ),
            if (memberType == "Prière")
              SelectionButton(
                data: [
                  SelectionButtonData(
                    activeIcon: EvaIcons.grid,
                    icon: EvaIcons.gridOutline,
                    label: "Tableau de bord",
                  ),
                ],
                onSelected: (index, value) {
                  log("index : $index | label : ${value.label}");

                  if (index == 0 || value.label == "Tableau de bord") {
                    Get.to(const PriereDashboardScreen());
                  }
                },
              ),
            const Divider(thickness: 1),
            const SizedBox(height: kSpacing * 2),
            GestureDetector(
              onTap: () async {
                SharedPreferences localStorage =
                    await SharedPreferences.getInstance();
                localStorage.remove('nom');
                localStorage.remove('prenom');
                localStorage.remove('token');
                localStorage.remove('member');

                Get.off(const LoginPage());
              },
              child: const Text(
                "Se deconnecter",
                style: TextStyle(color: Colors.red),
              ),
            ),
            UpgradePremiumCard(
              backgroundColor: Theme.of(context).canvasColor.withOpacity(.4),
              onPressed: () {},
            ),
            const SizedBox(height: kSpacing),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadClientData();
    getStats();
  }

  String memberType = "";
  _loadClientData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var clientdata = jsonDecode(localStorage.getString('member')!);

    setState(() {
      memberType = clientdata['membretype'] ?? "";
    });
  }

  int programmeNumber = 0;
  int memberNumber = 0;
  int eventNumber = 0;

  void getStats() async {
    try {
      final response = await Network().getData('/get/sidebar/stats');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          programmeNumber = data['programmeNumber'];
          memberNumber = data['memberNumber'];
          eventNumber = data['eventNumber'];
        });
      }
    } catch (e) {
      log("$e");
    }
  }
}
