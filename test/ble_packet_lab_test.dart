import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_lab/mini_apps/ble_packet_lab/ble_packet_lab_page.dart';
import 'package:logic_lab/mini_apps/ble_packet_lab/logic/ble_packet_decoder.dart';

void main() {
  group('BLE packet decoder', () {
    test('accepts common HEX separators and prefixes', () {
      final packet = BlePacketDecoder.decode('0x01, 0x10:27-A5');

      expect(packet.bytes, [0x01, 0x10, 0x27, 0xA5]);
      expect(packet.normalizedHex, '01 10 27 A5');
      expect(packet.byteCount, 4);
      expect(packet.bitCount, 32);
      expect(packet.checksum, 0xDD);
    });

    test('switches multi-byte interpretations with endianness', () {
      final little = BlePacketDecoder.decode(
        '34 12 00 00',
        endian: PacketEndian.little,
      );
      final big = BlePacketDecoder.decode(
        '34 12 00 00',
        endian: PacketEndian.big,
      );

      expect(little.uint16, 0x1234);
      expect(big.uint16, 0x3412);
      expect(little.uint32, 0x1234);
      expect(big.uint32, 0x34120000);
    });

    test('decodes signed, floating point, and text values', () {
      final signed = BlePacketDecoder.decode('FF FE');
      final floating = BlePacketDecoder.decode('00 00 48 41');
      final text = BlePacketDecoder.decode('48 52 3A 37 32');

      expect(signed.int16, -257);
      expect(floating.float32, closeTo(12.5, 0.001));
      expect(text.ascii, 'HR:72');
      expect(text.utf8Text, 'HR:72');
    });

    test('rejects malformed and oversized packets', () {
      expect(() => BlePacketDecoder.decode('0G'), throwsFormatException);
      expect(() => BlePacketDecoder.decode('ABC'), throwsFormatException);
      expect(
        () => BlePacketDecoder.decode(List.filled(257, 'AA').join(' ')),
        throwsFormatException,
      );
    });

    test('generates starters for all supported mobile languages', () {
      final packet = BlePacketDecoder.decode('34 12');

      expect(
        BlePacketCodeGenerator.generate(packet, PacketCodeLanguage.dart),
        contains('getUint16'),
      );
      expect(
        BlePacketCodeGenerator.generate(packet, PacketCodeLanguage.swift),
        contains('[UInt8]'),
      );
      expect(
        BlePacketCodeGenerator.generate(packet, PacketCodeLanguage.kotlin),
        contains('byteArrayOf'),
      );
    });
  });

  testWidgets('BLE Packet Lab stays usable on a small phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: const BlePacketLabPage(visitCount: 96),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BLE PACKET LAB'), findsOneWidget);
    expect(find.text('96 visits'), findsOneWidget);
    expect(find.text('Packet input'), findsOneWidget);
    expect(find.text('Packet overview'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField), 'GG');
    await tester.pump();
    expect(find.textContaining('non-hex characters'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '34 12');
    await tester.pump();
    expect(find.text('4660'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
