import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class FoodTrackerScreen extends StatelessWidget {
  const FoodTrackerScreen({super.key, required this.weekday, this.embedded = false});
  final int weekday;

  /// True when shown as the "Food" tab (no back arrow).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final date = dateForWeekday(weekday);

    return PageScaffold(
      showBack: !embedded,
      title: weekdayNames[weekday - 1],
      subtitle: embedded ? 'Today • ${longDate(date)}' : longDate(date),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _MacroRow(Macros.of(state.foodsOn(date))),
          const SizedBox(height: 16),
          for (final meal in MealType.values) _MealCard(date: date, meal: meal, items: state.foodsOn(date, meal)),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow(this.m);
  final Macros m;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: StatBox('Calories', fmtNum(m.calories), unit: 'kcal')),
        const SizedBox(width: 6),
        Expanded(child: StatBox('Protein', fmtNum(m.protein), unit: 'g')),
        const SizedBox(width: 6),
        Expanded(child: StatBox('Carbs', fmtNum(m.carbs), unit: 'g')),
        const SizedBox(width: 6),
        Expanded(child: StatBox('Fats', fmtNum(m.fat), unit: 'g')),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.date, required this.meal, required this.items});
  final DateTime date;
  final MealType meal;
  final List<FoodEntry> items;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.read(context);
    return DarkCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              IconBadge(meal.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text('${items.length} ${items.length == 1 ? 'item' : 'items'} logged',
                        style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.card,
                  builder: (_) => _AddFoodSheet(date: date, meal: meal),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add food'),
              ),
            ],
          ),
          for (final f in items)
            Dismissible(
              key: ObjectKey(f),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => state.removeFood(f),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 12),
                child: const Icon(Icons.delete_outline, color: AppColors.red),
              ),
              child: Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.cardAlt, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu, color: AppColors.muted, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.name, style: const TextStyle(fontSize: 13)),
                          if (f.quantity.isNotEmpty)
                            Text(f.quantity, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text('${fmtNum(f.calories)} kcal', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 8),
            _MacroRow(Macros.of(items)),
          ],
        ],
      ),
    );
  }
}

class _AddFoodSheet extends StatefulWidget {
  const _AddFoodSheet({required this.date, required this.meal});
  final DateTime date;
  final MealType meal;

  @override
  State<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<_AddFoodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _qty = TextEditingController();
  final _cal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _qty, _cal, _protein, _carbs, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  double _num(TextEditingController c) => double.tryParse(c.text) ?? 0;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    AppScope.read(context).addFood(FoodEntry(
      date: widget.date,
      meal: widget.meal,
      name: _name.text.trim(),
      quantity: _qty.text.trim(),
      calories: _num(_cal),
      protein: _num(_protein),
      carbs: _num(_carbs),
      fat: _num(_fat),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Widget numField(TextEditingController c, String label) => Expanded(
          child: TextFormField(
            controller: c,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: label),
          ),
        );

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add to ${widget.meal.label}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Food name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qty,
                    decoration: const InputDecoration(labelText: 'Quantity (e.g. 2 pcs)'),
                  ),
                ),
                const SizedBox(width: 10),
                numField(_cal, 'Calories'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                numField(_protein, 'Protein g'),
                const SizedBox(width: 10),
                numField(_carbs, 'Carbs g'),
                const SizedBox(width: 10),
                numField(_fat, 'Fat g'),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton('Add food', _save),
          ],
        ),
      ),
    );
  }
}
