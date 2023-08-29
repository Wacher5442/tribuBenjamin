import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Benjamin/app/constans/app_constants.dart';
import 'package:intl/intl.dart';

class PresenceAbsenceCardData {
  final int totalUndone;
  final int totalTaskInProress;

  const PresenceAbsenceCardData({
    required this.totalUndone,
    required this.totalTaskInProress,
  });
}

class PresenceAbsenceCard extends StatefulWidget {
  const PresenceAbsenceCard({
    required this.data,
    required this.onPressedCheck,
    Key? key,
  }) : super(key: key);

  final PresenceAbsenceCardData data;
  final Function() onPressedCheck;

  @override
  State<PresenceAbsenceCard> createState() => _PresenceAbsenceCardState();
}

class _PresenceAbsenceCardState extends State<PresenceAbsenceCard> {
  String dateOfWeek = "";
  @override
  void initState() {
    dateOfWeek = DateFormat('EEEE').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(kBorderRadius),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Transform.translate(
                offset: const Offset(10, 30),
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: SvgPicture.asset(
                    ImageVectorPath.happy2,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: kSpacing,
              top: kSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Aujourd'hui est : $dateOfWeek",
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 18),
                ),
                Text(
                  "Faite la liste de présence",
                  style: TextStyle(color: kFontColorPallets[1], fontSize: 16),
                ),
                const SizedBox(height: kSpacing),
                ElevatedButton(
                  onPressed: widget.onPressedCheck,
                  child: const Text("Etablir la liste"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
