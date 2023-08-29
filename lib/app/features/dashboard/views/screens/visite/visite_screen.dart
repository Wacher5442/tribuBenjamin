// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:Benjamin/app/config/global.dart';
import 'package:Benjamin/app/features/dashboard/models/profile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/header.dart';
import 'package:Benjamin/app/features/dashboard/views/components/profile_tile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/sidebar.dart';
import 'package:Benjamin/app/features/network_utils/api.dart';
import 'package:Benjamin/app/shared_components/empty_card.dart';
import 'package:Benjamin/app/shared_components/get_premium_card.dart';
import 'package:Benjamin/model/actionsocial_model.dart';
import 'package:Benjamin/model/listepresence.dart';
import 'package:Benjamin/model/visite_model.dart';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:Benjamin/app/shared_components/responsive_builder.dart';
import 'package:Benjamin/app/shared_components/project_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class VisiteScreen extends StatefulWidget {
  const VisiteScreen({Key? key, required this.menuType, this.isAdmin = false})
      : super(key: key);
  final String menuType;
  final bool isAdmin;
  @override
  State<VisiteScreen> createState() => _VisiteScreenState();
}

class _VisiteScreenState extends State<VisiteScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    if (scaffoldKey.currentState != null) {
      scaffoldKey.currentState!.openDrawer();
    }
  }

  String dateOfWeek = "";

  @override
  void initState() {
    print("ecran ${widget.menuType}");
    getProfil();
    getListeApi("Tous");
    getVisitesApi("tous", DateTime.now().subtract(const Duration(days: 60)),
        DateTime.now());
    fetchMember();
    getActionsApi();
    dateOfWeek = DateFormat('EEEE').format(DateTime.now());
    initializeDateFormatting('fr_FR', null);
    Intl.defaultLocale = "fr_FR";
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
            const Divider(),
            _buildProfile(data: prof),
            widget.menuType == "visite"
                ? buildVisiteCard()
                : buildActionSocialeCard(),
            const SizedBox(height: kSpacing * 2),
            if (widget.menuType == "visite") _buildPresences(),
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

  Widget buildVisiteCard() {
    return Card(
      color: Colors.green,
      margin: const EdgeInsets.only(right: 20, left: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacing),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacing),
              child: Row(
                children: [
                  const Text(
                    "Visite de la semaine",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      if (widget.isAdmin) {
                        errorToast(context, "Vous n'êtes pas de la commision");
                      } else {
                        setState(() {
                          isform = !isform;
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    tooltip: "Ajouter une visite",
                  )
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
                  Expanded(
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
                  ),
                ],
              ),
            ),
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
                                    value: myType.isNotEmpty ? myType : null,
                                    iconSize: 30,
                                    icon: (null),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    hint: const Text("Type de visite"),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        myType = newValue!;
                                      });
                                    },
                                    items: typesList.map((item) {
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
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                        child: TextFormField(
                            controller: raisonController,
                            keyboardType: TextInputType.number,
                            minLines: 3,
                            maxLines: 5,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Veillez renseignez la raison de la visite svp";
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
                              hintText: "Raison de visite",
                              isDense: true,
                              fillColor: const Color(0xFF480512),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                              onPressed: bornDatePicker,
                              child: const Text('Date de visite')),
                          const SizedBox(height: 10),
                          Text(visiteDateSelected == ''
                              ? 'Pas de date chosie!'
                              : DateFormat.yMMMd().format(dateToSee)),
                        ],
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
                                addVisiteApi(
                                    libelleController.text,
                                    myType,
                                    visiteDateSelected,
                                    raisonController.text,
                                    myMember);
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
              visites.isNotEmpty
                  ? ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 4),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: visites.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {},
                          child: _buildVisite(visites[index]),
                        );
                      },
                    )
                  : EmptyWidget(text: "Pas de visites cette semaine"),
          ],
        ),
      ),
    );
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

  Widget buildActionSocialeCard() {
    return Card(
      color: Colors.green,
      margin: const EdgeInsets.only(right: 20, left: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacing),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacing),
              child: Row(
                children: [
                  const Text(
                    "Actions sociales",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      if (widget.isAdmin) {
                        errorToast(context, "Vous n'êtes pas de la commision");
                      } else {
                        setState(() {
                          isformAction = !isformAction;
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    tooltip: "Ajouter une action",
                  )
                ],
              ),
            ),
            const Divider(
              thickness: 1,
            ),
            if (isformAction)
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
                            controller: actionLibelleController,
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
                            controller: descController,
                            minLines: 5,
                            maxLines: 7,
                            decoration: InputDecoration(
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Description",
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
                            decoration: InputDecoration(
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Montant depensé",
                              isDense: true,
                              fillColor: const Color(0xFF480512),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                              onPressed: bornDatePicker,
                              child: const Text('Date de visite')),
                          const SizedBox(height: 10),
                          Text(visiteDateSelected == ''
                              ? 'Pas de date chosie!'
                              : DateFormat.yMMMd().format(dateToSee)),
                        ],
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
                                addActionApi(
                                    actionLibelleController.text,
                                    descController.text,
                                    visiteDateSelected,
                                    montantController.text,
                                    myMember);
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
            if (!isformAction)
              actions.isNotEmpty
                  ? ListView.separated(
                      padding: EdgeInsets.zero,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 4),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: actions.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {},
                          child: _buildActionSociale(actions[index]),
                        );
                      },
                    )
                  : EmptyWidget(text: "Vous n'avez d'actions sociales"),
          ],
        ),
      ),
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
      getVisitesApi("filtre", dateRange.start, dateRange.end);
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

  Widget _buildVisite(VisiteModel visite) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: kSpacing),
          leading: GestureDetector(
            onTap: () {},
            child: const CircleAvatar(
                backgroundImage: AssetImage(ImageRasterPath.avatar1)),
          ),
          title: Text(
            '${visite.libelle}',
            style: TextStyle(
              fontSize: 14,
              color: kFontColorPallets[0],
            ),
          ),
          subtitle: Text(
            '${visite.raison}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
          trailing: Text(
            DateFormat.yMMMEd().format(visite.date),
            style: TextStyle(
              fontSize: 14,
              color: kFontColorPallets[0],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const Divider(
          color: Colors.white,
        ),
      ],
    );
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            const Text(
              'Irrégulier',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: () {
                  _launchUrl(list.contact);
                },
                child: const Icon(Icons.phone, size: 25, color: Colors.blue))
          ],
        ),
        children: list.stats.map(_buildList).toList(),
      ),
    );
  }

  Widget _buildActionSociale(ActionSociale action) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: kSpacing),
          leading: GestureDetector(
            onTap: () {},
            child: const CircleAvatar(
                backgroundImage: AssetImage(ImageRasterPath.avatar1)),
          ),
          title: Text(
            '${action.libelle}',
            style: TextStyle(
              fontSize: 14,
              color: kFontColorPallets[0],
            ),
          ),
          subtitle: Text(
            '${action.desc}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
          trailing: Text(
            DateFormat.yMMMEd().format(action.date),
            style: TextStyle(
              fontSize: 14,
              color: kFontColorPallets[0],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const Divider(
          color: Colors.white,
        ),
      ],
    );
  }

  Future<void> _launchUrl(contactNumber) async {
    final Uri phoneUri = Uri(scheme: "tel", path: contactNumber);
    try {
      if (await canLaunchUrl(phoneUri)) await launchUrl(phoneUri);
    } catch (error) {
      throw ("Cannot dial");
    }
  }

  List visites = [];
  List actions = [];

  void getVisitesApi(filterType, startDate, endDate) async {
    try {
      final response = await Network()
          .getData('/get/visites/$filterType/$startDate/$endDate');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          visites =
              data.map((details) => VisiteModel.fromJson(details)).toList();
        });
      } else {}
    } catch (e) {
      log("$e");
    }
  }

  void getActionsApi() async {
    try {
      final response = await Network().getData('/get/actions/sociales');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          actions =
              data.map((details) => ActionSociale.fromJson(details)).toList();
        });
      } else {}
    } catch (e) {
      log("$e");
    }
  }

  // ajouter une visite
  bool isform = false;
  bool isformAction = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController libelleController = TextEditingController();
  TextEditingController raisonController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController montantController = TextEditingController();
  TextEditingController actionLibelleController = TextEditingController();

  String myMember = '';

  String myType = '';

  List typesList = [
    {"id": 1, "libelle": "Visite"},
    {"id": 2, "libelle": "Appel"},
  ];

  String visiteDateSelected = DateTime.now().toString();
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
        visiteDateSelected = pickedDate.toString();
        dateToSee = pickedDate;
      });
    });
  }

  void addVisiteApi(String libelle, String type, String date, String raison,
      String membre) async {
    setState(() {
      isLoading = true;
    });
    try {
      var data = {
        "libelle": libelle,
        "type": type,
        "date": date,
        "raison": raison,
        "membre_id": membre,
      };
      var res = await Network().storeData(data, '/add/visite');
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        if (body['success']) {
          successToast(context, body['message']);
          getVisitesApi(
              "tous",
              DateTime.now().subtract(const Duration(days: 60)),
              DateTime.now());
          setState(() {
            libelleController.text = "";
            raisonController.text = "";
            visiteDateSelected = "";
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

  void addActionApi(String libelle, String desc, String date, String montant,
      String membre) async {
    setState(() {
      isLoading = true;
    });
    try {
      var data = {
        "libelle": libelle,
        "desc": desc,
        "date": date,
        "montant": montant,
        "membre_id": membre,
      };
      var res = await Network().storeData(data, '/add/action/sociale');
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        if (body['success']) {
          successToast(context, body['message']);
          getActionsApi();
          setState(() {
            actionLibelleController.text = "";
            raisonController.text = "";
            visiteDateSelected = "";
            isformAction = !isformAction;
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
