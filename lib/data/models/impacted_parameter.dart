import 'package:flutter/foundation.dart';

/// An expandable "parameters generally impacted by …" row on a score detail.
@immutable
class ImpactedParameter {
  const ImpactedParameter({required this.title, required this.description});

  final String title;
  final String description;

  factory ImpactedParameter.fromJson(Map<String, dynamic> json) =>
      ImpactedParameter(
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
      );
}
