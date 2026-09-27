import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:workout_tracker/main.dart';
import 'package:workout_tracker/models.dart';
import 'package:workout_tracker/screens/onboarding_screen.dart';
import 'package:workout_tracker/theme.dart';

void main() {
  testWidgets('splash leads to profile setup for new users', (tester) async {
    await tester.pumpWidget(WorkoutApp(state: AppState()));
    expect(find.textContaining('Personal Workout'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Create Profile'), findsOneWidget);
  });

  testWidgets('create profile shows live BMI and saves selected goals', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    final state = AppState();
    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp(theme: buildTheme(), home: const OnboardingScreen()),
    ));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '23');
    await tester.enterText(fields.at(1), '180');
    await tester.enterText(fields.at(2), '80');
    await tester.pump();
    expect(find.text('24.7'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);

    await tester.tap(find.text('Gain Muscle'));
    await tester.tap(find.text('Improve Strength'));
    await tester.pump();

    await tester.scrollUntilVisible(find.text('SAVE PROFILE'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('SAVE PROFILE'));
    await tester.pumpAndSettle();

    expect(state.profile!.goals, {Goal.gainMuscle, Goal.improveStrength});
    expect(state.profile!.heightCm, 180);
    expect(find.text("You're All Set"), findsOneWidget);
  });

  test('a day keeps its split and exercises after a restart', () async {
    SharedPreferences.setMockInitialValues({});
    final state = await AppState.load();
    state.setGroups(1, {'Chest', 'Triceps'});
    state.setExercises(1, 'Chest', [exerciseLibrary.firstWhere((e) => e.name == 'Bench Press')]);
    state.plans[1]!.first.exercises.first.sets.first
      ..weight = 60
      ..reps = 8;
    state.save();

    final restarted = await AppState.load();
    expect(restarted.plans[1]!.map((g) => g.group), ['Chest', 'Triceps']);
    final bench = restarted.groupPlan(1, 'Chest').exercises.single;
    expect(bench.info.name, 'Bench Press');
    expect(bench.sets.single.weight, 60);
    expect(bench.sets.single.reps, 8);
    expect(restarted.plans[2], isEmpty);
  });
}
