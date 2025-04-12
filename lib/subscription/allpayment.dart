import 'dart:async';
import 'dart:convert';

import 'package:dtlive/main.dart';
import 'package:dtlive/provider/channelsectionprovider.dart';
import 'package:dtlive/provider/paymentprovider.dart';
import 'package:dtlive/provider/profileprovider.dart';
import 'package:dtlive/provider/showdetailsprovider.dart';
import 'package:dtlive/provider/videodetailsprovider.dart';
import 'package:dtlive/subscription/instamojopg.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/utils/strings.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/widget/myimage.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:dtlive/widget/nodata.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
// import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
// import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:singular_flutter_sdk/singular.dart';
import 'package:uuid/uuid.dart';

class AllPayment extends StatefulWidget {
  final String? payType,
      itemId,
      price,
      itemTitle,
      typeId,
      videoType,
      productPackage,
      currency;
  const AllPayment({
    Key? key,
    required this.payType,
    required this.itemId,
    required this.price,
    required this.itemTitle,
    required this.typeId,
    required this.videoType,
    required this.productPackage,
    required this.currency,
  }) : super(key: key);

  @override
  State<AllPayment> createState() => AllPaymentState();
}

class AllPaymentState extends State<AllPayment>
// implements PayUCheckoutProProtocol
{
  final couponController = TextEditingController();
  late ProgressDialog prDialog;
  late PaymentProvider paymentProvider;
  SharedPre sharedPref = SharedPre();
  String? userId, userName, userEmail, userMobileNo, paymentId;
  String? strCouponCode = "";
  bool isPaymentDone = false;
  dynamic orderId;

  /* Paytm */
  String paytmResult = "";

  /* Flutterwave */
  String selectedCurrency = "";
  bool isTestMode = true;

  /* Stripe */
  Map<String, dynamic>? paymentIntent;

  /* PayU */
  // late PayUCheckoutProFlutter _payUCheckoutPro;

  @override
  void initState() {
    // if (!kIsWeb) _payUCheckoutPro = PayUCheckoutProFlutter(this);
    prDialog = ProgressDialog(context);
    _getData();

    super.initState();
  }

  _getData() async {
    paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    await paymentProvider.getPaymentOption();
    await paymentProvider.setFinalAmount(widget.price ?? "");

    if (paymentProvider.paymentOptionModel.status == 200) {
      if (paymentProvider.paymentOptionModel.result != null) {
        if (paymentProvider.paymentOptionModel.result?.flutterWave != null) {}
      }
    }

    /* PaymentID */
    paymentId = Utils.generateRandomOrderID();
    debugPrint('paymentId =====================> $paymentId');

    userId = await sharedPref.read("userid");
    userName = await sharedPref.read("username");
    userEmail = await sharedPref.read("useremail");
    userMobileNo = await sharedPref.read("usermobile");
    debugPrint('getUserData userId ==> $userId');
    debugPrint('getUserData userName ==> $userName');
    debugPrint('getUserData userEmail ==> $userEmail');
    debugPrint('getUserData userMobileNo ==> $userMobileNo');

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    paymentProvider.clearProvider();
    couponController.dispose();
    super.dispose();
  }

  /* add_transaction API */
  Future addTransaction(packageId, description, amount, paymentId, currencyCode,
      orderStatus, purchesVia) async {
    final videoDetailsProvider =
        Provider.of<VideoDetailsProvider>(context, listen: false);
    final showDetailsProvider =
        Provider.of<ShowDetailsProvider>(context, listen: false);
    final channelSectionProvider =
        Provider.of<ChannelSectionProvider>(context, listen: false);
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    Utils.showProgress(context, prDialog);
    await paymentProvider.addTransaction(
        packageId,
        description,
        amount,
        paymentId,
        currencyCode,
        strCouponCode,
        orderStatus,
        orderId,
        purchesVia);

    if (!paymentProvider.payLoading) {
      await prDialog.hide();

      if (paymentProvider.successModel.status == 200) {
        if (orderStatus == "success") {
          isPaymentDone = true;
          if (!mounted) return;
          await profileProvider.getProfile(context);
          await videoDetailsProvider.updatePrimiumPurchase();
          await showDetailsProvider.updatePrimiumPurchase();
          await channelSectionProvider.updatePrimiumPurchase();
          await videoDetailsProvider.updateRentPurchase();
          await showDetailsProvider.updateRentPurchase();
          print("Payment DONE 1 ----${orderStatus}");

          Singular.eventWithArgs('Razorpay Payment Success', {
            'event_name': 'Razorpay Payment Success',
            "packageId": packageId,
            "description": description,
            "amount": amount,
            "paymentId": paymentId,
            "couponCode": '${strCouponCode}',
            "orderStatus": orderStatus,
            "orderId": orderId,
            'user_id': Constant.userID.toString(),
            'is_revenue_event': true,
            'currencyCode': currencyCode
          });
          if (!mounted) return;
          Navigator.pop(context, isPaymentDone);
        } else {
          isPaymentDone = false;


          print("Payment DONE 2 ----${orderStatus}");


          Singular.eventWithArgs('Razorpay Payment Failed', {
            'event_name': 'Razorpay Payment Failed',
            "packageId": packageId,
            "description": description,
            "amount": amount,
            "paymentId": paymentId,
            "couponCode": '${strCouponCode}',
            "orderStatus": orderStatus,
            "orderId": orderId,
            'user_id': Constant.userID.toString(),
            'is_revenue_event': true,
            'currencyCode': currencyCode
          });
          if (!mounted) return;
          Navigator.pop(context, isPaymentDone);
        }
      } else {
        print("Payment failed ----");
          print("Payment DONE 3 ----${orderStatus}");

        isPaymentDone = false;
        if (!mounted) return;
        Navigator.pop(context, isPaymentDone);

        Utils.showSnackbar(
            context, "info", paymentProvider.successModel.message ?? "", false);
      }
    }
  }

  /* add_rent_transaction API */
  Future addRentTransaction(
      videoId, amount, typeId, videoType, orderStatus) async {
    final videoDetailsProvider =
        Provider.of<VideoDetailsProvider>(context, listen: false);
    final showDetailsProvider =
        Provider.of<ShowDetailsProvider>(context, listen: false);

    Utils.showProgress(context, prDialog);
    await paymentProvider.addRentTransaction(videoId, amount, typeId, videoType,
        strCouponCode, orderStatus, orderId);

    if (!paymentProvider.payLoading) {
      await prDialog.hide();

      if (paymentProvider.successModel.status == 200) {
        if (orderStatus == "success") {
          isPaymentDone = true;
          if (videoType == "1") {
            await videoDetailsProvider.updateRentPurchase();
          } else if (videoType == "2") {
            await showDetailsProvider.updateRentPurchase();
          }
          Singular.eventWithArgs('Razorpay Payment Success', {
            'event_name': 'Razorpay Payment Success',
            "videoId": videoId,
            "amount": amount,
            "typeId": typeId,
            "videoType": videoType,
            "couponCode": '${strCouponCode}',
            "orderStatus": orderStatus,
            "orderId": orderId,
            'user_id': Constant.userID.toString(),
            'is_revenue_event': true,
          });
          if (!mounted) return;
          Navigator.pop(context, isPaymentDone);
        } else {
          Singular.eventWithArgs('Razorpay Payment Failed', {
            'event_name': 'Razorpay Payment Failed',
            "videoId": videoId,
            "amount": amount,
            "typeId": typeId,
            "videoType": videoType,
            "couponCode": '${strCouponCode}',
            "orderStatus": orderStatus,
            "orderId": orderId,
            'user_id': Constant.userID.toString(),
            'is_revenue_event': true,
          });
          if (!mounted) return;
          Navigator.pop(context, isPaymentDone);
        }
      } else {
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
            context, "info", paymentProvider.successModel.message ?? "", true);
      }
    }
  }

  /* apply_coupon API */
  Future applyCoupon() async {
    FocusManager.instance.primaryFocus?.unfocus();
    Utils.showProgress(context, prDialog);
    if (widget.payType == "Package") {
      /* Package Coupon */
      await paymentProvider.applyPackageCouponCode(
          strCouponCode, widget.itemId);

      if (!paymentProvider.couponLoading) {
        await prDialog.hide();
        if (paymentProvider.couponModel.status == 200) {
          couponController.clear();
          await paymentProvider.setFinalAmount(
              paymentProvider.couponModel.result?.discountAmount.toString());
          strCouponCode =
              paymentProvider.couponModel.result?.uniqueId.toString();
          debugPrint("strCouponCode =============> $strCouponCode");
          debugPrint(
              "finalAmount =============> ${paymentProvider.finalAmount}");
          if (!mounted) return;
          Utils.showSnackbar(context, "success",
              paymentProvider.couponModel.message ?? "", false);
        } else {
          if (!mounted) return;
          Utils.showSnackbar(context, "fail",
              paymentProvider.couponModel.message ?? "", false);
        }
      }
    } else if (widget.payType == "Rent") {
      /* Rent Coupon */
      await paymentProvider.applyRentCouponCode(strCouponCode, widget.itemId,
          widget.typeId, widget.videoType, widget.price);

      if (!paymentProvider.couponLoading) {
        await prDialog.hide();
        if (paymentProvider.couponModel.status == 200) {
          couponController.clear();
          await paymentProvider.setFinalAmount(
              paymentProvider.couponModel.result?.discountAmount.toString());
          strCouponCode =
              paymentProvider.couponModel.result?.uniqueId.toString();
          debugPrint("strCouponCode =============> $strCouponCode");
          debugPrint(
              "finalAmount =============> ${paymentProvider.finalAmount}");
          if (!mounted) return;
          Utils.showSnackbar(context, "success",
              paymentProvider.couponModel.message ?? "", false);
        } else {
          if (!mounted) return;
          Utils.showSnackbar(context, "fail",
              paymentProvider.couponModel.message ?? "", false);
        }
      }
    } else {
      await prDialog.hide();
    }
  }

  openPayment({required String pgName}) async {
    debugPrint("finalAmount =============> ${paymentProvider.finalAmount}");
    if (paymentProvider.finalAmount != "0") {
      if (pgName == "paypal") {
        _paypalInit();
      } else if (pgName == "razorpay") {
        _initializeRazorpay();
      } else if (pgName == "flutterwave") {
        _flutterwaveInit();
      } else if (pgName == "payumoney") {
        _payUInit();
      } else if (pgName == "paytm") {
        _paytmInit();
      } else if (pgName == "instamojo") {
        _initInstamojo();
      } else if (pgName == "cash") {
        if (!mounted) return;
        Utils.showSnackbar(context, "info", "cash_payment_msg", true);
      }
    } else {
      if (widget.payType == "Package") {
        addTransaction(
            widget.itemId,
            widget.itemTitle,
            paymentProvider.finalAmount,
            paymentId,
            widget.currency,
            "success",
            "amount");
      } else if (widget.payType == "Rent") {
        addRentTransaction(widget.itemId, paymentProvider.finalAmount,
            widget.typeId, widget.videoType, "success");
      }
    }
  }

  bool checkKeysAndContinue({
    required String isLive,
    required bool isBothKeyReq,
    required String liveKey1,
    required String liveKey2,
    required String testKey1,
    required String testKey2,
  }) {
    if (isLive == "1") {
      if (isBothKeyReq) {
        if (liveKey1 == "" || liveKey2 == "") {
          Utils.showSnackbar(context, "", "payment_not_processed", true);
          return false;
        }
      } else {
        if (liveKey1 == "") {
          Utils.showSnackbar(context, "", "payment_not_processed", true);
          return false;
        }
      }
      return true;
    } else {
      if (isBothKeyReq) {
        if (testKey1 == "" || testKey2 == "") {
          Utils.showSnackbar(context, "", "payment_not_processed", true);
          return false;
        }
      } else {
        if (testKey1 == "") {
          Utils.showSnackbar(context, "", "payment_not_processed", true);
          return false;
        }
      }
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: _buildPage(),
    );
  }

  Widget _buildPage() {
    analytics.logEvent(
      name: "screen_view",
      parameters: {
        "screen_name": "Payment screen",
        "user_id": Constant.userID,
      },
    );
    Map<String, Object> screenViewEvent = {
      'screen_name': 'Payment screen',
      'user_id': Constant.userID.toString(),
    };
    Singular.eventWithArgs('screen_view', screenViewEvent);
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBgColor, // Set the app bar background color
        title: const Text(
          "Payment Details", // Title of the app bar
          style: TextStyle(
            color: colorPrimary, // Title text color
            fontSize: 18, // Title font size
            fontWeight: FontWeight.bold, // Title font weight
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: Colors.white), // Cupertino-style back icon
          onPressed: () async {
            // Call the onBackPressed event when the back button is pressed
            await onBackPressed();
          },
        ),
        elevation: 0, // Optional: Removes shadow under the app bar
      ),
      body: SafeArea(
        child: Center(
          child: _buildMobilePage(),
        ),
      ),
    );
  }

  Widget _buildMobilePage() {
    return Container(
      width:
          ((kIsWeb || Constant.isTV) && MediaQuery.of(context).size.width > 720)
              ? MediaQuery.of(context).size.width * 0.5
              : MediaQuery.of(context).size.width,
      margin: (kIsWeb || Constant.isTV)
          ? const EdgeInsets.fromLTRB(50, 0, 50, 50)
          : const EdgeInsets.all(0),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: (kIsWeb || Constant.isTV) ? 40 : 0),
          /* Coupon Code Box & Total Amount */
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 5,
              color: colorPrimaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                constraints: const BoxConstraints(minHeight: 50),
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    _buildCouponBox(),
                    const SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      constraints: const BoxConstraints(minHeight: 50),
                      decoration: Utils.setBackground(colorPrimary, 0),
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      alignment: Alignment.centerLeft,
                      child: Consumer<PaymentProvider>(
                        builder: (context, paymentProvider, child) {
                          return RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: payableAmountIs,
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  color: lightBlack,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      "${Constant.currencySymbol} ${paymentProvider.finalAmount ?? ""}",
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /* PGs */
          Expanded(
            child: SingleChildScrollView(
              child: paymentProvider.loading
                  ? Container(
                      height: 230,
                      padding: const EdgeInsets.all(20),
                      child: Utils.pageLoader(),
                    )
                  : paymentProvider.paymentOptionModel.status == 200
                      ? paymentProvider.paymentOptionModel.result != null
                          ? ((kIsWeb) ? _buildWebPayments() : _buildPayments())
                          : const NoData(
                              title: 'no_payment', subTitle: 'no_payment_desc')
                      : const NoData(
                          title: 'no_payment', subTitle: 'no_payment_desc'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponBox() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        border: Border.all(color: primaryDark, width: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')), // Disallow spaces
                ],
                onSubmitted: (value) async {
                  if (value.isNotEmpty) {
                    strCouponCode = value.toString();
                    applyCoupon();
                  } else {
                    strCouponCode = "";
                  }
                  debugPrint("strCouponCode ===========> $strCouponCode");
                },
                onChanged: (value) async {
                  if (value.isNotEmpty) {
                    strCouponCode = value.toString();
                  } else {
                    strCouponCode = "";
                  }
                  debugPrint("strCouponCode ===========> $strCouponCode");
                },
                textInputAction: TextInputAction.done,
                obscureText: false,
                controller: couponController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                style: const TextStyle(
                  color: white,
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: transparentColor,
                  hintStyle: TextStyle(
                    color: otherColor,
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: couponAddHint,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () async {
              debugPrint("Click on Apply!");
              debugPrint("strCouponCode ===========> $strCouponCode");
              if (strCouponCode != null && (strCouponCode ?? "").isNotEmpty) {
                applyCoupon();
              } else {
                Utils.showSnackbar(context, "info", emptyCouponMsg, false);
              }
            },
            child: Container(
              height: 30,
              constraints: const BoxConstraints(minWidth: 50),
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
              decoration: Utils.setBackground(white, 5),
              alignment: Alignment.center,
              child: MyText(
                color: black,
                text: "apply",
                multilanguage: true,
                fontsizeNormal: 13,
                fontsizeWeb: 14,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontweight: FontWeight.w600,
                textalign: TextAlign.end,
                fontstyle: FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCouponBox() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     height: 50,
  //     margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
  //     padding: const EdgeInsets.only(right: 10),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: primaryDark, width: 0.5),
  //       borderRadius: BorderRadius.circular(5),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Expanded(
  //           child: Container(
  //             width: MediaQuery.of(context).size.width,
  //             height: MediaQuery.of(context).size.height,
  //             alignment: Alignment.center,
  //             child: TextField(
  //               onSubmitted: (value) async {
  //                 if (value.isNotEmpty) {
  //                   strCouponCode = value.toString();
  //                   applyCoupon();
  //                 } else {
  //                   strCouponCode = "";
  //                 }
  //                 debugPrint("strCouponCode ===========> $strCouponCode");
  //               },
  //               onChanged: (value) async {
  //                 if (value.isNotEmpty) {
  //                   strCouponCode = value.toString();
  //                 } else {
  //                   strCouponCode = "";
  //                 }
  //                 debugPrint("strCouponCode ===========> $strCouponCode");
  //               },
  //               textInputAction: TextInputAction.done,
  //               obscureText: false,
  //               controller: couponController,
  //               keyboardType: TextInputType.text,
  //               maxLines: 1,
  //               style: const TextStyle(
  //                 color: white,
  //                 fontSize: 16,
  //                 overflow: TextOverflow.ellipsis,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //               decoration: const InputDecoration(
  //                 border: InputBorder.none,
  //                 filled: true,
  //                 fillColor: transparentColor,
  //                 hintStyle: TextStyle(
  //                   color: otherColor,
  //                   fontSize: 14,
  //                   overflow: TextOverflow.ellipsis,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //                 hintText: couponAddHint,
  //               ),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 10),
  //         InkWell(
  //           borderRadius: BorderRadius.circular(5),
  //           onTap: () async {
  //             debugPrint("Click on Apply!");
  //             debugPrint("strCouponCode ===========> $strCouponCode");
  //             if (strCouponCode != null && (strCouponCode ?? "").isNotEmpty) {
  //               applyCoupon();
  //             } else {
  //               Utils.showSnackbar(context, "info", emptyCouponMsg, false);
  //             }
  //           },
  //           child: Container(
  //             height: 30,
  //             constraints: const BoxConstraints(minWidth: 50),
  //             padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
  //             decoration: Utils.setBackground(white, 5),
  //             alignment: Alignment.center,
  //             child: MyText(
  //               color: black,
  //               text: "apply",
  //               multilanguage: true,
  //               fontsizeNormal: 13,
  //               fontsizeWeb: 14,
  //               maxline: 1,
  //               overflow: TextOverflow.ellipsis,
  //               fontweight: FontWeight.w600,
  //               textalign: TextAlign.end,
  //               fontstyle: FontStyle.normal,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPayments() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            color: whiteLight,
            text: "payment_methods",
            fontsizeNormal: 15,
            fontsizeWeb: 17,
            maxline: 1,
            multilanguage: true,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w600,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 5),
          MyText(
            color: otherColor,
            text: "choose_a_payment_methods_to_pay",
            multilanguage: true,
            fontsizeNormal: 13,
            fontsizeWeb: 15,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w500,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          MyText(
            color: complimentryColor,
            text: "pay_with",
            multilanguage: true,
            fontsizeNormal: 16,
            fontsizeWeb: 16,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w700,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 20),

          /* /* Payments */ */
          // /* In-App purchase */
          // paymentProvider.paymentOptionModel.result?.inAppPurchage != null
          //     ? paymentProvider.paymentOptionModel.result?.inAppPurchage
          //                 ?.visibility ==
          //             "1"
          //         ? Card(
          //             semanticContainer: true,
          //             clipBehavior: Clip.antiAliasWithSaveLayer,
          //             elevation: 5,
          //             color: colorPrimaryDark,
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(8),
          //             ),
          //             child: InkWell(
          //               borderRadius: BorderRadius.circular(8),
          //               onTap: () async {
          //                 await paymentProvider.setCurrentPayment("inapp");
          //                 openPayment(pgName: "inapppurchage");
          //               },
          //               child: _buildPGButton(
          //                   "pg_inapp.png", "InApp Purchase", 35, 110),
          //             ),
          //           )
          //         : const SizedBox.shrink()
          //     : const SizedBox.shrink(),
          // const SizedBox(height: 5),

          /* Paypal */
          paymentProvider.paymentOptionModel.result?.paypal != null
              ? paymentProvider.paymentOptionModel.result?.paypal?.visibility ==
                      "1"
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 5,
                        color: colorPrimaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await paymentProvider.setCurrentPayment("paypal");
                            openPayment(pgName: "paypal");
                          },
                          child: _buildPGButton(
                              "pg_paypal.png", "Paypal", 35, 130),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
              : const SizedBox.shrink(),

          /* Razorpay */
          paymentProvider.paymentOptionModel.result?.razorpay != null
              ? paymentProvider
                          .paymentOptionModel.result?.razorpay?.visibility ==
                      "1"
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 5,
                        color: colorPrimaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            print(
                                "FINAL PAYMENT IS: ${paymentProvider.finalAmount}");

                            if (paymentProvider.finalAmount == "0") {
                              // Directly call the addRentTransaction API
                              print("CALL rent api WHEN PAYMENT ZERO");
                              //               await paymentProvider.addRentTransaction( widget.itemId, paymentProvider.finalAmount,
                              //                   widget.typeId,
                              //                   widget.videoType,
                              // strCouponCode, "success", "CouponCode");

                              if (widget.payType == "Package") {
                                addTransaction(
                                    widget.itemId,
                                    widget.itemTitle,
                                    paymentProvider.finalAmount,
                                    paymentId,
                                    widget.currency,
                                    "success",
                                    "amount");
                              } else if (widget.payType == "Rent") {
                                addRentTransaction(
                                    widget.itemId,
                                    paymentProvider.finalAmount,
                                    widget.typeId,
                                    widget.videoType,
                                    "success");
                              }

                              // await addRentTransaction(
                              //       widget.itemId,
                              //       paymentProvider.finalAmount,
                              //       widget.typeId,
                              //       widget.videoType,
                              //       "success");
                            } else {
                              print(
                                  "FINAL PAYMENT IS: ${paymentProvider.finalAmount}");
                              // Proceed with the existing payment flow

                              print(
                                  "CALL ORDER CREATION WHEN PAYMENT NOT ZERO");
                              var id = await createOrder();

                              setState(() {
                                orderId = id;
                              });

                              await paymentProvider
                                  .setCurrentPayment("razorpay");
                              openPayment(pgName: "razorpay");
                              // try {
                              //   print("CALL ORDER CREATION WHEN PAYMENT NOT ZERO");
                              //   var id = await createOrder();

                              //   setState(() {
                              //     orderId = id;
                              //   });

                              //   await paymentProvider.setCurrentPayment("razorpay");
                              //   openPayment(pgName: "razorpay");
                              // } catch (e) {
                              //   print("Error creating order: $e");
                              // }
                            }
                          },
                          child: _buildPGButton(
                              "pg_razorpay.png", "Razorpay", 35, 130),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
              : const SizedBox.shrink(),

          // paymentProvider.paymentOptionModel.result?.razorpay != null
          //     ? paymentProvider
          //                 .paymentOptionModel.result?.razorpay?.visibility ==
          //             "1"
          //         ? Container(
          //             margin: const EdgeInsets.only(bottom: 5),
          //             child: Card(
          //               semanticContainer: true,
          //               clipBehavior: Clip.antiAliasWithSaveLayer,
          //               elevation: 5,
          //               color: colorPrimaryDark,
          //               shape: RoundedRectangleBorder(
          //                 borderRadius: BorderRadius.circular(8),
          //               ),
          //               child: InkWell(
          //                 borderRadius: BorderRadius.circular(8),
          //                 onTap: () async {
          //                   print("FINAL PAYMENT IS:${paymentProvider.finalAmount}");
          //                   try {
          //                     var id = await createOrder();
          //                     print(
          //                         "ORDER CREATION DONE IN ON TAP BUTTON ____>>>>>>>");
          //                     setState(() {
          //                       orderId = id;
          //                     });
          //                     await paymentProvider
          //                         .setCurrentPayment("razorpay");
          //                     openPayment(pgName: "razorpay");
          //                   } catch (e) {
          //                     print("Error creating order: $e");

          //                   }
          //                 },
          //                 child: _buildPGButton(
          //                     "pg_razorpay.png", "Razorpay", 35, 130),
          //               ),
          //             ),
          //           )
          //         : const SizedBox.shrink()
          //     : const SizedBox.shrink(),

          /* Paytm */
          paymentProvider.paymentOptionModel.result?.payTm != null
              ? paymentProvider.paymentOptionModel.result?.payTm?.visibility ==
                      "1"
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 5,
                        color: colorPrimaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await paymentProvider.setCurrentPayment("paytm");
                            openPayment(pgName: "paytm");
                          },
                          child:
                              _buildPGButton("pg_paytm.png", "Paytm", 30, 90),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
              : const SizedBox.shrink(),

          /* Flutterwave */
          paymentProvider.paymentOptionModel.result?.flutterWave != null
              ? paymentProvider
                          .paymentOptionModel.result?.flutterWave?.visibility ==
                      "1"
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 5,
                        color: colorPrimaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await paymentProvider
                                .setCurrentPayment("flutterwave");
                            openPayment(pgName: "flutterwave");
                          },
                          child: _buildPGButton(
                              "pg_flutterwave.png", "Flutterwave", 35, 135),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
              : const SizedBox.shrink(),

          /* Stripe */
          paymentProvider.paymentOptionModel.result?.stripe != null
              ? paymentProvider.paymentOptionModel.result?.stripe?.visibility ==
                      "1"
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 5,
                        color: colorPrimaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await paymentProvider.setCurrentPayment("stripe");
                            openPayment(pgName: "stripe");
                          },
                          child: _buildPGButton(
                              "pg_stripe.png", "Stripe", 35, 100),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
              : const SizedBox.shrink(),

          /* PayUMoney */
          paymentProvider.paymentOptionModel.result?.payUMoney != null
              ? paymentProvider
                          .paymentOptionModel.result?.payUMoney?.visibility ==
                      "1"
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 5,
                        color: colorPrimaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await paymentProvider
                                .setCurrentPayment("payumoney");
                            openPayment(pgName: "payumoney");
                          },
                          child: _buildPGButton("pg_payu.png", "PayU", 50, 120),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
              : const SizedBox.shrink(),

          /* Paystack */
          paymentProvider.paymentOptionModel.result?.paystack != null
              ? paymentProvider
                          .paymentOptionModel.result?.paystack?.visibility ==
                      "1"
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 5,
                        color: colorPrimaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await paymentProvider.setCurrentPayment("paystack");
                            openPayment(pgName: "paystack");
                          },
                          child: _buildPGButton(
                              "pg_paystack.png", "Paystack", 50, 125),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
              : const SizedBox.shrink(),

          /* Instamojo */
          paymentProvider.paymentOptionModel.result?.instamojo != null
              ? paymentProvider
                          .paymentOptionModel.result?.instamojo?.visibility ==
                      "1"
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 5,
                        color: colorPrimaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await paymentProvider
                                .setCurrentPayment("instamojo");
                            openPayment(pgName: "instamojo");
                          },
                          child: _buildPGButton(
                              "pg_instamojo.png", "Instamojo", 35, 130),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
              : const SizedBox.shrink(),

          /* Cash */
          paymentProvider.paymentOptionModel.result?.cash != null
              ? paymentProvider.paymentOptionModel.result?.cash?.visibility ==
                      "1"
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 5,
                        color: colorPrimaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            await paymentProvider.setCurrentPayment("cash");
                            openPayment(pgName: "cash");
                          },
                          child: _buildPGButton("pg_cash.png", "Cash", 50, 50),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildWebPayments() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            color: whiteLight,
            text: "payment_methods",
            fontsizeNormal: 15,
            fontsizeWeb: 17,
            maxline: 1,
            multilanguage: true,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w600,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 5),
          MyText(
            color: otherColor,
            text: "choose_a_payment_methods_to_pay",
            multilanguage: true,
            fontsizeNormal: 13,
            fontsizeWeb: 15,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w500,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          MyText(
            color: complimentryColor,
            text: "pay_with",
            multilanguage: true,
            fontsizeNormal: 16,
            fontsizeWeb: 16,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontweight: FontWeight.w700,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 20),

          /* Razorpay */
          paymentProvider.paymentOptionModel.result?.razorpay != null
              ? paymentProvider
                          .paymentOptionModel.result?.razorpay?.visibility ==
                      "1"
                  ? Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      color: colorPrimaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          await paymentProvider.setCurrentPayment("razorpay");
                          openPayment(pgName: "razorpay");
                        },
                        child: _buildPGButton(
                            "pg_razorpay.png", "Razorpay", 35, 130),
                      ),
                    )
                  : const SizedBox.shrink()
              : const NoData(title: 'no_payment', subTitle: 'no_payment_desc'),
        ],
      ),
    );
  }

  Widget _buildPGButton(
      String imageName, String pgName, double imgHeight, double imgWidth) {
    return Container(
      constraints: const BoxConstraints(minHeight: 85),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          MyImage(
            imagePath: imageName,
            fit: BoxFit.contain,
            height: imgHeight,
            width: imgWidth,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: MyText(
              color: white,
              text: pgName,
              multilanguage: false,
              fontsizeNormal: 14,
              fontsizeWeb: 15,
              maxline: 2,
              overflow: TextOverflow.ellipsis,
              fontweight: FontWeight.w600,
              textalign: TextAlign.end,
              fontstyle: FontStyle.normal,
            ),
          ),
          const SizedBox(width: 15),
          MyImage(
            imagePath: "ic_arrow_right.png",
            fit: BoxFit.fill,
            height: 22,
            width: 20,
            color: white,
          ),
        ],
      ),
    );
  }

  /* ********* Razorpay START ********* */

  Future<String> createOrder() async {
    try {
      var mapHeader = <String, String>{};
      mapHeader['Content-Type'] = 'application/json';

      var requestBody = jsonEncode({
        "amount": (double.parse(paymentProvider.finalAmount ?? "")).toInt(),
        "currency": "INR",
        "name": widget.itemTitle,
        "mobile": userMobileNo,
        "email": userEmail
      });

      var response = await http.post(
        Uri.parse('${Constant.baseurl}create-order'),
        headers: mapHeader,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        String orderIdd = responseData['result']['id'];
        print("Order id creation done --->>>>${orderIdd}");
        return orderIdd;
      } else {
        throw Exception(
            'Failed to create order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  void _initializeRazorpay() async {
    if (paymentProvider.paymentOptionModel.result?.razorpay != null) {
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.razorpay?.isLive ?? ""),
        isBothKeyReq: false,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.razorpay?.liveKey1 ??
                ""),
        liveKey2: "",
        testKey1:
            (paymentProvider.paymentOptionModel.result?.razorpay?.testKey1 ??
                ""),
        testKey2: "",
      );
      if (!isContinue) return;
      /* Check Keys */
      try {
        if (orderId == null || orderId.isEmpty || orderId == "") {
          Utils.showSnackbar(context, "", "order_creation_failed", true);
          return;
        } else {
          analytics.logEvent(
            name: "Razorpay open",
            parameters: {
              "user_id": Constant.userID,
              "price": widget.price,
              "name": widget.itemTitle
            },
          );
          Map<String, Object> screenViewEvent = {
            'event_name': 'Razorpay Open',
            "PayType": '${widget.payType}',
            "price": '${widget.price}',
            "name": '${widget.itemTitle}',
            'user_id': Constant.userID.toString(),
          };
          Singular.eventWithArgs('Razorpay Open', screenViewEvent);
          Razorpay razorpay = Razorpay();
          var options = {
            'key':
                (paymentProvider
                            .paymentOptionModel.result?.razorpay?.isLive ==
                        "1")
                    ? (paymentProvider
                            .paymentOptionModel.result?.razorpay?.liveKey1 ??
                        "")
                    : (paymentProvider
                            .paymentOptionModel.result?.razorpay?.testKey1 ??
                        ""),
            'currency': Constant.currency,
            'amount': (double.parse(paymentProvider.finalAmount ?? "") * 100),
            'name': widget.itemTitle ?? "",
            'order_id': orderId,
            'description': widget.itemTitle ?? "",
            'retry': {'enabled': true, 'max_count': 1},
            'send_sms_hash': true,
            'prefill': {'contact': userMobileNo, 'email': userEmail},
            'external': {
              'wallets': ['paytm']
            },
            'autocapture': 1
          };
          razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
          razorpay.on(
              Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
          razorpay.on(
              Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);

          razorpay.open(options);
        }
      } catch (e) {
        debugPrint('Razorpay Error: $e');
        Utils.showSnackbar(context, "", "payment_not_processed", true);
      }
    } else {
      Utils.showSnackbar(context, "", "payment_not_processed", true);
    }
  }



  void handlePaymentErrorResponse(PaymentFailureResponse response) async {
            debugPrint("============ Payment Failed event hit--- ============");

    analytics.logEvent(
      name: "Razorpay Payment Faild",
      parameters: {
        "user_id": Constant.userID,
        "PayType": widget.payType,
        "price": widget.price,
        "final amount": paymentProvider.finalAmount,
        "name": widget.itemTitle,
        "VId": widget.itemId
      },
    );
    Map<String, Object> screenViewEvent = {
      'event_name': 'Razorpay Payment Faield',
      "PayType": '${widget.payType}',
      "price": '${widget.price}',
      "name": '${widget.itemTitle}',
      "final amount": '${paymentProvider.finalAmount}',
      "VId": '${widget.itemId}',
      'user_id': Constant.userID.toString(),
    };
    Singular.eventWithArgs('Razorpay Payment Faild', screenViewEvent);
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    Utils.showSnackbar(context, "fail", "payment_fail", true);
    if (widget.payType == "Package") {
      addTransaction(
          widget.itemId,
          widget.itemTitle,
          paymentProvider.finalAmount,
          paymentId,
          widget.currency,
          "failed",
          "amount");
    } else if (widget.payType == "Rent") {
      addRentTransaction(widget.itemId, paymentProvider.finalAmount,
          widget.typeId, widget.videoType, "failed");
    }
    await paymentProvider.setCurrentPayment("");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
        debugPrint("============ Success paykment event hit--- ============");

    analytics.logEvent(
      name: "Razorpay Payment Success",
      parameters: {
        "user_id": Constant.userID,
        "PayType": widget.payType,
        "price": widget.price,
        "final amount": paymentProvider.finalAmount,
        "name": widget.itemTitle,
        "VId": widget.itemId
      },
    );
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */
    paymentId = response.paymentId.toString();
    debugPrint("paymentId ========> $paymentId");
    Utils.showSnackbar(context, "success", "payment_success", true);
    if (widget.payType == "Package") {
      addTransaction(
          widget.itemId,
          widget.itemTitle,
          paymentProvider.finalAmount,
          paymentId,
          widget.currency,
          "success",
          "amount");
    } else if (widget.payType == "Rent") {
      addRentTransaction(widget.itemId, paymentProvider.finalAmount,
          widget.typeId, widget.videoType, "success");
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    debugPrint("============ External Wallet event hit--- ============");
    if (widget.payType == "Package") {
      addTransaction(
          widget.itemId,
          widget.itemTitle,
          paymentProvider.finalAmount,
          paymentId,
          widget.currency,
          "external",
          "amount");
    } else if (widget.payType == "Rent") {
      addRentTransaction(widget.itemId, paymentProvider.finalAmount,
          widget.typeId, widget.videoType, "external");
    }
  }



  /* ********* Razorpay END ********* */

  /* ********* Paytm START ********* */
  Future<void> _paytmInit() async {
    if (paymentProvider.paymentOptionModel.result?.payTm != null) {
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.payTm?.isLive ?? ""),
        isBothKeyReq: false,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.payTm?.liveKey1 ?? ""),
        liveKey2: "",
        testKey1:
            (paymentProvider.paymentOptionModel.result?.payTm?.testKey1 ?? ""),
        testKey2: "",
      );
      if (!isContinue) return;
      /* Check Keys */

      bool payTmIsStaging;
      String payTmMerchantID,
          payTmOrderId,
          payTmCustmoreID,
          payTmChannelID,
          payTmTxnAmount,
          payTmWebsite,
          payTmCallbackURL,
          payTmIndustryTypeID;

      payTmOrderId = paymentId ?? "";
      payTmCustmoreID = "${Constant.userID}_$paymentId";
      payTmChannelID = "WAP";
      payTmTxnAmount = "${(paymentProvider.finalAmount ?? "")}.00";
      payTmIndustryTypeID = "Retail";

      if (paymentProvider.paymentOptionModel.result?.payTm?.isLive == "1") {
        payTmMerchantID =
            paymentProvider.paymentOptionModel.result?.payTm?.liveKey1 ?? "";
        payTmIsStaging = false;
        payTmWebsite = "DEFAULT";
        payTmCallbackURL =
            "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$payTmOrderId";
      } else {
        payTmMerchantID =
            paymentProvider.paymentOptionModel.result?.payTm?.testKey1 ?? "";
        payTmIsStaging = true;
        payTmWebsite = "WEBSTAGING";
        payTmCallbackURL =
            "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$payTmOrderId";
      }
      var sendMap = <String, dynamic>{
        "mid": payTmMerchantID,
        "orderId": payTmOrderId,
        "amount": payTmTxnAmount,
        "txnToken": paymentProvider.payTmModel.result?.paytmChecksum ?? "",
        "callbackUrl": payTmCallbackURL,
        "isStaging": payTmIsStaging,
        "restrictAppInvoke": true,
        "enableAssist": true,
      };
      debugPrint("sendMap ===> $sendMap");

      /* Generate CheckSum from Backend */
      await paymentProvider.getPaytmToken(
        payTmMerchantID,
        payTmOrderId,
        payTmCustmoreID,
        payTmChannelID,
        payTmTxnAmount,
        payTmWebsite,
        payTmCallbackURL,
        payTmIndustryTypeID,
      );

      if (!paymentProvider.loading) {
        if (paymentProvider.payTmModel.result != null) {
          if (paymentProvider.payTmModel.result?.paytmChecksum != null) {
            try {
              var response = AllInOneSdk.startTransaction(
                payTmMerchantID,
                payTmOrderId,
                payTmTxnAmount,
                paymentProvider.payTmModel.result?.paytmChecksum ?? "",
                payTmCallbackURL,
                payTmIsStaging,
                true,
                true,
              );
              response.then((value) {
                debugPrint("value ====> $value");
                setState(() {
                  paytmResult = value.toString();
                });
              }).catchError((onError) {
                if (onError is PlatformException) {
                  setState(() {
                    paytmResult = "${onError.message} \n  ${onError.details}";
                  });
                } else {
                  setState(() {
                    paytmResult = onError.toString();
                  });
                }
              });
            } catch (err) {
              paytmResult = err.toString();
            }
          } else {
            if (!mounted) return;
            Utils.showSnackbar(context, "", "payment_not_processed", true);
          }
        } else {
          if (!mounted) return;
          Utils.showSnackbar(context, "", "payment_not_processed", true);
        }
      }
    } else {
      Utils.showSnackbar(context, "", "payment_not_processed", true);
    }
  }
  /* ********* Paytm END ********* */

  /* ********* Paypal START ********* */
  Future<void> _paypalInit() async {
    if (paymentProvider.paymentOptionModel.result?.paypal != null) {
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.paypal?.isLive ?? ""),
        isBothKeyReq: true,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.paypal?.liveKey1 ?? ""),
        liveKey2:
            (paymentProvider.paymentOptionModel.result?.paypal?.liveKey2 ?? ""),
        testKey1:
            (paymentProvider.paymentOptionModel.result?.paypal?.testKey1 ?? ""),
        testKey2:
            (paymentProvider.paymentOptionModel.result?.paypal?.testKey2 ?? ""),
      );
      if (!isContinue) return;
      /* Check Keys */

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => UsePaypal(
              sandboxMode: (paymentProvider
                              .paymentOptionModel.result?.paypal?.isLive ??
                          "") ==
                      "1"
                  ? false
                  : true,
              clientId: (paymentProvider
                          .paymentOptionModel.result?.paypal?.isLive ==
                      "1")
                  ? (paymentProvider
                          .paymentOptionModel.result?.paypal?.liveKey1 ??
                      "")
                  : (paymentProvider
                          .paymentOptionModel.result?.paypal?.testKey1 ??
                      ""),
              secretKey: (paymentProvider
                          .paymentOptionModel.result?.paypal?.isLive ==
                      "1")
                  ? (paymentProvider
                          .paymentOptionModel.result?.paypal?.liveKey2 ??
                      "")
                  : (paymentProvider
                          .paymentOptionModel.result?.paypal?.testKey2 ??
                      ""),
              returnURL: "return.example.com",
              cancelURL: "cancel.example.com",
              transactions: [
                {
                  "amount": {
                    "total": '${paymentProvider.finalAmount}',
                    "currency": Constant.currency,
                    "details": {
                      "subtotal": '${paymentProvider.finalAmount}',
                      "shipping": '0',
                      "shipping_discount": 0
                    }
                  },
                  "description": widget.payType ?? "",
                  "item_list": {
                    "items": [
                      {
                        "name": "${widget.itemTitle}",
                        "quantity": 1,
                        "price": '${paymentProvider.finalAmount}',
                        "currency": Constant.currency
                      }
                    ],
                  }
                }
              ],
              note: "Contact us for any questions on your order.",
              onSuccess: (params) async {
                debugPrint("onSuccess: ${params["paymentId"]}");
                if (widget.payType == "Package") {
                  addTransaction(
                      widget.itemId,
                      widget.itemTitle,
                      paymentProvider.finalAmount,
                      params["paymentId"],
                      widget.currency,
                      "success",
                      "amount");
                } else if (widget.payType == "Rent") {
                  addRentTransaction(widget.itemId, paymentProvider.finalAmount,
                      widget.typeId, widget.videoType, "success");
                }
              },
              onError: (params) {
                debugPrint("onError: ${params["message"]}");
                Utils.showSnackbar(
                    context, "fail", params["message"].toString(), false);
              },
              onCancel: (params) {
                debugPrint('cancelled: $params');
                Utils.showSnackbar(context, "fail", params.toString(), false);
              }),
        ),
      );
    } else {
      Utils.showSnackbar(context, "", "payment_not_processed", true);
    }
  }
  /* ********* Paypal END ********* */

  // /* ********* Stripe START ********* */
  // Future<void> _stripeInit() async {
  //   if (paymentProvider.paymentOptionModel.result?.stripe != null) {
  //     stripe.Stripe.publishableKey = (paymentProvider
  //                 .paymentOptionModel.result?.stripe?.isLive ==
  //             "1")
  //         ? (paymentProvider.paymentOptionModel.result?.stripe?.liveKey1 ?? "")
  //         : (paymentProvider.paymentOptionModel.result?.stripe?.testKey1 ?? "");
  //     try {
  //       //STEP 1: Create Payment Intent
  //       paymentIntent = await createPaymentIntent(
  //           paymentProvider.finalAmount ?? "", Constant.currency);

  //       //STEP 2: Initialize Payment Sheet
  //       await stripe.Stripe.instance
  //           .initPaymentSheet(
  //               paymentSheetParameters: stripe.SetupPaymentSheetParameters(
  //             paymentIntentClientSecret: paymentIntent?['client_secret'],
  //             style: ThemeMode.light,
  //             merchantDisplayName: Constant.appName,
  //           ))
  //           .then((value) {});

  //       //STEP 3: Display Payment sheet
  //       displayPaymentSheet();
  //     } catch (err) {
  //       throw Exception(err);
  //     }
  //   } else {
  //     Utils.showSnackbar(context, "", "payment_not_processed", true);
  //   }
  // }

  // createPaymentIntent(String amount, String currency) async {
  //   try {
  //     //Request body
  //     Map<String, dynamic> body = {
  //       'amount': calculateAmount(amount),
  //       'currency': currency,
  //       'description': widget.itemTitle,
  //     };

  //     //Make post request to Stripe
  //     var response = await http.post(
  //       Uri.parse('https://api.stripe.com/v1/payment_intents'),
  //       headers: {
  //         'Authorization':
  //             'Bearer ${(paymentProvider.paymentOptionModel.result?.stripe?.isLive == "1") ? (paymentProvider.paymentOptionModel.result?.stripe?.liveKey2 ?? "") : (paymentProvider.paymentOptionModel.result?.stripe?.testKey2 ?? "")}',
  //         'Content-Type': 'application/x-www-form-urlencoded'
  //       },
  //       body: body,
  //     );
  //     return json.decode(response.body);
  //   } catch (err) {
  //     throw Exception(err.toString());
  //   }
  // }

  // calculateAmount(String amount) {
  //   final calculatedAmout = (int.parse(amount)) * 100;
  //   return calculatedAmout.toString();
  // }

  // displayPaymentSheet() async {
  //   try {
  //     await stripe.Stripe.instance.presentPaymentSheet().then((value) {
  //       Utils.showSnackbar(context, "success", "payment_success", true);
  //       if (widget.payType == "Package") {
  //         addTransaction(
  //             widget.itemId,
  //             widget.itemTitle,
  //             paymentProvider.finalAmount,
  //             paymentId,
  //             widget.currency,
  //             "success");
  //       } else if (widget.payType == "Rent") {
  //         addRentTransaction(widget.itemId, paymentProvider.finalAmount,
  //             widget.typeId, widget.videoType, "success");
  //       }

  //       paymentIntent = null;
  //     }).onError((error, stackTrace) {
  //       throw Exception(error);
  //     });
  //   } on stripe.StripeException catch (e) {
  //     debugPrint('Error is:---> $e');
  //     const AlertDialog(
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(
  //                 Icons.cancel,
  //                 color: Colors.red,
  //               ),
  //               Text("Payment Failed"),
  //             ],
  //           ),
  //         ],
  //       ),
  //     );
  //   } catch (e) {
  //     debugPrint('$e');
  //   }
  // }
  // /* ********* Stripe END ********* */

  /* ********* Flutterwave START ********* */
  _flutterwaveInit() async {
    /* Check Keys */
    bool isContinue = checkKeysAndContinue(
      isLive: (paymentProvider.paymentOptionModel.result?.flutterWave?.isLive ??
          ""),
      isBothKeyReq: false,
      liveKey1:
          (paymentProvider.paymentOptionModel.result?.flutterWave?.liveKey1 ??
              ""),
      liveKey2: "",
      testKey1:
          (paymentProvider.paymentOptionModel.result?.flutterWave?.testKey1 ??
              ""),
      testKey2: "",
    );
    if (!isContinue) return;
    /* Check Keys */

    final Customer customer = Customer(
        email: userEmail ?? "",
        name: userName ?? "",
        phoneNumber: userMobileNo ?? '');

    final Flutterwave flutterwave = Flutterwave(
      context: context,
      publicKey: (paymentProvider
                  .paymentOptionModel.result?.flutterWave?.isLive ==
              "1")
          ? (paymentProvider.paymentOptionModel.result?.flutterWave?.liveKey1 ??
              "")
          : (paymentProvider.paymentOptionModel.result?.flutterWave?.testKey1 ??
              ""),
      currency: Constant.currency,
      redirectUrl: 'https://www.divinetechs.com',
      txRef: const Uuid().v1(),
      amount: widget.price.toString().trim(),
      customer: customer,
      paymentOptions: "card, payattitude, barter, bank transfer, ussd",
      customization: Customization(title: widget.itemTitle),
      isTestMode:
          paymentProvider.paymentOptionModel.result?.flutterWave?.isLive == "1",
    );
    ChargeResponse? response = await flutterwave.charge();
    debugPrint("Flutterwave response =====> ${response.toJson()}");
    if (response.status == "success" && response.success == true) {
      paymentId = response.transactionId.toString();
      debugPrint("paymentId ========> $paymentId");
      if (!mounted) return;
      Utils.showSnackbar(context, "success", "payment_success", true);

      if (widget.payType == "Package") {
        addTransaction(
            widget.itemId,
            widget.itemTitle,
            paymentProvider.finalAmount,
            paymentId,
            widget.currency,
            "success",
            "amount");
      } else if (widget.payType == "Rent") {
        addRentTransaction(widget.itemId, paymentProvider.finalAmount,
            widget.typeId, widget.videoType, "success");
      }
    } else if (response.status == "cancel" && response.status == "cancelled") {
      if (!mounted) return;
      Utils.showSnackbar(context, "info", "payment_cancel", true);
    } else {
      if (!mounted) return;
      Utils.showSnackbar(context, "fail", "payment_fail", true);
    }
  }
  /* ********* Flutterwave END ********* */

  /* ********* PayU START ********* */
  _payUInit() async {
    debugPrint(
        "_payUInit isLive ======> ${paymentProvider.paymentOptionModel.result?.payUMoney?.isLive}");
    /* Check Keys */
    bool isContinue = checkKeysAndContinue(
      isLive:
          (paymentProvider.paymentOptionModel.result?.payUMoney?.isLive ?? ""),
      isBothKeyReq: false,
      liveKey1:
          (paymentProvider.paymentOptionModel.result?.payUMoney?.liveKey3 ??
              ""),
      liveKey2:
          (paymentProvider.paymentOptionModel.result?.payUMoney?.liveKey2 ??
              ""),
      testKey1:
          (paymentProvider.paymentOptionModel.result?.payUMoney?.testKey3 ??
              ""),
      testKey2:
          (paymentProvider.paymentOptionModel.result?.payUMoney?.testKey2 ??
              ""),
    );
    if (!isContinue) return;
    /* Check Keys */

    Map<dynamic, dynamic> additionalParam = {
      // PayUAdditionalParamKeys.udf1: "udf1",
      // PayUAdditionalParamKeys.udf2: "udf2",
      // PayUAdditionalParamKeys.udf3: "udf3",
      // PayUAdditionalParamKeys.udf4: "udf4",
      // PayUAdditionalParamKeys.udf5: "udf5",
    };

    Map<dynamic, dynamic> payUPaymentParams = {
      // PayUPaymentParamKey.key: (paymentProvider
      //               .paymentOptionModel.result?.payUMoney?.isLive ==
      //           "1")
      //       ? (paymentProvider.paymentOptionModel.result?.payUMoney?.liveKey2 ??
      //           "")
      //       : (paymentProvider.paymentOptionModel.result?.payUMoney?.testKey2 ??
      //           ""),
      //   PayUPaymentParamKey.transactionId: paymentId ?? "",
      //   PayUPaymentParamKey.amount: double.parse(widget.price ?? "0").toString(),
      //   PayUPaymentParamKey.productInfo: widget.itemTitle ?? "",
      //   PayUPaymentParamKey.firstName: userName ?? "",
      //   PayUPaymentParamKey.email: userEmail ?? "",
      //   PayUPaymentParamKey.phone: userMobileNo ?? "",
      //   PayUPaymentParamKey.ios_surl: "https://payu.herokuapp.com/ios_success",
      //   PayUPaymentParamKey.ios_furl: "https://payu.herokuapp.com/ios_failure",
      //   PayUPaymentParamKey.android_surl: "https://payu.herokuapp.com/success",
      //   PayUPaymentParamKey.android_furl: "https://payu.herokuapp.com/failure",
      //   PayUPaymentParamKey.environment:
      //       (paymentProvider.paymentOptionModel.result?.payUMoney?.isLive == "1")
      //           ? "0"
      //           : "1", //0 => Production, 1 => Test
      //   PayUPaymentParamKey.additionalParam: additionalParam,
      //   PayUPaymentParamKey.userCredential:
      //       ('${(paymentProvider.paymentOptionModel.result?.payUMoney?.isLive == "1") ? (paymentProvider.paymentOptionModel.result?.payUMoney?.liveKey2 ?? "") : (paymentProvider.paymentOptionModel.result?.payUMoney?.testKey2 ?? "")}:${userEmail ?? ""}')
    };
    // debugPrint("payUPaymentParams ======> ${payUPaymentParams.toString()}");

    try {
      // _payUCheckoutPro.openCheckoutScreen(
      //   payUPaymentParams: payUPaymentParams,
      //   payUCheckoutProConfig: PayUParams.createPayUConfigParams(),
      // );
    } on Exception catch (e) {
      debugPrint("_payUInit Exception ======> ${e.toString()}");
    }
  }

  @override
  generateHash(Map response) {
    // Pass response param to your backend server
    // Backend will generate the hash and will callback to
    // Map<dynamic, dynamic> hashResponse = PayUHashService((paymentProvider
    //                 .paymentOptionModel.result?.payUMoney?.isLive ==
    //             "1")
    //         ? (paymentProvider.paymentOptionModel.result?.payUMoney?.liveKey3 ??
    //             "")
    //         : (paymentProvider.paymentOptionModel.result?.payUMoney?.testKey3 ??
    //             ""))
    //     .generateHash(response);
    // debugPrint("hashResponse =====> $hashResponse");
    // _payUCheckoutPro.hashGenerated(hash: hashResponse);
  }

  @override
  onError(Map? response) {
    if (!mounted) return;
    Utils.showSnackbar(context, "fail", "payment_fail", true);
  }

  @override
  onPaymentCancel(Map? response) {
    if (!mounted) return;
    Utils.showSnackbar(context, "info", "payment_cancel", true);
  }

  @override
  onPaymentFailure(response) {
    Utils.showSnackbar(context, "fail", "payment_fail", true);
  }

  @override
  onPaymentSuccess(response) {
    if (!mounted) return;
    Utils.showSnackbar(context, "success", "payment_success", true);

    if (widget.payType == "Package") {
      addTransaction(
          widget.itemId,
          widget.itemTitle,
          paymentProvider.finalAmount,
          paymentId,
          widget.currency,
          "success",
          "amount");
    } else if (widget.payType == "Rent") {
      addRentTransaction(widget.itemId, paymentProvider.finalAmount,
          widget.typeId, widget.videoType, "success");
    }
  }
  /* ********* PayU END ********* */

  // /* ********* Paystack START ********* */
  // _paystackInit() async {
  //   /* Check Keys */
  //   bool isContinue = checkKeysAndContinue(
  //     isLive:
  //         (paymentProvider.paymentOptionModel.result?.paystack?.isLive ?? ""),
  //     isBothKeyReq: false,
  //     liveKey1:
  //         (paymentProvider.paymentOptionModel.result?.paystack?.liveKey1 ?? ""),
  //     liveKey2:
  //         (paymentProvider.paymentOptionModel.result?.paystack?.liveKey2 ?? ""),
  //     testKey1:
  //         (paymentProvider.paymentOptionModel.result?.paystack?.testKey1 ?? ""),
  //     testKey2:
  //         (paymentProvider.paymentOptionModel.result?.paystack?.testKey2 ?? ""),
  //   );
  //   if (!isContinue) return;
  //   /* Check Keys */

  //   debugPrint("_paystackInit price ========> ${widget.price}");
  //   debugPrint("_paystackInit currency =====> ${Constant.currency}");
  //   PayWithPayStack().now(
  //     context: context,
  //     customerEmail: userEmail ?? "",
  //     reference: DateTime.now().microsecondsSinceEpoch.toString(),
  //     currency: Constant.currency,
  //     amount: (int.parse(widget.price ?? "0") * 100).toString(),
  //     secretKey: (paymentProvider.paymentOptionModel.result?.paystack?.isLive ==
  //             "1")
  //         ? (paymentProvider.paymentOptionModel.result?.paystack?.liveKey1 ??
  //             "")
  //         : (paymentProvider.paymentOptionModel.result?.paystack?.testKey1 ??
  //             ""),
  //     transactionCompleted: () async {
  //       debugPrint("Transaction Successful");
  //       debugPrint("paymentId ========> $paymentId");

  //       if (!mounted) return;
  //       Utils.showSnackbar(context, "success", "payment_success", true);

  //       if (widget.payType == "Package") {
  //         await addTransaction(
  //             widget.itemId,
  //             widget.itemTitle,
  //             paymentProvider.finalAmount,
  //             paymentId,
  //             widget.currency,
  //             "success");
  //       } else if (widget.payType == "Rent") {
  //         await addRentTransaction(widget.itemId, paymentProvider.finalAmount,
  //             widget.typeId, widget.videoType, "success");
  //       }
  //       if (paymentProvider.successModel.status == 200) {
  //         if (!mounted) return;
  //         Navigator.pop(context, true);
  //       }
  //     },
  //     transactionNotCompleted: () {
  //       debugPrint("Transaction Not Successful!");
  //       if (!mounted) return;
  //       Utils.showSnackbar(context, "fail", "payment_fail", true);
  //     },
  //     callbackUrl: 'https://dtlive.divinetechs.in/',
  //   );
  // }
  // /* ********* Paystack END ********* */

  /* ********* Instamojo START ********* */
  Future<void> _initInstamojo() async {
    /* Check Keys */
    bool isContinue = checkKeysAndContinue(
      isLive:
          (paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? ""),
      isBothKeyReq: false,
      liveKey1:
          (paymentProvider.paymentOptionModel.result?.instamojo?.liveKey1 ??
              ""),
      liveKey2:
          (paymentProvider.paymentOptionModel.result?.instamojo?.liveKey2 ??
              ""),
      testKey1:
          (paymentProvider.paymentOptionModel.result?.instamojo?.testKey1 ??
              ""),
      testKey2:
          (paymentProvider.paymentOptionModel.result?.instamojo?.testKey2 ??
              ""),
    );
    if (!isContinue) return;
    /* Check Keys */

    String apiKey =
        ((paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? "") ==
                "1")
            ? (paymentProvider.paymentOptionModel.result?.instamojo?.liveKey1 ??
                "")
            : (paymentProvider.paymentOptionModel.result?.instamojo?.testKey1 ??
                "");
    String authToken =
        ((paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? "") ==
                "1")
            ? (paymentProvider.paymentOptionModel.result?.instamojo?.liveKey2 ??
                "")
            : (paymentProvider.paymentOptionModel.result?.instamojo?.testKey2 ??
                "");
    String requestURL =
        ((paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? "") ==
                "1")
            ? 'https://www.instamojo.com/api/1.1/payment-requests/'
            : 'https://test.instamojo.com/api/1.1/payment-requests/';
    debugPrint("_initInstamojo apiKey =========> $apiKey");
    debugPrint("_initInstamojo authToken ======> $authToken");
    debugPrint("_initInstamojo requestURL =====> $requestURL");

    final Map<String, dynamic> orderData = {
      'amount': double.parse(widget.price ?? '0').toString(), // Amount in INR
      'purpose': widget.payType ?? '',
      'buyer_name': userName ?? '',
      'email': userEmail ?? '',
      'phone': userMobileNo ?? '',
      'currency': Constant.currency,
      'send_email': 'False',
      'send_sms': 'False',
      'allow_repeated_payments': 'False',
    };

    final response = await http.post(
      Uri.parse(requestURL),
      headers: {
        "Accept": "application/json",
        'Content-Type': 'application/x-www-form-urlencoded',
        "X-Api-Key": apiKey,
        "X-Auth-Token": authToken,
      },
      body: orderData,
    );

    debugPrint('createInstamojoOrder statusCode : ${response.statusCode}');
    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String paymentUrl = responseData['payment_request']['longurl'];
      final String paymentReqID = responseData['payment_request']['id'];

      // Now you can open this payment URL in a WebView or a browser
      debugPrint('Payment URL : $paymentUrl');
      debugPrint('Payment ID  : $paymentReqID');
      if (!mounted) return;
      dynamic result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => InstamojoPG(
            paymentUrl: paymentUrl,
            paymentId: paymentReqID,
          ),
        ),
      );

      debugPrint("result =====> $result");
      debugPrint("paymentReqID =====> $paymentReqID");
      if (result != null && result == true) {
        _checkPaymentStatus(paymentReqID);
      }
    } else {
      // Handle error
      debugPrint('Failed to create Instamojo order');
      if (!mounted) return;
      Utils.showSnackbar(context, "fail", "payment_not_processed", true);
    }
  }

  _checkPaymentStatus(String id) async {
    debugPrint("_checkPaymentStatus id =========> $id");
    String apiKey =
        ((paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? "") ==
                "1")
            ? (paymentProvider.paymentOptionModel.result?.instamojo?.liveKey1 ??
                "")
            : (paymentProvider.paymentOptionModel.result?.instamojo?.testKey1 ??
                "");
    String authToken =
        ((paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? "") ==
                "1")
            ? (paymentProvider.paymentOptionModel.result?.instamojo?.liveKey2 ??
                "")
            : (paymentProvider.paymentOptionModel.result?.instamojo?.testKey2 ??
                "");
    String requestURL =
        ((paymentProvider.paymentOptionModel.result?.instamojo?.isLive ?? "") ==
                "1")
            ? 'https://www.instamojo.com/api/1.1/payment-requests/'
            : 'https://test.instamojo.com/api/1.1/payment-requests/';
    debugPrint("_checkPaymentStatus apiKey =========> $apiKey");
    debugPrint("_checkPaymentStatus authToken ======> $authToken");
    debugPrint("_checkPaymentStatus requestURL =====> $requestURL");

    final response = await http.get(
      Uri.parse('$requestURL$id/'),
      headers: {
        "Accept": "application/json",
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Api-Key': apiKey,
        'X-Auth-Token': authToken,
      },
    );

    debugPrint('createInstamojoOrder statusCode : ${response.statusCode}');
    final Map<String, dynamic> realResponse = json.decode(response.body);
    if (realResponse['success'] == true) {
      if (realResponse["payment_request"]['payments'] != null) {
        List<dynamic> myPayments = [];
        myPayments = realResponse["payment_request"]['payments'];
        if (myPayments.isNotEmpty) {
          if (myPayments[0]['status'] == "Credit") {
            paymentId = myPayments[0]['payment_id'];
            debugPrint('createInstamojoOrder paymentId : $paymentId');

            if (!mounted) return;
            Utils.showSnackbar(context, "success", "payment_success", true);

            if (widget.payType == "Package") {
              await addTransaction(
                  widget.itemId,
                  widget.itemTitle,
                  paymentProvider.finalAmount,
                  paymentId,
                  widget.currency,
                  "success",
                  "amount");
            } else if (widget.payType == "Rent") {
              await addRentTransaction(
                  widget.itemId,
                  paymentProvider.finalAmount,
                  widget.typeId,
                  widget.videoType,
                  "success");
            }
            debugPrint("PAYMENT STATUS SUCCESS");
            //payment is successful.
          } else {
            debugPrint("PAYMENT STATUS PENDING");
            if (!mounted) return;
            Utils.showSnackbar(context, "info", "payment_cancel", true);
            //payment failed or pending.
          }
        } else {
          debugPrint("PAYMENT STATUS PENDING");
          if (!mounted) return;
          Utils.showSnackbar(context, "info", "payment_cancel", true);
          //payment failed or pending.
        }
      } else {
        debugPrint("PAYMENT STATUS PENDING");
        if (!mounted) return;
        Utils.showSnackbar(context, "info", "payment_cancel", true);
        //payment failed or pending.
      }
    } else {
      debugPrint("PAYMENT STATUS FAILED");
      if (!mounted) return;
      Utils.showSnackbar(context, "fail", "payment_fail", true);
      //payment failed.
    }
  }
  /* ********* Instamojo END ********* */

  Future<bool> onBackPressed() async {
    if (!mounted) return Future.value(false);

    if (!isPaymentDone) {
      print("----------AAAA");
      analytics.logEvent(
        name: "subscription_canceled",
        parameters: {
          "user_id": Constant.userID,
          "package_id": widget.itemId, // Add the actual package id if available
          "package_name":
              widget.itemTitle, // Add the actual package name if available
          "package_amount":
              widget.price, // Add the actual package name if available
        },
      );
      Map<String, Object> screenViewEvent = {
        'event_name': 'subscription_canceled',
        "PayType": '${widget.payType}',
        "price": '${widget.price}',
        "name": '${widget.itemTitle}',
        "price": '${widget.price}',
        "final amount": '${paymentProvider.finalAmount}',
        "VId": '${widget.itemId}',
        'user_id': Constant.userID.toString(),
      };
      Singular.eventWithArgs('subscription_canceled', screenViewEvent);
    }
    Navigator.pop(context, isPaymentDone);
    return Future.value(isPaymentDone == true ? true : false);
  }
}
