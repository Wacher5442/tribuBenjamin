// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:Benjamin/app/config/global.dart';
import 'package:Benjamin/app/features/dashboard/models/profile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/header.dart';
import 'package:Benjamin/app/features/dashboard/views/components/profile_tile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/sidebar.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/tresorerie/widgets/cotisation_card.dart';
import 'package:Benjamin/app/features/network_utils/api.dart';
import 'package:Benjamin/app/shared_components/empty_card.dart';
import 'package:Benjamin/app/shared_components/get_premium_card.dart';
import 'package:Benjamin/model/cotisation_model.dart';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:Benjamin/app/shared_components/responsive_builder.dart';
import 'package:Benjamin/app/shared_components/project_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CotisationDashboardScreen extends StatefulWidget {
  const CotisationDashboardScreen({Key? key, this.isAdmin = false})
      : super(key: key);
  final bool isAdmin;
  @override
  State<CotisationDashboardScreen> createState() =>
      _CotisationDashboardScreenState();
}

class _CotisationDashboardScreenState extends State<CotisationDashboardScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    if (scaffoldKey.currentState != null) {
      scaffoldKey.currentState!.openDrawer();
    }
  }

  String dateOfWeek = "";
  String currentMonth = "";

  @override
  void initState() {
    getProfil();
    fetchMember();
    fetchCaisses();
    getCotisationsApi();
    dateOfWeek = DateFormat('EEEE').format(DateTime.now());
    String month = DateFormat('MMMM').format(DateTime.now());
    currentMonth = month.replaceFirst(month[0], month[0].toUpperCase());
    //WidgetsBinding.instance.addPostFrameCallback(_showOpenDialog);

    super.initState();
  }

  final NumberFormat usCurrency = NumberFormat('#,##0.00', 'en_US');

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
            _buildCotisations(),
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
                    const SizedBox(height: kSpacing),
                    _buildCotisations(),
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
                    const SizedBox(height: kSpacing * 2),
                    _buildCotisations(),
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

  Widget _buildCotisations() {
    return Card(
      margin: const EdgeInsets.only(right: 20, left: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Padding(
          padding: const EdgeInsets.all(kSpacing),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacing),
              child: Row(
                children: [
                  Text(
                    "Cotisations de ${myFilterMonth.isNotEmpty ? myFilterMonth : currentMonth} ${myFilterYear.isNotEmpty ? myFilterYear : DateTime.now().year}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      if (widget.isAdmin) {
                        errorToast(context, "Vous n'êtes pas de la tresorerie");
                      } else {
                        setState(() {
                          isform = !isform;
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    tooltip: "Ajouter",
                  )
                ],
              ),
            ),
            const Divider(
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacing),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<String>(
                          isDense: true,
                          isExpanded: true,
                          value: myFilterYear.isNotEmpty ? myFilterYear : null,
                          iconSize: 30,
                          icon: (null),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          hint: const Text("Année"),
                          onChanged: (String? newValue) {
                            setState(() {
                              myFilterYear = newValue!;
                              getCotisationsFilter(
                                  newValue,
                                  myFilterMonth.isNotEmpty
                                      ? myFilterMonth
                                      : currentMonth,
                                  myFilterMember.isNotEmpty
                                      ? myFilterMember
                                      : "null");
                            });
                          },
                          items: anneeList.map((item) {
                            return DropdownMenuItem(
                              value: item['libelle'].toString(),
                              child: Text(item['libelle']),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<String>(
                          isDense: true,
                          isExpanded: true,
                          value:
                              myFilterMonth.isNotEmpty ? myFilterMonth : null,
                          iconSize: 30,
                          icon: (null),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          hint: const Text("Mois"),
                          onChanged: (String? newValue) {
                            setState(() {
                              myFilterMonth = newValue!;
                              getCotisationsFilter(
                                  myFilterYear.isNotEmpty
                                      ? myFilterYear
                                      : DateTime.now().year,
                                  newValue,
                                  myFilterMember.isNotEmpty
                                      ? myFilterMember
                                      : "null");
                            });
                          },
                          items: moisList.map((item) {
                            return DropdownMenuItem(
                              value: item['libelle'].toString(),
                              child: Text(item['libelle']),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
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
                              getCotisationsFilter(
                                  myFilterYear.isNotEmpty
                                      ? myFilterYear
                                      : DateTime.now().year,
                                  myFilterMember.isNotEmpty
                                      ? myFilterMonth
                                      : currentMonth,
                                  newValue);
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
            const SizedBox(height: kSpacing / 2),
            if (isform)
              Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                        child: TextFormField(
                            controller: libelleController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Libellé",
                              isDense: true,
                              fillColor: const Color(0xFF480512),
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
                              fillColor: const Color(0xFF480512),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 40,
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    value: myYear.isNotEmpty ? myYear : null,
                                    iconSize: 30,
                                    icon: (null),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    hint: const Text("Année"),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        myYear = newValue!;
                                      });
                                    },
                                    items: anneeList.map((item) {
                                      return DropdownMenuItem(
                                        value: item['libelle'].toString(),
                                        child: Text(item['libelle']),
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
                      Container(
                        height: 40,
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    value: myMonth.isNotEmpty ? myMonth : null,
                                    iconSize: 30,
                                    icon: (null),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    hint: const Text("Mois"),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        myMonth = newValue!;
                                      });
                                    },
                                    items: moisList.map((item) {
                                      return DropdownMenuItem(
                                        value: item['libelle'].toString(),
                                        child: Text(item['libelle']),
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
                      Container(
                        height: 40,
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    value:
                                        myMember.isNotEmpty ? myMember : null,
                                    iconSize: 30,
                                    icon: (null),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    hint: const Text("Membre"),
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
                      Container(
                        height: 40,
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    value:
                                        myCaisse.isNotEmpty ? myCaisse : null,
                                    iconSize: 30,
                                    icon: (null),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    hint: const Text("Caisse"),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        myCaisse = newValue!;
                                      });
                                    },
                                    items: memberList.map((item) {
                                      return DropdownMenuItem(
                                        value: item['id'].toString(),
                                        child: Text('${item['nom']}'),
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
                                  formKey.currentState!.validate();
                              if (isValidForm) {
                                addCotisationApi(
                                    libelleController.text,
                                    myYear,
                                    myMonth,
                                    montantController.text,
                                    myMember,
                                    myCaisse);
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
                  )),
            if (!isform)
              cotisations.isNotEmpty
                  ? ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 4),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: cotisations.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {},
                          child: CotisationCard(data: cotisations[index]),
                        );
                      },
                    )
                  : EmptyWidget(text: "Vous n'avez pas de cotisations"),
          ])),
    );
  }

  List cotisations = [];
  void getCotisationsApi() async {
    try {
      final response = await Network().getData('/get/cotisations/courant');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          cotisations =
              data.map((details) => CotisationModel.fromJson(details)).toList();
        });
      } else {}
    } catch (e) {
      log("$e");
    }
  }

  void getCotisationsFilter(year, month, membre) async {
    try {
      final response = await Network()
          .getData('/get/cotisations/filtre/$year/$month/$membre');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          cotisations =
              data.map((details) => CotisationModel.fromJson(details)).toList();
        });
      } else {}
    } catch (e) {
      log("$e");
    }
  }

  List moisList = [
    {"id": 1, "libelle": "Janvier"},
    {"id": 2, "libelle": "Février"},
    {"id": 2, "libelle": "Mars"},
    {"id": 2, "libelle": "Avril"},
    {"id": 2, "libelle": "Mai"},
    {"id": 2, "libelle": "Juin"},
    {"id": 2, "libelle": "Juillet"},
    {"id": 2, "libelle": "Août"},
    {"id": 2, "libelle": "Septembre"},
    {"id": 2, "libelle": "Octobre"},
    {"id": 2, "libelle": "Novembre"},
    {"id": 2, "libelle": "Decembre"}
  ];
  String myMonth = '';

  List anneeList = [
    {"id": 1, "libelle": "2023"},
    {"id": 2, "libelle": "2024"},
    {"id": 2, "libelle": "2025"},
    {"id": 2, "libelle": "2026"},
    {"id": 2, "libelle": "2027"},
    {"id": 2, "libelle": "2028"},
  ];
  String myYear = '';
  String myMember = '';
  String myFilterMonth = '';
  String myFilterMember = '';
  String myFilterYear = '';

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

  List caissesList = [];
  String myCaisse = "";
  void fetchCaisses() async {
    try {
      final response = await Network().getData('/member/get/caisses');

      var data = jsonDecode(response.body);
      setState(() {
        caissesList = data;
      });
    } catch (e) {
      log("$e");
    }
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;

  TextEditingController libelleController = TextEditingController();
  TextEditingController montantController = TextEditingController();

  bool isform = false;

  void showfForm() {
    setState(() {
      isform = !isform;
    });
  }

  void addCotisationApi(String libelle, String year, String month,
      String montant, String membre, String caisse) async {
    setState(() {
      isLoading = true;
    });
    try {
      var data = {
        "libelle": libelle,
        "date": year,
        "mois": month,
        "membre_id": membre,
        "montant": montant,
        "caisseId": caisse
      };
      var res = await Network().storeData(data, '/add/cotisation');
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        if (body['success']) {
          successToast(context, body['message']);
          getCotisationsApi();
          setState(() {
            libelleController.text = "";
            montantController.text = "";
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
      setState(() {
        isLoading = false;
      });
    }
  }
}
