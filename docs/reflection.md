Course Topics Applied: 

1. Accessing Phone Sensors
We use the sensors_plus package to listen to the accelerometer via accelerometerEventStream() on the alarm dismiss screen. when the total magnitude across all three axes goes past the threshold of 20.0 the puzzle hint is revieald giving users a natural physical interaction (shaking the phone) as an alternative to the swipe down guesture without needing any screen input. 

2. Querying Web Services Using APIs
The Triva puzzle type fetches a question from the Open Triva Database (https://opentdb.com/api.php) using the http package. the response is JSON decoded and parsed to extract the question, answer, and inocrrect options which are then shuffled and formatted for display. we implemented a 5 second timeout and fallback to a locally generated math puzzle incase the request fails. This taught us how to handle async network calls defensivly where failure is unacceptable since the alarm has to be dismissible. 

3. Drawing with Canvas
The analog clock in the settings screen is built with a CustomPainter. the _ClockPainter class draws the clock face with 60 tick marks (longer one indicating hours (1-12) and three hands (hour, min, sec)) using trig to calculate hand angles from current time. An AnimationController in the parent widget ticks every second to trigger a repaint. shouldRepaint checks if the second has changed to avoid unnecesarry redraws, this was probably the most techinically involved UI compeneted in the app (and to be completely honest it wasn't really nesecarry at all). 

4. Geusture Detection
On the alarm dismiss screen we impleted a GuesterDetector using onPanUpdate and onPanEnd not just onTap to create a swipe down to reveal hint interaction. onPanUpdate accumulates the vertical delta into _slideOffset calmped to a target distance. when the offset reaches the target the hint is revealed. you can also trigger the hint by shaking your phone, this was done with the accelerometer shake detection as an alternative guesture. 

5. Undo and Redo

AlarmProvider maintains two List<List<Alarm>> stacks: _undoStack and _redoStack. Every mutating operation (add,edit,delete,toggle) first calls _snapshot(), which pushes a copy of the current alarm list onto the stack and then clears the redo stack. undo() pops from the undo stack, pushes the current state on the redo stack and applies the restored state. redo() does the reverse. since Alarm is immutable snapshots are safe and independent. the homescreen shows the undo/redo buttons in edit mode and they buttons are greyed out when the respective stacks are empty

6. Data persistence
Alarms are serialised to JSON and stored as a single string in SharedPreferences under the key nosnooze_alarm. The alarm model provides toJson()/fromJson and static listToJson()/listFromJson() methods. persistence is triggered after every mutation through _persist() in AlarmProvider. On startup, load() is called before runApp() so data is available on the first frame. The users selected locale is also saved under the key locale.

7. Internationalization: 
The app supports english and spanish using flutters flutter_localization and intl packages with ARB files (app_en.arb, app_es.arb) all user facing string are accesed through AppLocalizations.of(context) A LocaleProvider persist the chosen language switching languages in the settings screen updates the entire UI immediately with no restart. 


Accessibility and Inclusive Design
app uses high contrast colors throughout, there are interactive targes such as toggle switch, add button, day selector circiles all meet minimum tap target sizes. CupertinoSwitch provides native accessibilty semantics. the puzzle answer field is auto focused when the dismiss screen opens sothe user doesnt need to find it.

Resources and Citations:

alarm package documentation: https://pub.dev/packages/alarm — reviewed for AlarmSettings, VolumeSettings, NotificationSettings, and the ringing stream API.
sensors_plus package documentation: https://pub.dev/packages/sensors_plus — reviewed for accelerometerEventStream() usage.
provider package documentation: https://pub.dev/packages/provider — reviewed for ChangeNotifier, Consumer, and context.read / context.watch patterns.
shared_preferences package documentation: https://pub.dev/packages/shared_preferences
Open Trivia Database API: https://opentdb.com/api_config.php
Flutter CustomPainter documentation: https://api.flutter.dev/flutter/rendering/CustomPainter-class.html
Flutter Internationalisation guide: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
Gen Ai: used to assist with debugging alarm scheduling issues, fixing alarm.ringing stream type cast error, resturcturing alarm lookup login in AlarmDismissScreen. Prompts were focused on specific runtime errors, archetectural questions and code cleanup. AI was very helpful for finding bugs quickly but needed review as severial suggestions needed to be adapted inorder to work. 


What Changed from Original Concpet:
Our original proposal described a simple alarm app where a puzzle would block dismisissal and only be dismissed after solving a quick puzzle. The main idea of our app is unchanged but there have been a few implementation decisions that were evolved throuugh the implementation.

- Alarm package selection: we planned on using flutter_local_notifications for alarm scheduling, we switch the to the alarm package though as it was much more simpler to work with considering it handles the foreground service, audio, wake lock and lock screen presentation natively which would have been quite a hassle to code.
- Puzzle screen navigation: early versions passed only the integer alarm ID to the dismiss screen and relied on a hashCode reverse mapping to find the Alarm model. this was fragile and lead to the puzzle failing ot load in practice so we changed the approach to pass the UUID directly from the ringing streams payload field making the lookup direct aswell as reliable.
- Hint interaction: the original design had a shake for hint interaction, we added a swipe down gesture along with this though as a backup since somee devices may not have shake detection
- Localization scope: we only localized the most visible strings at first but realised we should localize everything so that it can be fully used by any spanish speakers. one caveat to this is that the puzzle screen doesnt have these localizations.

Future Work:
1. Custom puzzle difficulty and additional puzzle types: the math and puzzle difficulty are fixed in terms of how ahrd they are. a future version could offer different difficulty settings and we might be able to add new categories like word puzzles, memory sequences etc. Difficulty oculd also scale dynamically based on how often the user gets puzzles right/wrong

2. Alarm stats and streaks: the app has no memory of past alarm events, we could impleemnt a way to track how quickly a user is able to dismiss an alarm, how many puzzle they answer incorrectly, wheter they wake up on time etc. This data can be shown to the user inorder to motivate them to build better sleep habits possibly through the a form of a streak system. 

