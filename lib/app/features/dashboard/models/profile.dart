import 'package:flutter/material.dart';

class Profile {
  final ImageProvider photo;
  final dynamic name;
  final dynamic email;

  const Profile({
    required this.photo,
    required this.name,
    required this.email,
  });
}
