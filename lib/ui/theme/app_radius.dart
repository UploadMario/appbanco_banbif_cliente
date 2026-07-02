import 'package:flutter/material.dart';

class AppRadius {
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 28;

  static BorderRadius get small => BorderRadius.circular(sm);
  static BorderRadius get input => BorderRadius.circular(md);
  static BorderRadius get button => BorderRadius.circular(lg);
  static BorderRadius get card => BorderRadius.circular(xl);
}
