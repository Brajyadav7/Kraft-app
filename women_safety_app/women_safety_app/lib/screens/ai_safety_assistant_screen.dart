import 'package:flutter/material.dart';
import 'dart:io';
import '../services/ai_safety_assistant_service.dart';
import '../services/google_places_safety_service.dart';
import 'package:geolocator/geolocator.dart';

class AISafetyAssistantScreen extends StatefulWidget {
  const AISafetyAssistantScreen({super.key});

  @override
  State<AISafetyAssistantScreen> createState() =>
      _AISafetyAssistantScreenState();
}

class _AISafetyAssistantScreenState extends State<AISafetyAssistantScreen> {
  final AISafetyAssistantService _aiService = AISafetyAssistantService();
  final GooglePlacesSafetyService _googleService = GooglePlacesSafetyService();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _urlController = TextEditingController(
    text: Platform.isAndroid ? 'http://172.25.1.254:5000' : 'http://127.0.0.1:5000',
  );
  final TextEditingController _googleApiController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _needsBackend = false;
  bool _needsGoogleApi = false;

  @override
  void initState() {
    super.initState();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    try {
      // Try to connect to local custom AI backend
      await _aiService.initialize(_urlController.text);
      _addMessage(
        '👋 Hi! I\'m your AI Safety Assistant with emotional support. I\'m here to:\n\n'
        '✅ Provide practical safety advice\n'
        '💚 Offer emotional support and reassurance\n'
        '📍 Check area safety using Google Maps data\n'
        '🆘 Guide you through emergency situations\n\n'
        'Ask me anything about your safety concerns, and I\'ll respond with both practical advice and compassionate support.',
        isAI: true,
      );
    } catch (e) {
      setState(() {
        _needsBackend = true;
      });
      debugPrint('AI backend connection failed: $e');
    }
  }

  Future<void> _connectToBackend() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter backend URL')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _aiService.initialize(url);
      setState(() {
        _needsBackend = false;
        _isLoading = false;
      });
      _addMessage(
        '✅ Connected! I\'m your AI Safety Assistant. How can I help you feel safer today?',
        isAI: true,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to connect: $e')));
      }
    }
  }

  Future<void> _setupGoogleApi() async {
    final apiKey = _googleApiController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Google API Key')),
      );
      return;
    }

    _googleService.initialize(apiKey);
    setState(() {
      _needsGoogleApi = false;
    });
    _addMessage(
      '✅ Google Maps integration activated! I can now check area safety for you.',
      isAI: true,
    );
  }

  Future<void> _checkAreaSafety() async {
    try {
      final position = await Geolocator.getCurrentPosition();

      _addMessage(
        'Checking area safety at your current location...',
        isAI: false,
      );

      setState(() {
        _isLoading = true;
      });

      final safetyData = await _googleService.checkAreaSafety(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: '500',
      );

      final aiAnalysis = await _aiService.askSafetyQuestion(
        '''Based on the area data I've analyzed:
Safety Score: ${safetyData['safetyScore']}/100
Message: ${safetyData['message']}
Details: ${safetyData['details']}

Please provide a compassionate and practical response that:
1. Validates any safety concerns
2. Explains the area safety status
3. Offers actionable safety tips
4. Provides emotional reassurance''',
      );

      _addMessage(
        '📍 Area Safety Analysis:\n\n'
        '${safetyData['message']}\n\n'
        '🎯 Safety Score: ${safetyData['safetyScore']}/100\n\n'
        '💡 Recommendation: ${safetyData['recommendation']}\n\n'
        '🤖 AI Analysis:\n$aiAnalysis',
        isAI: true,
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _addMessage(
        'Error checking area safety: $e\n\nMake sure you have location permissions enabled.',
        isAI: true,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    _addMessage(userMessage, isAI: false);

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _aiService.askSafetyQuestion(userMessage);
      _addMessage(response, isAI: true);
    } catch (e) {
      _addMessage('Error: $e', isAI: true);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _addMessage(String text, {required bool isAI}) {
    setState(() {
      _messages.add(ChatMessage(text: text, isAI: isAI));
    });
  }

  void _clearHistory() {
    _aiService.clearChatHistory();
    setState(() {
      _messages.clear();
    });
    _addMessage(
      'Chat history cleared. How can I help you with safety?',
      isAI: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💚 AI Safety Assistant'),
        backgroundColor: Colors.red[700],
        elevation: 0,
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearHistory,
              tooltip: 'Clear chat history',
            ),
          if (_aiService.isInitialized && _googleService.isInitialized)
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: _checkAreaSafety,
              tooltip: 'Check area safety',
            ),
        ],
      ),
      body: _needsBackend
          ? _buildBackendSetup()
          : (_needsGoogleApi && _aiService.isInitialized)
          ? _buildGoogleApiSetup()
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 64,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Your Personal Safety Assistant',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'With Emotional Support 💚\n\n'
                                'Examples:\n'
                                '• Is this area safe at night?\n'
                                '• I\'m feeling anxious about traveling\n'
                                '• What should I do if followed?\n'
                                '• Safety tips for going out alone?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return _buildMessage(message);
                          },
                        ),
                ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'AI is thinking...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            hintText: 'Share your safety concern...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        mini: true,
                        onPressed: _isLoading ? null : _sendMessage,
                        backgroundColor: Colors.red[700],
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: message.isAI ? Colors.blue[50] : Colors.red[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isAI)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, size: 14, color: Colors.red[700]),
                    const SizedBox(width: 4),
                    Text(
                      'AI Safety Assistant',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleApiSetup() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 64, color: Colors.red[700]),
              const SizedBox(height: 24),
              const Text(
                'Setup Google Maps API',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enable area safety checking',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Setup Steps:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Go to Google Cloud Console\n'
                      '2. Create a new project\n'
                      '3. Enable Places API\n'
                      '4. Create API Key\n'
                      '5. Paste your key below',
                      style: TextStyle(fontSize: 12, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _googleApiController,
                decoration: InputDecoration(
                  labelText: 'Google API Key',
                  hintText: 'AIza...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _setupGoogleApi,
                icon: const Icon(Icons.check),
                label: const Text('Setup Google Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '💡 Optional: You can skip this and just use the AI assistant.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _needsGoogleApi = false;
                  });
                },
                child: const Text('Continue without Maps'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackendSetup() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.smart_toy, size: 64, color: Colors.red[700]),
              const SizedBox(height: 24),
              const Text(
                'Setup AI Assistant',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Custom AI Backend',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💚 Why use local AI Backend?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '✓ Runs locally (or on your server)\n'
                      '✓ No third-party API costs\n'
                      '✓ Your data stays private\n'
                      '✓ Controlled configuration and updates',
                      style: TextStyle(fontSize: 12, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Quick Start:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1️⃣ Start the custom backend (backend/start_backend.bat)\n'
                      '2️⃣ Device/Emulator: Use http://10.125.17.114:5000\n'
                      '3️⃣ Paste the URL below and click "Connect"',
                      style: TextStyle(fontSize: 12, height: 1.8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Backend URL',
                  hintText: Platform.isAndroid ? 'http://10.125.17.114:5000' : 'http://127.0.0.1:5000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  prefixIcon: const Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _connectToBackend,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.link),
                label: const Text('Connect to AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Make sure the custom AI backend is running on your machine or server',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _urlController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isAI;

  ChatMessage({required this.text, required this.isAI});
}
