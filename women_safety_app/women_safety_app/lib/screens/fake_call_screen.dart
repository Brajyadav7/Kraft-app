import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class FakeCallScreen extends StatefulWidget {
  final String contactName;
  final String phoneNumber;

  const FakeCallScreen({
    super.key,
    this.contactName = 'Singla',
    this.phoneNumber = 'Mobile +91 78371 47361',
  });

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  // States: 0 = Incoming, 1 = Connected
  int _callState = 0;
  Timer? _vibrationTimer;
  Timer? _callDurationTimer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startRinging();
  }

  @override
  void dispose() {
    _stopRinging();
    _callDurationTimer?.cancel();
    super.dispose();
  }

  void _startRinging() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      _vibrationTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
        if (_callState == 0) {
          Vibration.vibrate(duration: 500);
        } else {
          timer.cancel();
        }
      });
      Vibration.vibrate(duration: 500);
    }
  }

  void _stopRinging() {
    _vibrationTimer?.cancel();
    Vibration.cancel();
  }

  void _acceptCall() {
    _stopRinging();
    setState(() {
      _callState = 1;
    });
    _startCallTimer();
  }

  void _rejectCall() {
     _stopRinging();
     Navigator.pop(context);
  }

  void _startCallTimer() {
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1C1A), // Dark brownish-black
      body: SafeArea(
        child: _callState == 0 ? _buildIncomingUI() : _buildConnectedUI(),
      ),
    );
  }

  Widget _buildIncomingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top Section: Info
        Column(
          children: [
            const SizedBox(height: 80),
            // Name
            Text(
              widget.contactName,
              style: const TextStyle(
                color: Color(0xFFF1F0EF),
                fontSize: 48,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            // Number
            Text(
              widget.phoneNumber,
              style: TextStyle(
                color: const Color(0xFFF1F0EF).withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
        
        // Avatar (Wavy/Flower shape placeholder)
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF130F0F), // Darker center
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  )
                ],
              ),
            ),
             // We can't easily draw the exact flower shape without a custom painter or asset, 
             // so a dark circle with shadow mimics the vibe.
          ],
        ),

        // Bottom Section
        Column(
          children: [
            // Message Button
            Container(
              margin: const EdgeInsets.only(bottom: 40),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3C332A), // Brownish pill
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.message_outlined, color: Color(0xFFE8D0B3), size: 20),
                  SizedBox(width: 10),
                  Text(
                    "Message",
                    style: TextStyle(
                      color: Color(0xFFE8D0B3),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Slide Action
            _SwipeActionPill(
              onAnswer: _acceptCall,
              onDecline: _rejectCall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConnectedUI() {
    return Column(
      children: [
        const SizedBox(height: 60),
        
        // Timer HD
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "HD",
                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(_duration),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Name
        Text(
          widget.contactName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        // Number
        Text(
          widget.phoneNumber,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
          ),
        ),

        const Spacer(),

        // Avatar (Dark Void)
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFF130F0F),
            shape: BoxShape.circle,
            boxShadow: [
               BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 10,
              )
            ],
          ),
        ),
        
        const Spacer(),

        // Bottom Controls Container
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF26231F), // Dark panel
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               // 4 Buttons Row
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: [
                   _buildControlBtn(Icons.dialpad, "Keypad"),
                   _buildControlBtn(Icons.mic_off, "Mute"),
                   _buildControlBtn(Icons.volume_up, "Speaker"),
                   _buildControlBtn(Icons.more_vert, "More"),
                 ],
               ),
               const SizedBox(height: 30),
               
               // End Call Pill
               GestureDetector(
                 onTap: _rejectCall,
                 child: Container(
                   width: 140,
                   height: 70,
                   decoration: BoxDecoration(
                     color: const Color(0xFFF85C50), // Salmon Red
                     borderRadius: BorderRadius.circular(35),
                   ),
                   child: const Icon(Icons.call_end, color: Colors.white, size: 36),
                 ),
               ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlBtn(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF130F0F), // Dark circle button
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
            style: const TextStyle(color: Color(0xFFC4C4C4), fontSize: 13),
        ),
      ],
    );
  }
}

// Custom Swipe Button for Fake Call
class _SwipeActionPill extends StatefulWidget {
  final VoidCallback onAnswer;
  final VoidCallback onDecline;

  const _SwipeActionPill({
    required this.onAnswer,
    required this.onDecline,
  });

  @override
  State<_SwipeActionPill> createState() => _SwipeActionPillState();
}

class _SwipeActionPillState extends State<_SwipeActionPill> {
  double _dragValue = 0.0; // -1.0 to 1.0

  void _updateDrag(DragUpdateDetails details, double maxWidth) {
    setState(() {
      _dragValue += details.delta.dx / (maxWidth / 2);
      _dragValue = _dragValue.clamp(-1.0, 1.0);
    });
  }

  void _endDrag(DragEndDetails details) {
    if (_dragValue > 0.6) {
      widget.onAnswer();
    } else if (_dragValue < -0.6) {
      widget.onDecline();
    }
    
    setState(() {
      _dragValue = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 60, left: 24, right: 24),
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2926),
        borderRadius: BorderRadius.circular(44),
      ),
      clipBehavior: Clip.hardEdge, // Ensure drag doesn't overflow visually
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Opacity(
                      opacity: (1 - _dragValue.abs()).clamp(0.0, 1.0),
                      child: const Text("Decline", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: Opacity(
                      opacity: (1 - _dragValue.abs()).clamp(0.0, 1.0),
                      child: const Text("Answer", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ),
                  ),
                ],
              ),

              // Draggable Button
              Align(
                alignment: Alignment(_dragValue, 0.0),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) => _updateDrag(details, maxWidth),
                  onHorizontalDragEnd: _endDrag,
                  child: Container(
                    width: 72,
                    height: 72,
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Color(0xFF4CAF50),
                      size: 36,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
