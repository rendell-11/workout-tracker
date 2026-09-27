import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Exercise info plus the set logger (weight × reps, done checkbox).
class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.log, required this.group});
  final ExerciseLog log;
  final String group;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final info = log.info;
    const header = TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w700);

    return PageScaffold(
      title: info.name,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ImagePlaceholder.muscle(group, height: 150),
          const SizedBox(height: 12),
          DarkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.name.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text(info.equipment, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                const SizedBox(height: 8),
                Text(info.description, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Text('Targets: ${info.targets}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionLabel('Log sets'),
          const SizedBox(height: 8),
          DarkCard(
            child: Column(
              children: [
                const Row(
                  children: [
                    SizedBox(width: 36, child: Text('SET', style: header)),
                    Expanded(child: Text('WEIGHT (KG)', style: header)),
                    SizedBox(width: 10),
                    Expanded(child: Text('REPS', style: header)),
                    SizedBox(width: 48, child: Text('DONE', style: header, textAlign: TextAlign.center)),
                  ],
                ),
                for (var i = 0; i < log.sets.length; i++)
                  Dismissible(
                    key: ObjectKey(log.sets[i]),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 12),
                      child: const Icon(Icons.delete_outline, color: AppColors.red),
                    ),
                    onDismissed: (_) => state.removeSet(log, log.sets[i]),
                    child: _SetRow(index: i, entry: log.sets[i], onChanged: state.touch),
                  ),
                if (log.sets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('No sets yet', style: TextStyle(color: AppColors.muted)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text('Swipe a set left to delete it.', style: TextStyle(color: AppColors.muted, fontSize: 11)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => state.addSet(log),
            icon: const Icon(Icons.add),
            label: const Text('Add set'),
          ),
        ],
      ),
      bottom: PrimaryButton('Done', () => Navigator.of(context).pop()),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.index, required this.entry, required this.onChanged});
  final int index;
  final SetEntry entry;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(width: 36, child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(
            child: TextFormField(
              initialValue: entry.weight == 0 ? '' : fmtNum(entry.weight),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: '0'),
              onChanged: (v) {
                entry.weight = double.tryParse(v) ?? 0;
                AppScope.read(context).save();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              initialValue: entry.reps == 0 ? '' : '${entry.reps}',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: '0'),
              onChanged: (v) {
                entry.reps = int.tryParse(v) ?? 0;
                AppScope.read(context).save();
              },
            ),
          ),
          SizedBox(
            width: 48,
            child: Checkbox(
              value: entry.done,
              onChanged: (v) {
                entry.done = v ?? false;
                onChanged();
              },
            ),
          ),
        ],
      ),
    );
  }
}
