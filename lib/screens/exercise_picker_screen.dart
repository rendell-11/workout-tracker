import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ExercisePickerScreen extends StatefulWidget {
  const ExercisePickerScreen({super.key, required this.weekday, required this.group});
  final int weekday;
  final String group;

  @override
  State<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends State<ExercisePickerScreen> {
  late final Set<String> _selected = AppScope.read(context)
      .groupPlan(widget.weekday, widget.group)
      .exercises
      .map((e) => e.info.name)
      .toSet();
  String _filter = 'All';

  List<ExerciseInfo> get _options => exerciseLibrary.where((e) => e.group == widget.group).toList();

  void _save() {
    AppScope.read(context).setExercises(
      widget.weekday,
      widget.group,
      _options.where((e) => _selected.contains(e.name)).toList(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final options = _options;
    final filters = ['All', ...{for (final e in options) e.equipment}];
    final shown = _filter == 'All' ? options : options.where((e) => e.equipment == _filter).toList();

    return PageScaffold(
      title: widget.group,
      subtitle: 'Select exercises to add to your workout',
      body: Column(
        children: [
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final f in filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _filter == f ? AppColors.red : AppColors.card,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _filter == f ? AppColors.red : AppColors.border),
                        ),
                        child: Text(f == 'All' ? 'All exercises' : f, style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
              children: [for (final e in shown) _tile(e)],
            ),
          ),
        ],
      ),
      bottom: PrimaryButton('Save (${_selected.length})', _save),
    );
  }

  Widget _tile(ExerciseInfo e) {
    final selected = _selected.contains(e.name);
    return GestureDetector(
      onTap: () => setState(() => selected ? _selected.remove(e.name) : _selected.add(e.name)),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.red : AppColors.border),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: ImagePlaceholder.muscle(e.group, height: double.infinity)),
                const SizedBox(height: 8),
                Text(e.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Text(e.equipment, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? AppColors.red : AppColors.muted, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
