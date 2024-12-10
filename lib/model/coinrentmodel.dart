class PurchaseFromCoinResponse {
  final int status;
  final String message;
  final int balance;

  PurchaseFromCoinResponse({
    required this.status,
    required this.message,
    required this.balance,
  });

  factory PurchaseFromCoinResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseFromCoinResponse(
      status: json['status'],
      message: json['message'],
      balance: json['result']['balance'],
    );
  }
}
