import 'dart:async';
import 'package:flutter/material.dart';

class FakeCallService {
  static final FakeCallService _instance = FakeCallService._internal();
  static bool _isCallActive = false;
  static Timer? _callTimer;

  factory FakeCallService() {
    return _instance;
  }

  FakeCallService._internal();

  /// Start a fake incoming call with a default contact name
  static Future<void> startFakeCall({
    String? contactName,
    Function()? onCallAnswered,
    Function()? onCallRejected,
    BuildContext? context,
  }) async {
    if (_isCallActive) {
      debugPrint('Call already in progress');
      return;
    }

    _isCallActive = true;
    contactName = contactName ?? 'Unknown Caller';

    // Show incoming call screen for 30 seconds or until user acts
    if (context != null) {
      _showIncomingCallUI(
        context: context,
        contactName: contactName,
        onAnswered: onCallAnswered,
        onRejected: onCallRejected,
      );
    } else {
      // Fallback: Simple 30 second delay
      _callTimer = Timer(const Duration(seconds: 30), () {
        _isCallActive = false;
        onCallRejected?.call();
      });
    }
  }

  /// Show incoming call UI overlay
  static void _showIncomingCallUI({
    required BuildContext context,
    required String contactName,
    Function()? onAnswered,
    Function()? onRejected,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _IncomingCallWidget(
          contactName: contactName,
          onAnswered: () {
            onAnswered?.call();
            _isCallActive = false;
            Navigator.pop(context);
          },
          onRejected: () {
            onRejected?.call();
            _isCallActive = false;
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  /// Get a list of fake contact names for testing
  static List<String> getFakeContactNames() {
    return [
      'Mom',
      'Dad',
      'Sister',
      'Brother',
      'Best Friend',
      'Emergency Services',
    ];
  }

  /// Check if call is currently active
  static bool isCallActive() => _isCallActive;

  /// End fake call manually
  static void endCall() {
    _isCallActive = false;
    _callTimer?.cancel();
  }
}

/// Widget to display incoming call UI
class _IncomingCallWidget extends StatefulWidget {
  final String contactName;
  final VoidCallback onAnswered;
  final VoidCallback onRejected;

  const _IncomingCallWidget({
    required this.contactName,
    required this.onAnswered,
    required this.onRejected,
  });

  @override
  State<_IncomingCallWidget> createState() => _IncomingCallWidgetState();
}

class _IncomingCallWidgetState extends State<_IncomingCallWidget> {
  late Timer _callTimer;

  @override
  void initState() {
    super.initState();
    // Auto-reject call after 30 seconds
    _callTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        widget.onRejected();
      }
    });
  }

  @override
  void dispose() {
    _callTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar - Call type indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_calling_3,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Incoming call',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Contact Avatar - Large circle
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Contact Name - Large and bold
                    Text(
                      widget.contactName,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Phone number or contact info
                    Text(
                      'Mobile Number',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),

              // Message button (optional)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.amber.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Message',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom action buttons - Android style
              Padding(
                padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Decline Button
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onRejected,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Text(
                              'Decline',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Center white circle with green phone
                      GestureDetector(
                        onTap: widget.onAnswered,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.call,
                            color: Colors.green.shade600,
                            size: 32,
                          ),
                        ),
                      ),

                      // Answer Button
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onAnswered,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Text(
                              'Answer',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
