// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:Benjamin/app/features/dashboard/models/profile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/header.dart';
import 'package:Benjamin/app/features/dashboard/views/components/profile_tile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/recent_messages.dart';
import 'package:Benjamin/app/features/dashboard/views/components/sidebar.dart';
import 'package:Benjamin/app/features/dashboard/views/components/team_member.dart';
import 'package:Benjamin/app/features/network_utils/api.dart';
import 'package:Benjamin/app/shared_components/mycard/anniv_card.dart';
import 'package:Benjamin/app/shared_components/mycard/present_absence_card.dart';
import 'package:Benjamin/app/shared_components/stats/stats_card.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:Benjamin/app/shared_components/chatting_card.dart';
import 'package:Benjamin/app/shared_components/list_profil_image.dart';
import 'package:Benjamin/app/shared_components/responsive_builder.dart';
import 'package:Benjamin/app/shared_components/project_card.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

import 'package:Benjamin/model/memberModel/member_model.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared_components/get_premium_card.dart';
import '../components/custom_dialog.dart';
import 'members_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    getTotalMember();
    getNetworkImage();
    dateOfWeek = DateFormat('EEEE').format(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback(_showOpenDialog);

    super.initState();
  }

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
      title: 'Bienvenue à la tribu Benjamin',
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
            _buildAbsenceAndStatsCard(axis: Axis.vertical),
            const SizedBox(height: kSpacing),
            _buildTeamMember(data: getMember()),
            const SizedBox(height: kSpacing),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacing),
              child: AnnivCard(
                  backgroundColor: Theme.of(context).cardColor,
                  isAdmin: true,
                  onPressed: () {}),
            ),
            const SizedBox(height: kSpacing * 2),

            // _buildTaskOverview(
            //   headerAxis: Axis.vertical,
            //   crossAxisCount: 6,
            //   crossAxisCellCount: 6,
            // ),

            // _buildActiveProject(
            //   data: getActiveProject(),
            //   crossAxisCount: 6,
            //   crossAxisCellCount: 6,
            // ),
            // const SizedBox(height: kSpacing),

            _buildRecentMessages(),
            const SizedBox(height: kSpacing * 2),
            //_buildProgrammes(),
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
                    // _buildTaskOverview(
                    //   headerAxis: (constraints.maxWidth < 850)
                    //       ? Axis.vertical
                    //       : Axis.horizontal,
                    //   crossAxisCount: 6,
                    //   crossAxisCellCount: (constraints.maxWidth < 950)
                    //       ? 6
                    //       : (constraints.maxWidth < 1100)
                    //           ? 3
                    //           : 2,
                    // ),
                    // const SizedBox(height: kSpacing * 2),
                    // _buildActiveProject(
                    //   data: getActiveProject(),
                    //   crossAxisCount: 6,
                    //   crossAxisCellCount: (constraints.maxWidth < 950)
                    //       ? 6
                    //       : (constraints.maxWidth < 1100)
                    //           ? 3
                    //           : 2,
                    // ),
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
                    _buildTeamMember(data: getMember()),
                    const SizedBox(height: kSpacing),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
                      child: GetPremiumCard(onPressed: () {}),
                    ),
                    const SizedBox(height: kSpacing),
                    const Divider(thickness: 1),
                    const SizedBox(height: kSpacing),
                    _buildRecentMessages(),
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
                    _buildRecentMessages(),
                    // const SizedBox(height: kSpacing * 2),
                    //_buildProgrammes(),
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
                    _buildTeamMember(data: getMember()),
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

  Widget _buildAbsenceAndStatsCard({Axis axis = Axis.horizontal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: (axis == Axis.horizontal)
          ? Row(
              children: [
                //if (dateOfWeek == "Sunday" || dateOfWeek == "dimanche")
                Flexible(
                  flex: 5,
                  child: PresenceAbsenceCard(
                    data: const PresenceAbsenceCardData(
                      totalUndone: 10,
                      totalTaskInProress: 2,
                    ),
                    onPressedCheck: () {
                      //print(dateOfWeek);
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
                ),
                const SizedBox(width: kSpacing / 2),
              ],
            )
          : Column(
              children: [
                //if (dateOfWeek == "Sunday" || dateOfWeek == "dimanche")
                PresenceAbsenceCard(
                  data: const PresenceAbsenceCardData(
                    totalUndone: 10,
                    totalTaskInProress: 2,
                  ),
                  onPressedCheck: () {
                    //print(dateOfWeek);
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
                const SizedBox(height: kSpacing / 2),
                const StatsCard(),
              ],
            ),
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

  Widget _buildTeamMember({required List<ImageProvider> data}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeamMember(
            totalMember: nombreDeMembre,
            onPressedAdd: () {
              Get.to(const MembersScreen(
                ispresence: false,
                addEmployee: true,
              ));
            },
          ),
          const SizedBox(height: kSpacing / 2),
          ListProfilImage(maxImages: nombreDeMembre, images: data),
        ],
      ),
    );
  }

  List<ImageProvider> getMember() {
    if (images.isNotEmpty) {
      return const [
        AssetImage(ImageRasterPath.avatar2),
        AssetImage(ImageRasterPath.avatar3),
        AssetImage(ImageRasterPath.avatar4),
        AssetImage(ImageRasterPath.avatar5),
        AssetImage(ImageRasterPath.avatar6),
        AssetImage(ImageRasterPath.avatar2),
        AssetImage(ImageRasterPath.avatar3),
      ];
    } else {
      return images;
    }
  }

  List<ImageProvider> images = [];

  getNetworkImage() async {
    try {
      final response = await Network().getData('/get/members');
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        List<ImageProvider> imagesList = [];

        jsondata.asMap().forEach((index, el) {
          imagesList.add(NetworkImage(el["imageurl"] ??
              "https://firebasestorage.googleapis.com/v0/b/odigo-79f42.appspot.com/o/Ets%20JKM%2Flogo%2F8908CF42-964E-4803-A498-75B1C1E38557.jpeg?alt=media&token=23b6acf5-094a-4ccc-9492-b949ce747205"));
        });
        setState(() {
          images = imagesList;
        });
      }
    } catch (e) {
      log("$e");
    }
  }

  Widget _buildRecentMessages({
    int crossAxisCount = 6,
    int crossAxisCellCount = 2,
  }) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: crossAxisCount,
      itemCount: 1,
      addAutomaticKeepAlives: false,
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return FutureBuilder<List>(
          future: getMembersApi(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: kSpacing),
                        child: RecentMessages(onPressedMore: () {
                          Get.to(const MembersScreen(
                            ispresence: false,
                          ));
                        }),
                      ),
                      const SizedBox(height: kSpacing / 2),
                      ...snapshot.data!.map((e) => ChattingCard(
                            data: e,
                            ispresence: false,
                          ))
                    ]));
              }
            } else {
              return const CircularProgressIndicator();
            }
          },
        );
      },
      staggeredTileBuilder: (int index) =>
          StaggeredTile.fit((index == 0) ? crossAxisCount : crossAxisCellCount),
    );
  }

  // Data
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
      projectImage: const AssetImage(ImageRasterPath.logoTribu),
      projectName: "Tribu de benjamin",
      releaseTime: DateTime.now(),
    );
  }

  List programmes = [];

  int nombreDeMembre = 0;
  void getTotalMember() async {
    try {
      final response = await Network().getData('/get/members/team');
      var jsondata = json.decode(response.body);

      setState(() {
        nombreDeMembre = jsondata;
      });
    } catch (e) {
      log("$e");
    }
  }

  Future<List> getMembersApi() async {
    try {
      final response = await Network().getData('/get/members');
      List data;
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        data = jsondata.map((details) => Member.fromJson(details)).toList();
      } else {
        data = [];
      }

      return data;
    } catch (e) {
      return [];
    }
  }

  /*modalUploadForm() {
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
                
              ],
            ),
          );
        });
  } */
}
