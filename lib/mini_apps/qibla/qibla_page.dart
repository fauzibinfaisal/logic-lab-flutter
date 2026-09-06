import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logic_lab/mini_apps/qibla/heading/heading_provider.dart';
import 'package:logic_lab/mini_apps/qibla/qibla_calculator.dart';
import 'package:logic_lab/visit_counter/widgets/visit_count_badge.dart';

enum _LocationStatus { idle, loading, ready, permissionDenied, unavailable }

enum _HeadingStatus { idle, waiting, available, unsupported }

class QiblaPage extends StatefulWidget {
  final int? visitCount;
  final bool visitCountLoading;

  const QiblaPage({
    super.key,
    this.visitCount,
    this.visitCountLoading = false,
  });

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  late final HeadingProvider _headingProvider;
  StreamSubscription<double>? _headingSubscription;
  Timer? _headingTimeout;

  _LocationStatus _locationStatus = _LocationStatus.idle;
  _HeadingStatus _headingStatus = _HeadingStatus.idle;
  Position? _position;
  double? _qiblaBearing;
  double _heading = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _headingProvider = createHeadingProvider();
    _headingSubscription = _headingProvider.headings.listen((heading) {
      if (!mounted) return;
      _headingTimeout?.cancel();
      setState(() {
        _heading = heading;
        _headingStatus = _HeadingStatus.available;
      });
    });
  }

  @override
  void dispose() {
    _headingTimeout?.cancel();
    _headingSubscription?.cancel();
    _headingProvider.dispose();
    super.dispose();
  }

  Future<void> _activateQibla() async {
    if (_locationStatus == _LocationStatus.loading) return;

    setState(() {
      _locationStatus = _LocationStatus.loading;
      _headingStatus = _HeadingStatus.waiting;
      _errorMessage = null;
    });

    unawaited(_startHeading());

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationError(
          _LocationStatus.unavailable,
          'Location services are turned off. Enable location and try again.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setLocationError(
          _LocationStatus.permissionDenied,
          permission == LocationPermission.deniedForever
              ? 'Location access is blocked. Allow it in your browser or device settings, then retry.'
              : 'Location permission is needed to calculate the Qibla from where you are.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final bearing = QiblaCalculator.bearingFrom(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;
      setState(() {
        _position = position;
        _qiblaBearing = bearing;
        _locationStatus = _LocationStatus.ready;
      });
    } on TimeoutException {
      _setLocationError(
        _LocationStatus.unavailable,
        'Location is taking too long. Move to an open area and try again.',
      );
    } catch (_) {
      _setLocationError(
        _LocationStatus.unavailable,
        'Your location is currently unavailable. Check your connection and location settings.',
      );
    }
  }

  Future<void> _startHeading() async {
    final started = await _headingProvider.start();
    if (!mounted) return;

    if (!started) {
      setState(() => _headingStatus = _HeadingStatus.unsupported);
      return;
    }

    _headingTimeout?.cancel();
    _headingTimeout = Timer(const Duration(seconds: 4), () {
      if (mounted && _headingStatus == _HeadingStatus.waiting) {
        setState(() => _headingStatus = _HeadingStatus.unsupported);
      }
    });
  }

  void _setLocationError(_LocationStatus status, String message) {
    if (!mounted) return;
    setState(() {
      _locationStatus = status;
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 920;

    return Scaffold(
      backgroundColor: const Color(0xFF071019),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _QiblaTopBar(
                onBack: _goBack,
                visitCount: widget.visitCount,
                visitCountLoading: widget.visitCountLoading,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                width >= 720 ? 48 : 20,
                32,
                width >= 720 ? 48 : 20,
                56,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _QiblaHero(),
                        SizedBox(height: isWide ? 40 : 28),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: _buildCompassPanel()),
                              const SizedBox(width: 24),
                              Expanded(flex: 4, child: _buildInfoPanel()),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildCompassPanel(),
                              const SizedBox(height: 18),
                              _buildInfoPanel(),
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

  Widget _buildCompassPanel() {
    final isReady = _locationStatus == _LocationStatus.ready;
    final qiblaBearing = _qiblaBearing ?? 0;
    final hasHeading = _headingStatus == _HeadingStatus.available;

    return _GlassPanel(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusPill(
                label: isReady ? 'QIBLA READY' : 'AWAITING LOCATION',
                color:
                    isReady ? const Color(0xFF6EE7B7) : const Color(0xFFFFC857),
              ),
              IconButton(
                tooltip: 'Refresh location',
                onPressed: _locationStatus == _LocationStatus.loading
                    ? null
                    : _activateQibla,
                icon: const Icon(Icons.refresh_rounded),
                color: Colors.white70,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final size = math.min(constraints.maxWidth, 460.0);
              return SizedBox.square(
                dimension: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: isReady ? 1 : 0.32,
                      child: _CompassDial(
                        qiblaBearing: qiblaBearing,
                        heading: hasHeading ? _heading : 0,
                      ),
                    ),
                    if (!isReady)
                      _CompassStateOverlay(
                        status: _locationStatus,
                        errorMessage: _errorMessage,
                        onActivate: _activateQibla,
                      ),
                  ],
                ),
              );
            },
          ),
          if (isReady) ...[
            const SizedBox(height: 10),
            _AlignmentMessage(
              relativeDirection: QiblaCalculator.relativeDirection(
                qiblaBearing: qiblaBearing,
                heading: hasHeading ? _heading : 0,
              ),
              headingAvailable: hasHeading,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    final tt = Theme.of(context).textTheme;
    final qiblaBearing = _qiblaBearing;
    final headingAvailable = _headingStatus == _HeadingStatus.available;

    return Column(
      children: [
        _GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Direction details',
                style: tt.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _InfoRow(
                icon: Icons.mosque_rounded,
                label: 'Qibla direction',
                value: qiblaBearing == null
                    ? '—'
                    : '${qiblaBearing.toStringAsFixed(1)}° ${QiblaCalculator.cardinalDirection(qiblaBearing)}',
                accent: true,
              ),
              const _InfoDivider(),
              _InfoRow(
                icon: Icons.navigation_rounded,
                label: 'Device heading',
                value: headingAvailable
                    ? '${_heading.toStringAsFixed(1)}° ${QiblaCalculator.cardinalDirection(_heading)}'
                    : _headingStatus == _HeadingStatus.waiting
                        ? 'Detecting…'
                        : 'Not available',
              ),
              const _InfoDivider(),
              _InfoRow(
                icon: Icons.my_location_rounded,
                label: 'Current location',
                value: _position == null
                    ? 'Location not set'
                    : '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}',
              ),
              const _InfoDivider(),
              _InfoRow(
                icon: Icons.gps_fixed_rounded,
                label: 'Location accuracy',
                value: _position == null
                    ? '—'
                    : '±${_position!.accuracy.toStringAsFixed(0)} m',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _GlassPanel(
          color: const Color(0xFF10241F),
          borderColor: const Color(0xFF275444),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.tips_and_updates_outlined,
                color: Color(0xFF6EE7B7),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'For the best heading, hold your phone flat and keep it away from metal or magnetic objects.',
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white60,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back to Mini Apps'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF294259)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _goBack() => Navigator.of(context).pop();
}

class _QiblaTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final int? visitCount;
  final bool visitCountLoading;

  const _QiblaTopBar({
    required this.onBack,
    required this.visitCount,
    required this.visitCountLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF071019).withValues(alpha: 0.96),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF172A3A)),
        ),
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
              color: const Color(0xFF6EE7B7).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.explore_rounded,
              color: Color(0xFF6EE7B7),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'QIBLA',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
          ),
          const Spacer(),
          VisitCountBadge(
            count: visitCount,
            loading: visitCountLoading,
            color: Color(0xFF00D4FF),
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _QiblaHero extends StatelessWidget {
  const _QiblaHero();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find your direction.',
            style: tt.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A focused Qibla compass for wherever the journey finds you.',
            style: tt.bodyLarge?.copyWith(color: Colors.white60, height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _CompassStateOverlay extends StatelessWidget {
  final _LocationStatus status;
  final String? errorMessage;
  final VoidCallback onActivate;

  const _CompassStateOverlay({
    required this.status,
    required this.errorMessage,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isLoading = status == _LocationStatus.loading;
    final hasError = status == _LocationStatus.permissionDenied ||
        status == _LocationStatus.unavailable;

    return Container(
      width: 238,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1822).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF294259)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 30),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF6EE7B7),
              ),
            )
          else
            Icon(
              hasError
                  ? Icons.location_off_rounded
                  : Icons.location_searching_rounded,
              color:
                  hasError ? const Color(0xFFFFC857) : const Color(0xFF6EE7B7),
              size: 34,
            ),
          const SizedBox(height: 12),
          Text(
            isLoading
                ? 'Finding your location…'
                : hasError
                    ? 'Location unavailable'
                    : 'Your location is private',
            textAlign: TextAlign.center,
            style: tt.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            isLoading
                ? 'This usually takes a few seconds.'
                : errorMessage ??
                    'It is used only on this device to calculate the Qibla direction.',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(color: Colors.white54, height: 1.4),
          ),
          if (!isLoading) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onActivate,
                icon: Icon(
                  hasError ? Icons.refresh_rounded : Icons.my_location_rounded,
                  size: 18,
                ),
                label: Text(hasError ? 'Try again' : 'Use my location'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6EE7B7),
                  foregroundColor: const Color(0xFF071019),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompassDial extends StatelessWidget {
  final double qiblaBearing;
  final double heading;

  const _CompassDial({required this.qiblaBearing, required this.heading});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: heading),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, animatedHeading, _) => CustomPaint(
        painter: _CompassPainter(
          qiblaBearing: qiblaBearing,
          heading: animatedHeading,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double qiblaBearing;
  final double heading;

  const _CompassPainter({required this.qiblaBearing, required this.heading});

  static const _accent = Color(0xFF6EE7B7);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 14;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF102631), Color(0xFF09141E)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF284657)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      center,
      radius * 0.76,
      Paint()
        ..color = const Color(0xFF1B3543)
        ..style = PaintingStyle.stroke,
    );

    for (var degrees = 0; degrees < 360; degrees += 5) {
      final angle = _screenAngle(degrees.toDouble());
      final major = degrees % 30 == 0;
      final start = _point(center, radius - (major ? 16 : 9), angle);
      final end = _point(center, radius - 4, angle);
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = major ? Colors.white54 : Colors.white24
          ..strokeWidth = major ? 2 : 1,
      );
    }

    final labels = {0.0: 'N', 90.0: 'E', 180.0: 'S', 270.0: 'W'};
    for (final entry in labels.entries) {
      final angle = _screenAngle(entry.key);
      final point = _point(center, radius * 0.65, angle);
      _drawText(
        canvas,
        entry.value,
        point,
        entry.key == 0 ? _accent : Colors.white60,
        14,
      );
    }

    final qiblaAngle = _screenAngle(qiblaBearing);
    final arrowEnd = _point(center, radius * 0.61, qiblaAngle);
    canvas.drawLine(
      center,
      arrowEnd,
      Paint()
        ..color = _accent
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    final marker = _point(center, radius * 0.82, qiblaAngle);
    canvas.drawCircle(
      marker,
      20,
      Paint()
        ..color = _accent.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    final kaabaRect = Rect.fromCenter(center: marker, width: 25, height: 25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(kaabaRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF050707),
    );
    canvas.drawLine(
      Offset(kaabaRect.left, kaabaRect.center.dy - 3),
      Offset(kaabaRect.right, kaabaRect.center.dy - 3),
      Paint()
        ..color = const Color(0xFFD9B85D)
        ..strokeWidth = 3,
    );

    canvas.drawCircle(center, 12, Paint()..color = const Color(0xFF071019));
    canvas.drawCircle(center, 5, Paint()..color = _accent);

    final northPointer = Path()
      ..moveTo(center.dx, center.dy - radius - 5)
      ..lineTo(center.dx - 7, center.dy - radius + 8)
      ..lineTo(center.dx + 7, center.dy - radius + 8)
      ..close();
    canvas.drawPath(northPointer, Paint()..color = Colors.white);
  }

  double _screenAngle(double bearing) =>
      ((bearing - heading) - 90) * math.pi / 180;

  Offset _point(Offset center, double radius, double angle) => Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    Color color,
    double size,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.heading != heading ||
      oldDelegate.qiblaBearing != qiblaBearing;
}

class _AlignmentMessage extends StatelessWidget {
  final double relativeDirection;
  final bool headingAvailable;

  const _AlignmentMessage({
    required this.relativeDirection,
    required this.headingAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final aligned = relativeDirection <= 5 || relativeDirection >= 355;
    final turnRight = relativeDirection < 180;
    final message = !headingAvailable
        ? 'Qibla is marked relative to North'
        : aligned
            ? 'You are facing the Qibla'
            : 'Turn ${turnRight ? 'right' : 'left'} ${math.min(relativeDirection, 360 - relativeDirection).toStringAsFixed(0)}°';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (aligned && headingAvailable
                ? const Color(0xFF6EE7B7)
                : const Color(0xFF00D4FF))
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            aligned && headingAvailable
                ? Icons.check_circle_rounded
                : Icons.screen_rotation_alt_rounded,
            size: 18,
            color: aligned && headingAvailable
                ? const Color(0xFF6EE7B7)
                : const Color(0xFF00D4FF),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool accent;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (accent ? const Color(0xFF6EE7B7) : const Color(0xFF00D4FF))
                .withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: accent ? const Color(0xFF6EE7B7) : const Color(0xFF00D4FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.labelSmall?.copyWith(color: Colors.white38),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: tt.bodyMedium?.copyWith(
                  color: accent ? const Color(0xFF6EE7B7) : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(height: 1, color: Color(0xFF1B3343)),
      );
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = const Color(0xFF0C1A25),
    this.borderColor = const Color(0xFF1C3445),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 30, offset: Offset(0, 16)),
        ],
      ),
      child: child,
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
