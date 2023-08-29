// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:Benjamin/app/config/global.dart';
import 'package:Benjamin/app/features/dashboard/models/profile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/custom_dialog.dart';
import 'package:Benjamin/app/features/dashboard/views/components/header.dart';
import 'package:Benjamin/app/features/dashboard/views/components/profile_tile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/sidebar.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/members_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/tresorerie/widgets/budget_card.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/tresorerie/widgets/caisse_card.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/tresorerie/widgets/global.dart';
import 'package:Benjamin/app/features/network_utils/api.dart';
import 'package:Benjamin/app/shared_components/empty_card.dart';
import 'package:Benjamin/app/shared_components/get_premium_card.dart';
import 'package:Benjamin/app/shared_components/mycard/present_absence_card.dart';
import 'package:Benjamin/model/budget_model.dart';
import 'package:Benjamin/model/caisse_model.dart';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:Benjamin/app/shared_components/responsive_builder.dart';
import 'package:Benjamin/app/shared_components/project_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:intl/intl.dart';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cotisations_screen.dart';

class TresoDashboardScreen extends StatefulWidget {
  const TresoDashboardScreen({Key? key, this.isAdmin = false})
      : super(key: key);

  final bool isAdmin;
  @override
  State<TresoDashboardScreen> createState() => _TresoDashboardScreenState();
}

class _TresoDashboardScreenState extends State<TresoDashboardScreen> {
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
    fetchCaisses();
    getCaisseAmount();
    dateOfWeek = DateFormat('EEEE').format(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback(_showOpenDialog);

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
      title: 'Bienvenue à la tribu Benjamin (Trésorerie)',
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
                caisseSocial: caisseSocialAmount,
                caissePrincipal: caissePrincipalAmount,
                total: total,
                percentvalue: percent),
            const SizedBox(height: kSpacing),
            _buildCaisses(),
            const SizedBox(height: kSpacing * 2),
            _buildBudgets(),
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
      {Axis axis = Axis.horizontal,
      var caisseSocial,
      var caissePrincipal,
      total,
      percentvalue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: (axis == Axis.horizontal)
          ? Row(
              children: [
                if (dateOfWeek == "Sunday1" || dateOfWeek == "dimanche1")
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
                Container(
                  padding: const EdgeInsets.all(kSpacing),
                  height: 190,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.green,
                        Color.fromRGBO(157, 86, 248, 1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Nos avoirs",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          const SizedBox(height: 15),
                          CustomRichText(
                              value1: caissePrincipal != null
                                  ? "${usCurrency.format(double.parse('$caissePrincipal'))} XOF"
                                  : "0.0 FCFA ",
                              value2: "Principal"),
                          const SizedBox(height: 3),
                          CustomRichText(
                              value1: caisseSocial != null
                                  ? "${usCurrency.format(double.parse('$caisseSocial'))} XOF"
                                  : "0.0 FCFA ",
                              value2: "Social"),
                          const SizedBox(height: 3),
                          CustomRichText(
                              value1: total != null
                                  ? "${usCurrency.format(double.parse('$total'))} XOF"
                                  : "0.0 XOF",
                              value2: "Total"),
                        ],
                      ),
                      const Spacer(
                        flex: 3,
                      ),
                      CustomIndicator(percent: percentvalue ?? 0.0),
                    ],
                  ),
                ),
                if (widget.isAdmin)
                  const SizedBox(
                    height: 10,
                  ),
                if (widget.isAdmin)
                  GestureDetector(
                    onTap: () {
                      Get.to(const CotisationDashboardScreen(isAdmin: true));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(kSpacing),
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.green,
                            Color.fromRGBO(86, 248, 89, 1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/raster/salary.png'),
                          const SizedBox(
                            width: 20,
                          ),
                          const Text(
                            textAlign: TextAlign.center,
                            "Voir nos cotisations",
                          ),
                        ],
                      ),
                    ),
                  )
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

  Widget _buildBudgets({
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
          future: getBudgetsApi(),
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
                              "Budgets",
                              style: TextStyle(color: Colors.white),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isbudgetform = !isbudgetform;
                                });
                              },
                              icon: const Icon(Icons.add),
                              tooltip: "Ajouter",
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: kSpacing / 2),
                      if (isbudgetform)
                        Form(
                            key: _formKeyBudget,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 5),
                                  child: TextFormField(
                                      controller: anneeController,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Veillez saisir l'année svp";
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                        hintText: "Année",
                                        isDense: true,
                                        fillColor: Colors.grey,
                                      )),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 5),
                                  child: TextFormField(
                                      controller: descriptionBudgetController,
                                      decoration: InputDecoration(
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                        // prefixIcon: const Icon(EvaIcons.search),
                                        hintText: "Description",
                                        isDense: true,
                                        fillColor: Colors.grey,
                                      )),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 5),
                                  child: TextFormField(
                                      controller: montantBudgetController,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Veillez renseignez le montant svp";
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                        // prefixIcon: const Icon(EvaIcons.search),
                                        hintText: "Montant",
                                        isDense: true,
                                        fillColor: Colors.grey,
                                      )),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  height: 40,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: TextButton.icon(
                                      onPressed: () {
                                        final isValidForm = _formKeyBudget
                                            .currentState!
                                            .validate();
                                        if (isValidForm) {
                                          addBudgetApi(
                                              anneeController.text,
                                              montantBudgetController.text,
                                              descriptionBudgetController.text);
                                        } else {
                                          setState(() {});
                                        }
                                      },
                                      icon: isLoading
                                          ? const Icon(Icons.add,
                                              color: Colors.transparent,
                                              size: 2)
                                          : const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                      label: isLoading
                                          ? const CircularProgressIndicator
                                              .adaptive()
                                          : const Text(
                                              'Ajouter',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            )),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            )),
                      if (!isbudgetform)
                        ...snapshot.data!.map((e) => BudgetCard(
                              data: e,
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

  Widget _buildCaisses() {
    return Card(
      margin: const EdgeInsets.only(right: 20, left: 20),
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
                const Text(
                  "Nos caisses",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    showfForm();
                  },
                  style: TextButton.styleFrom(
                      foregroundColor: kFontColorPallets[1]),
                  child: const Text("Créer une caisse"),
                ),
              ],
            ),
            const Divider(
              thickness: 1,
            ),
            isform
                ? Form(
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
                              child: Text("Ajouter une caisse",
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
                              controller: nomController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Veillez renseignez le nom svp";
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
                                hintText: "Nom caisse",
                                isDense: true,
                                fillColor: Colors.grey,
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                          child: TextFormField(
                              controller: descriptionController,
                              decoration: InputDecoration(
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                // prefixIcon: const Icon(EvaIcons.search),
                                hintText: "Description",
                                isDense: true,
                                fillColor: Colors.grey,
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                          child: TextFormField(
                              controller: montantController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Veillez renseignez le montant svp";
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
                                // prefixIcon: const Icon(EvaIcons.search),
                                hintText: "Montant",
                                isDense: true,
                                fillColor: Colors.grey,
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
                                  addCaisseApi(
                                      nomController.text,
                                      montantController.text,
                                      descriptionController.text);
                                } else {
                                  setState(() {});
                                }
                              },
                              icon: isLoading
                                  ? const Icon(Icons.add,
                                      color: Colors.transparent, size: 2)
                                  : const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                              label: isLoading
                                  ? const CircularProgressIndicator.adaptive()
                                  : const Text(
                                      'Ajouter',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ))
                : caissesList.isNotEmpty
                    ? ListView.separated(
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 4),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: caissesList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {},
                            child: CaisseCard(data: caissesList[index]),
                          );
                        },
                      )
                    : EmptyWidget(text: "Vous n'avez pas de caisses"),
          ],
        ),
      ),
    );
  }

  Future<List> getBudgetsApi() async {
    try {
      final response = await Network().getData('/get/budgets');
      List data;
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        data =
            jsondata.map((details) => BudgetModel.fromJson(details)).toList();
      } else {
        data = [];
      }
      return data;
    } catch (e) {
      return [];
    }
  }

  List caissesList = [];
  void fetchCaisses() async {
    try {
      final response = await Network().getData('/member/get/caisses');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          caissesList =
              data.map((details) => CaisseModel.fromJson(details)).toList();
        });
      }
    } catch (e) {
      log("$e");
    }
  }

  var caisseSocialAmount;
  var caissePrincipalAmount;
  var total;
  var percent;
  void getCaisseAmount() async {
    try {
      final response = await Network().getData('/get/caisses/stats');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          caisseSocialAmount = data['social'];
          caissePrincipalAmount = data['principal'];
          total = data['total'];
          percent = data['percent'];
        });
      }
    } catch (e) {
      log("$e");
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyBudget = GlobalKey<FormState>();

  bool isLoading = false;
  bool isBudgetLoading = false;

  TextEditingController nomController = TextEditingController();
  TextEditingController montantController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  TextEditingController anneeController = TextEditingController();
  TextEditingController descriptionBudgetController = TextEditingController();
  TextEditingController montantBudgetController = TextEditingController();

  bool isform = false;
  bool isbudgetform = false;

  void showfForm() {
    setState(() {
      isform = !isform;
    });
  }

  void addCaisseApi(
    String nom,
    String montant,
    String description,
  ) async {
    setState(() {
      isLoading = true;
    });
    try {
      var data = {
        "nom": nom,
        "montant": montant,
        "description": description,
      };
      var res = await Network().storeData(data, '/add/caisse');
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        if (body['success']) {
          successToast(context, body['message']);
          fetchCaisses();
          setState(() {
            nomController.text = "";
            montantController.text = "";
            descriptionController.text = "";
            isform = !isform;
            isLoading = false;
          });
        } else {
          successToast(context, body['message']);
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void addBudgetApi(
    String annee,
    String montant,
    String description,
  ) async {
    setState(() {
      isBudgetLoading = true;
    });
    try {
      var data = {
        "annee": annee,
        "montant": montant,
        "description": description,
      };
      var res = await Network().storeData(data, '/add/budget');
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        if (body['success']) {
          successToast(context, body['message']);

          setState(() {
            anneeController.text = "";
            montantBudgetController.text = "";
            descriptionBudgetController.text = "";
            isbudgetform = !isbudgetform;
            isBudgetLoading = false;
          });
        } else {
          successToast(context, body['message']);
        }
      } else {
        setState(() {
          isBudgetLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isBudgetLoading = false;
      });
    }
  }
}
