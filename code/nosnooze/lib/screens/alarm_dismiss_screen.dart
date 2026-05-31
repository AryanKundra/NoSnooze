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

const _kBg      = Color(0xFF000000);
const _kSurface = Color(0xFF1C1C1E);
const _kOrange  = Color(0xFFFF9F0A);
const _kGrey    = Color(0xFF8E8E93);
const _kDivider = Color(0xFF38383A);
const _kGreen   = Color(0xFF34C759);

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
      duration: const Duration(milliseconds: 900),
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
          backgroundColor: _kBg,
          body: Center(
            child: Text(
              l10n.alarmNotFound,
              style: const TextStyle(color: _kGrey, fontSize: 16),
            ),
          ),
        ),
      );
    }

    if (_dismissed) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: _kBg,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline,
                    color: _kGreen, size: 72),
                const SizedBox(height: 16),
                Text(
                  l10n.correct,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _kBg,
        body: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: _kOrange))
              : _buildContent(l10n),
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Icon(
              Icons.alarm_rounded,
              size: 56,
              color: Color.lerp(_kOrange, Colors.white, _pulseController.value * 0.3),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _alarm.label.isEmpty ? l10n.puzzleTitle : _alarm.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.puzzleInstructions,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _kGrey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Divider(color: _kDivider, height: 32, thickness: 0.5),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kOrange.withValues(alpha: 0.35), width: 1),
            ),
            child: Text(
              _puzzle!.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                height: 1.55,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 12),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
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
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swipe_down_rounded,
                        color: _kGrey.withValues(alpha: 0.6), size: 17),
                    const SizedBox(width: 8),
                    Text(
                      l10n.shakeHint,
                      style: TextStyle(
                          color: _kGrey.withValues(alpha: 0.6), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            secondChild: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _kOrange.withValues(alpha: 0.5)),
              ),
              child: Text(
                _puzzle!.hint ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _kOrange, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 20),

       
          TextField(
            controller: _answerController,
            autofocus: true,
            keyboardType: _alarm.puzzleType == PuzzleType.math
                ? TextInputType.number
                : TextInputType.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
            decoration: InputDecoration(
              hintText: l10n.yourAnswer,
              hintStyle: TextStyle(
                  color: _kGrey.withValues(alpha: 0.5), fontSize: 16),
              errorText: _errorMessage,
              errorStyle: const TextStyle(color: _kOrange, fontSize: 13),
              filled: true,
              fillColor: _kSurface,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _kOrange, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _kOrange, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _kOrange, width: 1.5),
              ),
            ),
            onSubmitted: (_) => _checkAnswer(),
          ),
          const SizedBox(height: 16),

        
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                l10n.dismissAlarm,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}