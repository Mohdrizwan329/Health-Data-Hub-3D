import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/models.dart';

/// Loads the bundled sample data.
///
/// Decoding happens once per app launch; the parsed [HubData] is then cached by
/// the repository, so screens never re-read the bundle while scrolling.
class HubLocalSource {
  const HubLocalSource({this.assetPath = 'assets/data/hub_data.json'});

  final String assetPath;

  Future<HubData> load() async {
    final raw = await rootBundle.loadString(assetPath);
    return HubData.fromJson(json.decode(raw) as Map<String, dynamic>);
  }
}
