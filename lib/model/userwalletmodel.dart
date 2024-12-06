class UserWalletBalanceModel {
  final int status;
  final String message;
  final num balance;

  UserWalletBalanceModel({
    required this.status,
    required this.message,
    required this.balance,
  });

  factory UserWalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return UserWalletBalanceModel(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      balance: json['result']?['balance'] ?? 0, // Access the nested result object
    );
  }
}
