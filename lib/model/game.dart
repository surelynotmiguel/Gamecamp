class Game {
  final String id;
  final String name;
  final double price;
  final DateTime releaseDate;
  final bool isOnline;
  final double? promotionalPrice;
  final String brand;
  final String style;
  final String imageUrl;

  Game({
    required this.id,
    required this.name,
    required this.price,
    required this.releaseDate,
    required this.isOnline,
    this.promotionalPrice,
    required this.brand,
    required this.style,
    required this.imageUrl,
  });

  // Método para converter JSON para um Game
  factory Game.fromJson(String id, Map<String, dynamic> json) {
    return Game(
      id: id,
      name: json['name'],
      price: json['price'],
      releaseDate: DateTime.parse(json['releaseDate']),
      isOnline: json['isOnline'],
      promotionalPrice: json['promotionalPrice'],
      brand: json['brand'],
      style: json['style'],
      imageUrl: json['imageUrl'],
    );
  }

  // Método para converter um Game para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'releaseDate': releaseDate.toIso8601String(),
      'isOnline': isOnline,
      'promotionalPrice': promotionalPrice,
      'brand': brand,
      'style': style,
      'imageUrl': imageUrl,
    };
  }

  factory Game.fromMap(Map<dynamic, dynamic> map) {
    return Game(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      releaseDate: DateTime.parse(map['releaseDate']),
      isOnline: map['isOnline'],
      promotionalPrice: (map['promotionalPrice'] as num).toDouble(),
      brand: map['brand'],
      style: map['style'],
      imageUrl: map['imageUrl'],
    );
  }
}
