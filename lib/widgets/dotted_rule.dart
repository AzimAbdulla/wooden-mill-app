import 'package:flutter/material.dart';

/// Horizontal dotted or dashed line. Dots are the ledger leaders between a
/// bill label and its amount; dashes are the tear edges of a receipt slip.
class DottedRule extends StatelessWidget {
  final Color color;
  final double dash;
  final double gap;
  final double thickness;

  const DottedRule({
    super.key,
    required this.color,
    this.dash = 1.5,
    this.gap = 4,
    this.thickness = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: thickness,
      width: double.infinity,
      child: CustomPaint(painter: _RulePainter(color, dash, gap, thickness)),
    );
  }
}

class _RulePainter extends CustomPainter {
  final Color color;
  final double dash;
  final double gap;
  final double thickness;

  const _RulePainter(this.color, this.dash, this.gap, this.thickness);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    // Round caps add half the thickness at each end of a dash.
    final inset = thickness / 2;
    for (double x = inset; x + dash - thickness <= size.width - inset; x += dash + gap) {
      canvas.drawLine(Offset(x, y), Offset(x + dash - thickness, y), paint);
    }
  }

  @override
  bool shouldRepaint(_RulePainter old) =>
      old.color != color || old.dash != dash || old.gap != gap || old.thickness != thickness;
}
