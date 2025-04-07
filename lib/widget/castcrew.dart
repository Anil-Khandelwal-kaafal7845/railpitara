import 'package:dtlive/model/sectiondetailmodel.dart';
import 'package:dtlive/pages/cast_details.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:dtlive/widget/myusernetworkimg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class CastCrew extends StatefulWidget {
  final List<Cast>? castList;
  const CastCrew({required this.castList, Key? key}) : super(key: key);

  @override
  State<CastCrew> createState() => _CastCrewState();
}

class _CastCrewState extends State<CastCrew> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: MyText(
            color: white,
            text: "castandcrew",
            multilanguage: true,
            textalign: TextAlign.start,
            fontsizeNormal: 12,
            fontweight: FontWeight.w400,
            fontsizeWeb: 16,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
          ),
        ),

        const SizedBox(height: 5),
        _buildCAndCLayout(),
        // Container(
        //   width: MediaQuery.of(context).size.width,
        //   height: 0.7,
        //   margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        //   color: colorPrimary,
        // ),
        const SizedBox(height: 15),
      ],
    );
  }

Widget _buildCAndCLayout() {
  if (widget.castList != null && widget.castList!.isNotEmpty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ResponsiveGridList(
        minItemWidth: 100,
        verticalGridSpacing: 20,
        horizontalGridSpacing: 12,
        minItemsPerRow: 4,
        maxItemsPerRow: 6,
        listViewBuilderOptions:  ListViewBuilderOptions(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
        ),
        children: List.generate(widget.castList!.length, (index) {
          final cast = widget.castList![index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  if (kIsWeb || Constant.isTV) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CastDetails(
                        castID: cast.id.toString(),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: MyUserNetworkImage(
                    imageUrl: cast.image ?? "",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 90,
                child: MyText(
                  multilanguage: false,
                  text: cast.name ?? "",
                  fontstyle: FontStyle.normal,
                  fontsizeNormal: 11,
                  fontweight: FontWeight.w500,
                  fontsizeWeb: 14,
                  maxline: 2,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  color: white.withOpacity(0.85),
                ),
              ),
            ],
          );
        }),
      ),
    );
  } else {
    return const SizedBox.shrink();
  }
}


}
