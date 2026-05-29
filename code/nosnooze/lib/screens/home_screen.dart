import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../models/alarm.dart';
import 'add_edit_alarm_screen.dart';
import '../generated/app_localizations.dart';


class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  bool _editing = false;

  static const _bg = Color(0xFF000000);
  static const _surface = Color(0xFF1C1C1E);
  static const _divider = Color(0xFF38383A);
  static const _textPrimary = Colors.white;
  static const _textSecondary = Color(0xFF8E8E93);
  static const _orange = Color(0xFFFF9F0A);
  static const _green = Color(0xFF34C759);
  static const _red = Color(0xFFFF3B30);


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AlarmProvider>();
    final alarms = provider.alarms;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NavBar(
              editing: _editing,
              canUndo: provider.canUndo,
              canRedo: provider.canRedo,
              onEditToggle: () => setState(() => _editing = !_editing),
              onAdd: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const AddEditAlarmScreen()),
              ),
              onUndo: () => context.read<AlarmProvider>().undo(),
              onRedo: () => context.read<AlarmProvider>().redo(),
            ),
            Expanded(
              child: alarms.isEmpty ? _EmptyState(l10n: l10n) : _AlarmList(
                alarms: alarms,
                editing: _editing, 
                onToggle: (id) => context.read<AlarmProvider>().toggleAlarm(id),
                onDelete:(id) => context.read<AlarmProvider>().deleteAlarm(id),
                onTap: (alarm) => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => AddEditAlarmScreen(existing: alarm),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget{
  final bool editing;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onEditToggle;
  final VoidCallback onAdd;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const _NavBar({
    required this.editing,
    required this.canUndo,
    required this.canRedo,
    required this.onEditToggle,
    required this.onAdd,
    required this.onUndo,
    required this.onRedo,
  });

  static const _orange = Color(0xFFFF9F0A);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8,16, 0),
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 44,
                onPressed: onEditToggle,
                child: Text(
                  editing? 'Done' : 'Edit',
                  style: const TextStyle(
                    color: _orange,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (editing) ... [
                const SizedBox(width: 4),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 36,
                    onPressed: canUndo ? onUndo : null,
                    child: Icon(
                      CupertinoIcons.arrow_uturn_left,
                      color: canUndo ? _orange : const Color(0xFF48484A),
                      size: 20,
                ),
              ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 36,
                  onPressed: canRedo ? onRedo : null,
                  child:Icon(
                    CupertinoIcons.arrow_uturn_right,
                    color: canRedo ? _orange : const Color(0xFF48484A),
                    size:20,
                  ),
                ),
              ],
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize:44,
                onPressed: onAdd,
                child: const Icon(
                  CupertinoIcons.add_circled_solid,
                  color: _orange,
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text('Alarms',
          style:TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
          ),
          ),
          const Divider(color: Color(0xFF38383A), height: 1, thickness: 0.5),

      ],
    );
  }
}

class _AlarmList extends StatelessWidget {
  final List<Alarm> alarms;
  final bool editing;
  final void Function(String id) onToggle;
  final void Function(String id) onDelete;
  final void Function(Alarm) onTap;

  const _AlarmList({
    required this.alarms,
    required this.editing,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: alarms.length,
      separatorBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(left: 76),
        child: Divider(
          color: Color(0xFF38383A),
          height: 1,
          thickness: 0.5,
        ),
      ),
      itemBuilder: (ctx, i) => _AlarmRow(
        alarm: alarms[i],
        editing: editing,
        onToggle: () => onToggle(alarms[i].id),
        onDelete: () => onDelete(alarms[i].id),
        onTap: () => onTap(alarms[i]),
      ),
    );
  }
}


class _AlarmRow extends StatefulWidget {
  final Alarm alarm;
  final bool editing;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _AlarmRow({
    required this.alarm,
    required this.editing,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<_AlarmRow> createState() => _AlarmRowState();
}

class _AlarmRowState extends State<_AlarmRow> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250),
    );
    _slideIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    
  }

  @override
  void didUpdateWidget(_AlarmRow old){
    super.didUpdateWidget(old);
    widget.editing ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  void dispose(){
    _ctrl.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    final a = widget.alarm;
    final dimmed = !a.isEnabled;

    return GestureDetector(
      onTap: widget.editing? widget.onTap: null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: const Color(0xFF1C1C1E),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical:14),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizeTransition(
            sizeFactor: _slideIn,
            axis: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: widget.onDelete,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w200,
                      color: dimmed ? const Color(0xFF48484A) : Colors.white,
                      letterSpacing: -1.5,
                      height: 1.0,
                    ),
                    children: [
                      TextSpan(text: _hourMinute(a)),
                      TextSpan(
                        text: ' ${_period(a)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          color: dimmed ? const Color(0xFF48484A) : const Color(0xFFAEAEB2),
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subLabel(a),
                  style: TextStyle(
                    fontSize:14,
                    color: dimmed ? const Color(0xFF48484A) : const Color(0xFF8E8E93),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (!widget.editing)
          CupertinoSwitch(
            value: a.isEnabled,
            activeColor: const Color(0xFF34C759),
            onChanged: (_) => widget.onToggle(),

          ),

          if(widget.editing)
          const Icon(
            CupertinoIcons.chevron_right,
            color: Color(0xFF636366),
            size: 18,
          ),
        ],
        ),
      ),
    );
  }

  String _hourMinute(Alarm a) {
    final h = a.hour == 0 ? 12 : (a.hour > 12 ? a.hour -12:a.hour);
    final m = a.minute.toString().padLeft(2,'0');
    return '$h:$m';
  }

  String _period(Alarm a) => a.hour < 12 ? 'AM' : 'PM';

  String _subLabel(Alarm a ){
    final parts = <String>[];
    if (a.label.isNotEmpty) parts.add(a.label);
    parts.add(a.repeatLabel);
    return parts.join(' · ');
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        l10n.noAlarmsYet,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF636366),
          fontSize: 16,
          height: 1.6,
        ),
      ),
    );
  }
}