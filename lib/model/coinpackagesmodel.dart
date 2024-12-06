// models/coin_package_model.dart
class CoinPackage {
  final int id;
  final String name;
  final int price;
  final int noOfCoins;

  CoinPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.noOfCoins,
  });

  // Factory method to convert JSON data into CoinPackage object
  factory CoinPackage.fromJson(Map<String, dynamic> json) {
    return CoinPackage(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      noOfCoins: json['no_of_coin'],
    );
  }

  // Method to convert CoinPackage object back to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'no_of_coin': noOfCoins,
    };
  }
}
