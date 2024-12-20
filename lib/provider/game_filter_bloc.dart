import 'dart:async';

class GameFilterBloc {
  final _filtersController = StreamController<Map<String, dynamic>>.broadcast();
  final Map<String, dynamic> _filters = {
    'online': false,
    'promo': false,
    'maxPrice': 500.0,
    'brand': null,
    'isNew': false, // Novo filtro de jogos lançados recentemente
  };

  Stream<Map<String, dynamic>> get filtersStream => _filtersController.stream;

  void updateFilters({
    bool? online,
    bool? promo,
    double? maxPrice,
    String? brand,
    bool? isNew, // Novo parâmetro
  }) {
    if (online != null) _filters['online'] = online;
    if (promo != null) _filters['promo'] = promo;
    if (maxPrice != null) _filters['maxPrice'] = maxPrice;
    if (brand != null) {
      // Se a marca não for nula, adiciona o filtro de marca
      _filters['brand'] = brand;
    } else {
      // Se for nula, remove o filtro de marca
      _filters.remove('brand');
    }
    if (isNew != null) _filters['isNew'] = isNew;

    _filtersController.add(_filters); // Notifique os ouvintes sobre as mudanças
  }

  // Método para verificar se o jogo é novo (lançado nos últimos 30 dias)
  bool isGameNew(DateTime releaseDate) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return releaseDate.isAfter(thirtyDaysAgo);
  }

  void dispose() {
    _filtersController.close();
  }
}
