import 'dart:io';
import 'package:dtlive/provider/castdetailsprovider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/strings.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CastDetails extends StatefulWidget {
  final String? castID;
  const CastDetails({Key? key, required this.castID}) : super(key: key);

  @override
  State<CastDetails> createState() => _CastDetailsState();
}

class _CastDetailsState extends State<CastDetails> {
  late CastDetailsProvider castDetailsProvider;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  _getData() async {
    castDetailsProvider =
        Provider.of<CastDetailsProvider>(context, listen: false);
    await castDetailsProvider.getCastDetails(widget.castID);
    Future.delayed(Duration.zero).then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    castDetailsProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final castData = castDetailsProvider.castDetailModel.result;
    final castName = castData != null ? (castData[0].name ?? "-") : "-";
    final personalInfo =
        castData != null ? (castData[0].personalInfo ?? "-") : "-";
    final hasExtraContent = personalInfo.length > 200; // Determine scrolling

    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Cast Image Banner
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                MyNetworkImage(
                  imageUrl: castData != null ? (castData[0].image ?? "") : "",
                  fit: BoxFit.cover,
                  imgHeight: kIsWeb
                      ? MediaQuery.of(context).size.height
                      : (MediaQuery.of(context).size.height * 0.55),
                  imgWidth: MediaQuery.of(context).size.width,
                ),
                Container(
                  height: kIsWeb
                      ? MediaQuery.of(context).size.height
                      : (MediaQuery.of(context).size.height * 0.55),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [transparentColor, blackTransparent, black],
                    ),
                  ),
                ),
                if (Platform.isAndroid || Platform.isIOS)
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Utils.buildBackBtn(context),
                  ),
              ],
            ),

            // Cast Name & Description
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: SingleChildScrollView(
                  physics: hasExtraContent
                      ? null
                      : const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cast Name
                      MyText(
                        text: castName,
                        color: white,
                        textalign: TextAlign.start,
                        fontweight: FontWeight.w600,
                        fontsizeNormal: 22, // Reduced font size
                        multilanguage: false,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 8),

                      // Cast Description
                      ExpandableText(
                        personalInfo,
                        expandText: more,
                        collapseText: less_,
                        maxLines: 6, // Adjusted for better readability
                        linkColor: otherColor,
                        textAlign: TextAlign.start,
                        expandOnTextTap: true,
                        collapseOnTextTap: true,
                        style: GoogleFonts.montserrat(
                          fontSize: 13, // Reduced font size
                          color: white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
