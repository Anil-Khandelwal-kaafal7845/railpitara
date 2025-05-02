import 'dart:async';

import 'package:dtlive/pages/bottom_bar.dart';
import 'package:dtlive/provider/generalprovider.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/provider/sectiondataprovider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:singular_flutter_sdk/singular.dart';

import '../webservice/apiservices.dart';

class OTPVerify extends StatefulWidget {
  final String mobileNumber;
  final String type;
  final String email;

  const OTPVerify(this.mobileNumber, this.type, this.email, {Key? key})
      : super(key: key);

  @override
  State<OTPVerify> createState() => OTPVerifyState();
}

class OTPVerifyState extends State<OTPVerify> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late ProgressDialog prDialog;
  SharedPre sharePref = SharedPre();
  final numberController = TextEditingController();
  final pinPutController = TextEditingController();
  ScrollController scollController = ScrollController();
  String? verificationId, strDeviceType, strDeviceToken;
  int? forceResendingToken;
  bool codeResended = false;

  late Timer _resendTimer;
  int _resendCountdown = 30;

  bool _isLoading = false;

  @override
  void initState() {
    print("EMNAIL AA GYI ---${widget.email}");
    super.initState();
    // _getDeviceToken();
    startResendTimer();
    _sendWhatsappOTP();
    prDialog = ProgressDialog(context);
    // codeSend(false);
  }

  void startResendTimer() {
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _resendTimer.cancel(); // Stop the timer when it reaches 0
        }
      });
    });
  }

  //   void startResendTimer() {
  //   _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     setState(() {
  //       if (_resendCountdown > 0) {
  //         _resendCountdown--;
  //       } else {
  //         _resendTimer.cancel(); // Stop the timer when it reaches 0
  //       }
  //     });
  //   });
  // }

  _sendWhatsappOTP() async {
    await ApiService()
        .loginWithWhatsapp(widget.mobileNumber, widget.type, widget.email);
  }

  @override
  void dispose() {
    _resendTimer.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Object> screenViewEvent = {
      'screen_name': 'OTP Verify Screen',
      'user_id': Constant.userID.toString(),
    };
    Singular.eventWithArgs('screen_view', screenViewEvent);
    return Scaffold(
      backgroundColor: appBgColor,
      resizeToAvoidBottomInset: true,
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
                                "assets/images/otpscreenimage.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            // constraints: BoxConstraints(
                            //   minHeight: MediaQuery.of(context).size.height * 0.05,
                            // ),
                            padding:
                            const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
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
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min, // important for scroll

                                    children: [
                                      const SizedBox(height: 30),

                                      widget.mobileNumber.isNotEmpty
                                          ? MyText(
                                        color: black.withOpacity(0.4),
                                        text: "code_sent_desc",
                                        fontsizeNormal: 16,
                                        fontweight: FontWeight.w500,
                                        maxline: 3,
                                        overflow: TextOverflow.ellipsis,
                                        textalign: TextAlign.center,
                                        multilanguage: true,
                                        fontstyle: FontStyle.normal,
                                      )
                                          : MyText(
                                        color: black.withOpacity(0.4),
                                        text: "code_sent_desc_email",
                                        fontsizeNormal: 16,
                                        fontweight: FontWeight.w500,
                                        maxline: 3,
                                        overflow: TextOverflow.ellipsis,
                                        textalign: TextAlign.center,
                                        multilanguage: true,
                                        fontstyle: FontStyle.normal,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),

                                      MyText(
                                        color: black.withOpacity(0.3),
                                        text: widget.mobileNumber.isNotEmpty
                                            ? widget.mobileNumber
                                            : widget.email,
                                        fontsizeNormal: 13,
                                        fontweight: FontWeight.w500,
                                        maxline: 3,
                                        overflow: TextOverflow.ellipsis,
                                        textalign: TextAlign.center,
                                        multilanguage: false,
                                        fontstyle: FontStyle.normal,
                                      ),

                                      const SizedBox(height: 40),

                                      /* Enter Received OTP */
                                      Pinput(
                                        length: 4,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.next,
                                        controller: pinPutController,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        defaultPinTheme: PinTheme(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: white, width: 0.7),
                                            shape: BoxShape.rectangle,
                                            color: black.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          textStyle: GoogleFonts.montserrat(
                                            color: black,
                                            fontSize: 16,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),

                                      /* Confirm Button */
                                      InkWell(
                                        borderRadius: BorderRadius.circular(26),
                                        onTap: () {
                                          debugPrint(
                                              "Clicked sms Code =====> ${pinPutController.text}");
                                          if (pinPutController.text.toString().isEmpty) {
                                            Utils.showSnackbar(
                                                context, "info", "enterreceivedotp", true);
                                          } else {
                                            // if (verificationId == null || verificationId == "") {
                                            //   Utils.showSnackbar(
                                            //       context, "info", "otp_not_working", true);
                                            //   return;
                                            // }
                                            // Utils.showProgress(context, prDialog);
                                            // _checkOTPAndLogin();
                                            _isLoading ? null : _checkOTPAndLogin();
                                          }
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width / 2.3,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [primaryDark, primaryLight],
                                              begin: FractionalOffset(0.0, 0.0),
                                              end: FractionalOffset(1.0, 0.0),
                                              stops: [0.0, 1.0],
                                              tileMode: TileMode.clamp,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: MyText(
                                            color: white,
                                            text: "confirm",
                                            fontsizeNormal: 15,
                                            multilanguage: true,
                                            fontweight: FontWeight.w600,
                                            maxline: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textalign: TextAlign.center,
                                            fontstyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      /* Resend */
                                      // InkWell(
                                      //   borderRadius: BorderRadius.circular(10),
                                      //   onTap: () {
                                      //     _sendWhatsappOTP();

                                      //     // if (!codeResended) {
                                      //     //   codeSend(true);
                                      //     // }
                                      //   },
                                      //   child: Container(
                                      //     constraints: const BoxConstraints(minWidth: 70),
                                      //     padding: const EdgeInsets.all(5),
                                      //     child: MyText(
                                      //       color: white,
                                      //       text: "resend",
                                      //       multilanguage: true,
                                      //       fontsizeNormal: 16,
                                      //       fontweight: FontWeight.w700,
                                      //       maxline: 1,
                                      //       overflow: TextOverflow.ellipsis,
                                      //       textalign: TextAlign.center,
                                      //       fontstyle: FontStyle.normal,
                                      //     ),
                                      //   ),
                                      // ),

                                      InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: _resendCountdown == 0
                                            ? () {
                                          _sendWhatsappOTP();
                                          setState(() {
                                            _resendCountdown =
                                            30; // Reset the countdown
                                          });
                                          startResendTimer(); // Start the countdown again
                                        }
                                            : null,
                                        child: Container(
                                          constraints: const BoxConstraints(minWidth: 70),
                                          padding: const EdgeInsets.all(5),
                                          child: _resendCountdown == 0
                                              ? Text(
                                            "Resend",
                                            style: TextStyle(
                                                color: black.withOpacity(0.4),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15),
                                          )
                                              : Text(
                                            "Resend OTP in 00:${_resendCountdown.toString().padLeft(2, '0')} second",
                                            style: TextStyle(
                                                color: black.withOpacity(0.8),
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14),
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

      ),
    );
  }

  // codeSend(bool isResend) async {
  //   codeResended = isResend;
  // await phoneSignIn(phoneNumber: widget.mobileNumber.toString());
  //   prDialog.hide();
  // }

  Future<void> phoneSignIn({required String phoneNumber}) async {
    await _auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 60),
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _onCodeTimeout,
    );
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    debugPrint("verification completed ======> ${authCredential.smsCode}");
    setState(() {
      pinPutController.text = authCredential.smsCode ?? "";
    });
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      debugPrint("The phone number entered is invalid!");
      Utils.showSnackbar(context, "fail", "invalidphonenumber", true);
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    this.forceResendingToken = forceResendingToken;
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
    debugPrint("verificationId =======> $verificationId");
    debugPrint("resendingToken =======> ${forceResendingToken.toString()}");
    debugPrint("code sent");
  }

  _onCodeTimeout(String verificationId) {
    debugPrint("_onCodeTimeout verificationId =======> $verificationId");
    this.verificationId = verificationId;
    prDialog.hide();
    codeResended = false;
    return null;
  }

  _checkOTPAndLogin() async {
    if (_isLoading) return; // Prevent multiple taps

    setState(() {
      _isLoading = true;
    });

    debugPrint("_checkOTPAndLogin verificationId =====> $verificationId");
    debugPrint("_checkOTPAndLogin smsCode =====> ${pinPutController.text}");

    try {
      bool value = await ApiService().verifyLoginWithWhatsapp(
          widget.mobileNumber, pinPutController.text, widget.email);

      if (value) {
        _login(widget.mobileNumber.toString(), widget.email.toString());
      } else {
        await prDialog.hide();
        if (!mounted) return;
        Utils.showSnackbar(context, "info", "otp_invalid", true);
      }
    } catch (e) {
      debugPrint("Error during OTP verification: $e");
      if (mounted) {
        Utils.showSnackbar(context, "error", "Something went wrong", true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // _checkOTPAndLogin() async {
  //   if (_isLoading) return; // Prevent multiple taps
  //
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   // bool error = false;
  //   // UserCredential? userCredential;
  //
  //   debugPrint("_checkOTPAndLogin verificationId =====> $verificationId");
  //   debugPrint("_checkOTPAndLogin smsCode =====> ${pinPutController.text}");
  //
  //   // Create a PhoneAuthCredential with the code
  //   // PhoneAuthCredential? phoneAuthCredential = PhoneAuthProvider.credential(
  //   //   verificationId: verificationId ?? "",
  //   //   smsCode: pinPutController.text.toString(),
  //   // );
  //
  //   // debugPrint(
  //   //     "phoneAuthCredential.smsCode        =====> ${phoneAuthCredential.smsCode}");
  //   // debugPrint(
  //   //     "phoneAuthCredential.verificationId =====> ${phoneAuthCredential.verificationId}");
  //
  //   ///
  //   await ApiService()
  //       .verifyLoginWithWhatsapp(
  //       widget.mobileNumber, pinPutController.text, widget.email)
  //       .then((value) async {
  //     if (value) {
  //       _login(widget.mobileNumber.toString(), widget.email.toString());
  //     } else {
  //       await prDialog.hide();
  //       if (!mounted) return;
  //       Utils.showSnackbar(context, "info", "otp_invalid", true);
  //       return;
  //     }
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   });
  //
  //   ///
  //
  //   // try {
  //   //   userCredential = await _auth.signInWithCredential(phoneAuthCredential);
  //   //   debugPrint(
  //   //       "_checkOTPAndLogin userCredential =====> ${userCredential.user?.phoneNumber ?? ""}");
  //   // } on FirebaseAuthException catch (e) {
  //   //   await prDialog.hide();
  //   //   debugPrint("_checkOTPAndLogin error Code =====> ${e.code}");
  //   //   if (e.code == 'invalid-verification-code' ||
  //   //       e.code == 'invalid-verification-id') {
  //   //     if (!mounted) return;
  //   //     Utils.showSnackbar(context, "info", "otp_invalid", true);
  //   //     return;
  //   //   } else if (e.code == 'session-expired') {
  //   //     if (!mounted) return;
  //   //     Utils.showSnackbar(context, "fail", "otp_session_expired", true);
  //   //     return;
  //   //   } else {
  //   //     error = true;
  //   //   }
  //   // }
  //   // debugPrint(
  //   //     "Firebase Verification Complated & phoneNumber => ${userCredential?.user?.phoneNumber} and isError => $error");
  //
  //   // if (!error && userCredential != null) {
  //   //   _login(widget.mobileNumber.toString());
  //   // } else {
  //   //   await prDialog.hide();
  //   //   if (!mounted) return;
  //   //   Utils.showSnackbar(context, "fail", "otp_login_fail", true);
  //   // }
  // }

  _login(String mobile, String email) async {
    debugPrint("click on Submit mobile => $mobile");
    debugPrint("click on Submit mobile => $email");
    var generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    if (!prDialog.isShowing()) {
      Utils.showProgress(context, prDialog);
    }
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final sectionDataProvider =
    Provider.of<SectionDataProvider>(context, listen: false);
    await generalProvider.loginWithOTP(mobile, email);

    if (!generalProvider.loading) {
      if (generalProvider.loginOTPModel.status == 200) {
        debugPrint(
            'loginOTPModel ==>> ${generalProvider.loginOTPModel.toString()}');
        debugPrint('Login Successfull!');
        Utils.saveUserCreds(
          userID: generalProvider.loginOTPModel.result?[0].id.toString(),
          userName: generalProvider.loginOTPModel.result?[0].name.toString(),
          userEmail: generalProvider.loginOTPModel.result?[0].email.toString(),
          userMobile:
          generalProvider.loginOTPModel.result?[0].mobile.toString(),
          userImage: generalProvider.loginOTPModel.result?[0].image.toString(),
          userPremium:
          generalProvider.loginOTPModel.result?[0].isBuy.toString(),
          userType: generalProvider.loginOTPModel.result?[0].type.toString(),
        );

        // Set UserID for Next
        Constant.userID =
            generalProvider.loginOTPModel.result?[0].id.toString();
        debugPrint('Constant userID ==>> ${Constant.userID}');

        await homeProvider.setLoading(true);
        await sectionDataProvider.getSectionBanner("0", "1");
        await sectionDataProvider.getSectionList("0", "1", "0");

        await prDialog.hide();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const Bottombar()),
              (Route<dynamic> route) => false,
        );
      } else {
        await prDialog.hide();
        if (!mounted) return;
        Utils.showSnackbar(
            context, "fail", "${generalProvider.loginOTPModel.message}", false);
      }
    }
  }
}
