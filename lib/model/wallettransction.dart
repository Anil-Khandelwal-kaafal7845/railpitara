class WalletTransaction {
  final String name;
  final String tokenType;
  final String tokenFrom;
  final int noOfTokens;
  final String date;

  WalletTransaction({
    required this.name,
    required this.tokenType,
    required this.tokenFrom,
    required this.noOfTokens,
    required this.date,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      name: json['name'],
      tokenType: json['token_type'],
      tokenFrom: json['token_from'],
      noOfTokens: json['no_of_token'],
      date: json['date'],
    );
  }
}
