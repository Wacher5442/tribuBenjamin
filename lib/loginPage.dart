// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:Benjamin/Widget/loading.dart';
import 'package:Benjamin/app/config/global.dart';
import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/com/com_dashbord_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/events/event_dashboard_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/priere/priere_dashboard_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/tresorerie/treso_dashboard_screen.dart';
import 'package:Benjamin/app/features/dashboard/views/screens/visite/visite_screen.dart';
import 'package:Benjamin/app/features/network_utils/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Widget/bezierContainer.dart';
import 'app/features/dashboard/views/screens/dashboard_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Widget _entryField(
      String title, TextEditingController control, bool ispassword) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
              controller: control,
              style: const TextStyle(color: Color(0xffF02E65)),
              obscureText: ispassword ? !passwordVisible : false,
              keyboardType:
                  ispassword ? TextInputType.name : TextInputType.name,
              validator: (value) {
                if (value != null && value.length < 6) {
                  return "Entrez au moins 6 caractères";
                } else {
                  return null;
                }
              },
              decoration: ispassword
                  ? InputDecoration(
                      isDense: true,
                      hintText: "Entrez votre mot de passe svp",
                      fillColor: const Color(0xfff3f3f4),
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      suffixIcon: IconButton(
                          onPressed: togglePassword,
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: mainColor,
                          )),
                      contentPadding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.grey.shade400)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(color: Colors.red)),
                    )
                  : InputDecoration(
                      isDense: true,
                      hintText: "Entrez votre contact",
                      fillColor: const Color(0xfff3f3f4),
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      contentPadding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Colors.grey.shade400)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(color: Colors.red)),
                    ))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF63272e), Color(0xFF63272e)])),
      child: const Text(
        'Se connecter',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: const Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('Tribu Benjamin'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _facebookButton() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff1959a9),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    topLeft: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: const Text('',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w400)),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff2872ba),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(5),
                    topRight: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: const Text('Créer un compte',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _createAccountLabel() {
  //   return InkWell(
  //     onTap: () {
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => SignUpPage()));
  //     },
  //     child: Container(
  //       margin: EdgeInsets.symmetric(vertical: 20),
  //       padding: EdgeInsets.all(15),
  //       alignment: Alignment.bottomCenter,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           Text(
  //             'Don\'t have an account ?',
  //             style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  //           ),
  //           SizedBox(
  //             width: 10,
  //           ),
  //           Text(
  //             'Register',
  //             style: TextStyle(
  //                 color: Color(0xfff79c4f),
  //                 fontSize: 13,
  //                 fontWeight: FontWeight.w600),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
          text: 'Tribu',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF118A06)),
          children: [
            TextSpan(
              text: 'Benj',
              style: TextStyle(color: Colors.red, fontSize: 30),
            ),
            TextSpan(
              text: 'amin',
              style: TextStyle(color: Color(0xFFCCF000), fontSize: 30),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Contact", nomController, false),
        _entryField("Mot de passe", contactController, true),
      ],
    );
  }

  TextEditingController nomController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  bool passwordVisible = false;

  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: const Color(0xFF031b03),
            body: SizedBox(
              height: height,
              child: Stack(
                children: <Widget>[
                  Positioned(
                      top: -height * .15,
                      right: -MediaQuery.of(context).size.width * .4,
                      child: const BezierContainer()),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: height * .2),
                          _title(),
                          const SizedBox(height: 50),
                          _emailPasswordWidget(),
                          const SizedBox(height: 20),
                          GestureDetector(
                            child: _submitButton(),
                            onTap: () {
                              loginFunction(
                                  nomController.text, contactController.text);
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.centerRight,
                            child: const Text('',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(
                            height: 100,
                          ),
                          _divider(),
                          //_facebookButton(),

                          Text(
                            err,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * .055),
                          // _createAccountLabel(),
                        ],
                      ),
                    ),
                  ),
                  // Positioned(top: 40, left: 0, child: _backButton()),
                ],
              ),
            ));
  }

  String err = "";
  bool loading = false;

  void loginFunction(String contact, String password) async {
    setState(() {
      err = "";
      loading = true;
    });
    try {
      var data = {'contact': contact, 'password': password};
      var res = await Network().authData(data, '/member/login');
      var body = json.decode(res.body);

      if (res.statusCode == 200) {
        if (body['success']) {
          String token = body["token"];
          var member = body["member"];
          var membertype = body["membertype"];

          //user shared preference to save data
          SharedPreferences localStorage =
              await SharedPreferences.getInstance();
          localStorage.setString('token', json.encode(token));
          localStorage.setString('member', json.encode(member));
          if (membertype == "Admin") {
            Get.off(const DashboardScreen());
          } else if (membertype == "Treso") {
            Get.off(const TresoDashboardScreen());
          } else if (membertype == "Com") {
            Get.off(const ComDashboardScreen());
          } else if (membertype == "Visite") {
            Get.off(const VisiteScreen(
              menuType: 'visite',
            ));
          } else if (membertype == "Event") {
            Get.off(const EventDashboardScreen());
          } else if (membertype == "Prière") {
            Get.off(const PriereDashboardScreen());
          } else {
            errorToast(context, "Vous n'avez pas de rôle");
          }
        } else {
          setState(() {
            loading = false;
            err = body['message'];
          });

          errorToast(context, body['message']);
        }
      } else {
        setState(() {
          loading = false; //don't show progress indicator
          err = "Erreur de connexion au serveur.";
        });
        errorToast(context, "Erreur de connexion au serveur.");
      }
    } catch (e) {
      setState(() => loading = false);
      if (kDebugMode) {
        print(e);
      }
      errorToast(context, "Une erreur s'est produite, veillez réessayer !");
    }
  }

  void login(String nom, String contact) async {
    setState(() {
      err = "";
      loading = true;
    });
    try {
      print(nom);
      final response = await http.post(
          Uri.parse("https://tribubenjamin.000webhostapp.com/login/newlog.php"),
          body: {"nom": nom, "contact": contact});
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        print(jsondata);
        if (jsondata["error"] == true) {
          setState(() {
            loading = false; //don't show progress indicator
            err = jsondata["message"];
          });
        } else {
          if (jsondata["success"] == true) {
            setState(() {
              loading = false;
            });
            //save the data returned from server
            //and navigate to home page
            String nom = jsondata["nom"];
            String prenom = jsondata["prenom"];
            String contact = jsondata["contact"];
            String token = jsondata["token"];
            var member = jsondata["member"];

            //user shared preference to save data
            SharedPreferences localStorage =
                await SharedPreferences.getInstance();
            localStorage.setString('token', json.encode(token));
            localStorage.setString('nom', json.encode(nom));
            localStorage.setString('prenom', json.encode(prenom));
            localStorage.setString('contact', json.encode(contact));
            localStorage.setString('member', json.encode(member));
            print(jsondata["nom"]);

            Get.off(const DashboardScreen());

            // // ignore: use_build_context_synchronously
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const DashboardScreen()),
            // );
          } else {
            loading = false; //don't show progress indicator
            err = "Something went wrong.";
            print(" erreur ");
          }
        }
      } else {
        setState(() {
          loading = false; //don't show progress indicator
          err = "Error during connecting to server.";
        });
        print(" erreur 2 ");
      }
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }
}
