import 'dart:convert';
import 'dart:developer';

import 'package:Benjamin/app/features/dashboard/views/components/fade_animation.dart';
import 'package:Benjamin/app/features/network_utils/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Service {
  final String name;
  final String imageURL;
  final bool isMonetic;
  Service(this.name, this.imageURL, this.isMonetic);
}

class StatsView extends StatefulWidget {
  const StatsView({Key? key}) : super(key: key);

  @override
  _StatsViewState createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  List<Service> services = [
    Service('12', 'Absence', false),
    Service('15000000.45', 'Caisse', true),
    Service('35000', 'Caisse Social', true),
  ];

  int selectedService = 0;
  final NumberFormat usCurrency = NumberFormat('#,###.##', 'en_US');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          /*const Text(
            'Statistiques',
            style: TextStyle(fontSize: 18),
          ),*/
          Row(
            children: [
              TextButton(
                onPressed: () => pickDareRange(),
                child: Text(
                  '${dateRange.start.day}/${dateRange.start.month}/${dateRange.start.year}',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
                child: Text("à"),
              ),
              TextButton(
                onPressed: () => pickDareRange(),
                child: Text(
                  '${dateRange.end.day}/${dateRange.end.month}/${dateRange.end.year}',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          GridView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 6.0,
                mainAxisSpacing: 5.0,
              ),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              itemBuilder: (BuildContext context, int index) {
                return FadeAnimation(
                    delay: (1.0 + index) / 4,
                    child: serviceContainer(
                        services[index].imageURL,
                        services[index].name,
                        services[index].isMonetic,
                        index));
              }),
        ],
      ),
    );
  }

  serviceContainer(String image, String name, bool isMonetic, int index) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: selectedService == index
              ? const Color(0xFF480512)
              : const Color(0xFF480512),
          border: Border.all(
            color: selectedService == index
                ? Colors.blue.shade100
                : Colors.grey.withOpacity(0),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                image,
                style: const TextStyle(color: Colors.greenAccent),
              ),
              const SizedBox(
                height: 10,
              ),
              caissePrincipalAmount != null &&
                      caisseSocialAmount != null &&
                      absent != null
                  ? Text(
                      isMonetic
                          ? index == 1
                              ? "${usCurrency.format(double.parse("$caissePrincipalAmount"))} F"
                              : "${usCurrency.format(double.parse("$caisseSocialAmount"))} F"
                          : "$absent",
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      isMonetic ? "0 F" : "0",
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      textAlign: TextAlign.center,
                    )
            ]),
      ),
    );
  }

  @override
  void initState() {
    getCaisseAmount("tous", DateTime.now().subtract(const Duration(days: 60)),
        DateTime.now());
    super.initState();
  }

  String dropdownValue = 'Tous';

  DateTimeRange dateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
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
      getCaisseAmount("filtre", newDateRange.start, newDateRange.end);
      dateRange = newDateRange;
    });
  }

  var caisseSocialAmount;
  var caissePrincipalAmount;
  var absent;
  var percent;
  void getCaisseAmount(filterType, startDate, endDate) async {
    try {
      final response = await Network()
          .getData('/get/admin/stats/$filterType/$startDate/$endDate');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          caisseSocialAmount = data['social'];
          caissePrincipalAmount = data['principal'];
          absent = data['absent'];
        });
      }
    } catch (e) {
      log("$e");
    }
  }
}
