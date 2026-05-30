import 'dart:async';
import 'package:alarm/alarm.dart' as alarm_pkg;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/alarm.dart';
import '../models/puzzle.dart';
import '../providers/alarm_provider.dart';
import '../utils/puzzle_service.dart';
import '../utils/notification_helper.dart';
import '../generated/app_localizations.dart';

class AlarmDismissScreen extends StatefulWidget {
  final int alarmIntId;

  final String? alarmUuid;

  const AlarmDismissScreen({
    super.key,
    required this.alarmIntId,
    this.alarmUuid,
  });

  @override
  State<AlarmDismissScreen> createState() => _AlarmDismissScreenState();
}

class _AlarmDismissScreenState extends State<AlarmDismissScreen>
    with SingleTickerProviderStateMixin {
  Puzzle? _puzzle;
  bool _loading = true;
  bool _hintVisible = false;
  bool _dismissed = false;
  bool _alarmNotFound = false;

  late Alarm _alarm;

  final TextEditingController _answerController = TextEditingController();
  String? _errorMessage;

  StreamSubscription<AccelerometerEvent>? _accelSub;

  static const double _shakeThreshold = 20.0;
  static const double _slideTarget = 200.0;
  double _slideOffset = 0;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _loadAlarmAndPuzzle();
    _startShakeDetection();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }



  @override
  void dispose() {
    _accelSub?.cancel();
    _answerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadAlarmAndPuzzle() async {
    await Future.microtask(() {});
    if (!mounted) return;

    final provider = context.read<AlarmProvider>();

    Alarm? found;

    if (widget.alarmUuid != null && widget.alarmUuid!.isNotEmpty) {
      found = provider.getAlarmById(widget.alarmUuid!);
    }

    if (found == null) {
      for (final a in provider.alarms) {
        if ((a.id.hashCode & 0x7FFFFFFF) == widget.alarmIntId) {
          found = a;
          break;
        }
      }
    }

    if (found == null) {
      try {
        final activeAlarms = await alarm_pkg.Alarm.getAlarms();
        for (final settings in activeAlarms) {
          if (settings.id == widget.alarmIntId) {
            final uuid = settings.payload;
            if (uuid != null && uuid.isNotEmpty) {
              found = provider.getAlarmById(uuid);
            }
            break;
          }
        }
      } catch (e) {
        debugPrint('Fallback alarm lookup error: $e');
      }
    }

    if (found == null) {
      await alarm_pkg.Alarm.stop(widget.alarmIntId);
      if (mounted) setState(() => _alarmNotFound = true);
      return;
    }

    _alarm = found;
    final puzzle = await PuzzleService.generate(_alarm.puzzleType);
    if (!mounted) return;

    setState(() {
      _puzzle = puzzle;
      _loading = false;
    });
  }

  void _startShakeDetection() {
    _accelSub = accelerometerEventStream().listen((event) {
      final magnitude = event.x.abs() + event.y.abs() + event.z.abs();
      if (magnitude > _shakeThreshold && !_hintVisible && _puzzle != null) {
        setState(() => _hintVisible = true);
      }
    });
  }

  void _checkAnswer() {
    if (_puzzle == null) return;
    if (_puzzle!.check(_answerController.text.trim())) {
      _dismissAlarm();
    } else {
      setState(() => _errorMessage = AppLocalizations.of(context)!.incorrect);
      _answerController.clear();
    }
  }

  Future<void> _dismissAlarm() async {
    await alarm_pkg.Alarm.stop(widget.alarmIntId);
    setState(() => _dismissed = true);

    await NotificationHelper.cancelAlarm(_alarm);
    if (_alarm.isEnabled && _alarm.repeatDays.isNotEmpty) {
      await NotificationHelper.scheduleNext(_alarm);
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_alarmNotFound) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          body: Center(
            child: Text(AppLocalizations.of(context)!.alarmNotFound,
                style: const TextStyle(color: Colors.white)),
          ),
        ),
      );
    }

    if (_dismissed) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.greenAccent, size: 80),
                const SizedBox(height: 16),
                Text(l10n.correct,
                    style: const TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE94560)))
              : _buildContent(l10n),
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Icon(
              Icons.alarm,
              size: 60,
              color: Color.lerp(
                const Color(0xFFE94560),
                Colors.orangeAccent,
                _pulseController.value,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _alarm.label.isEmpty ? l10n.puzzleTitle : _alarm.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.puzzleInstructions,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE94560).withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              _puzzle!.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _hintVisible
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _slideOffset =
                      (_slideOffset + details.delta.dy).clamp(0, _slideTarget);
                  if (_slideOffset >= _slideTarget) _hintVisible = true;
                });
              },
              onPanEnd: (_) => setState(() => _slideOffset = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3460),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.swipe_down,
                        color: Colors.white38, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.shakeHint,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ),
            ),
            secondChild: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Text(
                _puzzle!.hint ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.amber, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _answerController,
            autofocus: true,
            keyboardType: _alarm.puzzleType == PuzzleType.math
                ? TextInputType.number
                : TextInputType.text,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            decoration: InputDecoration(
              hintText: l10n.yourAnswer,
              hintStyle: const TextStyle(color: Colors.white30),
              errorText: _errorMessage,
              filled: true,
              fillColor: const Color(0xFF16213E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _checkAnswer(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              l10n.dismissAlarm,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}