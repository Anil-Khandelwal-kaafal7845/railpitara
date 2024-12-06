// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:math';

import 'package:dtlive/utils/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class MyText extends StatelessWidget {
  String text;
  double? fontsizeNormal, fontsizeWeb;
  var maxline, fontstyle, fontweight, textalign, multilanguage;
  Color color;
  var overflow;

  MyText({
    Key? key,
    required this.color,
    required this.text,
    this.fontsizeNormal,
    this.fontsizeWeb,
    this.maxline,
    this.multilanguage,
    this.overflow,
    this.textalign,
    this.fontweight,
    this.fontstyle,
  }) : super(key: key);

  static getAdaptiveTextSize(BuildContext context, dynamic value) {
    // 720 is medium screen height
    if (kIsWeb || Constant.isTV) {
      return (value / 650) *
          min(MediaQuery.of(context).size.height,
              MediaQuery.of(context).size.width);
    } else {
      return (value / 720 * MediaQuery.of(context).size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (multilanguage == true) {
      return LocaleText(
        text,
        textAlign: textalign,
        overflow: overflow,
        maxLines: maxline,
        style: GoogleFonts.montserrat(
          fontSize: getAdaptiveTextSize(context,
              (kIsWeb || Constant.isTV) ? fontsizeWeb : fontsizeNormal),
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontweight,
        ),
      );
    } else {
      return Text(
        text,
        textAlign: textalign,
        overflow: overflow,
        maxLines: maxline,
        style: GoogleFonts.montserrat(
          fontSize: getAdaptiveTextSize(context,
              (kIsWeb || Constant.isTV) ? fontsizeWeb : fontsizeNormal),
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontweight,
        ),
      );
    }
  }
}

class MyTextTWO extends StatelessWidget {
  final String text;
  final double? fontsizeNormal, fontsizeWeb;
  final int? maxline;
  final FontStyle fontstyle;
  final FontWeight fontweight;
  final TextAlign textalign;
  final bool multilanguage;
  final Color color;
  final TextOverflow overflow;

  MyTextTWO({
    Key? key,
    required this.color,
    required this.text,
    this.fontsizeNormal,
    this.fontsizeWeb,
    this.maxline,
    this.multilanguage = false,
    this.overflow = TextOverflow.ellipsis,
    this.textalign = TextAlign.left,
    this.fontweight = FontWeight.normal,
    this.fontstyle = FontStyle.normal,
  }) : super(key: key);

  static double getAdaptiveTextSize(BuildContext context, double value) {
    if (kIsWeb || Constant.isTV) {
      return (value / 650) *
          min(MediaQuery.of(context).size.height,
              MediaQuery.of(context).size.width);
    } else {
      return (value / 720) * MediaQuery.of(context).size.height;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      fontFamily: 'Proximanova',
      fontSize: getAdaptiveTextSize(context, (kIsWeb || Constant.isTV) ? fontsizeWeb! : fontsizeNormal!),
      fontStyle: fontstyle,
      color: color,
      fontWeight: fontweight,
    );

    Widget textWidget;
    if (multilanguage) {
      textWidget = LocaleText(
        text,
        textAlign: textalign,
        overflow: overflow,
        maxLines: maxline,
        style: textStyle,
      );
    } else {
      textWidget = Text(
        text,
        textAlign: textalign,
        overflow: overflow,
        maxLines: maxline,
        style: textStyle,
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width / 1.4,
      child: textWidget,
    );
  }
}
