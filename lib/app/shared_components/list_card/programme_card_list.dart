import 'package:Benjamin/model/programme_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:Benjamin/app/constans/app_constants.dart';

class ProgrammeListCard extends StatelessWidget {
  const ProgrammeListCard({
    required this.data,
    Key? key,
  }) : super(key: key);

  final ProgrammeModel data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          thickness: 1,
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _ProgressIndicator(
              percent: "0.5",
              center: _ProfilImage(image: AssetImage(ImageRasterPath.schedule)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleText('${data.libelle}'),
                  const SizedBox(height: 5),
                  Text(
                    maxLines: 1,
                    '${data.description}',
                    style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const _SubtitleText("Date : "),
                      _ReleaseTimeText(data.date)
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const _SubtitleText("Responsable : "),
                      Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2.5),
                          child: Text(
                            "${data.responsable}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ))
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}

/* -----------------------------> COMPONENTS <------------------------------ */
class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({
    required this.percent,
    required this.center,
    Key? key,
  }) : super(key: key);

  final String? percent;
  final Widget center;

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 40,
      lineWidth: 2.0,
      percent: double.parse('$percent'),
      center: center,
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Colors.green.shade900,
      progressColor: Theme.of(Get.context!).primaryColor,
    );
  }
}

class _ProfilImage extends StatelessWidget {
  const _ProfilImage({required this.image, Key? key}) : super(key: key);

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: image,
      radius: 20,
      backgroundColor: Colors.white,
    );
  }
}

class _TitleText extends StatelessWidget {
  const _TitleText(this.data, {Key? key}) : super(key: key);

  final String data;

  @override
  Widget build(BuildContext context) {
    return Text(
      data.capitalize!,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: kFontColorPallets[0],
        letterSpacing: 0.8,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _SubtitleText extends StatelessWidget {
  const _SubtitleText(this.data, {Key? key}) : super(key: key);

  final String data;
  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: TextStyle(fontSize: 11, color: kFontColorPallets[2]),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ReleaseTimeText extends StatelessWidget {
  const _ReleaseTimeText(this.date, {Key? key}) : super(key: key);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: kNotifColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
        child: Text(
          DateFormat.yMMMd().format(date),
          style: const TextStyle(fontSize: 14, color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ));
  }
}
