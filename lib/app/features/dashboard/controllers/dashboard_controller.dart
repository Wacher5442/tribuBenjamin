// import 'dart:convert';

// import 'package:Benjamin/app/constans/app_constants.dart';
// import 'package:Benjamin/app/features/dashboard/models/profile.dart';
// import 'package:Benjamin/app/shared_components/project_card.dart';
// import 'package:Benjamin/app/shared_components/task_card.dart';
// import 'package:Benjamin/model/memberModel/member_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// class DashboardController extends GetxController {
//   final scaffoldKey = GlobalKey<ScaffoldState>();

//   void openDrawer() {
//     if (scaffoldKey.currentState != null) {
//       scaffoldKey.currentState!.openDrawer();
//     }
//   }

//   // Data
//   Profile getProfil() {
//     // SharedPreferences localStorage = await SharedPreferences.getInstance();
//     // var member = jsonDecode(localStorage.getString('member')!);

//     return Profile(
//       photo: const AssetImage(ImageRasterPath.avatar1),
//       name: 'YEO',
//       email: "054426090",
//     );
//   }

//   Future<List<TaskCardData>> _getTaskData() async {
//     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//     final snapshot = await _firestore.collection('epiwxnqg3s5h').get();
//     final data = snapshot.docs.map((doc) {
//       final docData = doc.data();
//       return TaskCardData(
//           title: docData['title'],
//           subTitle: docData['subTitle'],
//           totalComments: docData['totalComments'],
//           totalContributors: docData['totalContributors']);
//     }).toList();
//     return data;
//   }

//   // List<TaskCardData> getAllTask() {
//   //   return [
//   //     const TaskCardData(
//   //       title: "Landing page UI Design",
//   //       dueDay: 2,
//   //       totalComments: 50,
//   //       type: TaskType.todo,
//   //       totalContributors: 30,
//   //       profilContributors: [
//   //         AssetImage(ImageRasterPath.avatar1),
//   //         AssetImage(ImageRasterPath.avatar2),
//   //         AssetImage(ImageRasterPath.avatar3),
//   //         AssetImage(ImageRasterPath.avatar4),
//   //       ],
//   //     ),
//   //     const TaskCardData(
//   //       title: "Landing page UI Design",
//   //       dueDay: -1,
//   //       totalComments: 50,
//   //       totalContributors: 34,
//   //       type: TaskType.inProgress,
//   //       profilContributors: [
//   //         AssetImage(ImageRasterPath.avatar5),
//   //         AssetImage(ImageRasterPath.avatar6),
//   //         AssetImage(ImageRasterPath.avatar7),
//   //         AssetImage(ImageRasterPath.avatar8),
//   //       ],
//   //     ),
//   //     const TaskCardData(
//   //       title: "Landing page UI Design",
//   //       dueDay: 1,
//   //       totalComments: 50,
//   //       totalContributors: 34,
//   //       type: TaskType.done,
//   //       profilContributors: [
//   //         AssetImage(ImageRasterPath.avatar5),
//   //         AssetImage(ImageRasterPath.avatar3),
//   //         AssetImage(ImageRasterPath.avatar4),
//   //         AssetImage(ImageRasterPath.avatar2),
//   //       ],
//   //     ),
//   //   ];
//   // }

//   ProjectCardData getSelectedProject() {
//     return ProjectCardData(
//       percent: .3,
//       projectImage: const AssetImage(ImageRasterPath.logo1),
//       projectName: "Tribu de benjamin",
//       releaseTime: DateTime.now(),
//     );
//   }

//   List<ProjectCardData> getActiveProject() {
//     return [
//       ProjectCardData(
//         percent: .3,
//         projectImage: const AssetImage(ImageRasterPath.logo2),
//         projectName: "Taxi Online",
//         releaseTime: DateTime.now().add(const Duration(days: 130)),
//       ),
//       ProjectCardData(
//         percent: .5,
//         projectImage: const AssetImage(ImageRasterPath.logo3),
//         projectName: "E-Movies Mobile",
//         releaseTime: DateTime.now().add(const Duration(days: 140)),
//       ),
//       ProjectCardData(
//         percent: .8,
//         projectImage: const AssetImage(ImageRasterPath.logo4),
//         projectName: "Video Converter App",
//         releaseTime: DateTime.now().add(const Duration(days: 100)),
//       ),
//     ];
//   }

//   List<ImageProvider> getMember() {
//     return const [
//       AssetImage(ImageRasterPath.avatar1),
//       AssetImage(ImageRasterPath.avatar2),
//       AssetImage(ImageRasterPath.avatar3),
//       AssetImage(ImageRasterPath.avatar4),
//       AssetImage(ImageRasterPath.avatar5),
//       AssetImage(ImageRasterPath.avatar6),
//     ];
//   }

//   Future<List> getMembers() async {
//     final response = await http.get(
//       Uri.parse("https://tribubenjamin.000webhostapp.com/crud/users.php"),
//     );
//     var jsondata = json.decode(response.body);
//     List data = jsondata.map((details) => Member.fromJson(details)).toList();

//     return data;
//   }
// }
