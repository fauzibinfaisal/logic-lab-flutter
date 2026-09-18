import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logic_lab/mini_apps/ble_packet_lab/logic/ble_packet_decoder.dart';
import 'package:logic_lab/visit_counter/widgets/visit_count_badge.dart';

const _background = Color(0xFF070B17);
const _surface = Color(0xFF10182A);
const _surfaceHigh = Color(0xFF17223A);
const _outline = Color(0xFF2A3859);
const _accent = Color(0xFF8B9DFF);
const _cyan = Color(0xFF63E6FF);
const _green = Color(0xFF70E7B1);

class BlePacketLabPage extends StatefulWidget {
  final int? visitCount;
  final bool visitCountLoading;
  final VoidCallback? onExit;

  const BlePacketLabPage({
    super.key,
    this.visitCount,
    this.visitCountLoading = false,
    this.onExit,
  });

  @override
  State<BlePacketLabPage> createState() => _BlePacketLabPageState();
}

class _BlePacketLabPageState extends State<BlePacketLabPage> {
  static const _defaultPacket = '01 10 27 6C 09 A5';
  static const _samples = [
    ('Sensor frame', '01 10 27 6C 09 A5'),
    ('Heart rate text', '48 52 3A 37 32'),
    ('Battery service', '64'),
    ('Float value', '00 00 48 41'),
  ];

  late final TextEditingController _controller;
  PacketEndian _endian = PacketEndian.little;
  PacketCodeLanguage _language = PacketCodeLanguage.dart;
  late DecodedBlePacket _packet;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _defaultPacket);
    _packet = BlePacketDecoder.decode(_defaultPacket, endian: _endian);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _decode() {
    try {
      final packet = BlePacketDecoder.decode(
        _controller.text,
        endian: _endian,
      );
      setState(() {
        _packet = packet;
        _error = null;
      });
    } on FormatException catch (error) {
      setState(() => _error = error.message.toString());
    }
  }

  void _useSample(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    _decode();
  }

  void _changeEndian(PacketEndian endian) {
    if (_endian == endian) return;
    _endian = endian;
    _decode();
  }

  Future<void> _copySnippet() async {
    final snippet = BlePacketCodeGenerator.generate(_packet, _language);
    await Clipboard.setData(ClipboardData(text: snippet));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_language.label} snippet copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 980;
    final horizontalPadding = width >= 720 ? 48.0 : 20.0;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _PacketLabTopBar(
                visitCount: widget.visitCount,
                visitCountLoading: widget.visitCountLoading,
                onBack: widget.onExit ?? () => Navigator.of(context).pop(),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isWide ? 48 : 32,
                horizontalPadding,
                64,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _PacketLabHero(),
                        SizedBox(height: isWide ? 36 : 26),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 390,
                                child: _buildEditor(),
                              ),
                              const SizedBox(width: 22),
                              Expanded(child: _buildResults()),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildEditor(),
                              const SizedBox(height: 20),
                              _buildResults(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    final tt = Theme.of(context).textTheme;

    return _LabPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.bluetooth_searching_rounded,
            title: 'Packet input',
            subtitle: 'Paste raw HEX bytes from a BLE characteristic.',
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 7,
            onChanged: (_) => _decode(),
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 15,
              height: 1.5,
            ),
            decoration: InputDecoration(
              labelText: 'HEX payload',
              hintText: '01 10 27 6C 09 A5',
              alignLabelWithHint: true,
              helperText:
                  'Spaces, commas, colons and 0x prefixes are accepted.',
              helperMaxLines: 2,
              errorText: _error,
              errorMaxLines: 3,
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _accent, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Byte order',
            style: tt.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<PacketEndian>(
              segments: const [
                ButtonSegment(
                  value: PacketEndian.little,
                  label: Text('Little'),
                  icon: Icon(Icons.first_page_rounded),
                ),
                ButtonSegment(
                  value: PacketEndian.big,
                  label: Text('Big'),
                  icon: Icon(Icons.last_page_rounded),
                ),
              ],
              selected: {_endian},
              onSelectionChanged: (selection) => _changeEndian(selection.first),
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Quick samples',
            style: tt.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final sample in _samples)
                ActionChip(
                  avatar: const Icon(Icons.bolt_rounded, size: 16),
                  label: Text(sample.$1),
                  onPressed: () => _useSample(sample.$2),
                  backgroundColor: _surfaceHigh,
                  side: const BorderSide(color: _outline),
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _green.withValues(alpha: 0.2)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline_rounded, color: _green, size: 19),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Everything is decoded locally in your browser. Packet data is never uploaded.',
                    style: TextStyle(
                      color: Colors.white60,
                      height: 1.45,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_error != null) {
      return const _LabPanel(
        child: _EmptyResult(),
      );
    }

    return Column(
      children: [
        _SummarySection(packet: _packet),
        const SizedBox(height: 20),
        _InterpretationSection(packet: _packet),
        const SizedBox(height: 20),
        _ByteInspector(packet: _packet),
        const SizedBox(height: 20),
        _buildCodeSection(),
      ],
    );
  }

  Widget _buildCodeSection() {
    final snippet = BlePacketCodeGenerator.generate(_packet, _language);

    return _LabPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.code_rounded,
            title: 'Code starter',
            subtitle: 'Take the parsed bytes into your mobile project.',
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final language in PacketCodeLanguage.values)
                ChoiceChip(
                  label: Text(language.label),
                  selected: language == _language,
                  onSelected: (_) => setState(() => _language = language),
                  selectedColor: _accent.withValues(alpha: 0.24),
                  side: BorderSide(
                    color: language == _language ? _accent : _outline,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF070B12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _outline),
            ),
            child: SelectableText(
              snippet,
              style: const TextStyle(
                color: Color(0xFFD7E1FF),
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _copySnippet,
              icon: const Icon(Icons.copy_rounded, size: 17),
              label: const Text('Copy snippet'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PacketLabTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final int? visitCount;
  final bool visitCountLoading;

  const _PacketLabTopBar({
    required this.onBack,
    required this.visitCount,
    required this.visitCountLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _background.withValues(alpha: 0.97),
        border: const Border(bottom: BorderSide(color: _outline)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back to Mini Apps',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 6),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.bluetooth_rounded, color: _accent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'BLE PACKET LAB',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          VisitCountBadge(
            count: visitCount,
            loading: visitCountLoading,
            color: _accent,
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _PacketLabHero extends StatelessWidget {
  const _PacketLabHero();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: _accent.withValues(alpha: 0.28)),
            ),
            child: const Text(
              'DEVELOPER TOOL · LOCAL FIRST',
              style: TextStyle(
                color: _accent,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Decode BLE packets without leaving the browser.',
            style: tt.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Inspect bytes, switch endianness, reveal common values, and generate a clean parsing starter for Dart, Swift, or Kotlin.',
            style: tt.bodyLarge?.copyWith(color: Colors.white60, height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final DecodedBlePacket packet;

  const _SummarySection({required this.packet});

  @override
  Widget build(BuildContext context) {
    return _LabPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.analytics_outlined,
            title: 'Packet overview',
            subtitle: 'A quick health check for the current payload.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth >= 620
                  ? (constraints.maxWidth - 30) / 4
                  : (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MetricCard(
                    width: cardWidth,
                    label: 'Bytes',
                    value: '${packet.byteCount}',
                  ),
                  _MetricCard(
                    width: cardWidth,
                    label: 'Bits',
                    value: '${packet.bitCount}',
                  ),
                  _MetricCard(
                    width: cardWidth,
                    label: 'Checksum',
                    value: '0x${DecodedBlePacket.hexByte(packet.checksum)}',
                  ),
                  _MetricCard(
                    width: cardWidth,
                    label: 'Order',
                    value: packet.endian == PacketEndian.little ? 'LE' : 'BE',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: SelectableText(
              packet.normalizedHex,
              style: const TextStyle(
                color: _cyan,
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterpretationSection extends StatelessWidget {
  final DecodedBlePacket packet;

  const _InterpretationSection({required this.packet});

  String _floatLabel(double? value) {
    if (value == null) return 'Needs 4 bytes';
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value.isNegative ? '-Infinity' : 'Infinity';
    return value.toStringAsPrecision(7);
  }

  String _compactInteger(BigInt value) {
    final text = value.toString();
    if (text.length <= 42) return text;
    final negativeOffset = text.startsWith('-') ? 1 : 0;
    final start = text.substring(0, 20 + negativeOffset);
    final end = text.substring(text.length - 12);
    return '$start…$end (${text.length - negativeOffset} digits)';
  }

  @override
  Widget build(BuildContext context) {
    final values = [
      ('UInt16 · first 2 bytes', packet.uint16?.toString() ?? 'Needs 2 bytes'),
      ('Int16 · first 2 bytes', packet.int16?.toString() ?? 'Needs 2 bytes'),
      ('UInt32 · first 4 bytes', packet.uint32?.toString() ?? 'Needs 4 bytes'),
      ('Int32 · first 4 bytes', packet.int32?.toString() ?? 'Needs 4 bytes'),
      ('Float32 · first 4 bytes', _floatLabel(packet.float32)),
      ('Unsigned · all bytes', _compactInteger(packet.unsignedInteger)),
      ('Signed · all bytes', _compactInteger(packet.signedInteger)),
      ('ASCII preview', packet.ascii),
      ('UTF-8 preview', packet.utf8Text),
    ];

    return _LabPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            icon: Icons.data_object_rounded,
            title: 'Interpretations',
            subtitle: '${packet.endian.label} · values start at offset 0.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 620
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final value in values)
                    _ValueCard(
                      width: width,
                      label: value.$1,
                      value: value.$2,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ByteInspector extends StatelessWidget {
  static const _visibleByteLimit = 64;

  final DecodedBlePacket packet;

  const _ByteInspector({required this.packet});

  @override
  Widget build(BuildContext context) {
    final visibleCount = packet.byteCount.clamp(0, _visibleByteLimit);

    return _LabPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.grid_view_rounded,
            title: 'Byte inspector',
            subtitle: 'Offset, HEX, unsigned, signed, binary, and ASCII.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 620 ? 4 : 2;
              final spacing = 10.0;
              final cellWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (var index = 0; index < visibleCount; index++)
                    _ByteCell(
                      width: cellWidth,
                      index: index,
                      hex: packet.hexAt(index),
                      unsigned: packet.bytes[index],
                      signed: packet.signedAt(index),
                      binary: packet.binaryAt(index),
                      ascii: packet.asciiAt(index),
                    ),
                ],
              );
            },
          ),
          if (packet.byteCount > _visibleByteLimit) ...[
            const SizedBox(height: 14),
            Text(
              'Showing the first $_visibleByteLimit of ${packet.byteCount} bytes.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white54),
            ),
          ],
        ],
      ),
    );
  }
}

class _LabPanel extends StatelessWidget {
  final Widget child;

  const _LabPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_surfaceHigh, _surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _outline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PanelTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tt.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: tt.bodySmall?.copyWith(
                  color: Colors.white54,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final double width;
  final String label;
  final String value;

  const _MetricCard({
    required this.width,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.white38),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _cyan,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
          ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final double width;
  final String label;
  final String value;

  const _ValueCard({
    required this.width,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.white38),
          ),
          const SizedBox(height: 7),
          SelectableText(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ByteCell extends StatelessWidget {
  final double width;
  final int index;
  final String hex;
  final int unsigned;
  final int signed;
  final String binary;
  final String ascii;

  const _ByteCell({
    required this.width,
    required this.index,
    required this.hex,
    required this.unsigned,
    required this.signed,
    required this.binary,
    required this.ascii,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '0x${index.toRadixString(16).padLeft(2, '0').toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white38,
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                ascii,
                style:
                    const TextStyle(color: _green, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hex,
            style: const TextStyle(
              color: _cyan,
              fontFamily: 'monospace',
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            binary,
            style: const TextStyle(
              color: Colors.white60,
              fontFamily: 'monospace',
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'u $unsigned  ·  s $signed',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 54),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.data_array_rounded, color: _accent, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            'Waiting for a valid packet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 7),
          Text(
            'Fix the HEX input and the decoded values will update instantly.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white54, height: 1.45),
          ),
        ],
      ),
    );
  }
}
