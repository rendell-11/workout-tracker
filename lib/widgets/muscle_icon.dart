import 'package:flutter/material.dart';

/// A small body figure with the muscles of [group] highlighted.
///
/// The figure is drawn from the front or back depending on where the muscle
/// sits. Muscles not being trained are drawn in [baseColor] (a faded [color]
/// by default).
class MuscleIcon extends StatelessWidget {
  const MuscleIcon(this.group, {super.key, this.size = 24, required this.color, this.baseColor});
  final String group;
  final double size;
  final Color color;
  final Color? baseColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MusclePainter(group, color, baseColor ?? color.withValues(alpha: 0.28)),
    );
  }
}

// Shapes are laid out in a 100×100 box. Paired muscles are drawn for the
// figure's right side (viewer's left) and mirrored.

Path _head() => Path()..addOval(Rect.fromCircle(center: const Offset(50, 10), radius: 6.5));

Path _delt() => Path()
  ..moveTo(34, 19)
  ..quadraticBezierTo(25, 19, 24, 29)
  ..lineTo(30, 30)
  ..quadraticBezierTo(31, 23, 35, 21)
  ..close();

Path _upperArm() => Path()
  ..moveTo(24, 31)
  ..lineTo(30, 32)
  ..lineTo(30, 44)
  ..quadraticBezierTo(27, 45.5, 24, 44)
  ..close();

Path _forearm() => Path()
  ..moveTo(24, 46.5)
  ..quadraticBezierTo(27, 48, 30, 46.5)
  ..lineTo(29, 59.5)
  ..lineTo(25.5, 59.5)
  ..close();

Path _hand() => Path()..addOval(Rect.fromCircle(center: const Offset(27.3, 63), radius: 2.6));

Path _chest() => Path()
  ..moveTo(36.5, 21)
  ..lineTo(49, 21)
  ..lineTo(49, 33)
  ..quadraticBezierTo(42, 36, 35.5, 31.5)
  ..quadraticBezierTo(35, 26, 36.5, 21)
  ..close();

Path _abs() => Path()
  ..moveTo(40, 35.5)
  ..lineTo(60, 35.5)
  ..lineTo(59, 53)
  ..quadraticBezierTo(50, 57, 41, 53)
  ..close();

Path _quad() => Path()
  ..moveTo(38.5, 56)
  ..lineTo(49, 57)
  ..lineTo(48, 78)
  ..lineTo(40.5, 78)
  ..quadraticBezierTo(37, 67, 38.5, 56)
  ..close();

Path _shin() => Path()
  ..moveTo(40.5, 80.5)
  ..lineTo(48, 80.5)
  ..lineTo(47, 95)
  ..lineTo(42.5, 95)
  ..close();

Path _traps() => Path()
  ..moveTo(44, 16.5)
  ..lineTo(56, 16.5)
  ..lineTo(61, 20)
  ..lineTo(39, 20)
  ..close();

Path _lat() => Path()
  ..moveTo(36.5, 21)
  ..lineTo(49, 21)
  ..lineTo(49, 43.5)
  ..quadraticBezierTo(42, 43.5, 37.5, 38)
  ..quadraticBezierTo(35, 30, 36.5, 21)
  ..close();

Path _lowerBack() => Path()
  ..moveTo(40.5, 45.5)
  ..lineTo(59.5, 45.5)
  ..lineTo(60, 53)
  ..lineTo(40, 53)
  ..close();

Path _glute() => Path()
  ..moveTo(38.5, 54.5)
  ..lineTo(49, 54.5)
  ..lineTo(49, 66)
  ..quadraticBezierTo(42.5, 68, 38.5, 63.5)
  ..close();

Path _hamstring() => Path()
  ..moveTo(38.5, 66)
  ..quadraticBezierTo(43, 69.5, 49, 68.5)
  ..lineTo(48, 80)
  ..lineTo(40.5, 80)
  ..quadraticBezierTo(38, 73, 38.5, 66)
  ..close();

Path _calf() => Path()
  ..moveTo(40.5, 82)
  ..lineTo(48, 82)
  ..quadraticBezierTo(48.5, 89, 46.5, 95)
  ..lineTo(42.5, 95)
  ..quadraticBezierTo(39.5, 88, 40.5, 82)
  ..close();

Path _heart() => Path()
  ..moveTo(50, 86)
  ..cubicTo(20, 64, 10, 48, 10, 34)
  ..cubicTo(10, 21, 20, 13, 31, 13)
  ..cubicTo(39, 13, 46, 18, 50, 25)
  ..cubicTo(54, 18, 61, 13, 69, 13)
  ..cubicTo(80, 13, 90, 21, 90, 34)
  ..cubicTo(90, 48, 80, 64, 50, 86)
  ..close();

class _Part {
  const _Part(this.name, this.path, {this.paired = true});
  final String name;
  final Path Function() path;
  final bool paired;
}

const _front = [
  _Part('head', _head, paired: false),
  _Part('delts', _delt),
  _Part('chest', _chest),
  _Part('abs', _abs, paired: false),
  _Part('biceps', _upperArm),
  _Part('forearms', _forearm),
  _Part('hands', _hand),
  _Part('quads', _quad),
  _Part('shins', _shin),
];

const _back = [
  _Part('head', _head, paired: false),
  _Part('traps', _traps, paired: false),
  _Part('delts', _delt),
  _Part('lats', _lat),
  _Part('lowerBack', _lowerBack, paired: false),
  _Part('triceps', _upperArm),
  _Part('forearms', _forearm),
  _Part('hands', _hand),
  _Part('glutes', _glute),
  _Part('hamstrings', _hamstring),
  _Part('calves', _calf),
];

/// Group name -> (figure, highlighted parts). Groups not listed (Cardio)
/// draw a heart.
const _groups = <String, (List<_Part>, Set<String>)>{
  'Chest': (_front, {'chest'}),
  'Back': (_back, {'traps', 'lats', 'lowerBack'}),
  'Shoulders': (_front, {'delts'}),
  'Triceps': (_back, {'triceps'}),
  'Biceps': (_front, {'biceps'}),
  'Forearms': (_front, {'forearms'}),
  'Full Arms': (_front, {'biceps', 'forearms', 'delts'}),
  'Core': (_front, {'abs'}),
  'Hamstrings': (_back, {'hamstrings'}),
  'Glutes': (_back, {'glutes'}),
  'Legs': (_front, {'quads', 'shins'}),
};

class _MusclePainter extends CustomPainter {
  _MusclePainter(this.group, this.color, this.baseColor);
  final String group;
  final Color color;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100, size.height / 100);
    final spec = _groups[group];
    if (spec == null) {
      canvas.drawPath(_heart(), Paint()..color = color);
      return;
    }
    final (parts, highlighted) = spec;
    for (final p in parts) {
      final paint = Paint()..color = highlighted.contains(p.name) ? color : baseColor;
      final path = p.path();
      canvas.drawPath(path, paint);
      if (p.paired) {
        canvas
          ..save()
          ..translate(100, 0)
          ..scale(-1, 1)
          ..drawPath(path, paint)
          ..restore();
      }
    }
  }

  @override
  bool shouldRepaint(_MusclePainter old) =>
      old.group != group || old.color != color || old.baseColor != baseColor;
}
