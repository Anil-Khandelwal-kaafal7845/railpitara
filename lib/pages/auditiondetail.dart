import 'package:dtlive/model/auditionmodel.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class AuditionDetailsScreen extends StatefulWidget {
  final String email;
   AuditionDetailsScreen({
    required this.email,
    super.key});

  @override
  State<AuditionDetailsScreen> createState() => _AuditionDetailsScreenState();
}



class _AuditionDetailsScreenState extends State<AuditionDetailsScreen> {

  AuditionModel? auditionData;
  bool isloading =true;

  @override
  void initState() {
    print(widget.email);
    super.initState();
   ApiService().auditionDetaiApi(widget.email).then((value) {
    
                            setState(() {

                              auditionData = value;
                              isloading=false;
                            });
                            print(auditionData.toString());

   });}
  
  
  @override
  
  Widget build(BuildContext context) {
    return  Scaffold(
     appBar: Utils.myAppBarWithBack(context, "Audition Form", false),
      backgroundColor: Colors.white,
     body: isloading
          ? Center(child: CircularProgressIndicator())
          : auditionData!.result == null
              ? Center(child: Text("There is no information available for this email."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                   children: [
                      buildListTile("Is Shortlisted", auditionData!.result!.isShortlisted),
                      buildListTile("ID", auditionData!.result!.id.toString()),
                      buildListTile("Code Number", auditionData!.result!.audditionCodNumber),
                      buildListTile("Profession", auditionData!.result!.profession),
                      buildListTile("Name", auditionData!.result!.name),
                      buildListTile("Email", auditionData!.result!.email),
                      buildListTile("WhatsApp Number", auditionData!.result!.whatsappNumber),
                      buildListTile("Mobile", auditionData!.result!.mobile),
                      buildListTile("School", auditionData!.result!.school),
                      buildListTile("Facebook ID", auditionData!.result!.facebookId),
                      buildListTile("Instagram ID", auditionData!.result!.instaId),
                      buildListTile("Father's Name", auditionData!.result!.fathername),
                      buildListTile("Mother's Name", auditionData!.result!.mothername),
                      buildListTile("Age", auditionData!.result!.age.toString()),
                      buildListTile("Date of Birth", auditionData!.result!.dob.toString()),
                      buildListTile("Address", auditionData!.result!.address),
                      buildListTile("City", auditionData!.result!.city),
                      buildListTile("State", auditionData!.result!.state),
                      buildListTile("Audition Song", auditionData!.result!.audditionSong),
                      buildListTile("Music Company", auditionData!.result!.musicCompany),
                      buildListTile("Singer Name", auditionData!.result!.singerName),
                      buildListTile("Film Name", auditionData!.result!.filmName),
                      buildListTile("Language", auditionData!.result!.language),
                    ],
                  ),
                ),
    );
  }
}
  Widget buildListTile(String title, String? value) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(value ?? "N/A"),
        ),
        Divider(),
      ],
    );
  }