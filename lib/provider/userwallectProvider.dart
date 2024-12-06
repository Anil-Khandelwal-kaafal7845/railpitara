import 'package:dtlive/model/coinpackagesmodel.dart';
import 'package:dtlive/model/userwalletmodel.dart';
import 'package:dtlive/model/wallettransction.dart';
import 'package:dtlive/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class WalletProvider with ChangeNotifier {
  UserWalletBalanceModel? userWalletBalanceModel;
  bool isLoading = false;
  List<CoinPackage> coinPackages = [];
  List<WalletTransaction> walletHistory = [];

  

  // Add coins after watching an ad
  Future<void> addCoinsAfterWatchAd(String userId, dynamic videoId, dynamic showId, dynamic tokenValue) async {
    setLoading(true);
    try {
      userWalletBalanceModel = await ApiService().addCoinsAfterWatchAd(userId, videoId, showId, tokenValue);
      print("Updated Wallet Balance after Ad: ${userWalletBalanceModel?.balance}");
      notifyListeners();
    } catch (e) {
      print("Error adding coins after watching ad: $e");
    }
    setLoading(false);
  }

  // Fetch coin packages
  Future<void> fetchCoinPackages() async {
    setLoading(true);
    try {
      coinPackages = await ApiService().getCoinPackages();
      notifyListeners();
    } catch (e) {
      print("Error fetching coin packages: $e");
    }
    setLoading(false);
  }

  // Wallet transactions
  Future<void> fetchWalletHistory(String userId) async {
    setLoading(true);
    try {
      walletHistory = await ApiService().getWalletHistory(userId);
      notifyListeners();
    } catch (e) {
      print("Error fetching wallet history: $e");
    }
    setLoading(false);
  }

  // Add coin transaction

Future<void> addCoinTransaction({
  required String userId,
  required int coinPackageId,
  required dynamic amount,
  required dynamic paymentId,
  required String currencyCode,
  required String orderStatus,
  required String orderId,
  required String paymentMethod,
}) async {
  setLoading(true);
  try {
    // Call the API method and store the result
    bool isSuccess = await ApiService().addCoinTransaction(
      userId: userId,
      coinPackageId: coinPackageId,
      amount: amount,
      paymentId: paymentId,
      currencyCode: currencyCode,
      orderStatus: orderStatus,
      orderId: orderId,
      paymentMethod: paymentMethod,
    );

    // Handle success or failure
    if (isSuccess) {
      print("Transaction added successfully");
    } else {
      print("Transaction failed");
    }
    notifyListeners();
  } catch (e) {
    print("Error in addCoinTransaction: $e");
  }
  setLoading(false);
}




  // Future<void> addCoinTransaction({
  //   required String userId,
  //   required int coinPackageId,
  //   required dynamic amount,
  //   required String paymentId,
  //   required String currencyCode,
  //   required String orderStatus,
  //   required String orderId,
  //   required String paymentMethod,
  // }) async {
  //   setLoading(true);
  //   try {
  //     await ApiService().addCoinTransaction(
  //       userId: userId,
  //       coinPackageId: coinPackageId,
  //       amount: amount,
  //       paymentId: paymentId,
  //       currencyCode: currencyCode,
  //       orderStatus: orderStatus,
  //       orderId: orderId,
  //       paymentMethod: paymentMethod,
  //     );
  //     print("Transaction added successfully");
  //     notifyListeners();
  //   } catch (e) {
  //     print("Error in addCoinTransaction: $e");
  //   }
  //   setLoading(false);
  // }

  // Set loading state to show/hide loading indicators
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
