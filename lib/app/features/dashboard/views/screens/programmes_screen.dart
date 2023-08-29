import 'package:Benjamin/app/config/global.dart';
import 'package:Benjamin/app/features/dashboard/models/profile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/header.dart';
import 'package:Benjamin/app/features/dashboard/views/components/profile_tile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/sidebar.dart';
import 'package:Benjamin/app/features/network_utils/api.dart';
import 'package:Benjamin/app/shared_components/list_card/programme_card_list.dart';
import 'package:Benjamin/model/programme_model.dart';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:Benjamin/app/shared_components/progress_card.dart';
import 'package:Benjamin/app/shared_components/progress_report_card.dart';
import 'package:Benjamin/app/shared_components/responsive_builder.dart';
import 'package:Benjamin/app/shared_components/project_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProgrammeScreen extends StatefulWidget {
  const ProgrammeScreen({Key? key}) : super(key: key);

  @override
  State<ProgrammeScreen> createState() => _ProgrammeScreenState();
}

class _ProgrammeScreenState extends State<ProgrammeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    if (scaffoldKey.currentState != null) {
      scaffoldKey.currentState!.openDrawer();
    }
  }

  @override
  void initState() {
    getProfil();
    super.initState();
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
            _buildProgrammes(),
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
                    _buildProgrammes(),
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
                    //_buildProgrammes(),
                    const SizedBox(height: kSpacing * 2),
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

  Widget _buildProgress({Axis axis = Axis.horizontal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: (axis == Axis.horizontal)
          ? Row(
              children: [
                Flexible(
                  flex: 5,
                  child: ProgressCard(
                    data: const ProgressCardData(
                      totalUndone: 10,
                      totalTaskInProress: 2,
                    ),
                    onPressedCheck: () {},
                  ),
                ),
                const SizedBox(width: kSpacing / 2),
                const Flexible(
                  flex: 4,
                  child: ProgressReportCard(
                    data: ProgressReportCardData(
                      title: "1st Sprint",
                      doneTask: 5,
                      percent: .3,
                      task: 3,
                      undoneTask: 2,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                ProgressCard(
                  data: const ProgressCardData(
                    totalUndone: 10,
                    totalTaskInProress: 2,
                  ),
                  onPressedCheck: () {},
                ),
                const SizedBox(height: kSpacing / 2),
                const ProgressReportCard(
                  data: ProgressReportCardData(
                    title: "1st Sprint",
                    doneTask: 5,
                    percent: .3,
                    task: 3,
                    undoneTask: 2,
                  ),
                ),
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

  Widget _buildProgrammes({
    int crossAxisCount = 6,
    int crossAxisCellCount = 2,
    Axis headerAxis = Axis.horizontal,
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
          future: getProgrammes(),
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
                          child: Row(
                            children: [
                              const Text(
                                "Programmes de la tribu",
                                style: TextStyle(color: Colors.white),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  errorToast(context,
                                      "Contactez le support d'administration");
                                },
                                icon: const Icon(
                                  EvaIcons.plus,
                                  color: Colors.white,
                                ),
                                tooltip: "more",
                              )
                            ],
                          )),
                      const SizedBox(height: kSpacing / 2),
                      ...snapshot.data!.map((e) => ProgrammeListCard(data: e))
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

  /*Future<List> getProgrammes() async {
    final response = await http.get(
      Uri.parse(
          "https://tribubenjamin.000webhostapp.com/crud/getProgrammes.php"),
    );
    var jsondata = json.decode(response.body);
    List data =
        jsondata.map((details) => ProgrammeModel.fromJson(details)).toList();

    return data;
  }*/

  Future<List> getProgrammes() async {
    try {
      final response = await Network().getData('/get/programmes');
      List data;
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        data = jsondata
            .map((details) => ProgrammeModel.fromJson(details))
            .toList();
      } else {
        data = [];
      }

      return data;
    } catch (e) {
      return [];
    }
  }
}
