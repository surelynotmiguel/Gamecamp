import 'dart:async';
import 'package:gamecamp/model/game.dart';
import 'package:firebase_database/firebase_database.dart';

class GameProvider {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<List<Game>> fetchGames(
      {bool? online, bool? promo, double? maxPrice}) async {
    final ref = _database.ref('games');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> gamesData = snapshot.value as Map<dynamic, dynamic>;

      return gamesData.entries.map((entry) {
        return Game(
          id: entry.key,
          name: entry.value['name'],
          price: (entry.value['price'] as num).toDouble(),
          releaseDate: DateTime.parse(entry.value['releaseDate']),
          isOnline: entry.value['isOnline'],
          promotionalPrice: entry.value['promotionalPrice'] != null
              ? (entry.value['promotionalPrice'] as num).toDouble()
              : null,
          brand: entry.value['brand'],
          style: entry.value['style'],
          imageUrl: entry.value['imageUrl'],
        );
      }).where((game) {
        if (online != null && game.isOnline != online) return false;
        if (promo != null && (game.promotionalPrice == null) != promo)
          return false;
        if (maxPrice != null && game.price > maxPrice) return false;
        return true;
      }).toList();
    }

    return [];
  }
}
