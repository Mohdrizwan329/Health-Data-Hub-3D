import 'dart:convert';
import 'dart:io';

import 'package:healthdatahub/data/models/models.dart';

/// Reads the shipped sample data straight from disk.
///
/// Widget tests cannot rely on `rootBundle` — after the first test in a file it
/// no longer resolves inside the fake-async zone — so tests inject this instead
/// of exercising the asset bundle.
HubData loadHubFixture() {
  final raw = File('assets/data/hub_data.json').readAsStringSync();
  return HubData.fromJson(json.decode(raw) as Map<String, dynamic>);
}
