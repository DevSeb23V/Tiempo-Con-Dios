import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Niveles de madurez de la Llama de Crecimiento.
enum FlameLevel {
  nivel1, // 1-7 días: brasa pequeña sobre plato sencillo
  nivel2, // 8-30 días: fuego estable sobre base de bronce
  nivel3, // 31-90 días: candelabro de tres llamas
  nivel4, // 91+ días: altar devocional completo
}

/// Estado de la llama según la actividad reciente.
enum FlameState {
  viva,   // Registro en las últimas 36 h
  reposo, // Más de 48 h sin registro (Regla de la Gracia)
}

/// Widget animado suavemente para renderizar la Llama de Crecimiento devocional.
class GrowthFlameWidget extends StatefulWidget {
  final int diasAcumulados;
  final bool isViva;

  const GrowthFlameWidget({
    super.key,
    required this.diasAcumulados,
    this.isViva = true,
  });

  /// Determina el nivel de crecimiento según los días acumulados
  static FlameLevel getLevel(int dias) {
    if (dias <= 7) return FlameLevel.nivel1;
    if (dias <= 30) return FlameLevel.nivel2;
    if (dias <= 90) return FlameLevel.nivel3;
    return FlameLevel.nivel4;
  }

  @override
  State<GrowthFlameWidget> createState() => _GrowthFlameWidgetState();
}

class _GrowthFlameWidgetState extends State<GrowthFlameWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animación calmada y lenta de 4 segundos
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = GrowthFlameWidget.getLevel(widget.diasAcumulados);
    final state = widget.isViva ? FlameState.viva : FlameState.reposo;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 200),
          painter: GrowthFlamePainter(
            level: level,
            state: state,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

/// Pintor vectorial personalizado que dibuja las montañas, la base y la llama/brasa.
class GrowthFlamePainter extends CustomPainter {
  final FlameLevel level;
  final FlameState state;
  final double animationValue;

  GrowthFlamePainter({
    required this.level,
    required this.state,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.72);

    // 1. Fondo: Silueta de colinas/montañas en tonos cálidos
    _drawMountainSilhouettes(canvas, size);

    // 2. Base según el nivel acumulado
    _drawBaseStructure(canvas, center, level);

    // 3. Fuego o Brasa según el estado (Viva vs Reposo)
    if (state == FlameState.viva) {
      _drawLivingFlame(canvas, center, level);
    } else {
      _drawRestingEmbersAndSmoke(canvas, center, level);
    }
  }

  /// Dibuja colinas suaves en el fondo en tonos naranja cálido tenue
  void _drawMountainSilhouettes(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFFF6C8A4).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.75);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.60,
      size.width * 0.5,
      size.height * 0.70,
    );
    path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.78,
      size.width,
      size.height * 0.62,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = const Color(0xFFF1B082).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);
    path2.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.72,
      size.width * 0.7,
      size.height * 0.82,
    );
    path2.lineTo(size.width, size.height * 0.78);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  /// Dibuja la base correspondiente al nivel alcanzado
  void _drawBaseStructure(Canvas canvas, Offset center, FlameLevel lvl) {
    switch (lvl) {
      case FlameLevel.nivel1:
        // Nivel 1: Plato sencillo de barro / piedra suave
        final dishPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFB08968), Color(0xFF7F5539)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromCenter(center: center, width: 90, height: 26));

        final dishRect = Rect.fromCenter(
          center: Offset(center.dx, center.dy + 8),
          width: 84,
          height: 22,
        );
        canvas.drawOval(dishRect, dishPaint);

        final innerPlate = Paint()
          ..color = const Color(0xFF674835)
          ..style = PaintingStyle.fill;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + 6),
            width: 70,
            height: 14,
          ),
          innerPlate,
        );
        break;

      case FlameLevel.nivel2:
        // Nivel 2: Base elegante de bronce pulido
        final bronzePaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFE5A962), Color(0xFFB87333), Color(0xFF804A1B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromCenter(center: center, width: 100, height: 35));

        final baseStem = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(center.dx, center.dy + 12), width: 24, height: 22),
          const Radius.circular(6),
        );
        canvas.drawRRect(baseStem, bronzePaint);

        final pedestal = Rect.fromCenter(
          center: Offset(center.dx, center.dy + 22),
          width: 90,
          height: 16,
        );
        canvas.drawOval(pedestal, bronzePaint);

        final topBowl = Rect.fromCenter(
          center: Offset(center.dx, center.dy + 4),
          width: 76,
          height: 18,
        );
        canvas.drawOval(topBowl, bronzePaint);
        break;

      case FlameLevel.nivel3:
        // Nivel 3: Candelabro de tres ramas en bronce dorado
        final goldPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFD166), Color(0xFFD4AF37), Color(0xFFAA7C11)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromCenter(center: center, width: 140, height: 50));

        // Pie central
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(center.dx, center.dy + 15), width: 16, height: 30),
            const Radius.circular(4),
          ),
          goldPaint,
        );
        // Base inferior
        canvas.drawOval(
          Rect.fromCenter(center: Offset(center.dx, center.dy + 28), width: 90, height: 16),
          goldPaint,
        );
        // Brazos curvos izquierdo y derecho
        final branchPaint = Paint()
          ..color = const Color(0xFFD4AF37)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;

        final leftBranch = Path()
          ..moveTo(center.dx, center.dy + 18)
          ..cubicTo(center.dx - 25, center.dy + 22, center.dx - 45, center.dy + 8, center.dx - 45, center.dy - 2);
        canvas.drawPath(leftBranch, branchPaint);

        final rightBranch = Path()
          ..moveTo(center.dx, center.dy + 18)
          ..cubicTo(center.dx + 25, center.dy + 22, center.dx + 45, center.dy + 8, center.dx + 45, center.dy - 2);
        canvas.drawPath(rightBranch, branchPaint);

        // Platillos para las 3 llamas
        canvas.drawOval(Rect.fromCenter(center: Offset(center.dx - 45, center.dy - 2), width: 22, height: 8), goldPaint);
        canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + 2), width: 28, height: 10), goldPaint);
        canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + 45, center.dy - 2), width: 22, height: 8), goldPaint);
        break;

      case FlameLevel.nivel4:
        // Nivel 4: Altar devocional completo de piedras y leños
        final stonePaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF9E9284), Color(0xFF6B6054), Color(0xFF4A4036)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromCenter(center: center, width: 140, height: 40));

        // Bloques del altar
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(center.dx, center.dy + 22), width: 130, height: 20),
            const Radius.circular(8),
          ),
          stonePaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(center.dx, center.dy + 10), width: 108, height: 18),
            const Radius.circular(6),
          ),
          stonePaint,
        );

        // Leños sobre el altar
        final woodPaint = Paint()
          ..color = const Color(0xFF532E16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(center.dx - 36, center.dy + 3),
          Offset(center.dx + 36, center.dy - 2),
          woodPaint,
        );
        canvas.drawLine(
          Offset(center.dx - 32, center.dy - 2),
          Offset(center.dx + 32, center.dy + 4),
          woodPaint,
        );
        break;
    }
  }

  /// Dibuja el fuego en estado VIVA con colores vibrantes y suave balanceo
  void _drawLivingFlame(Canvas canvas, Offset center, FlameLevel lvl) {
    final wave = math.sin(animationValue * 2 * math.pi) * 3;
    final waveCos = math.cos(animationValue * 2 * math.pi) * 2;

    // Resplandor cálido exterior
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF4B77A).withValues(alpha: 0.45),
          const Color(0xFFF7F3EA).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(center.dx, center.dy - 25), radius: 65));
    canvas.drawCircle(Offset(center.dx, center.dy - 25), 65, glowPaint);

    if (lvl == FlameLevel.nivel3) {
      // 3 llamas en el candelabro
      _drawSingleFlame(canvas, Offset(center.dx - 45, center.dy - 2), 0.65, wave * 0.7);
      _drawSingleFlame(canvas, Offset(center.dx, center.dy + 2), 1.0, wave);
      _drawSingleFlame(canvas, Offset(center.dx + 45, center.dy - 2), 0.65, -wave * 0.7);
    } else {
      // 1 llama principal de escala según nivel
      final scale = lvl == FlameLevel.nivel1 ? 0.75 : (lvl == FlameLevel.nivel2 ? 1.0 : 1.3);
      _drawSingleFlame(canvas, center, scale, wave);
    }

    // Partículas y chispas ascendentes suaves
    _drawSparks(canvas, center, waveCos);
  }

  /// Dibuja una llama individual con 3 capas de color (exterior, medio y núcleo)
  void _drawSingleFlame(Canvas canvas, Offset origin, double scale, double sway) {
    final height = 65 * scale;
    final width = 40 * scale;
    final top = Offset(origin.dx + sway, origin.dy - height);

    // 1. Capa Exterior (Naranja Cálido)
    final outerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE9915A), Color(0xFFE06D2E)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromPoints(origin, top));

    final outerPath = Path();
    outerPath.moveTo(origin.dx, origin.dy);
    outerPath.cubicTo(
      origin.dx - width * 0.8,
      origin.dy - height * 0.25,
      origin.dx - width * 0.6 + sway * 0.5,
      origin.dy - height * 0.7,
      top.dx,
      top.dy,
    );
    outerPath.cubicTo(
      origin.dx + width * 0.6 + sway * 0.5,
      origin.dy - height * 0.7,
      origin.dx + width * 0.8,
      origin.dy - height * 0.25,
      origin.dx,
      origin.dy,
    );
    outerPath.close();
    canvas.drawPath(outerPath, outerPaint);

    // 2. Capa Media (Amarillo Dorado)
    final midPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD166), Color(0xFFF4B77A)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromPoints(origin, top));

    final midPath = Path();
    midPath.moveTo(origin.dx, origin.dy);
    midPath.cubicTo(
      origin.dx - width * 0.5,
      origin.dy - height * 0.2,
      origin.dx - width * 0.35 + sway * 0.4,
      origin.dy - height * 0.55,
      top.dx,
      top.dy + height * 0.2,
    );
    midPath.cubicTo(
      origin.dx + width * 0.35 + sway * 0.4,
      origin.dy - height * 0.55,
      origin.dx + width * 0.5,
      origin.dy - height * 0.2,
      origin.dx,
      origin.dy,
    );
    midPath.close();
    canvas.drawPath(midPath, midPaint);

    // 3. Núcleo Interno (Blanco / Amarillo Luz)
    final corePaint = Paint()..color = const Color(0xFFFFF7E6);
    final corePath = Path();
    corePath.moveTo(origin.dx, origin.dy);
    corePath.cubicTo(
      origin.dx - width * 0.25,
      origin.dy - height * 0.15,
      origin.dx - width * 0.15,
      origin.dy - height * 0.35,
      top.dx,
      top.dy + height * 0.5,
    );
    corePath.cubicTo(
      origin.dx + width * 0.15,
      origin.dy - height * 0.35,
      origin.dx + width * 0.25,
      origin.dy - height * 0.15,
      origin.dx,
      origin.dy,
    );
    corePath.close();
    canvas.drawPath(corePath, corePaint);
  }

  /// Dibuja chispas ascendentes lentas y tenues
  void _drawSparks(Canvas canvas, Offset center, double offset) {
    final sparkPaint = Paint()..color = AppColors.orangeLight.withValues(alpha: 0.7);
    final sparkPositions = [
      Offset(center.dx - 18 + offset, center.dy - 75 - (animationValue * 20)),
      Offset(center.dx + 16 - offset, center.dy - 85 - (animationValue * 25)),
      Offset(center.dx + 4 + offset * 0.5, center.dy - 95 - (animationValue * 15)),
    ];

    for (final pos in sparkPositions) {
      canvas.drawCircle(pos, 2.0, sparkPaint);
    }
  }

  /// Dibuja la brasa en reposo con humo suave (Regla de la Gracia)
  void _drawRestingEmbersAndSmoke(Canvas canvas, Offset center, FlameLevel lvl) {
    // Brasa en tono terracota cálido y ceniza suave
    final emberPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE9915A).withValues(alpha: 0.8),
          const Color(0xFF8D5B4C).withValues(alpha: 0.7),
          const Color(0xFF5A4D45).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(center.dx, center.dy - 4), radius: 24));

    canvas.drawCircle(Offset(center.dx, center.dy - 4), 22, emberPaint);

    // Pequeño fulgor tenue en el corazón de la brasa
    final coreGlow = Paint()
      ..color = const Color(0xFFFFA97A).withValues(alpha: 0.55 + 0.25 * math.sin(animationValue * 2 * math.pi));
    canvas.drawCircle(Offset(center.dx, center.dy - 4), 8, coreGlow);

    // Hilos de humo tenue elevándose con gracia
    final smokePaint = Paint()
      ..color = const Color(0xFFB5AAA0).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final smokeWave = math.sin(animationValue * 2 * math.pi) * 8;

    final smokePath = Path();
    smokePath.moveTo(center.dx, center.dy - 10);
    smokePath.cubicTo(
      center.dx + smokeWave,
      center.dy - 35,
      center.dx - smokeWave,
      center.dy - 65,
      center.dx + smokeWave * 0.5,
      center.dy - 95,
    );
    canvas.drawPath(smokePath, smokePaint);
  }

  @override
  bool shouldRepaint(covariant GrowthFlamePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.level != level ||
        oldDelegate.state != state;
  }
}
