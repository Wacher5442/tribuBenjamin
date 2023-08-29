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

import 'package:Benjamin/model/event/event_model.dart';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:Benjamin/app/shared_components/responsive_builder.dart';
import 'package:Benjamin/app/shared_components/project_card.dart';

import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PriereDashboardScreen extends StatefulWidget {
  const PriereDashboardScreen({Key? key, this.isAdmin = false})
      : super(key: key);
  final bool isAdmin;
  @override
  State<PriereDashboardScreen> createState() => _PriereDashboardScreenState();
}

class _PriereDashboardScreenState extends State<PriereDashboardScreen> {
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
      title: 'Bienvenue à la tribu Benjamin (Prière)',
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
            /*Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacing),
              child: AnnivCard(onPressed: () {}),
            ),*/
            buildEvennementCard(),
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

  Widget buildEvennementCard() {
    return Card(
      color: Colors.green,
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
                  const Text(
                    "Programmes de prière",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      if (widget.isAdmin) {
                        errorSnackBar(
                            context, "Oup's ! vous n'êtes pas de la commision");
                      } else {
                        setState(() {
                          viewdata = false;
                          isform = !isform;
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    tooltip: "Ajouter",
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        getEventsApi('tous', 'ras', 'ras');
                        viewdata = !viewdata;
                        isform = false;
                      });
                    },
                    icon: const Icon(Icons.arrow_downward),
                    tooltip: "Voir",
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
            const Divider(
              thickness: 1,
            ),
            if (viewdata == false && isform == true)
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
                            style: const TextStyle(color: Colors.pinkAccent),
                            decoration: InputDecoration(
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Libellé",
                              isDense: true,
                              hintStyle: const TextStyle(color: Colors.grey),
                              fillColor:
                                  const Color.fromARGB(255, 238, 231, 232),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 40,
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 238, 231, 232),
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
                                      color: Colors.pinkAccent,
                                      fontSize: 16,
                                    ),
                                    hint: const Text(
                                      "Type d'évènement",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        myType = newValue!;
                                      });
                                    },
                                    items: typesList.map((item) {
                                      return DropdownMenuItem(
                                        value: item['libelle'].toString(),
                                        child: Text('${item['libelle']}'),
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
                            controller: descController,
                            minLines: 5,
                            maxLines: 7,
                            style: const TextStyle(color: Colors.pinkAccent),
                            decoration: InputDecoration(
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Description",
                              isDense: true,
                              hintStyle: const TextStyle(color: Colors.grey),
                              fillColor:
                                  const Color.fromARGB(255, 238, 231, 232),
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
                            style: const TextStyle(color: Colors.pinkAccent),
                            decoration: InputDecoration(
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Montant à allouer",
                              isDense: true,
                              hintStyle: const TextStyle(color: Colors.grey),
                              fillColor:
                                  const Color.fromARGB(255, 238, 231, 232),
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
                          Text(eventDateSelected == ''
                              ? 'Pas de date chosie!'
                              : DateFormat.yMMMd().format(dateToSee)),
                        ],
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
                                addEventApi(
                                    libelleController.text,
                                    descController.text,
                                    eventDateSelected,
                                    montantController.text,
                                    myType);
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
            if (viewdata == true && isform == false)
              events.isNotEmpty
                  ? ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 4),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: events.length,
                      padding: const EdgeInsets.only(top: 5),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {},
                          child: _buildEvents(events[index]),
                        );
                      },
                    )
                  : EmptyWidget(text: "Pas de données disponible"),
          ])),
    );
  }

  Widget _buildEvents(EventModel event) {
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
            '${event.libelle}',
            style: TextStyle(
              fontSize: 14,
              color: kFontColorPallets[0],
            ),
          ),
          subtitle: Text(
            '${event.type}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
          trailing: Text(
            DateFormat.yMMMEd().format(event.date),
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

  bool isform = false;
  bool viewdata = false;

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
      getEventsApi('filtre', dateRange.start, dateRange.end);
    });
  }

  List events = [];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController libelleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController montantController = TextEditingController();

  String myType = '';

  List typesList = [
    {"id": 1, "libelle": "Anniversaire"},
    {"id": 2, "libelle": "Sortie"},
    {"id": 3, "libelle": "Agapé"},
    {"id": 4, "libelle": "Sketch"},
    {"id": 5, "libelle": "Balé"}
  ];

  String eventDateSelected = DateTime.now().toString();
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
        eventDateSelected = pickedDate.toString();
        dateToSee = pickedDate;
      });
    });
  }

  void getEventsApi(filtre, startDate, endDate) async {
    try {
      final response = await Network()
          .getData('/get/evenements/$filtre/$startDate/$endDate');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          events = data.map((details) => EventModel.fromJson(details)).toList();
        });
      } else {}
    } catch (e) {
      log("$e");
    }
  }

  void addEventApi(String libelle, String desc, String date, String montant,
      String type) async {
    setState(() {
      isLoading = true;
    });
    try {
      var data = {
        "libelle": libelle,
        "desc": desc,
        "date": date,
        "budget": montant,
        "type": type,
      };
      var res = await Network().storeData(data, '/add/evenement');
      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        if (body['success']) {
          successToast(context, body['message']);
          getEventsApi('tous', 'ras', 'ras');
          setState(() {
            libelleController.text = "";
            descController.text = "";
            eventDateSelected = "";
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
