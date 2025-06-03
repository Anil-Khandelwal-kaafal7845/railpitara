import 'dart:convert';

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dtlive/main.dart';
import 'package:dtlive/pages/bottom_bar.dart';
import 'package:dtlive/pages/login_mobile.dart';
import 'package:dtlive/pages/otp_verify.dart';
import 'package:dtlive/provider/generalprovider.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/provider/sectiondataprovider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/widget/myimage.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:moengage_flutter/moengage_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:singular_flutter_sdk/singular.dart';

import '../utils/moenage_service.dart';

class LoginViaSocialEmail extends StatefulWidget {
  const LoginViaSocialEmail({Key? key}) : super(key: key);

  @override
  State<LoginViaSocialEmail> createState() => LoginViaSocialState();
}

class LoginViaSocialState extends State<LoginViaSocialEmail> {
  late ProgressDialog prDialog;
  late GeneralProvider generalProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  String? mobileNumber,
      email,
      userName,
      strType,
      strDeviceType,
      strDeviceToken,
      strPrivacyAndTNC;
  File? mProfileImg;
  String? loginTypes;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userEmail = "";

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    super.initState();
    prDialog = ProgressDialog(context);
    _getDeviceToken();
    _getData();
  }

  _getDeviceToken() async {
    try {
      if (Platform.isAndroid) {
        strDeviceType = "1";
        strDeviceToken = await FirebaseMessaging.instance.getToken();
      } else {
        strDeviceType = "2";
        // final status = await OneSignal.shared.getDeviceState();
        // strDeviceToken = status?.userId;
      }
    } catch (e) {
      debugPrint("_getDeviceToken Exception ===> $e");
    }
    debugPrint("===>strDeviceToken $strDeviceToken");
    debugPrint("===>strDeviceType $strDeviceType");
  }

  String baseUrl = Constant.baseurlwithoutapi;

  _getData() async {
    String? privacyUrl, termsConditionUrl;
    await generalProvider.getPages();
    if (!generalProvider.loading) {
      if (generalProvider.pagesModel.status == 200 &&
          generalProvider.pagesModel.result != null) {
        if ((generalProvider.pagesModel.result?.length ?? 0) > 0) {
          for (var i = 0;
              i < (generalProvider.pagesModel.result?.length ?? 0);
              i++) {
            if ((generalProvider.pagesModel.result?[i].pageName ?? "")
                .toLowerCase()
                .contains("privacy")) {
              privacyUrl =
                  '$baseUrl${generalProvider.pagesModel.result?[i].url}';
            }
            if ((generalProvider.pagesModel.result?[i].pageName ?? "")
                .toLowerCase()
                .contains("terms")) {
              termsConditionUrl =
                  '$baseUrl${generalProvider.pagesModel.result?[i].url}';
            }
          }
        }
      }
    }

    debugPrint('privacyUrl ==> $privacyUrl');
    debugPrint('termsConditionUrl ==> $termsConditionUrl');

    strPrivacyAndTNC = await Utils.getPrivacyTandCText(
        privacyUrl ?? "", termsConditionUrl ?? "");

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  // _getData() async {
  //   String? privacyUrl, termsConditionUrl;
  //   await generalProvider.getPages();
  //   if (!generalProvider.loading) {
  //     if (generalProvider.pagesModel.status == 200 &&
  //         generalProvider.pagesModel.result != null) {
  //       if ((generalProvider.pagesModel.result?.length ?? 0) > 0) {
  //         for (var i = 0;
  //             i < (generalProvider.pagesModel.result?.length ?? 0);
  //             i++) {
  //           if ((generalProvider.pagesModel.result?[i].pageName ?? "")
  //               .toLowerCase()
  //               .contains("privacy")) {
  //             privacyUrl = generalProvider.pagesModel.result?[i].url;
  //           }
  //           if ((generalProvider.pagesModel.result?[i].pageName ?? "")
  //               .toLowerCase()
  //               .contains("terms")) {
  //             termsConditionUrl = generalProvider.pagesModel.result?[i].url;
  //           }
  //         }
  //       }
  //     }
  //   }
  //   debugPrint('privacyUrl ==> $privacyUrl');
  //   debugPrint('termsConditionUrl ==> $termsConditionUrl');

  //   strPrivacyAndTNC = await Utils.getPrivacyTandCText(
  //       privacyUrl ?? "", termsConditionUrl ?? "");
  //   Future.delayed(Duration.zero).then((value) {
  //     if (!mounted) return;
  //     setState(() {});
  //   });
  // }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    analytics.logEvent(
      name: "screen_view",
      parameters: {
        "screen_name": "Login Email",
        "user_id": Constant.userID,
      },
    );
    Map<String, Object> screenViewEvent = {
      'screen_name': 'Email Login',
      'user_id': Constant.userID.toString(),
    };
    Singular.eventWithArgs('screen_view', screenViewEvent);
    final properties = MoEProperties()
      ..addAttribute('screen_name', 'Login Email')
      ..addAttribute('user_id', Constant.userID.toString())

      ..addAttribute('timestamp', DateTime.now().toIso8601String());

    MoEngageService.instance.trackEvent('screen_view', properties);
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: appBgColor,
                resizeToAvoidBottomInset: true, // Ensures UI shifts above keyboard


          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTap: () => FocusScope.of(context)
                      .unfocus(),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                          child:  Column(
                            children: [

                              SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                              Center(
                                child: SizedBox(
                                  height: 250,
                                  width: 250,
                                  child: Image.asset(
                                    "assets/images/loginimage.png",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),


                              Container(
                                width: double.infinity,
                                // constraints: BoxConstraints(
                                //   minHeight: MediaQuery.of(context).size.height * 0.05,
                                // ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(80),
                                    topRight: Radius.circular(0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  constraints: BoxConstraints(
                                    minHeight: MediaQuery.of(context).size.height * 0.65,
                                  ),
                                  child: IntrinsicHeight(
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize:
                                        MainAxisSize.min, // important for scroll

                                        children: [

                                          generalProvider.isMobileLogin == "1"
                                              ? Container(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [

                                                    SizedBox(height: 15,) ,
                                                    Container(
                                                      width: 200,
                                                      height: 90,
                                                      alignment: Alignment.center,
                                                      child: MyImage(
                                                        fit: BoxFit.fill,
                                                        imagePath: "appicon.png",
                                                      ),
                                                    ),




                                                    SizedBox(
                                                      width: 10,
                                                    ),


                                                  ],
                                                ),
                                                const SizedBox(height: 15),

                                                Text(
                                                  "Login With Email",
                                                  style: TextStyle(color: black, fontSize: 18 ,fontWeight: FontWeight.w600),
                                                ),
                                                const SizedBox(height: 15),


                                                //                   Container(
                                                //                     width:
                                                //                         MediaQuery.of(context).size.width,
                                                //                     height: 50,
                                                //                     decoration: BoxDecoration(
                                                //                       border: Border.all(
                                                //                         color: white,
                                                //                         width: 0.7,
                                                //                       ),
                                                //                       color: Colors.black.withOpacity(
                                                //                           0.3), // Black shade with transparency
                                                //                       borderRadius: const BorderRadius.all(
                                                //                         Radius.circular(5),
                                                //                       ),
                                                //                     ),
                                                //                     child: Padding(
                                                //                       padding: const EdgeInsets.symmetric(
                                                //                           horizontal: 8.0),
                                                //                       child: Row(
                                                //                         children: [
                                                //                           // Country code field

                                                // const SizedBox(height: 30),
                                                // Container(
                                                //   padding: EdgeInsets.only(left: 12),
                                                //   width: MediaQuery.of(context).size.width,
                                                //   height: 50,
                                                //   decoration: BoxDecoration(
                                                //     border: Border.all(
                                                //       color: colorPrimary,
                                                //       width: 0.7,
                                                //     ),
                                                //     color: edtBG,
                                                //     borderRadius: const BorderRadius.all(
                                                //       Radius.circular(5),
                                                //     ),
                                                //   ),
                                                //   child:

                                                //   TextFormField(
                                                //     textAlignVertical: TextAlignVertical.center,
                                                //     autovalidateMode: AutovalidateMode.disabled,
                                                //     controller:
                                                //         emailController, // Assuming you have a TextEditingController
                                                //     style: const TextStyle(fontSize: 16, color: white),
                                                //     keyboardType: TextInputType
                                                //         .emailAddress, // Setting keyboard type to email address
                                                //     textInputAction: TextInputAction.done,
                                                //     decoration: InputDecoration(
                                                //       border: InputBorder.none,
                                                //       filled: false,
                                                //       hintStyle: GoogleFonts.montserrat(
                                                //         color: black
                                                //                                       .withOpacity(0.3),
                                                //         fontSize: 14,
                                                //         fontWeight: FontWeight.w500,
                                                //       ),
                                                //       hintText: 'Enter your email',
                                                //       // Placeholder text for the email input
                                                //     ),
                                                //   ),

                                                // ),

                                                //                         ],
                                                //                       ),
                                                //                     ),
                                                //                   ),


                                                // old --
                                                Container(
                                                  padding: EdgeInsets.only(left: 12),
                                                  width: MediaQuery.of(context).size.width,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: white,
                                                      width: 0.7,
                                                    ),
                                                    color: Colors.black.withOpacity(
                                                        0.3),
                                                    borderRadius: const BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                  ),
                                                  child: TextFormField(
                                                    textAlignVertical: TextAlignVertical.center,
                                                    autovalidateMode: AutovalidateMode.disabled,
                                                    controller:
                                                    emailController, // Assuming you have a TextEditingController
                                                    style: const TextStyle(fontSize: 16, color: black),
                                                    keyboardType: TextInputType
                                                        .emailAddress, // Setting keyboard type to email address
                                                    textInputAction: TextInputAction.done,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      filled: false,
                                                      hintStyle: GoogleFonts.montserrat(
                                                        color: Colors.black.withOpacity(
                                                            0.3),
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      hintText: 'Enter your email',
                                                      // Placeholder text for the email input
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 25),
                                                InkWell(
                                                  onTap: () async {
                                                    MoEngageService.instance.setUserName(emailController.text.toString());
                                                    // Get device ID
                                                    final deviceInfoPlugin = DeviceInfoPlugin();
                                                    String deviceId;

                                                    if (Platform.isAndroid) {
                                                      final androidInfo = await deviceInfoPlugin.androidInfo;
                                                      deviceId = androidInfo.id ?? 'unknown';
                                                    } else if (Platform.isIOS) {
                                                      final iosInfo = await deviceInfoPlugin.iosInfo;
                                                      deviceId = iosInfo.identifierForVendor ?? 'unknown';
                                                    } else {
                                                      deviceId = 'unsupported_platform';
                                                    }

                                                    MoEngageService.instance.identifyUser(mobileNumber.toString());
                                                    final timestamp = DateTime.now().toIso8601String();

                                                    final properties = MoEProperties()
                                                      ..addAttribute('user_id ', emailController.text.toString())
                                                      ..addAttribute('signup_method ', 'email')
                                                      ..addAttribute('device_id', deviceId)
                                                      ..addAttribute('timestamp', timestamp);

                                                    MoEngageService.instance.trackEvent('User_Registration', properties);

                                                    print("MoEngage event tracked with device ID: $deviceId and timestamp: $timestamp");

                                                    String email = emailController.text.toString();
                                                    if (email.isEmpty) {
                                                      // Show snackbar if the email is empty
                                                      Utils.showSnackbar(
                                                          context, "info", "login_with_email_note", true);
                                                    } else {
                                                      // Email regex pattern
                                                      String emailPattern =
                                                          r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$';
                                                      RegExp regex = RegExp(emailPattern);
                                                      if (!regex.hasMatch(email)) {
                                                        // Show snackbar if the email is invalid
                                                        Utils.showSnackbar(
                                                            context, "info", "login_with_email_note", true);
                                                      } else {
                                                        // Proceed to OTPVerify screen if email is valid
                                                        Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                OTPVerify("", "email", emailController.text),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  borderRadius: BorderRadius.circular(18),
                                                  child: Container(
                                                    width:
                                                    MediaQuery.of(context).size.width/2.3,
                                                    height: 45,
                                                    decoration: BoxDecoration(
                                                      gradient: const LinearGradient(
                                                        colors: [
                                                          primaryDark,
                                                          primaryLight
                                                        ],
                                                        begin: FractionalOffset(0.0, 0.0),
                                                        end: FractionalOffset(1.0, 0.0),
                                                        stops: [0.0, 1.0],
                                                        tileMode: TileMode.clamp,
                                                      ),
                                                      borderRadius:
                                                      BorderRadius.circular(12),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: MyText(
                                                      color: white,
                                                      text: "login",
                                                      multilanguage: true,
                                                      fontsizeNormal: 15,
                                                      fontsizeWeb: 17,
                                                      fontweight: FontWeight.w600,
                                                      maxline: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      textalign: TextAlign.center,
                                                      fontstyle: FontStyle.normal,
                                                    ),
                                                  ),
                                                ),
                                                // const SizedBox(height: 10),
                                                // if (strPrivacyAndTNC != null)
                                                //   Utils.htmlTexts(strPrivacyAndTNC),
                                                const SizedBox(height: 20),

                                                /* Or */
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 80,
                                                      height: 1,
                                                      color: colorAccent,
                                                    ),
                                                    const SizedBox(width: 15),
                                                    MyText(
                                                      color: otherColor,
                                                      text: "or",
                                                      multilanguage: true,
                                                      fontsizeNormal: 14,
                                                      fontsizeWeb: 16,
                                                      fontweight: FontWeight.w500,
                                                      maxline: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      textalign: TextAlign.center,
                                                      fontstyle: FontStyle.normal,
                                                    ),
                                                    const SizedBox(width: 15),
                                                    Container(
                                                      width: 80,
                                                      height: 1,
                                                      color: colorAccent,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),
                                              ],
                                            ),
                                          )
                                              : SizedBox.shrink(),

                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                30), // Clipping to round the edges
                                            child: Container(
                                              padding:
                                              const EdgeInsets.symmetric(horizontal: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  if (generalProvider.isGoogleLogin == "1")
                                                    _buildSocialButton(
                                                      imagePath: "ic_google.png",
                                                      onTap: _gmailLogin,
                                                      bgColor: Colors.white,
                                                    ),
                                                  if (generalProvider.isEmail == "1")
                                                    _buildSocialButton(
                                                      icon: CupertinoIcons.phone_fill,
                                                      iconColor: Colors.red,
                                                      onTap: () {
                                                        Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => LoginViaSocial()),
                                                              (route) => false, // This removes all previous routes
                                                        );

                                                      },
                                                      bgColor: Colors.white,
                                                    ),

                                                  if (generalProvider.isGoogleLogin == "1")

                                                    if (Platform.isIOS)
                                                      _buildSocialButton(
                                                        imagePath: "ic_apple.png",
                                                        onTap: signInWithApple,
                                                        bgColor: Colors.white,
                                                      ),
                                                  if (generalProvider.isFbLogin == "1")
                                                    _buildSocialButton(
                                                      imagePath: "ic_facebook.png",
                                                      onTap: () async {
                                                        final LoginResult result =
                                                        await FacebookAuth.instance.login();
                                                        if (result.status ==
                                                            LoginStatus.success) {
                                                          final userData = await FacebookAuth
                                                              .instance
                                                              .getUserData();
                                                          print(userData);
                                                        } else {
                                                          print(result.status);
                                                          print(result.message);
                                                        }
                                                      },
                                                      bgColor: Colors.blue,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),



                                        ],

                                      ),
                                    ),
                                  ),
                                ),
                              )




                            ],
                          ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )));






    
    


  }

    Widget _buildSocialButton({
    String? imagePath,
    IconData? icon,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
    required Color bgColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        elevation: 2, // Adds elevation to buttons
        shape: CircleBorder(),
        color: bgColor, // Background color for the button
        child: InkWell(
          onTap: onTap,
          customBorder: CircleBorder(),
          child: Container(
            width: 50, // Circular button size
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Center(
              child: imagePath != null
                  ? MyImage(
                      width: 27,
                      height: 27,
                      imagePath: imagePath,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      icon,
                      size: 26,
                      color: iconColor,
                    ),
            ),
          ),
        ),
      ),
    );
  }


  /* Google Login */
  Future<void> _gmailLogin() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    GoogleSignInAccount user = googleUser;

    debugPrint('GoogleSignIn ===> id : ${user.id}');
    debugPrint('GoogleSignIn ===> email : ${user.email}');
    debugPrint('GoogleSignIn ===> displayName : ${user.displayName}');
    debugPrint('GoogleSignIn ===> photoUrl : ${user.photoUrl}');

    if (!mounted) return;
    Utils.showProgress(context, prDialog);

    UserCredential userCredential;
    try {
      GoogleSignInAuthentication googleSignInAuthentication =
          await user.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      userCredential = await _auth.signInWithCredential(credential);
      assert(await userCredential.user?.getIdToken() != null);
      debugPrint("User Name: ${userCredential.user?.displayName}");
      debugPrint("User Email ${userCredential.user?.email}");
      debugPrint("User photoUrl ${userCredential.user?.photoURL}");
      debugPrint("uid ===> ${userCredential.user?.uid}");
      String firebasedid = userCredential.user?.uid ?? "";
      debugPrint('firebasedid :===> $firebasedid');

      /* Save PhotoUrl in File */
      mProfileImg =
          await Utils.saveImageInStorage(userCredential.user?.photoURL ?? "");
      debugPrint('mProfileImg :===> $mProfileImg');

      checkAndNavigate(user.email, user.displayName ?? "", "2");
    } on FirebaseAuthException catch (e) {
      debugPrint('===>Exp${e.code.toString()}');
      debugPrint('===>Exp${e.message.toString()}');
      if (e.code.toString() == "user-not-found") {
      } else if (e.code == 'wrong-password') {
        // Hide Progress Dialog
        await prDialog.hide();
        debugPrint('Wrong password provided.');
        Utils.showToast('Wrong password provided.');
      } else {
        // Hide Progress Dialog
        await prDialog.hide();
      }
    }
  }

  /* Apple Login */
  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signInWithApple() async {
    // Generate a nonce to prevent replay attacks
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      // Request credentials for the signed-in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      debugPrint(
          "Apple Authorization Code: ${appleCredential.authorizationCode}");

      // Create an OAuth credential from the Apple credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase
      final authResult = await _auth.signInWithCredential(oauthCredential);

      final firebaseUser = authResult.user;

      // Initialize variables
      String? displayName =
          '${appleCredential.givenName ?? ""} ${appleCredential.familyName ?? ""}'
              .trim();
      String userEmail = firebaseUser?.email ?? "";
      String? firebasedId = firebaseUser?.uid;

      debugPrint("Firebase User UID: $firebasedId");

      if (userEmail.isEmpty) {
        // If the email is not available from Apple, use Firebase data
        userEmail = firebaseUser?.email ?? "";
        displayName = firebaseUser?.displayName ?? displayName;
      } else {
        // Update Firebase user's profile with name and email
        await firebaseUser?.updateDisplayName(displayName);
        await firebaseUser?.updateEmail(userEmail);
      }

      // Final debug prints
      debugPrint("Final User Email: $userEmail");
      debugPrint("Final Display Name: $displayName");
      debugPrint("Final Firebase ID: $firebasedId");

      // Navigate based on user details
      checkAndNavigate(userEmail, displayName, "5");
      return firebaseUser;
    } catch (exception) {
      debugPrint("Apple Login Exception: $exception");
      return null;
    }
  }

  checkAndNavigate(String mail, String displayName, String type) async {
    email = mail;
    userName = displayName;
    strType = type;
    debugPrint('checkAndNavigate email ==>> $email');
    debugPrint('checkAndNavigate userName ==>> $userName');
    debugPrint('checkAndNavigate strType ==>> $strType');
    debugPrint('checkAndNavigate mProfileImg :===> $mProfileImg');
    if (!prDialog.isShowing()) {
      Utils.showProgress(context, prDialog);
    }
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    await generalProvider.loginWithSocial(
        email, userName, strType, mProfileImg);
    debugPrint('checkAndNavigate loading ==>> ${generalProvider.loading}');

    if (!generalProvider.loading) {
      if (generalProvider.LoginViaSocialModel.status == 200) {
        debugPrint('Login Successfull!');
        Utils.saveUserCreds(
          userID: generalProvider.LoginViaSocialModel.result?[0].id.toString(),
          userName: generalProvider.LoginViaSocialModel.result?[0].name.toString(),
          userEmail:
              generalProvider.LoginViaSocialModel.result?[0].email.toString(),
          userMobile:
              generalProvider.LoginViaSocialModel.result?[0].mobile.toString(),
          userImage:
              generalProvider.LoginViaSocialModel.result?[0].image.toString(),
          userPremium:
              generalProvider.LoginViaSocialModel.result?[0].isBuy.toString(),
          userType: generalProvider.LoginViaSocialModel.result?[0].type.toString(),
        );

        // Set UserID for Next
        Constant.userID =
            generalProvider.LoginViaSocialModel.result?[0].id.toString();
        debugPrint('Constant userID ==>> ${Constant.userID}');

        await homeProvider.setSelectedTab(0);
        await sectionDataProvider.getSectionBanner("0", "1");
        await sectionDataProvider.getSectionList("0", "1", "0");

        // Hide Progress Dialog
        await prDialog.hide();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const Bottombar()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Hide Progress Dialog
        await prDialog.hide();
        if (!mounted) return;
        Utils.showSnackbar(context, "fail",
            "${generalProvider.LoginViaSocialModel.message}", false);
      }
    }
  }
}
