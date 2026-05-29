import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm.dart';
import '../providers/alarm_provider.dart';
import '../generated/app_localizations.dart';

class AddEditAlarmScreen extends StatefulWidget{
  final Alarm? existing;
  const AddEditAlarmScreen({super.key, this.existing});

  @override
  State<AddEditAlarmScreen> createState() => _AddEditAlarmScreenState();

}

class _AddEditAlarmScreenState extends State<AddEditAlarmScreen> {
  static const _uuid = Uuid();

  late int _hour;
  late int _minute;
  late String _label;
  late Set<Weekday> _repeatDays;
  late PuzzleType _puzzleType;

  final _labelController = TextEditingController();

  static const _bg = Color(0xFF000000);
  static const _surface = Color(0xFF1C1C1E);
  static const _surface2 = Color(0xFF2C2C2E);
  static const _divider = Color(0xFF38383A);
  static const _orange = Color(0xFFFF9F0A);
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xFF8E9E93);

  @override
  void initState(){
    super.initState();
    final a = widget.existing;
    _hour = a?.hour??TimeOfDay.now().hour;
    _minute = a?.minute??TimeOfDay.now().minute;
    _label = a?.label??'';
    _repeatDays = Set.of(a?.repeatDays??{});
    _puzzleType = a?.puzzleType??PuzzleType.math;
    _labelController.text = _label;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _save() {
    final alarm = Alarm(
      id: widget.existing?.id??_uuid.v4(),
      label: _labelController.text.trim(),
      hour: _hour,
      minute: _minute,
      repeatDays: _repeatDays,
      puzzleType: _puzzleType,
    );
    final provider = context.read<AlarmProvider>();
    widget.existing != null ? provider.updateAlarm(alarm):provider.addAlarm(alarm);
    Navigator.pop(context);

  }

  @override
  Widget build (BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold (
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical:4),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: _orange,fontSize:17)),

                  ),
                  const Spacer(),
                  Text(
                    isEditing?'Edit Alarm' : 'Add Alarm',
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 17, fontWeight: FontWeight.w600
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: _save,
                    child: const Text('Save', style:TextStyle(color: _orange, fontSize: 17, fontWeight: FontWeight.w600,)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding:EdgeInsets.zero,
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
                        initialDateTime: DateTime(2000,1,1,_hour,_minute),
                        use24hFormat: false,
                        onDateTimeChanged: (dt) {
                          setState(() {
                            _hour = dt.hour;
                            _minute = dt.minute;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _GroupLabel('ALARM'),
                  _GroupContainer(children: [
                    _LabelRow(controller: _labelController),
                    _RowDivider(),
                    _RepeatRow(
                      selected: _repeatDays,
                      onChanged: (days) => setState(() => _repeatDays = days),

                    ),
                    _RowDivider(),
                    _PuzzleRow(
                      selected: _puzzleType,
                      onChanged:(t) => setState(() => _puzzleType = t),
                    ),
                  ]),
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

const _surface2 = Color(0xFF2C2C2E);
const _orange = Color(0xFFFF9F0A);
const _textSecondary = Color(0xFF8E8E93);

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
    child: Text(
      text, style:const TextStyle(
        color: Color(0xFF8E8E93),
        fontSize:13,
        fontWeight: FontWeight.w400,
        letterSpacing:0.5,
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
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(left: 16),
    child: Divider(color: Color(0xFF38383A), height:1,thickness:0.5),
  );
}

class _LabelRow extends StatelessWidget{
  final TextEditingController controller;
  const _LabelRow({required this.controller});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal:16,vertical:4),
    child: Row(
      children:[
        const Text('Label',
          style: TextStyle(color: Colors.white, fontSize:16)),
          const SizedBox(width: 16),
          Expanded(
            child:TextField(
              controller: controller,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Alarm',
                hintStyle: TextStyle(color: Color(0xFF48484A)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical:12),
              ),
            ),
          ),
      ],
    ),
  );
}

class _RepeatRow extends StatelessWidget {
  final Set<Weekday> selected;
  final ValueChanged<Set<Weekday>> onChanged;
  const _RepeatRow({required this.selected, required this.onChanged});

  static const _abbr = ['M','T', 'W', 'T', 'F', 'S', 'S'];

  String get _summary {
    if (selected.isEmpty) return 'Never';
    if (selected.length == 7) return 'Every Day';
    final weekdays =  {Weekday.mon, Weekday.tue, Weekday.wed, Weekday.thu, Weekday.fri};
    final weekend = {Weekday.sat, Weekday.sun};
    if (selected.containsAll(weekdays) && selected.length == 5) return 'Weekdays';
    if (selected.containsAll(weekend) && selected.length == 2) return 'Weekends';
    const names = {
    Weekday.mon: 'Mon', Weekday.tue: 'Tue', Weekday.wed: 'Wed',Weekday.thu: 'Thu', Weekday.fri: 'Fri', Weekday.sat: 'Sat', Weekday.sun: 'Sun',
    };
    return selected.map((d) => names[d]!).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16,4,16,12),
      iconColor: const Color(0xFF636366),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      title: const Text('Repeat',
      style: TextStyle(color: Colors.white, fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children:[
          Text(_summary,
          style:const TextStyle(color: Color(0xFF8E8E93), fontSize:16)),
          const SizedBox(width: 6),
          const Icon(CupertinoIcons.chevron_right,
          color: Color(0xFF636366), size: 16),
        ],
      ),
      children:[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final day = Weekday.values[i];
            final on = selected.contains(day);
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
                  color: on ? _orange: const Color(0xFF2C2C2E),
                ),
                child: Center(
                  child:Text(
                    _abbr[i],
                    style: TextStyle(
                      color: on?Colors.black:const Color(0xFF8E8E93),
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

class _PuzzleRow extends StatelessWidget{
  final PuzzleType selected;
  final ValueChanged<PuzzleType> onChanged;
  const _PuzzleRow({required this.selected, required this.onChanged});
  
  static const _labels = {
    PuzzleType.math: 'Math',
    PuzzleType.trivia: 'Trivia',
    PuzzleType.pattern: 'Pattern',
  };

  @override
  Widget build(BuildContext context){
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16,4,16,16),
      iconColor: const Color(0xFF636366),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      title: const Text('Puzzle',
      style: TextStyle(color: Colors.white, fontSize:16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_labels[selected]!,
          style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 16)),
          const SizedBox(width: 6),
          const Icon(CupertinoIcons.chevron_right,
          color: Color(0xFF636366), size: 16),
        ],
      ),
      children: [
        CupertinoSlidingSegmentedControl<PuzzleType>(
          groupValue: selected,
          backgroundColor: const Color(0xFF2C2C2E),
          thumbColor: const Color(0xFF636366),
          children: const{
            PuzzleType.math: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Math', style: TextStyle(color: Colors.white, fontSize:13)),
            ),
            PuzzleType.trivia: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('Trivia',
              style:TextStyle(color: Colors.white, fontSize:13)),

            ),
            PuzzleType.pattern: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child:Text('Pattern',
              style: TextStyle(color: Colors.white, fontSize:13)),
            ),
          },
          onValueChanged: (t) {if (t != null) onChanged(t);},
        ),
      ],
    );
  }
}