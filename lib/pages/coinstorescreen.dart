import 'dart:convert';
import 'package:dtlive/pages/wallethistoryscreen.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/provider/paymentprovider.dart';
import 'package:dtlive/provider/userwallectProvider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:http/http.dart' as http;

class CoinStoreScreen extends StatefulWidget {
  @override
  _CoinStoreScreenState createState() => _CoinStoreScreenState();
}

class _CoinStoreScreenState extends State<CoinStoreScreen> {
  late HomeProvider homeProvider;
  late WalletProvider walletProvider;
  late Razorpay _razorpay;
  late PaymentProvider paymentProvider;

  SharedPre sharedPref = SharedPre();
  String? userId, userName, userEmail, userMobileNo, paymentId;
  String? selectedCoinPackageId;
  dynamic selectedAmount;
  bool isLoading = false; // Add loader state

  @override
  void initState() {
    super.initState();
    _getData();
    _initializeRazorpay();
    _initializeData();
  }

    _getData() async {

      paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    await paymentProvider.getPaymentOption();
  
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


  void _initializeRazorpay() {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clean up the Razorpay instance
    super.dispose();
  }

  Future<void> _initializeData() async {
    userId = await sharedPref.read("userid");
    userName = await sharedPref.read("username");
    userEmail = await sharedPref.read("useremail");
    userMobileNo = await sharedPref.read("usermobile");

    debugPrint('getUserData userId ==> $userId');
    debugPrint('getUserData userName ==> $userName');
    debugPrint('getUserData userEmail ==> $userEmail');
    debugPrint('getUserData userMobileNo ==> $userMobileNo');

    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);

    // Fetch coin packages asynchronously
    Provider.of<WalletProvider>(context, listen: false).fetchCoinPackages();
  }

  Future<String> createOrder() async {
    try {
      var mapHeader = <String, String>{};
      mapHeader['Content-Type'] = 'application/json';

      var requestBody = jsonEncode({
        "amount": (selectedAmount ?? 0).toInt(),
        "currency": "INR",
        "name": 'Coin Pack',
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
        String orderId = responseData['result']['id'];
        return orderId;
      } else {
        throw Exception(
            'Failed to create order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  Future<void> _createOrderAndPay(dynamic amount) async {
    try {
      setState(() {
        selectedAmount = amount;
         isLoading = true; // Show loader
      });

      String orderId = await createOrder();
      print("Order ID created: $orderId");
      if (orderId != null) {
        _openRazorpayPaymentGateway(amount, orderId);
      } else {
        Utils.showSnackbar(context, "fail", "order_creation_failed", true);
      }
    } catch (e) {
      print("Error creating order: $e");
      Utils.showSnackbar(context, "fail", "order_creation_failed", true);
    }finally {
      setState(() {
        isLoading = false; // Hide loader
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Utils.showSnackbar(context, "success", "payment_success", true);

    dynamic paymentId = response.paymentId!;
    dynamic orderId = response.orderId!;
    int coinPackageId = int.tryParse(selectedCoinPackageId ?? '') ?? 0;

    walletProvider
        .addCoinTransaction(
      userId: userId!,
      coinPackageId: coinPackageId,
      amount: selectedAmount ?? 0.0,
      paymentId: paymentId,
      currencyCode: 'INR',
      orderStatus: 'success',
      orderId: orderId,
      paymentMethod: 'razorpay',
    )
        .then((_) {
      Navigator.pop(context);
      print("Transaction processed");
    }).catchError((e) {
      print("Error processing payment success: $e");
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Utils.showSnackbar(context, "fail", "payment_fail", true);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  // void _openRazorpayPaymentGateway(dynamic amount, dynamic orderId) {
  //   try {
  //     var options = {
  //       'key': 'rzp_test_E7TfP2p9bA9q75',
  //       'amount': (amount * 100).toString(),
  //       'name': 'Coin Purchase',
  //       'prefill': {'contact': userMobileNo, 'email': userEmail},
  //       'order_id': orderId,
  //       'theme': {'color': '#F37254'},
  //     };

  //     _razorpay.open(options);
  //   } catch (e) {
  //     print('Error in opening Razorpay: $e');
  //     Utils.showSnackbar(context, "fail", "payment_error", true);
  //   }
  // }

    void _openRazorpayPaymentGateway(dynamic amount, dynamic orderId) {

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
    try {
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
        'amount': (amount * 100).toString(),
        'name': 'Coin Purchase',
        'prefill': {'contact': userMobileNo, 'email': userEmail},
        'order_id': orderId,
        'theme': {'color': '#F37254'},
      };

      _razorpay.open(options);
    } catch (e) {
      print('Error in opening Razorpay: $e');
      Utils.showSnackbar(context, "fail", "payment_error", true);
    }
  }



@override
Widget build(BuildContext context) {
  final walletProvider = Provider.of<WalletProvider>(context);
  final coinPackages = walletProvider.coinPackages;

  return Scaffold(
    appBar: Utils.myAppBarWithBack(context, "coin", true),
    body: Stack(
      children: [
        // Main Content
        walletProvider.isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coin Balance Section
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 5),
                      height: 55,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 10),
                          Image.asset('assets/images/coin.png',
                              width: 50, height: 50),
                          SizedBox(width: 5),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Balance',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: lightGray),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${homeProvider.userWalletBalanceModel?.balance} Coins',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      WalletHistodyScreen()));
                            },
                            child: Icon(CupertinoIcons.chevron_forward,
                                color: white),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: 35),

                    // Coin Packs Text
                    Text(
                      'Coin Packs',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 20),

                    // Coin Packages List
                    Expanded(
                      child: ListView.builder(
                        itemCount: coinPackages.length,
                        itemBuilder: (context, index) {
                          final package = coinPackages[index];
                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Image.asset('assets/images/coin.png',
                                        width: 30, height: 30),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          package.name,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: colorPrimary),
                                        ),
                                        SizedBox(height: 5),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${package.noOfCoins}  ',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              TextSpan(
                                                text: 'Coins',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedCoinPackageId =
                                              package.id.toString();
                                          selectedAmount = package.price;
                                        });
                                        _createOrderAndPay(package.price);
                                      },
                                      child: Container(
                                        width: 100,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: colorPrimary,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '\u{20B9}${package.price}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(color: Colors.grey.shade300),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

        // Loader Overlay
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    ),
  );
}

  // @override
  // Widget build(BuildContext context) {
  //   final walletProvider = Provider.of<WalletProvider>(context);
  //   final coinPackages = walletProvider.coinPackages;

  //   return Scaffold(
  //     appBar: Utils.myAppBarWithBack(context, "coin", true),
  //     body: walletProvider.isLoading
  //         ? Center(child: CircularProgressIndicator())
  //         : Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Coin Balance Section
  //                 Container(
  //                   padding: EdgeInsets.only(top: 10, bottom: 5),
  //                   height: 55,
  //                   decoration: BoxDecoration(
  //                     color: shimmerColor,
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   child: Row(
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     children: [
  //                       SizedBox(width: 10),
  //                       Image.asset('assets/images/coin.png',
  //                           width: 35, height: 35),
  //                       SizedBox(width: 10),
  //                       Column(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             'Balance',
  //                             style: TextStyle(
  //                                 fontSize: 12,
  //                                 fontWeight: FontWeight.w300,
  //                                 color: lightGray),
  //                           ),
  //                           SizedBox(height: 5),
  //                           Text(
  //                             '${homeProvider.userWalletBalanceModel?.balance} Coins',
  //                             style: TextStyle(
  //                                 fontSize: 16,
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.w600),
  //                           ),
  //                         ],
  //                       ),
  //                       Spacer(),
  //                       GestureDetector(
  //                         onTap: () {
  //                           Navigator.of(context).push(MaterialPageRoute(
  //                               builder: (context) => WalletHistodyScreen()));
  //                         },
  //                         child: Icon(CupertinoIcons.chevron_forward,
  //                             color: white),
  //                       ),
  //                       SizedBox(width: 10),
  //                     ],
  //                   ),
  //                 ),
  //                 SizedBox(height: 35),

  //                 // Coin Packs Text
  //                 Text(
  //                   'Coin Packs',
  //                   style: TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.white),
  //                 ),
  //                 SizedBox(height: 20),

  //                 // Coin Packages List
  //                 Expanded(
  //                   child: ListView.builder(
  //                     itemCount: coinPackages.length,
  //                     itemBuilder: (context, index) {
  //                       final package = coinPackages[index];
  //                       return Column(
  //                         children: [
  //                           Container(
  //                             padding: EdgeInsets.all(10),
  //                             child: Row(
  //                               children: [
  //                                 Image.asset('assets/images/coin.png',
  //                                     width: 30, height: 30),
  //                                 SizedBox(width: 10),
  //                                 Column(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.start,
  //                                   children: [
  //                                     Text(
  //                                       package.name,
  //                                       style: TextStyle(
  //                                           fontSize: 16,
  //                                           fontWeight: FontWeight.bold,
  //                                           color: colorPrimary),
  //                                     ),
  //                                     SizedBox(height: 5),
  //                                     Text.rich(
  //                                       TextSpan(
  //                                         children: [
  //                                           TextSpan(
  //                                             text: '${package.noOfCoins}  ',
  //                                             style: TextStyle(
  //                                                 fontSize: 17,
  //                                                 fontWeight: FontWeight.bold,
  //                                                 color: Colors.white),
  //                                           ),
  //                                           TextSpan(
  //                                             text: 'Coins',
  //                                             style: TextStyle(
  //                                                 fontSize: 14,
  //                                                 fontWeight: FontWeight.normal,
  //                                                 color: Colors.grey),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 Spacer(),
  //                                 GestureDetector(
  //                                   onTap: () {
  //                                     // Ensure selectedAmount is of type double?
  //                                     setState(() {
  //                                       selectedCoinPackageId = package.id
  //                                           .toString(); // Convert int to String
  //                                       selectedAmount = package
  //                                           .price; // Convert int to double
  //                                     });
  //                                     _createOrderAndPay(package
  //                                         .price); // Convert price to double if needed
  //                                   },
  //                                   child: Container(
  //                                     width: 100,
  //                                     padding: EdgeInsets.symmetric(
  //                                         horizontal: 10, vertical: 5),
  //                                     decoration: BoxDecoration(
  //                                       color: colorPrimary,
  //                                       borderRadius: BorderRadius.circular(6),
  //                                     ),
  //                                     child: Center(
  //                                       child: Text(
  //                                         '\u{20B9}${package.price}',
  //                                         style: TextStyle(
  //                                             color: Colors.white,
  //                                             fontSize: 16,
  //                                             fontWeight: FontWeight.w600),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           Divider(color: Colors.grey.shade300),
  //                         ],
  //                       );
  //                     },
  //                   ),
  //                 ),


                 

  //                  if (isLoading)
  //           Container(
  //             color: Colors.black.withOpacity(0.5),
  //             child: Center(
  //               child: CircularProgressIndicator(),
  //             ),
  //           ),
  //               ],
  //             ),
  //           ),
  //   );
  // }



}
