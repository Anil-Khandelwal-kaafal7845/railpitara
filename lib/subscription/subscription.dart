import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dtlive/main.dart';
import 'package:dtlive/model/subscriptionmodel.dart';
import 'package:dtlive/pages/coinstorescreen.dart';
import 'package:dtlive/pages/loginsocial.dart';
import 'package:dtlive/pages/successPrime.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/shimmer/shimmerutils.dart';
import 'package:dtlive/subscription/allpayment.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/webwidget/footerweb.dart';
import 'package:dtlive/widget/nodata.dart';
import 'package:dtlive/provider/subscriptionprovider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/widget/myimage.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class Subscription extends StatefulWidget {
  const Subscription({
    Key? key,
  }) : super(key: key);

  @override
  State<Subscription> createState() => SubscriptionState();
}

class SubscriptionState extends State<Subscription>with RouteAware {
  late SubscriptionProvider subscriptionProvider;
  CarouselController pageController = CarouselController();
  int selectedIndex = 0;
  late HomeProvider homeProvider;

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    super.initState();
    _getData();
  }

  _getData() async {
    Utils.getCurrencySymbol();
    await subscriptionProvider.getPackages();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }


  void _fetchDataAgain() async {
     homeProvider.fetchUserWalletBalance(Constant.userID??"");
    _getData();
    setState(() {});
  }

   @override
  void didPopNext() {
    _fetchDataAgain();
    super.didPopNext();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _checkAndPay(List<Result>? packageList, int index) async {
    if (Constant.userID != null) {
      for (var i = 0; i < (packageList?.length ?? 0); i++) {
        if (packageList?[i].isBuy == 1) {
          debugPrint("<============= Purchaged =============>");
          Utils.showSnackbar(context, "info", "already_purchased", true);
          return;
        }
      }

      if (packageList?[index].isBuy == 0) {
        analytics.logEvent(
          name: "choose_subscription_plan_pay",
          parameters: {
            "package_id": packageList?[index].id,
            "package_name": packageList?[index].name,
            "package_price": packageList?[index].price,
            "user_id": Constant.userID,
          },
        );

        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return
              
               AllPayment(
                payType: 'Package',
                itemId: packageList?[index].id.toString() ?? '',
                price: packageList?[index].price.toString() ?? '',
                itemTitle: packageList?[index].name.toString() ?? '',
                typeId: '',
                videoType: '',
                productPackage: (!kIsWeb)
                    ? (Platform.isIOS
                        ? (packageList?[index].iosProductPackage.toString() ??
                            '')
                        : (packageList?[index]
                                .androidProductPackage
                                .toString() ??
                            ''))
                    : '',
                currency: '',
              );
            },
          ),
        );
      
      
      }
    } else {
      if ((kIsWeb || Constant.isTV)) {
        Utils.buildWebAlertDialog(context, "login", "");
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginSocial();
          },
        ),
      );
    }
  }

// // Function that checks the user's wallet balance and navigates accordingly
// Future<void> _checkRentViaCoin(
//     List<Result>? packageList, int index, BuildContext context) async {
//   try {
//     // Check if the selected package is already purchased
//     if (packageList?[index].isBuy == 1) {
//       debugPrint("<============= Purchaged =============>");
//       Utils.showSnackbar(context, "info", "already_purchased", true);
//       return;
//     }

//     // Access the user balance and the selected package's coin amount
//     dynamic userBalance = homeProvider.userWalletBalanceModel?.balance ?? 0;
//     dynamic videoCoinValue = packageList?[index].coinAmount ?? '0';

//     // Debugging prints to check values
//     debugPrint("<============= User Balance: $userBalance =============>");
//     debugPrint("<============= Video Coin Value: $videoCoinValue =============>");

//     // Check if the user has enough balance
//     if (userBalance >= videoCoinValue) {
//       debugPrint("<============= Sufficient Balance, Navigating to TransactionStatusScreen =============>");
//       // If the user has enough balance, navigate to the transaction status screen
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => TransactionStatusScreen(
//             userId: "${Constant.userID}",
//             noOfToken: "${packageList?[index].coinAmount}",
//             packageId: "${packageList?[index].id}",
//             amount: "${packageList?[index].price}",
//           ),
//         ),
//       );
//     } else {
//       debugPrint("<============= Insufficient Balance, Navigating to CoinStoreScreen =============>");
//       // If the user does not have enough balance, navigate to CoinStoreScreen
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => CoinStoreScreen(),
//         ),
//       );
//     }
//   } catch (e) {
//     // Catch any errors and print them for debugging
//     debugPrint('Error: $e');
//   }
// }

Future<void> _checkRentViaCoin (
    List<Result>? packageList, int index, BuildContext context) async {
  try {
    // Check if the selected package is already purchased
    if (packageList?[index].isBuy == 1) {
      debugPrint("<============= Purchaged =============>");
      Utils.showSnackbar(context, "info", "already_purchased", true);
      return;
    }

    // Access the user balance and the selected package's coin amount
    dynamic userBalance = homeProvider.userWalletBalanceModel?.balance ?? 0;
    dynamic videoCoinValue = packageList?[index].coinAmount ?? '0';

    debugPrint("<============= User Balance: $userBalance =============>");
    debugPrint("<============= Video Coin Value: $videoCoinValue =============>");

    // Check if the user has enough balance
    if (userBalance >= videoCoinValue && userBalance >= 0) {
      debugPrint("<============= Sufficient Balance, Navigating to TransactionStatusScreen =============>");
      // If the user has enough balance, navigate to the transaction status screen
    
    
    
   await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return
              
               TransactionStatusScreen(
            userId: "${Constant.userID}",
            noOfToken: "${packageList?[index].coinAmount}",
            packageId: "${packageList?[index].id}",
            amount: "${packageList?[index].price}",
          );
            },
          ),
        );
      

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => TransactionStatusScreen(
      //       userId: "${Constant.userID}",
      //       noOfToken: "${packageList?[index].coinAmount}",
      //       packageId: "${packageList?[index].id}",
      //       amount: "${packageList?[index].price}",
      //     ),
      //   ),
      // );


    } else {
      debugPrint("<============= Invalid Balance or Insufficient Funds, Navigating to CoinStoreScreen =============>");
      // If the user does not have enough balance, navigate to CoinStoreScreen
      
       await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoinStoreScreen(),
          ),
        );
      
    }
  } catch (e) {
    debugPrint('Error: $e');
  }
}

// Function to show the bottom sheet with payment methods
void _checkPackageAndShowBottomSheet(
    List<Result>? packageList, int index, BuildContext context) {
  // Check if any package in the list has isBuy == 1 (already purchased)
  bool isAnyPackagePurchased = packageList?.any((package) => package.isBuy == 1) ?? false;

  debugPrint("<============= Package Purchase Check: $isAnyPackagePurchased =============>");

  if (isAnyPackagePurchased) {
    // Show Snackbar if any package is already purchased
    debugPrint("<============= Purchased Package Found =============>");
    Utils.showSnackbar(context, "info", "already_purchased", true);
  } else {
    // If no package is purchased, show the bottom sheet
    debugPrint("<============= No Purchased Packages =============>");
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.black,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                'Select Payment Method',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.grey, thickness: 1),

              // Rent via Payment option
              ListTile(
                leading: Image.asset(
                  'assets/images/rupee.png',
                  height: 30,
                  width: 30,
                ),
                title: const Text(
                  'Rent via Payment',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  debugPrint("<============= Rent via Payment Selected =============>");
                  // Call the payment function here
                  await _checkAndPay(packageList, index);
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
              const Divider(color: Colors.grey, thickness: 1),

              // Rent via Coin option
              ListTile(
                leading: Image.asset(
                  'assets/images/coin.png',
                  height: 40,
                  width: 40,
                ),
                title: const Text(
                  'Rent via Coin',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  debugPrint("<============= Rent via Coin Selected =============>");
                  // Call the function to check wallet balance and make payment via coins
                  await _checkRentViaCoin(packageList, index, context);
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }
}


// // Function that checks the user's wallet balance and navigates accordingly
//   Future<void> _checkRentViaCoin(
//       List<Result>? packageList, int index, BuildContext context) async {
//     try {
//       if (packageList?[index].isBuy == 1) {
//         debugPrint("<============= Purchaged =============>");
//         Utils.showSnackbar(context, "info", "already_purchased", true);
//         return;
//       }
//       // Access the user balance and the selected package's coin amount
//       dynamic userBalance = homeProvider.userWalletBalanceModel?.balance ?? 0;
//       dynamic videoCoinValue = packageList?[index].coinAmount ?? '0';

//       // Check if the user has enough balance
//       if (userBalance >= videoCoinValue) {
//         // If the user has enough balance, navigate to the transaction status screen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TransactionStatusScreen(
//               userId: "${Constant.userID}",
//               noOfToken: "${packageList?[index].coinAmount}",
//               packageId: "${packageList?[index].id}",
//               amount: "${packageList?[index].price}",
//             ),
//           ),
//         );
//       } else {
//        Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CoinStoreScreen(),
//             ),
//           );
        
//       }
//     } catch (e) {
//       debugPrint('Error: $e');
//     }
//   }

//   void _checkPackageAndShowBottomSheet(
//       List<Result>? packageList, int index, BuildContext context) {
//     // Check if any package in the list has isBuy == 1 (already purchased)
//     bool isAnyPackagePurchased =
//         packageList?.any((package) => package.isBuy == 1) ?? false;

//     if (isAnyPackagePurchased) {
//       // Show Snackbar if any package is already purchased
//       debugPrint("<============= Purchased Package Found =============>");
//       Utils.showSnackbar(context, "info", "already_purchased", true);
//     } else {
//       // If no package is purchased, show the bottom sheet
//       debugPrint("<============= No Purchased Packages =============>");
//        showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       backgroundColor: Colors.black,
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 10),
//               Text(
//                 'Select Payment Method',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Divider(color: Colors.grey, thickness: 1),

//               // Rent via Payment option
//               ListTile(
//                 leading: Image.asset(
//                   'assets/images/rupee.png',
//                   height: 30,
//                   width: 30,
//                 ),
//                 title: const Text(
//                   'Rent via Payment',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 onTap: () async {
//                   // Call the payment function here
//                   await _checkAndPay(packageList, index);
//                   Navigator.pop(context); // Close the bottom sheet
//                 },
//               ),
//               const Divider(color: Colors.grey, thickness: 1),

//               // Rent via Coin option
//               ListTile(
//                 leading: Image.asset(
//                   'assets/images/coin.png',
//                   height: 40,
//                   width: 40,
//                 ),
//                 title: const Text(
//                   'Rent via Coin',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 onTap: () async {
//                   // Call the function to check wallet balance and make payment via coins
//                   await _checkRentViaCoin(packageList, index, context);
//                   Navigator.pop(context); // Close the bottom sheet
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
  
//     }
//   }


  @override
  Widget build(BuildContext context) {
    analytics.logEvent(
      name: "screen_view",
      parameters: {
        "screen_name": "Subscription Package Screen",
        "user_id": Constant.userID,
      },
    );
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: appBgColor,
        body: SingleChildScrollView(
          child: _buildSubscription(),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: appBgColor,
        appBar: Utils.myAppBarWithBack(context, "subsciption", true),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: _buildSubscription(),
              ),
            ),
            /* AdMob Banner */
            // Container(
            //   child: Utils.showBannerAd(context),
            // ),
          ],
        ),
      );
    }
  }

  Widget _buildSubscription() {
    if (subscriptionProvider.loading) {
      if ((kIsWeb || Constant.isTV) &&
          MediaQuery.of(context).size.width > 720) {
        return ShimmerUtils.buildSubscribeWebShimmer(context);
      } else {
        return ShimmerUtils.buildSubscribeShimmer(context);
      }
    } else {
      if (subscriptionProvider.subscriptionModel.status == 200) {
        return Column(
          children: [
            SizedBox(
                height: ((kIsWeb || Constant.isTV) &&
                        MediaQuery.of(context).size.width > 720)
                    ? 40
                    : 12),
            SizedBox(
                height: ((kIsWeb || Constant.isTV) &&
                        MediaQuery.of(context).size.width > 720)
                    ? 40
                    : 12),

            /* Remaining Data */
            _buildItems(subscriptionProvider.subscriptionModel.result),
            const SizedBox(height: 20),

            /* Web Footer */
            kIsWeb ? const FooterWeb() : const SizedBox.shrink(),
          ],
        );
      } else {
        return const NoData(title: '', subTitle: '');
      }
    }
  }

  Widget _buildItems(List<Result>? packageList) {
    if ((kIsWeb || Constant.isTV) && MediaQuery.of(context).size.width > 800) {
      return buildWebItem(packageList);
    } else {
      return Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: subscriblue,
        ),
        child: Column(
          children: [
            _buildBenefits(packageList, selectedIndex),
            buildMobileItem(packageList),
            GestureDetector(
              onTap: () {
                _checkPackageAndShowBottomSheet(
                    packageList, selectedIndex, context);

//       showModalBottomSheet(
//             context: context,
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             backgroundColor: Colors.black,
//             builder: (context) {

//               return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const SizedBox(height: 10),
//                     Text(
//                       'Select Payment Method',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     const Divider(color: Colors.grey, thickness: 1),

//                     // Rent via Payment option
//                     ListTile(
//                       leading: Image.asset(
//                         'assets/images/rupee.png',
//                         height: 30,
//                         width: 30,
//                       ),
//                       title: const Text(
//                         'Rent via Payment',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       onTap: () async {
//                          _checkAndPay(packageList, selectedIndex);

//                       },
//                     ),
//                     const Divider(color: Colors.grey, thickness: 1),

//                     // Rent via Coin option

//                     ListTile(
//   leading: Image.asset(
//     'assets/images/coin.png',
//     height: 40,
//     width: 40,
//   ),
//   title: const Text(
//     'Rent via Coin',
//     style: TextStyle(color: Colors.white),
//   ),
//   onTap: () async {
//    await _checkRentViaCoin(packageList, selectedIndex, context);
//   },
// )

//                 //  ListTile(
//                 //           leading: Image.asset(
//                 //             'assets/images/coin.png',
//                 //             height: 40,
//                 //             width: 40,
//                 //           ),
//                 //           title: const Text(
//                 //             'Rent via Coin',
//                 //             style: TextStyle(color: Colors.white),
//                 //           ),
//                 //           onTap: () async {

//                 //           },
//                 //         ),

//                  ],
//                 ),
//               );
//             },
//           );
              },
              child: Container(
                margin: EdgeInsets.only(top: 35, bottom: 25),
                height: 50,
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: subscrimain,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  color: subscridark,
                ),
                child: Center(
                  child: MyText(
                    color: white,
                    text: "chooseplan",
                    textalign: TextAlign.center,
                    fontsizeNormal: 15,
                    fontsizeWeb: 20,
                    fontweight: FontWeight.w700,
                    multilanguage: true,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  Widget buildMobileItem(List<Result>? packageList) {
    if (packageList != null) {
      return Container(
        margin: EdgeInsets.only(top: 30),
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 4,
          ),
          shrinkWrap: true,
          itemCount: packageList.length,
          itemBuilder: (BuildContext context, int index) {
            bool isSelected = selectedIndex == index;
            bool isPurchased = packageList[index].isBuy == 1;

            return InkWell(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });

                analytics.logEvent(
                  name: "package_selected",
                  parameters: {
                    "package_id": packageList[index].id,
                    "package_name": packageList[index].name,
                    "package_price": packageList[index].price,
                    "user_id": Constant.userID,
                  },
                );
              },
              child: Container(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: isPurchased
                      ? subscridark
                      : isSelected
                          ? subscridark
                          : subscrimain,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                          color: isPurchased ? white : subscriblue,
                          text: packageList[index].name ?? "",
                          textalign: TextAlign.start,
                          fontsizeNormal: 16,
                          fontsizeWeb: 24,
                          maxline: 1,
                          multilanguage: false,
                          overflow: TextOverflow.ellipsis,
                          fontweight: FontWeight.w700,
                          fontstyle: FontStyle.normal,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        MyText(
                          color: isPurchased ? white : subscriblue,
                          text:
                              "\u{20B9} ${packageList[index].price.toString()}",
                          textalign: TextAlign.center,
                          fontsizeNormal: 30,
                          fontsizeWeb: 22,
                          maxline: 1,
                          multilanguage: false,
                          overflow: TextOverflow.ellipsis,
                          fontweight: FontWeight.w600,
                          fontstyle: FontStyle.normal,
                        ),
                        MyText(
                          color: isPurchased ? white : subscriblue,
                          text: "or",
                          textalign: TextAlign.center,
                          fontsizeNormal: 13,
                          fontsizeWeb: 13,
                          maxline: 1,
                          multilanguage: false,
                          overflow: TextOverflow.ellipsis,
                          fontweight: FontWeight.w600,
                          fontstyle: FontStyle.normal,
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "${packageList[index].coinAmount.toString()} ",
                                style: TextStyle(
                                  color: isPurchased ? white : subscriblue,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              TextSpan(
                                text: "coin",
                                style: TextStyle(
                                  color: isPurchased ? white : subscriblue,
                                  fontSize:
                                      25, // Smaller font size for the "coin" text
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildBenefits(List<Result>? packageList, int? index) {
    if (packageList?[index ?? 0].data != null &&
        (packageList?[index ?? 0].data?.length ?? 0) > 0) {
      return Container(
        constraints: BoxConstraints(
          minHeight: 15,
        ),
        width: MediaQuery.of(context).size.width,
        child: AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 25,
          padding: const EdgeInsets.fromLTRB(15, 2, 15, 5),
          itemCount: (packageList?[index ?? 0].data?.length ?? 0),
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int position) {
            return Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyText(
                          color: (packageList?[index ?? 0].isBuy == 1
                              ? white
                              : white),
                          text: packageList?[index ?? 0]
                                  .data?[position]
                                  .packageKey ??
                              "",
                          textalign: TextAlign.start,
                          multilanguage: false,
                          fontsizeNormal: 15,
                          fontsizeWeb: 18,
                          maxline: 3,
                          overflow: TextOverflow.ellipsis,
                          fontweight: FontWeight.w600,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                      const SizedBox(width: 5),
                      ((packageList?[index ?? 0].data?[position].packageValue ??
                                      "") ==
                                  "1" ||
                              (packageList?[index ?? 0]
                                          .data?[position]
                                          .packageValue ??
                                      "") ==
                                  "0")
                          ? MyImage(
                              width: 23,
                              height: 23,
                              color: (packageList?[index ?? 0]
                                              .data?[position]
                                              .packageValue ??
                                          "") ==
                                      "1"
                                  ? (packageList?[index ?? 0].isBuy == 1
                                      ? subscrigreen
                                      : subscrigreen)
                                  : redColor,
                              imagePath: (packageList?[index ?? 0]
                                              .data?[position]
                                              .packageValue ??
                                          "") ==
                                      "1"
                                  ? "tick_mark.png"
                                  : "cross_mark.png",
                            )
                          : MyText(
                              color: (packageList?[index ?? 0].isBuy == 1
                                  ? subscrigreen
                                  : subscrigreen),
                              text: packageList?[index ?? 0]
                                      .data?[position]
                                      .packageValue ??
                                  "",
                              textalign: TextAlign.center,
                              fontsizeNormal: 16,
                              fontsizeWeb: 24,
                              multilanguage: false,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontweight: FontWeight.w600,
                              fontstyle: FontStyle.normal,
                            ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildWebItem(List<Result>? packageList) {
    if (packageList != null) {
      return Container(
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
        child: ResponsiveGridList(
          minItemWidth: (MediaQuery.of(context).size.width > 720)
              ? Dimens.widthPackageWeb
              : Dimens.widthPackage,
          verticalGridSpacing: 8,
          horizontalGridSpacing: 6,
          minItemsPerRow: 1,
          maxItemsPerRow: 3,
          listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            (packageList.length),
            (index) {
              return Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                elevation: 3,
                color: (packageList[index].isBuy == 1 ? colorPrimary : black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 18, right: 18),
                      constraints: const BoxConstraints(minHeight: 55),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: MyText(
                              color: (packageList[index].isBuy == 1
                                  ? black
                                  : colorPrimary),
                              text: packageList[index].name ?? "",
                              textalign: TextAlign.start,
                              fontsizeNormal: 18,
                              fontsizeWeb: 24,
                              maxline: 1,
                              multilanguage: false,
                              overflow: TextOverflow.ellipsis,
                              fontweight: FontWeight.w700,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                          const SizedBox(width: 5),
                          MyText(
                            color: (packageList[index].isBuy == 1
                                ? black
                                : colorPrimary),
                            text:
                                "${Constant.currencySymbol} ${packageList[index].price.toString()} / ${packageList[index].time.toString()} ${packageList[index].type.toString()}",
                            textalign: TextAlign.center,
                            fontsizeNormal: 16,
                            fontsizeWeb: 22,
                            maxline: 1,
                            multilanguage: false,
                            overflow: TextOverflow.ellipsis,
                            fontweight: FontWeight.w600,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 0.5,
                      margin: const EdgeInsets.only(bottom: 12),
                      color: otherColor,
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(1, 9, 1, 9),
                      height: 300,
                      child: SingleChildScrollView(
                        child: _buildBenefits(packageList, index),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /* Choose Plan */
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () async {
                            _checkAndPay(packageList, index);
                          },
                          child: Container(
                            height: 45,
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            decoration: BoxDecoration(
                              color: (packageList[index].isBuy == 1
                                  ? white
                                  : colorPrimary),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            alignment: Alignment.center,
                            child: Consumer<SubscriptionProvider>(
                              builder: (context, subscriptionProvider, child) {
                                return MyText(
                                  color: black,
                                  text: (packageList[index].isBuy == 1)
                                      ? "current"
                                      : "chooseplan",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 16,
                                  fontsizeWeb: 20,
                                  fontweight: FontWeight.w700,
                                  multilanguage: true,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
