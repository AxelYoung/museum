import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;
import 'dart:async';

// 添加箭头画笔类
class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 30.0  // 增加线条粗细
      ..strokeCap = StrokeCap.round  // 添加圆角
      ..style = PaintingStyle.stroke;

    // 画箭头主干（45度角）
    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.7)  // 起点
      ..lineTo(size.width * 0.7, size.height * 0.3); // 终点（45度角）

    // 画箭头头部
    path.lineTo(size.width * 0.7, size.height * 0.5); // 箭头尾部

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GuidePage extends StatefulWidget {
  final bool isEmbedded;

  const GuidePage({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  CameraController? _controller;
  bool _isCameraPermissionGranted = false;
  double _direction = 0.0;
  bool _hasCompass = false;
  double _pitch = 0.0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndSensors();
    _initAccelerometer();
  }

  void _initAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          _pitch = -math.atan2(event.y, event.z) * 1.0;
        });
      }
    });
  }

  Matrix4 _calculateTransform() {
    const double perspectiveValue = 0.005;  // 透视效果强度
    final Matrix4 matrix = Matrix4.identity()
      ..setEntry(3, 2, perspectiveValue)  // 添加透视效果
      ..rotateX(_pitch);  // 根据俯仰角度旋转

    // 修正缩放方向：向下看时放大，向上看时缩小
    double scaleEffect = math.sin(_pitch);  // -1 到 1 之间的值
    // 当向下看时（正值）放大，向上看时（负值）缩小
    double scale = scaleEffect < 0 
        ? 1.0 - scaleEffect * 0.2  // 向上看时缩小
        : 1.0 / (1.0 + scaleEffect * 0.2);  // 向下看时放大

    matrix.scale(1.0, scale, 1.0);

    return matrix;
  }

  Future<void> _checkPermissionsAndSensors() async {
    try {
      _hasCompass = await FlutterCompass.events != null;
      if (_hasCompass) {
        _compassSubscription = FlutterCompass.events!.listen((event) {
          if (mounted && event.heading != null) {
            setState(() {
              _direction = (-event.heading! - 90) * (math.pi / 180);
            });
          }
        });
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('传感器初始化错误: $e');
      _hasCompass = false;
    }
    await _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isCameraPermissionGranted = status.isGranted;
    });
    if (status.isGranted) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // 使用后置相机
    final rearCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      rearCamera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('相机初始化错误: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _accelerometerSubscription?.cancel();
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraPermissionGranted || !_hasCompass) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isCameraPermissionGranted) ...[
                const Text('需要相机权限'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _requestCameraPermission,
                  child: const Text('授权相机权限'),
                ),
                const SizedBox(height: 24),
              ],
              if (!_hasCompass) ...[
                const Text('设备不支持指南针功能或指南针不可用'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    _hasCompass = await FlutterCompass.events != null;
                    setState(() {});
                  },
                  child: const Text('检查指南针状态'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error reading heading'));
              }
              
              if (snapshot.hasData) {
                double? direction = snapshot.data!.heading;
                if (direction != null) {
                  _direction = (-direction - 90) * (math.pi / 180);
                }
              }

              return Center(
                child: Transform(
                  transform: _calculateTransform(),
                  alignment: Alignment.center,
                  child: Transform.rotate(
                    angle: _direction,
                    child: Container(
                      width: 250,  // 稍微大一点以容纳边框
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Image.asset(
                            'assets/images/arror.png',
                            color: Colors.white,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (!widget.isEmbedded)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }
} 