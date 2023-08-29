import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:Benjamin/app/shared_components/stats/stats_view.dart';
import 'package:flutter/material.dart';

class StatsCard extends StatefulWidget {
  const StatsCard({
    Key? key,
  }) : super(key: key);

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kSpacing),
      height: 210,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(111, 88, 255, 1),
            Color.fromRGBO(157, 86, 248, 1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: const StatsView(),
    );
  }
}
