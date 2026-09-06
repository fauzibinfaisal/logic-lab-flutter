import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logic_lab/sections/footer_section.dart';
import 'package:logic_lab/visit_counter/data/visit_counter_api.dart';
import 'package:logic_lab/visit_counter/widgets/visit_count_badge.dart';

void main() {
  test('visit counter sends only a fixed scope and maps aggregate counts',
      () async {
    late Map<String, dynamic> submitted;
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/visits');
      submitted = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'counts': {
            'site': 1204,
            'qibla': 82,
            'number-adventure': 315,
            'memory-quest': 144,
          },
        }),
        200,
      );
    });
    final api = VisitCounterApi(
      baseUrl: 'https://leaderboard.example.test',
      client: client,
    );

    final counts = await api.recordVisit(VisitScope.numberAdventure);

    expect(submitted, {'scope': 'number-adventure'});
    expect(submitted.containsKey('location'), isFalse);
    expect(submitted.containsKey('visitorId'), isFalse);
    expect(counts[VisitScope.site], 1204);
    expect(counts[VisitScope.numberAdventure], 315);
  });

  test('visit counter rejects unknown scopes before making a request',
      () async {
    var requested = false;
    final api = VisitCounterApi(
      baseUrl: 'https://leaderboard.example.test',
      client: MockClient((_) async {
        requested = true;
        return http.Response('{}', 200);
      }),
    );

    await expectLater(
      api.recordVisit('unknown-app'),
      throwsA(isA<VisitCounterApiException>()),
    );
    expect(requested, isFalse);
  });

  testWidgets('footer presents the aggregate site visit count', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: const Scaffold(
          body: FooterSection(siteVisitCount: 1204),
        ),
      ),
    );

    expect(find.text('1,204 visits'), findsOneWidget);
  });

  test('visit labels use correct singular and plural forms', () {
    expect(formatVisitLabel(1), '1 visit');
    expect(formatVisitLabel(2), '2 visits');
  });
}
