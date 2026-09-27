import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:workout_tracker/demo_data.dart';
import 'package:workout_tracker/models.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('profile, history and food survive a restart', () async {
    final state = await AppState.load();
    state.saveProfile(Profile(
      age: 30,
      gender: 'Female',
      heightCm: 165,
      weightKg: 60,
      goals: {Goal.improveEndurance},
      targetWeightKg: 58,
    ));
    state.setGroups(2, {'Legs'});
    state.setExercises(2, 'Legs', [exerciseNamed('Squat')!]);
    state.startWorkout(2);
    state.plans[2]!.single.exercises.single.sets.single
      ..weight = 70
      ..reps = 5
      ..done = true;
    state.finishWorkout();
    state.addFood(FoodEntry(
      date: DateTime(2026, 9, 1, 8),
      meal: MealType.breakfast,
      name: 'Eggs',
      quantity: '3',
      calories: 210,
      protein: 18,
    ));

    final restarted = await AppState.load();
    expect(restarted.profile!.gender, 'Female');
    expect(restarted.profile!.goals, {Goal.improveEndurance});
    expect(restarted.profile!.targetWeightKg, 58);

    final record = restarted.history.single;
    expect(record.exercises.single.info.name, 'Squat');
    expect(record.volume, 350);
    expect(record.duration.inSeconds, state.history.single.duration.inSeconds);

    expect(restarted.foods.single.name, 'Eggs');
    expect(restarted.foods.single.meal, MealType.breakfast);
    expect(restarted.foods.single.protein, 18);
  });

  test('plans saved in the old [weight, reps] format still load', () async {
    SharedPreferences.setMockInitialValues({
      'plans': '{"1":[{"group":"Chest","exercises":[{"name":"Bench Press","sets":[[60,8]]}]}]}',
    });
    final state = await AppState.load();
    final set = state.groupPlan(1, 'Chest').exercises.single.sets.single;
    expect((set.weight, set.reps, set.done), (60, 8, false));
  });

  test('an unreadable section does not lose the others', () async {
    SharedPreferences.setMockInitialValues({
      'history': 'not json',
      'profile': '{"age":20,"gender":"Male","heightCm":180,"weightKg":75,"goals":["bulk"]}',
    });
    final state = await AppState.load();
    expect(state.history, isEmpty);
    expect(state.profile!.goals, {Goal.bulk});
  });

  test('demo data fills every screen and survives a restart', () async {
    final now = DateTime(2026, 9, 24, 12); // a Thursday
    final state = await AppState.load();
    loadDemoData(state, now: now);

    expect(state.profile, isNotNull);
    expect(state.plans[1]!.map((g) => g.group), ['Chest', 'Triceps']);
    expect(state.plans[4], isEmpty);
    expect(state.history.length, greaterThan(30));
    expect(state.history.every((r) => r.date.isBefore(DateTime(2026, 9, 24))), isTrue);
    // Newest first, like workouts finished in the app.
    expect(state.history.first.date.isAfter(state.history.last.date), isTrue);
    expect(state.history.fold(0, (n, r) => n + r.personalRecords), greaterThan(0));
    expect(state.foodsOn(now), isNotEmpty);

    final bench = [
      for (final r in state.history.reversed)
        for (final e in r.exercises.where((e) => e.info.name == 'Bench Press')) e.sets.first.weight,
    ];
    expect(bench.last, greaterThan(bench.first));

    final restarted = await AppState.load();
    expect(restarted.history.length, state.history.length);
    expect(restarted.plans[1]!.first.exercises.first.sets.first.done, isFalse);
  });
}
