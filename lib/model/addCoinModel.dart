class AddCoinResponseModel {
  final String message;
  final int statusCode;

  AddCoinResponseModel({required this.message, required this.statusCode});

  factory AddCoinResponseModel.fromJson(Map<String, dynamic> json) {
    return AddCoinResponseModel(
      message: json['message'] ?? '',
      statusCode: json['status_code'] ?? 0,
    );
  }
}
