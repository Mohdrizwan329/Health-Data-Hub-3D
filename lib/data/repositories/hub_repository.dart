import '../models/models.dart';
import '../sources/hub_local_source.dart';

/// Single entry point the UI uses to reach hub data.
///
/// Swapping [HubLocalSource] for a network client later would not touch any
/// widget, since screens only ever depend on this repository.
class HubRepository {
  HubRepository({HubLocalSource? source})
    : _source = source ?? const HubLocalSource();

  final HubLocalSource _source;
  Future<HubData>? _inFlight;

  /// Returns the cached snapshot, loading it on first call.
  Future<HubData> fetch() => _inFlight ??= _source.load();
}
