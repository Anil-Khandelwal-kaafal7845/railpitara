import 'package:dtlive/model/coinrentmodel.dart';
import 'package:dtlive/provider/userwallectProvider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SuccessShowScreen extends StatefulWidget {
  final String userId;
  final String videoId;
   final String showId;
  final String noOfToken;

  SuccessShowScreen({
    required this.userId,
    required this.videoId,
    required this.showId,
    required this.noOfToken,
  });

  @override
  _SuccessShowScreenState createState() => _SuccessShowScreenState();
}

class _SuccessShowScreenState extends State<SuccessShowScreen> {
  late WalletProvider walletProvider;
  bool _isLoading = true;
  bool _isSuccess = false;  // Flag to check success/failure
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    _makeApiCall();
  }

  // Method to make API call
  Future<void> _makeApiCall() async {
    try {
      // Perform the API call
      PurchaseFromCoinResponse response = await walletProvider.purchaseViaCoin(
        context: context,
        userId: widget.userId,
        videoId: widget.videoId,
        showId: widget.showId,
        tokenFrom: "purchase_video",
        noOfToken: widget.noOfToken,
      );

      // Check the response status
      if (response.status == 200) {
        setState(() {
          _isSuccess = true;  // Set success flag to true
          _isLoading = false;  // Stop loading
        });
      } else {
        setState(() {
          _isSuccess = false;  // Set failure flag
          _errorMessage = response.message;
          _isLoading = false;  // Stop loading
        });
      }
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;  // Stop loading
      });
    } finally {
      // Show the Lottie animation for 3 seconds and then navigate back
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()  // Show a loading indicator while waiting for the response
            : _isSuccess
                ? Lottie.asset('assets/json/success.json')  // Success Lottie file
                : Lottie.asset('assets/json/error.json'),  // Error Lottie file
      ),
    );
  }
}
