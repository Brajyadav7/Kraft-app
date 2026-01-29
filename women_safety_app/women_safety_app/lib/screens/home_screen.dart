import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/sos_button.dart';
import '../services/shake_service.dart';
import '../services/emergency_service.dart';
import '../services/safety_checkin_service.dart';
import '../services/safety_rating_service.dart';
import '../services/emergency_numbers_service.dart';
import '../services/trusted_zone_service.dart';
import '../services/recording_service.dart';
import 'contacts_screen.dart';
import 'settings_screen.dart';
import 'botpress_chat_screen.dart';
import '../services/voice_command_service.dart';
import '../services/permission_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ShakeDetectionService _shakeService = ShakeDetectionService();
  bool _shakeEnabled = false;
  bool _voiceSosEnabled = false;
  final VoiceCommandService _voiceService = VoiceCommandService();
  Position? _currentPosition;
  String? _locationName;
  double _safetyRating = 5.0;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _shakeEnabled = false;
    _voiceSosEnabled = false;
    _initializeVoiceService();
    _checkSafetyCheckIn();
    _initializeAndLoadLocation();
    _shakeService.initializeNotifications();
  }

  Future<void> _requestPermissions() async {
    await PermissionService.requestAllPermissions();
  }

  Future<void> _initializeVoiceService() async {
    await _voiceService.initialize();
  }

  void _toggleVoiceSos() {
    setState(() {
      _voiceSosEnabled = !_voiceSosEnabled;
    });

    if (_voiceSosEnabled) {
      _voiceService.startListening(
        onResult: (text) {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎤 Heard: "$text"'),
                duration: const Duration(milliseconds: 1000),
                backgroundColor: Colors.blue.shade900,
              ),
            );
          }
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎤 Voice SOS Active! Say "HELP" or "EMERGENCY"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      _voiceService.stopListening();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice SOS Deactivated'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }
  }

  Future<void> _initializeAndLoadLocation() async {
    // Initialize default zones (Chandigarh University)
    await TrustedZoneService.initializeDefaultZones();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
        forceAndroidLocationManager: true,
      );

      final rating = await SafetyRatingService.calculateSafetyRating(position);
      final locationName = await TrustedZoneService.getLocationName(position);

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _locationName = locationName;
          _safetyRating = rating;
          _loadingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading location: $e');
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  Future<void> _refreshLocation() async {
    setState(() => _loadingLocation = true);
    await _loadCurrentLocation();
  }

  Future<void> _callEmergency(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot call $number on this device'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error calling $number: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error initiating call'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkSafetyCheckIn() async {
    final isOverdue = await SafetyCheckInService.isCheckInOverdue();
    if (isOverdue && mounted) {
      _showCheckInDialog();
    }
  }

  void _showCheckInDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Safety Check-in'),
        content: const Text('Are you safe? Please check in.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _recordCheckIn();
            },
            child: const Text('I\'m Safe'),
          ),
        ],
      ),
    );
  }

  Future<void> _recordCheckIn() async {
    await SafetyCheckInService.recordCheckIn();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Check-in recorded'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _shakeService.stopListening();
    super.dispose();
  }

  Future<void> _triggerSOSFromShake() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('📱 Shake SOS Activated! Sending Alerts...'),
          backgroundColor: Colors.red.shade900,
          duration: const Duration(seconds: 2),
        ),
      );

      // Trigger the SOS logic via EmergencyService
      await EmergencyService.triggerSOS((status) {
        if (mounted) {
          _showSOSStatus(status);
        }
      });
    }
  }

  void _showSOSStatus(String status) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(status),
        duration: const Duration(seconds: 2),
        backgroundColor: status.toLowerCase().contains('error') || status.toLowerCase().contains('failed')
            ? Colors.red.shade900
            : Colors.blue.shade900,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KRAFT',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.red.shade700,
        elevation: 8,
        actions: [
          // Shake detection toggle button
          Tooltip(
            message: _shakeEnabled
                ? 'Shake detection ON'
                : 'Shake detection OFF',
            child: IconButton(
              icon: Icon(
                _shakeEnabled ? Icons.vibration : Icons.volume_off,
                size: 24,
                color: _shakeEnabled ? Colors.yellow : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _shakeEnabled = !_shakeEnabled;
                  if (_shakeEnabled) {
                    _shakeService.startListening(_triggerSOSFromShake);
                  } else {
                    _shakeService.stopListening();
                  }
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _shakeEnabled
                            ? '✅ Shake Detection ENABLED'
                            : '❌ Shake Detection DISABLED',
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          // Voice SOS Toggle
          IconButton(
            icon: Icon(
              _voiceSosEnabled ? Icons.mic : Icons.mic_off,
              color: _voiceSosEnabled ? Colors.greenAccent : Colors.white,
            ),
            onPressed: _toggleVoiceSos,
            tooltip: 'Voice SOS (Say "Help")',
          ),
          IconButton(
            icon: const Icon(Icons.person_add, size: 24),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactsScreen()),
            ),
            tooltip: 'Add emergency contacts',
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy, size: 24),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BotpressChatScreen(),
              ),
            ),
            tooltip: 'AI Safety Assistant',
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 24),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            tooltip: 'Settings & Features',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.pink.shade50],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Recording Status Banner
              ValueListenableBuilder<bool>(
                valueListenable: RecordingService.isRecordingNotifier,
                builder: (context, isRecording, child) {
                  if (!isRecording) return const SizedBox.shrink();
                  return Container(
                    width: double.infinity,
                    color: Colors.red,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          "RECORDING ACTIVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await EmergencyService.stopSOS(onStatusChange: (status) {
                              if (mounted) {
                                _showSOSStatus(status);
                              }
                            });
                          },
                          icon: const Icon(Icons.stop, color: Colors.red),
                          label: const Text(
                            "STOP",
                            style: TextStyle(color: Colors.red),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 80,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Emergency Alert',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Press the SOS button or shake your phone to send alerts to your emergency contacts',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const SosButton(),
              const SizedBox(height: 30),

              // Location and Safety Rating Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _loadingLocation
                        ? SizedBox(
                            height: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 12),
                                const Text('Loading location...'),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Current Location
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.red.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Current Location',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelMedium,
                                        ),
                                        // Place Name (if in trusted zone)
                                        if (_locationName != null)
                                          Text(
                                            _locationName!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green.shade700,
                                                ),
                                          ),
                                        if (_currentPosition != null)
                                          Text(
                                            '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          )
                                        else
                                          Text(
                                            'Location unavailable',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: _refreshLocation,
                                    iconSize: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Safety Rating
                              Container(
                                decoration: BoxDecoration(
                                  color: SafetyRatingService.getRatingColor(
                                    _safetyRating,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: SafetyRatingService.getRatingColor(
                                      _safetyRating,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.security,
                                      color: SafetyRatingService.getRatingColor(
                                        _safetyRating,
                                      ),
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Area Safety Rating',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelMedium,
                                          ),
                                          Text(
                                            '${_safetyRating.toStringAsFixed(1)}/10 - ${SafetyRatingService.getRatingLabel(_safetyRating)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      SafetyRatingService.getRatingColor(
                                                        _safetyRating,
                                                      ),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Emergency Numbers Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Numbers',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.0,
                          ),
                      itemCount:
                          EmergencyNumbersService.emergencyNumbers.length,
                      itemBuilder: (context, index) {
                        final emergency =
                            EmergencyNumbersService.emergencyNumbers[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: () => _callEmergency(emergency.number),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    emergency.icon,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  Text(
                                    emergency.name,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    emergency.number,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _callEmergency(emergency.number),
                                    icon: const Icon(Icons.call, size: 16),
                                    label: const Text('Call'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Shake detection status indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _shakeEnabled
                        ? Colors.yellow.shade50
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _shakeEnabled
                          ? Colors.yellow.shade400
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _shakeEnabled ? Icons.vibration : Icons.volume_off,
                        color: _shakeEnabled ? Colors.orange : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _shakeEnabled
                              ? 'Shake detection is active'
                              : 'Shake detection is inactive',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _shakeEnabled
                                    ? Colors.orange
                                    : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Make sure to add your emergency contacts in settings',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget to show shake pending notification with countdown and cancel option
class _ShakePendingDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ShakePendingDialog({required this.onConfirm, required this.onCancel});

  @override
  State<_ShakePendingDialog> createState() => _ShakePendingDialogState();
}

class _ShakePendingDialogState extends State<_ShakePendingDialog>
    with TickerProviderStateMixin {
  late AnimationController _countdownController;
  int _secondsRemaining = 5;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // Update countdown every second
    _countdownController.addListener(() {
      final newSeconds = (5 - (_countdownController.value * 5)).ceil();
      if (newSeconds != _secondsRemaining && mounted) {
        setState(() => _secondsRemaining = newSeconds);
      }

      // Auto-confirm when countdown reaches 0
      if (_countdownController.isCompleted && mounted) {
        widget.onConfirm();
      }
    });

    _countdownController.forward();
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red.shade900, Colors.red.shade700],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Alert Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.vibration, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Shake Detected!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              'Was this intentional?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Countdown Circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _countdownController.value,
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation(
                      Colors.white.withValues(alpha: 0.8),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                Text(
                  _secondsRemaining.toString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Info text
            Text(
              'Sending SOS in $_secondsRemaining seconds...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: widget.onCancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Send SOS Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: widget.onConfirm,
                    child: const Text(
                      'Send SOS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
