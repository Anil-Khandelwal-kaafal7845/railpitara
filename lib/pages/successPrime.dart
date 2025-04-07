import 'package:dtlive/pages/bottom_bar.dart';
import 'package:dtlive/provider/paymentprovider.dart';
import 'package:dtlive/provider/userwallectProvider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class TransactionStatusScreen extends StatefulWidget {
  final String userId;

  final String noOfToken;
  final String packageId;
  final String amount;

  TransactionStatusScreen({
    required this.userId,
    required this.noOfToken,
    required this.packageId,
    required this.amount,
  });

  @override
  _TransactionStatusScreenState createState() =>
      _TransactionStatusScreenState();
}

class _TransactionStatusScreenState extends State<TransactionStatusScreen> {
  late WalletProvider walletProvider;
  late PaymentProvider paymentProvider;
  bool _isLoading = true;
  bool _isSuccess = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    _makeApiCall();
  }

  Future<void> _makeApiCall() async {
    try {
      await paymentProvider.addTransaction(
        widget.packageId,
        '',
        widget.amount,
        '',
        '',
        '',
        '',
        '',
        'Coin',
      );

      setState(() {
        _isSuccess = paymentProvider.successModel.status == 200;
        _errorMessage =
            paymentProvider.successModel.message ?? 'Transaction failed';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    } finally {
     Future.delayed(Duration(seconds: 2), () {
  if (mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Bottombar()),
      (Route<dynamic> route) => false, // This removes all previous routes
    );
  }
});

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Center(
        child: _isLoading
            ? _buildLoadingUI()
            : _isSuccess
                ? _buildSuccessUI()
                : _buildErrorUI(),
      ),
    );
  }

  Widget _buildLoadingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text('Processing your transaction...', style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildSuccessUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/json/success.json', width: 150, height: 150),
        SizedBox(height: 20),
        Text('Transaction Successful',
            style: TextStyle(fontSize: 20, color: Colors.green)),
        SizedBox(height: 20),
      
      ],
    );
  }

  Widget _buildErrorUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/json/error.json', width: 150, height: 150),
        SizedBox(height: 20),
        Text(
          _errorMessage,
          style: TextStyle(color: Colors.red, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Go Back'),
        ),
      ],
    );
  }
}
