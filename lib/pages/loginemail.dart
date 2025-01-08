import 'dart:convert';

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dtlive/main.dart';
import 'package:dtlive/pages/bottombar.dart';
import 'package:dtlive/pages/loginsocial.dart';
import 'package:dtlive/pages/otpverify.dart';
import 'package:dtlive/pages/splash.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class LoginSocialEmail extends StatefulWidget {
  const LoginSocialEmail({Key? key}) : super(key: key);

  @override
  State<LoginSocialEmail> createState() => LoginSocialState();
}

class LoginSocialState extends State<LoginSocialEmail> {
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
              privacyUrl = generalProvider.pagesModel.result?[i].url;
            }
            if ((generalProvider.pagesModel.result?[i].pageName ?? "")
                .toLowerCase()
                .contains("terms")) {
              termsConditionUrl = generalProvider.pagesModel.result?[i].url;
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
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: appBgColor,
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 170,
                    height: 60,
                    alignment: Alignment.centerLeft,
                    child: MyImage(
                      fit: BoxFit.fill,
                      imagePath: "appicon.png",
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Login with Email",
                    style: TextStyle(color: white, fontSize: 21),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    "Enter your Email to login",
                    style: TextStyle(color: otherColor, fontSize: 19),
                  ),
                  const SizedBox(height: 30),

                
                  Container(
                    padding: EdgeInsets.only(left: 12),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorPrimary,
                        width: 0.7,
                      ),
                      color: edtBG,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      autovalidateMode: AutovalidateMode.disabled,
                      controller:
                          emailController, // Assuming you have a TextEditingController
                      style: const TextStyle(fontSize: 16, color: white),
                      keyboardType: TextInputType
                          .emailAddress, // Setting keyboard type to email address
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: false,
                        hintStyle: GoogleFonts.montserrat(
                          color: otherColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'Enter your email',
                        // Placeholder text for the email input
                      ),

                      
             
                    ),
                  ),

                  const SizedBox(height: 25),

                  /* Login Button */
                  InkWell(
                 onTap: () {
              String email = emailController.text.toString();
              if (email.isEmpty) {
                // Show snackbar if the email is empty
              Utils.showSnackbar(
                            context, "info", "login_with_email_note", true);
              } else {
                // Email regex pattern
                String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$';
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
                    // onTap: () {
                    //   print("EMAIL enter ${emailController.text.toString()}");
                    //   //  debugPrint("Click mobileNumber ==> $mobileNumber");
                    //   if (emailController.text.toString().isEmpty) {
                    //     Utils.showSnackbar(
                    //         context, "info", "login_with_email_note", true);
                    //   } else {
                    //     debugPrint("mobileNumber ==> $mobileNumber");
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (context) =>
                    //             // OTPVerify( "","email" ,emailController.text.toString()?? ""),
                    //             OTPVerify(
                    //                 "", "email", emailController.text.toString()),
                    //       ),
                    //     );
                    //   }
                    // },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            primaryLight,
                            primaryDark,
                          ],
                          begin: FractionalOffset(0.0, 0.0),
                          end: FractionalOffset(1.0, 0.0),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: MyText(
                        color: white,
                        text: "login",
                        multilanguage: true,
                        fontsizeNormal: 17,
                        fontsizeWeb: 19,
                        fontweight: FontWeight.w700,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  

                  /* Privacy & TermsCondition link */
                  if (strPrivacyAndTNC != null)
               
                    Utils.htmlTexts(strPrivacyAndTNC),
                  const SizedBox(height: 10),

                  /* Or */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 25),

                  /* Mobile Login Button */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 52,
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        // Navigator.pushAndRemoveUntil(context, newRoute, (route) => false)
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginSocial()),
                            (route) => false);
                      },
                      borderRadius: BorderRadius.circular(26),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.phone_fill, // Cupertino icon
                            size: 28, // Adjust the size as needed
                            color: Colors.black, // Adjust the color as needed
                          ),
                          const SizedBox(width: 20),
                          MyText(
                            color: black,
                            text: "loginwithphone",
                            fontsizeNormal: 12,
                            fontsizeWeb: 12,
                            multilanguage: true,
                            fontweight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),


   /* Google Login Button */
              generalProvider.isGoogleLogin == "1"
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: 52,
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          debugPrint("Clicked on : ====> loginWith Google");
                          _gmailLogin();
                        },
                        borderRadius: BorderRadius.circular(26),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyImage(
                              width: 30,
                              height: 30,
                              imagePath: "ic_google.png",
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 30),
                            MyText(
                              color: black,
                              text: "loginwithgoogle",
                              fontsizeNormal: 14,
                              fontsizeWeb: 16,
                              multilanguage: true,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.center,
                              fontstyle: FontStyle.normal,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
              const SizedBox(height: 5),
                  /* Apple Login Button */
                  if (Platform.isIOS)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 52,
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          debugPrint("Clicked on : ====> loginWith Apple");
                          signInWithApple();
                        },
                        borderRadius: BorderRadius.circular(26),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyImage(
                              width: 30,
                              height: 30,
                              imagePath: "ic_apple.png",
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 30),
                            MyText(
                              color: black,
                              text: "loginwithapple",
                              fontsizeNormal: 14,
                              fontsizeWeb: 16,
                              multilanguage: true,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.center,
                              fontstyle: FontStyle.normal,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            )),
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
      if (generalProvider.loginSocialModel.status == 200) {
        debugPrint('Login Successfull!');
        Utils.saveUserCreds(
          userID: generalProvider.loginSocialModel.result?[0].id.toString(),
          userName: generalProvider.loginSocialModel.result?[0].name.toString(),
          userEmail:
              generalProvider.loginSocialModel.result?[0].email.toString(),
          userMobile:
              generalProvider.loginSocialModel.result?[0].mobile.toString(),
          userImage:
              generalProvider.loginSocialModel.result?[0].image.toString(),
          userPremium:
              generalProvider.loginSocialModel.result?[0].isBuy.toString(),
          userType: generalProvider.loginSocialModel.result?[0].type.toString(),
        );

        // Set UserID for Next
        Constant.userID =
            generalProvider.loginSocialModel.result?[0].id.toString();
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
            "${generalProvider.loginSocialModel.message}", false);
      }
    }
  }
}
