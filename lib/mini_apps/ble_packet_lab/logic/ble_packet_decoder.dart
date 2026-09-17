import 'dart:convert';
import 'dart:typed_data';

enum PacketEndian { little, big }

extension PacketEndianLabel on PacketEndian {
  String get label =>
      this == PacketEndian.little ? 'Little endian' : 'Big endian';

  Endian get dartEndian =>
      this == PacketEndian.little ? Endian.little : Endian.big;
}

class BlePacketDecoder {
  static const maxBytes = 256;

  const BlePacketDecoder._();

  static DecodedBlePacket decode(
    String input, {
    PacketEndian endian = PacketEndian.little,
  }) {
    final compact = input
        .replaceAll(RegExp(r'0[xX]'), '')
        .replaceAll(RegExp(r'[\s,:;\-\[\](){}_]'), '');

    if (compact.isEmpty) {
      throw const FormatException('Enter at least one hexadecimal byte.');
    }
    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(compact)) {
      throw const FormatException(
        'Packet contains non-hex characters. Use digits 0–9 and letters A–F.',
      );
    }
    if (compact.length.isOdd) {
      throw const FormatException(
        'Every byte needs two hex characters. Add a leading zero if needed.',
      );
    }

    final byteCount = compact.length ~/ 2;
    if (byteCount > maxBytes) {
      throw const FormatException('Packet is limited to 256 bytes.');
    }

    final bytes = List<int>.generate(
      byteCount,
      (index) => int.parse(
        compact.substring(index * 2, index * 2 + 2),
        radix: 16,
      ),
      growable: false,
    );
    return DecodedBlePacket(bytes: bytes, endian: endian);
  }
}

class DecodedBlePacket {
  final List<int> bytes;
  final PacketEndian endian;

  DecodedBlePacket({required List<int> bytes, required this.endian})
      : bytes = List.unmodifiable(bytes);

  int get byteCount => bytes.length;
  int get bitCount => byteCount * 8;
  int get checksum => bytes.fold(0, (total, byte) => (total + byte) & 0xFF);

  String get normalizedHex => bytes.map(hexByte).join(' ');

  String get ascii => bytes
      .map(
          (byte) => byte >= 32 && byte <= 126 ? String.fromCharCode(byte) : '·')
      .join();

  String get utf8Text {
    final decoded = utf8.decode(bytes, allowMalformed: true).trim();
    return decoded.isEmpty ? 'No readable UTF-8 text' : decoded;
  }

  BigInt get unsignedInteger {
    var value = BigInt.zero;
    final ordered = endian == PacketEndian.big ? bytes : bytes.reversed;
    for (final byte in ordered) {
      value = (value << 8) | BigInt.from(byte);
    }
    return value;
  }

  BigInt get signedInteger {
    final unsigned = unsignedInteger;
    final signByte = endian == PacketEndian.big ? bytes.first : bytes.last;
    if (signByte & 0x80 == 0) return unsigned;
    return unsigned - (BigInt.one << bitCount);
  }

  int? get uint16 =>
      byteCount >= 2 ? _data.getUint16(0, endian.dartEndian) : null;

  int? get int16 =>
      byteCount >= 2 ? _data.getInt16(0, endian.dartEndian) : null;

  int? get uint32 =>
      byteCount >= 4 ? _data.getUint32(0, endian.dartEndian) : null;

  int? get int32 =>
      byteCount >= 4 ? _data.getInt32(0, endian.dartEndian) : null;

  double? get float32 =>
      byteCount >= 4 ? _data.getFloat32(0, endian.dartEndian) : null;

  ByteData get _data => ByteData.sublistView(Uint8List.fromList(bytes));

  String hexAt(int index) => hexByte(bytes[index]);

  String binaryAt(int index) => bytes[index].toRadixString(2).padLeft(8, '0');

  int signedAt(int index) =>
      bytes[index] >= 128 ? bytes[index] - 256 : bytes[index];

  String asciiAt(int index) {
    final byte = bytes[index];
    return byte >= 32 && byte <= 126 ? String.fromCharCode(byte) : '·';
  }

  static String hexByte(int value) =>
      value.toRadixString(16).padLeft(2, '0').toUpperCase();
}

enum PacketCodeLanguage { dart, swift, kotlin }

extension PacketCodeLanguageLabel on PacketCodeLanguage {
  String get label => switch (this) {
        PacketCodeLanguage.dart => 'Dart',
        PacketCodeLanguage.swift => 'Swift',
        PacketCodeLanguage.kotlin => 'Kotlin',
      };
}

class BlePacketCodeGenerator {
  const BlePacketCodeGenerator._();

  static String generate(
    DecodedBlePacket packet,
    PacketCodeLanguage language,
  ) {
    final values = packet.bytes
        .map((byte) => '0x${DecodedBlePacket.hexByte(byte)}')
        .join(', ');
    final little = packet.endian == PacketEndian.little;

    return switch (language) {
      PacketCodeLanguage.dart => '''import 'dart:typed_data';

final packet = Uint8List.fromList([$values]);
final data = ByteData.sublistView(packet);
${packet.byteCount >= 2 ? "final value = data.getUint16(0, Endian.${little ? 'little' : 'big'});" : 'final value = packet.first;'}''',
      PacketCodeLanguage.swift => '''let packet: [UInt8] = [$values]
${packet.byteCount >= 2 ? '''let value = ${little ? '' : 'UInt16(packet[0]) << 8 | '}${little ? 'UInt16(packet[0]) | UInt16(packet[1]) << 8' : 'UInt16(packet[1])'}''' : 'let value = packet[0]'}''',
      PacketCodeLanguage.kotlin => '''val packet = byteArrayOf(
    ${packet.bytes.map((byte) => '0x${DecodedBlePacket.hexByte(byte)}.toByte()').join(', ')}
)
${packet.byteCount >= 2 ? '''val value = ${little ? '(packet[0].toInt() and 0xFF) or\n    ((packet[1].toInt() and 0xFF) shl 8)' : '((packet[0].toInt() and 0xFF) shl 8) or\n    (packet[1].toInt() and 0xFF)'}''' : 'val value = packet[0].toInt() and 0xFF'}''',
    };
  }
}
