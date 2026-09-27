import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../demo_data.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _target = TextEditingController();
  String _gender = 'Male';
  final Set<Goal> _goals = {};

  /// Set on the first save attempt so invalid rows only turn red after the user tries to continue.
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    // Rebuild on every keystroke so the BMI card and error highlights stay live.
    for (final c in [_age, _height, _weight, _target]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_age, _height, _weight, _target]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

  int? get _ageValue {
    final v = int.tryParse(_age.text.trim());
    return v != null && v >= 10 && v <= 100 ? v : null;
  }

  double? get _heightValue {
    final v = _num(_height);
    return v != null && v >= 100 && v <= 250 ? v : null;
  }

  double? get _weightValue {
    final v = _num(_weight);
    return v != null && v >= 25 && v <= 350 ? v : null;
  }

  /// Target weight is optional: empty is fine, anything typed must be a sensible weight.
  bool get _targetValid {
    if (_target.text.trim().isEmpty) return true;
    final v = _num(_target);
    return v != null && v >= 25 && v <= 350;
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (_ageValue == null || _heightValue == null || _weightValue == null || !_targetValid) {
      messenger.showSnackBar(const SnackBar(content: Text('Please check the highlighted fields')));
      return;
    }
    if (_goals.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Pick at least one goal')));
      return;
    }

    AppScope.read(context).saveProfile(Profile(
      age: _ageValue!,
      gender: _gender,
      heightCm: _heightValue!,
      weightKg: _weightValue!,
      goals: {..._goals},
      targetWeightKg: _num(_target),
    ));
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AllSetDialog(),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  void _loadDemo() {
    loadDemoData(AppScope.read(context));
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            Center(child: SvgPicture.asset('assets/icons/dumbbell.svg', height: 36)),
            const SizedBox(height: 10),
            const Text(
              'Create Profile',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            const Text(
              'Set up your starting point.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _Section(
              title: 'About you',
              children: [
                _FieldRow(
                  icon: _svg('calendar'),
                  label: 'Age',
                  error: _submitted && _ageValue == null,
                  child: _numInput(_age, hint: '23', integer: true),
                ),
                _FieldRow(
                  icon: _svg('gender'),
                  label: 'Gender',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _gender,
                      isDense: true,
                      dropdownColor: AppColors.cardAlt,
                      borderRadius: BorderRadius.circular(10),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.muted),
                      style: const TextStyle(fontSize: 14, color: AppColors.muted),
                      items: const ['Male', 'Female', 'Other']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                ),
                _FieldRow(
                  icon: _svg('height'),
                  label: 'Height',
                  error: _submitted && _heightValue == null,
                  child: _numInput(_height, hint: '175', unit: 'cm'),
                ),
                _FieldRow(
                  icon: _svg('weight'),
                  label: 'Weight',
                  error: _submitted && _weightValue == null,
                  child: _numInput(_weight, hint: '90', unit: 'kg'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Section(
              title: 'Your goal',
              children: [
                _FieldRow(
                  icon: _svg('target'),
                  label: 'Target Weight',
                  error: _submitted && !_targetValid,
                  child: _numInput(_target, hint: '80', unit: '(kg)'),
                ),
                for (var i = 0; i < Goal.values.length; i += 2)
                  Row(
                    children: [
                      Expanded(child: _goalTile(Goal.values[i])),
                      const SizedBox(width: 8),
                      Expanded(
                        child: i + 1 < Goal.values.length ? _goalTile(Goal.values[i + 1]) : const SizedBox(),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _Section(title: 'Your BMI', children: [_bmiCard()]),
            const SizedBox(height: 18),
            PrimaryButton('Save profile', _save),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _loadDemo,
                child: const Text('Just exploring? Try it with demo data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numInput(TextEditingController c, {required String hint, String? unit, bool integer = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64,
          child: TextField(
            controller: c,
            textAlign: TextAlign.end,
            keyboardType: TextInputType.numberWithOptions(decimal: !integer),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(integer ? r'\d' : r'[\d.,]'))],
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              isCollapsed: true,
              filled: false,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        if (unit != null) ...[
          const SizedBox(width: 8),
          Text(unit, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        ],
      ],
    );
  }

  Widget _goalTile(Goal g) {
    final selected = _goals.contains(g);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => selected ? _goals.remove(g) : _goals.add(g));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.red : Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.red : AppColors.border),
        ),
        child: Row(
          children: [
            _goalIcon(g),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                g.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalIcon(Goal g) => switch (g) {
        Goal.loseWeight => _svg('lose-weight'),
        Goal.gainMuscle => _svg('muscle'),
        Goal.bulk => _svg('bulk'),
        Goal.maintainWeight => const Icon(Icons.balance, size: 20, color: Colors.white),
        Goal.improveStrength => _svg('dumbell'),
        Goal.improveEndurance => const Icon(Icons.directions_run, size: 20, color: Colors.white),
        Goal.generalFitness => const Icon(Icons.favorite, size: 20, color: Colors.white),
      };

  Widget _bmiCard() {
    final h = _heightValue;
    final w = _weightValue;
    final bmi = h != null && w != null ? bmiFor(h, w) : null;
    final (label, color, message) = switch (bmi == null ? null : bmiCategory(bmi)) {
      null => ('', AppColors.muted, 'Enter your height and weight'),
      BmiCategory.underweight => ('Underweight', const Color(0xFFFFB020), 'Your BMI is below the healthy range'),
      BmiCategory.normal => ('Normal', const Color(0xFF34C759), 'Your BMI is in the healthy range'),
      BmiCategory.overweight => ('Overweight', const Color(0xFFFF9500), 'Your BMI is above the healthy range'),
      BmiCategory.obese => ('Obese', AppColors.red, 'Your BMI is well above the healthy range'),
    };

    return Row(
      children: [
        SvgPicture.asset('assets/icons/BMI.svg', height: 52),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bmi?.toStringAsFixed(1) ?? '--',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              if (label.isNotEmpty)
                Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(message, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A white, single-colour icon from assets/icons.
Widget _svg(String name) => SvgPicture.asset(
      'assets/icons/$name.svg',
      width: 20,
      height: 20,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );

/// Card with a red section label and evenly spaced children.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(title),
          for (final child in children) ...[const SizedBox(height: 8), child],
        ],
      ),
    );
  }
}

/// One bordered input row: icon, label on the left, value on the right.
class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.icon, required this.label, required this.child, this.error = false});
  final Widget icon;
  final String label;
  final Widget child;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: error ? AppColors.red : AppColors.border),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
          ),
          child,
        ],
      ),
    );
  }
}

class _AllSetDialog extends StatelessWidget {
  const _AllSetDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.red, size: 56),
            const SizedBox(height: 12),
            const Text("You're All Set", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              "Your profile is ready.\nLet's start building your weekly plan.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            PrimaryButton('Continue', () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
