import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/provider/userwallectProvider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletHistodyScreen extends StatefulWidget {
  const WalletHistodyScreen({Key? key}) : super(key: key);

  @override
  State<WalletHistodyScreen> createState() => _WalletHistodyScreenState();
}

class _WalletHistodyScreenState extends State<WalletHistodyScreen> {
  late WalletProvider walletProvider;
  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    walletProvider.fetchWalletHistory('${Constant.userID}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.myAppBarWithBack(context, "wallet_history", true),
      body: Consumer<WalletProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // Wallet Balance Section
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                margin: EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 10),
                    Image.asset(
                      'assets/images/wallet.png',
                      width: 50,
                      height: 50,
                      color: white,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Wallet Balance',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              color: whiteLight),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${homeProvider.userWalletBalanceModel?.balance} Coins',
                          style: TextStyle(
                              fontSize: 27,
                              color: colorPrimary,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Wallet History Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Wallet History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: white,
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Wallet Transactions List
              Expanded(
                child: ListView.builder(
                  itemCount: provider.walletHistory.length,
                  itemBuilder: (context, index) {
                    final transaction = provider.walletHistory[index];
                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              // Transaction Name and Source
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      transaction.name.isNotEmpty
                                          ? transaction.name
                                          : transaction
                                              .tokenFrom, // Fallback to tokenFrom if name is empty
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: white,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      transaction.tokenFrom,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Transaction Tokens and Date
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${transaction.noOfTokens}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: transaction.tokenType == 'credit'
                                            ? Colors.green
                                            : Colors.red),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    transaction.date,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
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
          );
        },
      ),
    );
  }
}
