// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:Benjamin/app/config/global.dart';
import 'package:Benjamin/app/features/dashboard/models/profile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/header.dart';
import 'package:Benjamin/app/features/dashboard/views/components/profile_tile.dart';
import 'package:Benjamin/app/features/dashboard/views/components/sidebar.dart';
import 'package:Benjamin/app/features/network_utils/api.dart';
import 'package:Benjamin/app/features/network_utils/dio_client.dart';
import 'package:dio/dio.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:Benjamin/app/shared_components/chatting_card.dart';
import 'package:Benjamin/app/shared_components/progress_card.dart';
import 'package:Benjamin/app/shared_components/progress_report_card.dart';
import 'package:Benjamin/app/shared_components/responsive_builder.dart';
import 'package:Benjamin/app/shared_components/project_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';

import 'package:Benjamin/model/memberModel/member_model.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MembersScreen extends StatefulWidget {
  const MembersScreen(
      {Key? key,
      required this.ispresence,
      this.addEmployee = false,
      this.member})
      : super(key: key);

  final bool ispresence;
  final bool addEmployee;
  final Member? member;

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    if (scaffoldKey.currentState != null) {
      scaffoldKey.currentState!.openDrawer();
    }
  }

  int time = 0;
  int second = 0;
  String todayDate = "";
  @override
  void initState() {
    getProfil();
    if (widget.member != null) {
      getMemberInfos(widget.member!);
    }
    DateTime now = DateTime.now();
    time = now.hour;
    second = now.second;
    todayDate = "${now.year}-${now.month}-${now.day}";

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
            const Divider(),
            if (widget.addEmployee == false) _buildProfile(data: prof),
            if (widget.addEmployee == false) _buildRecentMessages(),
            if (widget.addEmployee) addMemberCard()
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
                flex: 9,
                child: Column(
                  children: [
                    const SizedBox(height: kSpacing),
                    _buildHeader(),
                    const SizedBox(height: kSpacing * 2),
                    _buildRecentMessages(),
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
          future: widget.ispresence
              ? getMembersPresence(time <= 11 ? "culte1" : "culte2")
              : getMembersApi(),
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
                                "Membres de la tribu",
                                style: TextStyle(color: Colors.white),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  EvaIcons.eye,
                                  color: Colors.transparent,
                                ),
                                tooltip: "more",
                              )
                            ],
                          )),
                      if (widget.ispresence)
                        Text(
                          time <= 11
                              ? '$time H:$second s (Liste Présence Culte 1)'
                              : '$time H:$second s (Liste Présence Culte 2)',
                          style: const TextStyle(fontSize: 16),
                        ),
                      const SizedBox(height: kSpacing / 2),
                      ...snapshot.data!.map((e) => ChattingCard(
                            data: e,
                            ispresence: widget.ispresence,
                            culte: time <= 11 ? "Culte 1" : "Culte 2",
                            date: todayDate,
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

  Widget addMemberCard() {
    return Card(
      margin: const EdgeInsets.only(right: 20, left: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSpacing),
        child: Column(
          children: [
            const Divider(
              thickness: 1,
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
                          border:
                              Border(bottom: BorderSide(color: Colors.green))),
                      child: const Center(
                          child: Text("Ajouter un membre",
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
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: TextFormField(
                          controller: nomController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Veillez renseignez le nom svp";
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              EvaIcons.person,
                              color: Theme.of(context).cardColor,
                            ),
                            hintText: "Nom",
                            hintStyle: TextStyle(
                              color: Theme.of(context).cardColor,
                            ),
                            isDense: true,
                            fillColor: Colors.green.shade100,
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: TextFormField(
                          controller: prenomsController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Veillez renseignez le(s) prénom(s) svp";
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(
                              EvaIcons.people,
                              color: Theme.of(context).cardColor,
                            ),
                            hintText: "Prénom(s)",
                            hintStyle: TextStyle(
                              color: Theme.of(context).cardColor,
                            ),
                            isDense: true,
                            fillColor: Colors.green.shade100,
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: TextFormField(
                          controller: departementController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Département",
                            hintStyle: TextStyle(
                              color: Theme.of(context).cardColor,
                            ),
                            isDense: true,
                            fillColor: Colors.green.shade100,
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 55,
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      decoration: BoxDecoration(
                          color: Colors.green.shade100,
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
                                      myBapteme.isNotEmpty ? myBapteme : null,
                                  iconSize: 30,
                                  icon: (null),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  hint: Text(
                                    "Est-il baptisé?",
                                    style: TextStyle(
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      myBapteme = newValue!;
                                    });
                                  },
                                  items: baptiserList.map((item) {
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
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: TextFormField(
                          controller: contactController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Veillez renseignez le contact svp";
                            } else {
                              return null;
                            }
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            // prefixIcon: const Icon(EvaIcons.search),
                            // errorStyle: TextStyle(color: Colors.green),
                            hintText: "Contact",
                            hintStyle: TextStyle(
                              color: Theme.of(context).cardColor,
                            ),
                            isDense: true,
                            fillColor: Colors.green.shade100,
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: TextFormField(
                          controller: fonctionController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            // prefixIcon: const Icon(EvaIcons.search),
                            hintText: "Fonction",
                            hintStyle: TextStyle(
                              color: Theme.of(context).cardColor,
                            ),
                            isDense: true,
                            fillColor: Colors.green.shade100,
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
                            child: const Text('Date de Naissance')),
                        const SizedBox(height: 10),
                        Text(bornDateSelected == ''
                            ? 'Pas de date chosie!'
                            : DateFormat.yMMMd().format(dateToSee)),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 55,
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton<String>(
                                  value: myGenre.isNotEmpty ? myGenre : null,
                                  iconSize: 30,
                                  icon: (null),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  hint: Text(
                                    "Genre",
                                    style: TextStyle(
                                        color: Theme.of(context).cardColor),
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      myGenre = newValue!;
                                    });
                                  },
                                  items: genreList.map((item) {
                                    return DropdownMenuItem(
                                      value: item['libelle'].toString(),
                                      child: Text(item['libelle'] == "H"
                                          ? "Homme"
                                          : "Femme"),
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
                    GestureDetector(
                      onTap: () {
                        _showPicker(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Ajouter une image",
                            style: TextStyle(
                                fontSize: 14, color: Colors.green.shade100),
                          ),
                          const Icon(Icons.file_present)
                        ],
                      ),
                    ),
                    Text(
                      _path,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
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
                              storeApi(
                                  memberId,
                                  _filename,
                                  _fileSize,
                                  _path,
                                  nomController.text,
                                  prenomsController.text,
                                  departementController.text,
                                  myBapteme,
                                  bornDateSelected,
                                  fonctionController.text,
                                  contactController.text,
                                  myGenre);
                            } else {
                              setState(() {});
                            }
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          label: isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.amber[600],
                                )
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
          ],
        ),
      ),
    );
  }

  Future<List> getMembers() async {
    final response = await http.get(
      Uri.parse("https://tribubenjamin.000webhostapp.com/crud/users.php"),
    );
    var jsondata = json.decode(response.body);
    List data = jsondata.map((details) => Member.fromJson(details)).toList();

    return data;
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

  Future<List> getMembersPresence(culte) async {
    try {
      DateTime now = DateTime.now();
      String date = "${now.year}-${now.month}-${now.day}";
      final response =
          await Network().getData('/get/members/presence/$date/$culte');
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

  String bornDateSelected = DateTime.now().toString();
  DateTime dateToSee = DateTime.now();
  void bornDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime(1999),
            firstDate: DateTime(1980),
            lastDate: DateTime(2010))
        .then((pickedDate) {
      if (pickedDate == null) {
        //if user tap cancel then this function will stop
        return;
      }
      setState(() {
        bornDateSelected = pickedDate.toString();
        dateToSee = pickedDate;
      });
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomsController = TextEditingController();
  TextEditingController departementController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController fonctionController = TextEditingController();
  List baptiserList = [
    {"id": 1, "libelle": "Oui"},
    {"id": 2, "libelle": "Non"}
  ];
  String myBapteme = '';

  List genreList = [
    {"id": 1, "libelle": "H"},
    {"id": 2, "libelle": "F"}
  ];
  String myGenre = '';

  int memberId = 0;
  File? imagepick;
  String _path = "";
  var _fileSize;
  var _filename;
  var folder;

  _imageFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);

    if (image != null) {
      var bytes = File(image.path);
      var enc = await bytes.readAsBytes();
      double val = enc.length / 1024;
      setState(() {
        imagepick = File(image.path);
        _path = image.path.toString();
        _filename = image.name;
        _fileSize = val.round();

        // print(_image);
        // print('size $_fileSize');
        // print('name $_filename');
      });
    }
  }

  _imageFromGalery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      var bytes = File(image.path);
      var enc = await bytes.readAsBytes();
      double val = enc.length / 1024;
      setState(() {
        imagepick = File(image.path);
        _path = image.path.toString();
        _filename = image.name;
        _fileSize = val.round();
        // print(_image);
        // print('size $_fileSize');
      });
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Galerie"),
                onTap: () {
                  _imageFromGalery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  _imageFromCamera();
                  Navigator.of(context).pop();
                },
              )
            ],
          ));
        });
  }

  void getMemberInfos(Member member) {
    if (widget.member != null) {
      memberId = member.id ?? 0;
      nomController.text = member.nom ?? "";
      prenomsController.text = member.prenoms ?? "";
      departementController.text = member.departement ?? "";
      contactController.text = member.contact ?? "";
      fonctionController.text = member.fonction ?? "";
      myBapteme = member.baptise ?? "";
      myGenre = member.sex ?? "";
    }
  }

  void storeApi(
      id,
      filename,
      filesize,
      path,
      String nom,
      String prenoms,
      String departement,
      String baptise,
      String birthdate,
      String fonction,
      String contact,
      String genre) async {
    try {
      var formData = FormData.fromMap({
        "id": id,
        "nom": nom,
        "prenoms": prenoms,
        "departement": departement,
        "baptise": baptise,
        "birthdate": birthdate,
        "fonction": fonction,
        "binomeId": "0",
        "contact": contact,
        "sex": genre,
        'image': await MultipartFile.fromFile(path, filename: filename),
      });

      var response = await DioClient().postFile("/membre/add", formData);

      if (response['success']) {
        successToast(context, response['message']);
        setState(() {
          _path = '';
          nomController.text = "";
          prenomsController.text = "";
          departementController.text = "";
          contactController.text = "";
          fonctionController.text = "";
          isLoading = false;
        });
      } else {
        errorToast(context, response['message']);
      }
    } catch (e) {
      log('$e');
      errorSnackBar(context,
          "Une erreure s'est produite, Veuillez réessayer ou contacter le support");
    }
  }

  void addMemberApi(
      String nom,
      String prenoms,
      String departement,
      String baptise,
      String birthdate,
      String fonction,
      String contact,
      String genre) async {
    setState(() {
      isLoading = true;
    });
    try {
      var data = {
        "nom": nom,
        "prenoms": prenoms,
        "departement": departement,
        "baptise": baptise,
        "birthdate": birthdate,
        "fonction": fonction,
        "binomeId": "0",
        "contact": contact,
        "sex": genre,
      };
      var res = await Network().storeData(data, '/membre/add');

      if (res.statusCode == 200) {
        var body = json.decode(res.body);
        if (body['success']) {
          successToast(context, body['message']);
          setState(() {
            nomController.text = "";
            prenomsController.text = "";
            departementController.text = "";
            contactController.text = "";
            fonctionController.text = "";
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print(body['message']);
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
