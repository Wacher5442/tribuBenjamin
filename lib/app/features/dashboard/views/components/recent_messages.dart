import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

class RecentMessages extends StatelessWidget {
  const RecentMessages({
    required this.onPressedMore,
    Key? key,
  }) : super(key: key);

  final Function() onPressedMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Membres de la tribu",
          style: TextStyle(color: Colors.white),
        ),
        const Spacer(),
        IconButton(
          onPressed: onPressedMore,
          icon: const Icon(EvaIcons.eye),
          tooltip: "Voir",
        )
      ],
    );
  }
}
