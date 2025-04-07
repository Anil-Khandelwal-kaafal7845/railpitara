
import 'package:dtlive/model/auditionmodel.dart';
import 'package:dtlive/pages/aboutprivacyterms.dart';
import 'package:dtlive/pages/auditiondetail.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EmailScreenAudition extends StatefulWidget {
  // final String url;
  const EmailScreenAudition({Key? key, }) : super(key: key);

  @override
  State<EmailScreenAudition> createState() => _EmailScreenAuditionState();
}

class _EmailScreenAuditionState extends State<EmailScreenAudition> {
  TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> emailKey = GlobalKey<FormState>();
  AuditionModel? auditionData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: Utils.myAppBarWithBack(context, "Audition Form", false),
      backgroundColor: appBgColor,
      body: Padding(
        padding: EdgeInsets.only(left: 15 ,right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            SizedBox(height: 50,) ,
            const Text(
              "Check Your Audition Details Here",
              style: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.34,
                width: MediaQuery.of(context).size.width * 1,
                child: Form(
                  key: emailKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Please fill up below details",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.normal),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      TextFormField(
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        validator: (value) {
                          if (!EmailValidator.validate(value ?? "")) {
                            return "Please enter valid email address";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.only(
                            right: 20,
                            top: 17,
                            bottom: 17,
                          ),
                        prefixIcon: const Icon(CupertinoIcons.mail_solid, color: Colors.red),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (emailKey.currentState == null ||
                              !emailKey.currentState!.validate()) {
                            debugPrint('Form validation failed');
                            return;
                          }
                           Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AuditionDetailsScreen(
                          email: emailController.text,
                        ),
                      )
                      );

                          // ApiService().auditionDetaiApi(emailController.text).then((value) {
                          //   setState(() {
                          //     auditionData = value;
                          //   });
                          //   _showAuditionDetailsDialog();
                          // });
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.05,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red,
                          ),
                          child: const Center(
                              child: Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      GestureDetector(
                        onTap: () {
      
                          //https:\/\/admin.aaryaadigital.com\/audition-form
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AboutPrivacyTerms(
                          appBarTitle:'Audition Form',
                          loadURL:"https:\/\/admin.aaryaadigital.com\/audition-form",
                        ),
                      )
                      );
                        },
                        child: const Center(
                          child: Text(
                            'Click here to fill out the audition form',
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              fontSize: 16
                            ),
                          ),
                        ),
                      )
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




  void _showAuditionDetailsDialog() {
    if (auditionData!.status == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: 
            FractionallySizedBox(
               widthFactor: 1,
              child: SingleChildScrollView(

                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Audition Details',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Text('Name: ${auditionData!.result!.name}'),
                      _buildDetailDivider(),
                      Text('Email: ${auditionData!.result!.email}'),
                      _buildDetailDivider(),
                          
                      Text('Mobile Number: ${auditionData!.result!.mobile}'),
                      _buildDetailDivider(),
                          
                      Text('Age: ${auditionData!.result!.age}'),
                      _buildDetailDivider(),
                          Text('Date of birth: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(auditionData!.result!.dob.toString()))}'),
                      _buildDetailDivider(),
                          
                      Text("Father's Name: ${auditionData!.result!.fathername}"),
                      _buildDetailDivider(),
                          
                      Text("Mother's Name: ${auditionData!.result!.mothername}"),
                      _buildDetailDivider(),
                          
                      Text('School: ${auditionData!.result!.school}'),
                      _buildDetailDivider(),
                          
                      Text('City: ${auditionData!.result!.city}'),
                      _buildDetailDivider(),
                          
                      Text('State: ${auditionData!.result!.state}'),
                      _buildDetailDivider(),
                          
                      Text('Shortlisted: ${auditionData!.result!.isShortlisted}'),
                      _buildDetailDivider(),
                          
                      Text('Judge Name: ${auditionData!.result!.judgeName}'),
                      _buildDetailDivider(),
                          
                      Text('Language: ${auditionData!.result!.language}'),
                      _buildDetailDivider(),
                          
                      Text('Instagram Id: ${auditionData!.result!.instaId}'),
                      _buildDetailDivider(),
                          
                      Text('Facebook Id: ${auditionData!.result!.facebookId}'),
                      _buildDetailDivider(),
                          
                      Text('Profession: ${auditionData!.result!.profession}'),
                      _buildDetailDivider(),
                          
                      Text('Audition Song: ${auditionData!.result!.audditionSong}'),
                      _buildDetailDivider(),
                          
                      Text('Audition city: ${auditionData!.result!.audditionCity}'),
                      _buildDetailDivider(),
                          
                      Text(
                          'Audition center name: ${auditionData!.result!.audditionCenterName}'),
                          
                      // Add other details as needed
                      const SizedBox(height: 20.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Close',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
         
         );
        },
      );
  
    } else {
      // Handle case where auditionData is null (e.g., API call failed)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Audition Details Found'),
            content:
                const Text('There is no information available for this email.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

}

Widget _buildDetailDivider() {
  return Divider(
    height: 20,
    color: Colors.grey[400],
    thickness: 1.0,
  );
}
