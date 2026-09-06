import 'package:logic_lab/visit_counter/data/visit_counter_api.dart';

class VisitCounterRepository {
  final VisitCounterApi _api;

  VisitCounterRepository({VisitCounterApi? api})
      : _api = api ?? VisitCounterApi();

  bool get isConfigured => _api.isConfigured;

  Future<VisitCounts> recordVisit(String scope) => _api.recordVisit(scope);

  Future<VisitCounts> fetchCounts() => _api.fetchCounts();

  void dispose() => _api.close();
}
