import 'package:dtlive/model/auditionmodel.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/webservice/apiservices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package

class AuditionDetailsScreen extends StatefulWidget {
  final String email;

  AuditionDetailsScreen({required this.email, super.key});

  @override
  State<AuditionDetailsScreen> createState() => _AuditionDetailsScreenState();
}

class _AuditionDetailsScreenState extends State<AuditionDetailsScreen> {
  AuditionModel? auditionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    ApiService().auditionDetaiApi(widget.email).then((value) {
      setState(() {
        auditionData = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.myAppBarWithBack(context, "Audition Form", false),
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : auditionData!.result == null
              ? Center(child: Text("There is no information available for this email."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      buildHeader(),
                      const SizedBox(height: 16),
                      buildMainDetails(),
                      const SizedBox(height: 0),
                      buildExtraDetails(),
                    ],
                  ),
                ),
    );
  }

  Widget buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundImage: NetworkImage(auditionData!.result!.pic ?? 'https://static.vecteezy.com/system/resources/thumbnails/003/337/584/small/default-avatar-photo-placeholder-profile-icon-vector.jpg'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Code Number :",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: otherColor,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "${auditionData!.result!.audditionCodNumber ?? "N/A"}",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: white,
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 0),
                child: Row(
                  children: [
                    Text(
                      "Is Shortlisted  :",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: otherColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    auditionData!.result!.isShortlisted == "yes"
                        ? Icon(
                            CupertinoIcons.check_mark,
                            color: Colors.green,
                            size: 18,
                          )
                        : Icon(
                            CupertinoIcons.clear,
                            color: Colors.red,
                            size: 18,
                          ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  children: [
                    Text(
                      "Name :",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: otherColor,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "${auditionData!.result!.name ?? "N/A"}",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: white,
                      ),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    "Email :",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: otherColor,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "${auditionData!.result!.email ?? "N/A"}",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildMainDetails() {
    return Container(
      child: Column(
        children: [
          buildListTile("Audition City", auditionData!.result!.audditionCity),
          buildListTile("Audition Center Name", auditionData!.result!.audditionCenterName),
          buildListTile("Judge Name", auditionData!.result!.judgeName),
          buildListTile("Director Name", auditionData!.result!.directorName),
        ],
      ),
    );
  }

  Widget buildExtraDetails() {
    return Column(
      children: [
        buildListTile("Profession", auditionData!.result!.profession),
        buildListTile("WhatsApp Number", auditionData!.result!.whatsappNumber),
        buildListTile("Mobile", auditionData!.result!.mobile),
        buildListTile("School", auditionData!.result!.school),
        buildListTile("Facebook ID", auditionData!.result!.facebookId),
        buildListTile("Instagram ID", auditionData!.result!.instaId),
        buildListTile("Father's Name", auditionData!.result!.fathername),
        buildListTile("Mother's Name", auditionData!.result!.mothername),
        buildListTile("Age", auditionData!.result!.age.toString()),
        buildListTile("Date of Birth", formatDate(auditionData!.result!.dob)), // Format the date
        buildListTile("Address", auditionData!.result!.address),
        buildListTile("State", auditionData!.result!.state),
        buildListTile("Audition Song", auditionData!.result!.audditionSong),
        buildListTile("Music Company", auditionData!.result!.musicCompany),
        buildListTile("Singer Name", auditionData!.result!.singerName),
        buildListTile("Film Name", auditionData!.result!.filmName),
        buildListTile("Language", auditionData!.result!.language),
      ],
    );
  }

  Widget buildListTile(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "${title} : ",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: otherColor,
                ),
              ),
              SizedBox(width: 8),
              Text(
                "${value}",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: white,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Divider(
              height: 0,
              color: otherColor,
            ),
          )
        ],
      ),
    );
  }

  Widget buildListTilenormal(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
      child: Row(
        children: [
          Text(
            "${title} : ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: otherColor,
            ),
          ),
          SizedBox(width: 8),
          Text(
            "${value}",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: white,
            ),
          )
        ],
      ),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat('yyyy-MM-dd').format(date); // Format as needed
  }
}
