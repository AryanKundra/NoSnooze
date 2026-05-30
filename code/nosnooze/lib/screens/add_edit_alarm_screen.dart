import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm.dart';
import '../providers/alarm_provider.dart';
import '../generated/app_localizations.dart';

const _kBg       = Color(0xFF000000);
const _kSurface  = Color(0xFF1C1C1E);
const _kSurface2 = Color(0xFF2C2C2E);
const _kDivider  = Color(0xFF38383A);
const _kOrange   = Color(0xFFFF9F0A);
const _kGrey     = Color(0xFF8E8E93);
const _kGreyDark = Color(0xFF636366);
const _kGreyDeep = Color(0xFF48484A);

class AddEditAlarmScreen extends StatefulWidget {
  final Alarm? existing;
  const AddEditAlarmScreen({super.key, this.existing});

  @override
  State<AddEditAlarmScreen> createState() => _AddEditAlarmScreenState();
}

class _AddEditAlarmScreenState extends State<AddEditAlarmScreen> {
  static const _uuid = Uuid();

  late int _hour;
  late int _minute;
  late Set<Weekday> _repeatDays;
  late PuzzleType _puzzleType;

  final _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _hour       = a?.hour   ?? TimeOfDay.now().hour;
    _minute     = a?.minute ?? TimeOfDay.now().minute;
    _repeatDays = Set.of(a?.repeatDays ?? {});
    _puzzleType = a?.puzzleType ?? PuzzleType.math;
    _labelController.text = a?.label ?? '';
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _save() {
    final alarm = Alarm(
      id:         widget.existing?.id ?? _uuid.v4(),
      label:      _labelController.text.trim(),
      hour:       _hour,
      minute:     _minute,
      repeatDays: _repeatDays,
      puzzleType: _puzzleType,
    );
    final provider = context.read<AlarmProvider>();
    widget.existing != null ? provider.updateAlarm(alarm) : provider.addAlarm(alarm);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.existing != null;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(color: _kOrange, fontSize: 17),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isEditing ? l10n.editAlarm : l10n.addAlarm,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: _save,
                    child: Text(
                      l10n.save,
                      style: const TextStyle(
                        color: _kOrange,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: 220,
                    child: CupertinoTheme(
                      data: const CupertinoThemeData(
                        brightness: Brightness.dark,
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: DateTime(2000, 1, 1, _hour, _minute),
                        use24hFormat: false,
                        onDateTimeChanged: (dt) {
                          setState(() {
                            _hour   = dt.hour;
                            _minute = dt.minute;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _GroupLabel(l10n.alarmSectionHeader),
                  _GroupContainer(
                    children: [
                      _LabelRow(controller: _labelController),
                      const _RowDivider(),
                      _RepeatRow(
                        selected:  _repeatDays,
                        onChanged: (days) => setState(() => _repeatDays = days),
                      ),
                      const _RowDivider(),
                      _PuzzleRow(
                        selected:  _puzzleType,
                        onChanged: (t) => setState(() => _puzzleType = t),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Text(
          text,
          style: const TextStyle(
            color: _kGrey,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      );
}

class _GroupContainer extends StatelessWidget {
  final List<Widget> children;
  const _GroupContainer({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: children),
      );
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Divider(color: _kDivider, height: 1, thickness: 0.5),
      );
}

class _LabelRow extends StatelessWidget {
  final TextEditingController controller;
  const _LabelRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            l10n.alarmLabel,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              style: const TextStyle(color: _kGrey, fontSize: 16),
              decoration: InputDecoration(
                hintText: l10n.alarmLabelHint,
                hintStyle: const TextStyle(color: _kGreyDeep),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RepeatRow extends StatelessWidget {
  final Set<Weekday> selected;
  final ValueChanged<Set<Weekday>> onChanged;
  const _RepeatRow({required this.selected, required this.onChanged});

  String _summary(AppLocalizations l10n) {
    if (selected.isEmpty) return l10n.repeatNever;
    if (selected.length == 7) return l10n.repeatEveryDay;
    const weekdays = {Weekday.mon, Weekday.tue, Weekday.wed, Weekday.thu, Weekday.fri};
    const weekend  = {Weekday.sat, Weekday.sun};
    if (selected.containsAll(weekdays) && selected.length == 5) return l10n.repeatWeekdays;
    if (selected.containsAll(weekend)  && selected.length == 2) return l10n.repeatWeekends;
    final names = {
      Weekday.mon: l10n.dayMon, Weekday.tue: l10n.dayTue, Weekday.wed: l10n.dayWed,
      Weekday.thu: l10n.dayThu, Weekday.fri: l10n.dayFri, Weekday.sat: l10n.daySat,
      Weekday.sun: l10n.daySun,
    };
    return selected.map((d) => names[d]!).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final abbr = [
      l10n.dayMonAbbr, l10n.dayTueAbbr, l10n.dayWedAbbr, l10n.dayThuAbbr,
      l10n.dayFriAbbr, l10n.daySatAbbr, l10n.daySunAbbr,
    ];

    return ExpansionTile(
      tilePadding:              const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding:          const EdgeInsets.fromLTRB(16, 4, 16, 12),
      iconColor:                _kGreyDark,
      backgroundColor:          Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      title: Text(l10n.repeatDays,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_summary(l10n), style: const TextStyle(color: _kGrey, fontSize: 16)),
          const SizedBox(width: 6),
          const Icon(CupertinoIcons.chevron_right, color: _kGreyDark, size: 16),
        ],
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final day = Weekday.values[i];
            final on  = selected.contains(day);
            return GestureDetector(
              onTap: () {
                final next = Set.of(selected);
                on ? next.remove(day) : next.add(day);
                onChanged(next);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: on ? _kOrange : _kSurface2,
                ),
                child: Center(
                  child: Text(
                    abbr[i],
                    style: TextStyle(
                      color: on ? Colors.black : _kGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PuzzleRow extends StatelessWidget {
  final PuzzleType selected;
  final ValueChanged<PuzzleType> onChanged;
  const _PuzzleRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = {
      PuzzleType.math:    l10n.mathPuzzle,
      PuzzleType.trivia:  l10n.triviaPuzzle,
      PuzzleType.pattern: l10n.patternPuzzle,
    };

    return ExpansionTile(
      tilePadding:              const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding:          const EdgeInsets.fromLTRB(16, 4, 16, 16),
      iconColor:                _kGreyDark,
      backgroundColor:          Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      title: Text(l10n.puzzleType,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(labels[selected]!,
              style: const TextStyle(color: _kGrey, fontSize: 16)),
          const SizedBox(width: 6),
          const Icon(CupertinoIcons.chevron_right, color: _kGreyDark, size: 16),
        ],
      ),
      children: [
        CupertinoSlidingSegmentedControl<PuzzleType>(
          groupValue:      selected,
          backgroundColor: _kSurface2,
          thumbColor:      _kGreyDark,
          children: {
            PuzzleType.math: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(l10n.mathPuzzle,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
            PuzzleType.trivia: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(l10n.triviaPuzzle,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
            PuzzleType.pattern: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(l10n.patternPuzzle,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
          },
          onValueChanged: (t) {
            if (t != null) onChanged(t);
          },
        ),
      ],
    );
  }
}