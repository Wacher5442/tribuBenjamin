import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class TodayText extends StatefulWidget {
  const TodayText({Key? key}) : super(key: key);

  @override
  State<TodayText> createState() => _TodayTextState();
}

class _TodayTextState extends State<TodayText> {
  @override
  void initState() {
    initializeDateFormatting('fr_FR', null);
    Intl.defaultLocale = "fr_FR"; //définit global,
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Aujourd'hui",
            style: Theme.of(context).textTheme.caption,
          ),
          Text(
            DateFormat.yMMMEd().format(DateTime.now()),
          )
        ],
      ),
    );
  }
}
