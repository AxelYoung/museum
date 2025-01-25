import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math' as math;
import 'guide_page.dart';

class AudioGuidePage extends StatefulWidget {
  final bool isEmbedded;

  const AudioGuidePage({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<AudioGuidePage> createState() => _AudioGuidePageState();
}

class AudioWaveform extends StatefulWidget {
  final double amplitude;
  
  const AudioWaveform({super.key, required this.amplitude});

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform> {
  final List<double> _amplitudes = List.filled(27, 0.0);
  
  @override
  void didUpdateWidget(AudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 更新振幅历史记录
    _amplitudes.removeAt(0);
    _amplitudes.add(widget.amplitude);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 60),
      painter: WaveformPainter(amplitudes: _amplitudes),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  static const int barsCount = 27;
  
  WaveformPainter({required this.amplitudes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final width = size.width;
    final height = size.height;
    final barWidth = (width / barsCount) * 0.7;
    final spacing = (width / barsCount) * 0.3;
    final mid = height / 2;

    for (var i = 0; i < barsCount; i++) {
      final normalizedAmplitude = (amplitudes[i] * 50).clamp(0.0, 1.0);
      final magnitude = (normalizedAmplitude * height / 2).clamp(4.0, height / 2);
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(i * (barWidth + spacing) + barWidth / 2, mid),
          width: barWidth,
          height: magnitude * 2,
        ),
        const Radius.circular(4),
      );
      
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AudioGuidePageState extends State<AudioGuidePage> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  double _currentAmplitude = 0.0;
  Timer? _amplitudeTimer;
  late final AnimationController _animationController;
  int _selectedExhibitIndex = 0;

  final List<String> _exhibits = [
    '青铜器',
    '陶器',
    '玉器',
    '书画',
    '瓷器',
    '金银器',
    '漆器',
    '石刻',
    '织绣',
    '古钱币',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _amplitudeTimer?.cancel();
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (!mounted) return;
    
    if (!_isRecording) {
      final status = await Permission.microphone.request();
      if (status == PermissionStatus.granted) {
        if (!mounted) return;
        setState(() {
          _isRecording = true;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('需要麦克风权限才能录音'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } else {
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _currentAmplitude = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomBarHeight = kBottomNavigationBarHeight + bottomPadding;
    final panelHeight = size.height * 0.8;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          if (!widget.isEmbedded)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          Positioned(
            bottom: bottomBarHeight + 24,
            left: 0,
            right: 0,
            child: Hero(
              tag: 'audio_guide_button',
              flightShuttleBuilder: (
                BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext,
              ) {
                return Material(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                );
              },
              child: Material(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                  top: Radius.circular(16),
                ),
                elevation: 8,
                child: Container(
                  width: size.width,
                  height: panelHeight,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            if (!widget.isEmbedded)
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 12),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            const SizedBox(height: 40),
                            Container(
                              width: 200,
                              height: 200,
                              margin: const EdgeInsets.only(bottom: 40),
                              child: Stack(
                                children: [
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        size: const Size(200, 200),
                                        painter: AnimatedCircleRingPainter(
                                          animation: _animationController.value,
                                          color1: colorScheme.primary,
                                          color2: colorScheme.tertiary,
                                        ),
                                      );
                                    },
                                  ),
                                  CustomPaint(
                                    size: const Size(200, 200),
                                    painter: CircleRingPainter(
                                      color: colorScheme.primary.withOpacity(0.12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.outlineVariant,
                                        width: 1,
                                      ),
                                    ),
                                    child: SizedBox(
                                      width: size.width / 3 - 24,
                                      height: 240,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme.surfaceVariant.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: _exhibits.length,
                                          itemBuilder: (context, index) {
                                            final isSelected = _selectedExhibitIndex == index;
                                            return AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              margin: EdgeInsets.zero,
                                              child: FilledButton.tonal(
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedExhibitIndex = index;
                                                  });
                                                },
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: isSelected
                                                      ? colorScheme.primaryContainer
                                                      : Colors.transparent,
                                                  foregroundColor: isSelected
                                                      ? colorScheme.onPrimaryContainer
                                                      : colorScheme.onSurfaceVariant,
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                                  elevation: 0,
                                                  minimumSize: Size(size.width / 3 - 24, 48),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(0),
                                                  ),
                                                ),
                                                child: Text(_exhibits[index]),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_isRecording)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: AudioWaveform(amplitude: _currentAmplitude),
                              ),
                            SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FilledButton.tonal(
                                      onPressed: () {
                                        if (!mounted) return;
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => const GuidePage(
                                              isEmbedded: false,
                                            ),
                                          ),
                                        );
                                      },
                                      style: FilledButton.styleFrom(
                                        fixedSize: const Size(56, 56),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        backgroundColor: colorScheme.secondaryContainer,
                                        foregroundColor: colorScheme.onSecondaryContainer,
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Icon(
                                        Icons.switch_left_rounded,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    FilledButton.tonal(
                                      onPressed: _toggleRecording,
                                      style: FilledButton.styleFrom(
                                        fixedSize: const Size(64, 64),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        backgroundColor: _isRecording 
                                          ? colorScheme.errorContainer
                                          : colorScheme.secondaryContainer,
                                        foregroundColor: _isRecording
                                          ? colorScheme.onErrorContainer
                                          : colorScheme.onSecondaryContainer,
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Icon(
                                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                        size: 32,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: bottomBarHeight + 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    '5m',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModalBottomSheet extends StatelessWidget {
  final Widget child;
  final VoidCallback onDismiss;
  final Color backgroundColor;

  const ModalBottomSheet({
    super.key,
    required this.child,
    required this.onDismiss,
    this.backgroundColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(color: Colors.transparent),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        ],
      ),
    );
  }
}

class CircleRingPainter extends CustomPainter {
  final Color color;
  
  CircleRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - paint.strokeWidth / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedCircleRingPainter extends CustomPainter {
  final double animation;
  final Color color1;
  final Color color2;
  
  AnimatedCircleRingPainter({
    required this.animation,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (size.width / 2) - 20;
    final now = DateTime.now().millisecondsSinceEpoch / 1000;

    // 绘制白色背景
    final bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 绘制内部呼吸波浪效果
    final innerPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    
    final breathe = (math.sin(now * 0.8) * 0.3 + 0.7);
    
    for (int i = 0; i < 15; i++) {
      final progress = (now / 4 + i / 15) % 1.0;
      final innerPath = Path();
      
      for (double angle = 0; angle < 360; angle += 1) {
        final rad = angle * math.pi / 180;
        final wavePhase = now * 1.5 + angle * math.pi / 180;
        final innerWave = math.sin(wavePhase) * 3 * breathe +
                         math.sin(wavePhase * 1.2) * 2 * breathe;
                        
        final r = (baseRadius - 30) * (1 - progress * 0.15) + innerWave;
        final x = center.dx + r * math.cos(rad);
        final y = center.dy + r * math.sin(rad);
        
        if (angle == 0) {
          innerPath.moveTo(x, y);
        } else {
          innerPath.lineTo(x, y);
        }
      }
      innerPath.close();

      final color = Color.lerp(
        const Color(0xFF7B42F6).withOpacity(0.2),
        const Color(0xFF4F9CF8).withOpacity(0.2),
        progress,
      )!;
      
      innerPaint.color = color.withOpacity((1 - progress) * 0.12 * breathe);
      canvas.drawPath(innerPath, innerPaint);
    }

    // 绘制渐变边框
    final List<Color> ringColors = [
      const Color(0xFFB939E5), // 粉紫色
      const Color(0xFF7B42F6), // 紫色
      const Color(0xFF4F9CF8), // 蓝色
    ];

    for (int i = 0; i < 3; i++) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..color = ringColors[i].withOpacity(0.5);

      final ringPath = Path();
      final timeOffset = now * (1.2 + i * 0.15);
      
      for (double angle = 0; angle < 360; angle += 1) {
        final rad = angle * math.pi / 180;
        final wave = math.sin(timeOffset + angle * math.pi / 45) * 3 +
                    math.sin(timeOffset * 1.2 - angle * math.pi / 30) * 2;
                    
        final r = baseRadius + wave + i * 2;
        final x = center.dx + r * math.cos(rad);
        final y = center.dy + r * math.sin(rad);
        
        if (angle == 0) {
          ringPath.moveTo(x, y);
        } else {
          ringPath.lineTo(x, y);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

