import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/transcription_provider.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎙️ ', style: TextStyle(fontSize: 24)),
            const Text('MindLink AI'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
            tooltip: 'History',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
            tooltip: 'About',
          ),
        ],
      ),
      body: const SafeArea(
        child: Column(
          children: [
            Expanded(child: _TranscriptionArea()),
            _ControlBar(),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About MindLink AI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Malayalam Voice Typing',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Convert your voice to Malayalam text with 99% accuracy. Supports all Kerala dialects.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => launchUrl(Uri.parse('https://mindlink-ai.com')),
              child: const Text('Visit Website →'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _TranscriptionArea extends StatelessWidget {
  const _TranscriptionArea();

  @override
  Widget build(BuildContext context) {
    return Consumer<TranscriptionProvider>(
      builder: (context, provider, _) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAB308),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Malayalam Voice Typing',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (provider.isRecording)
                      Text(
                        '${provider.recordingDuration}s',
                        style: const TextStyle(
                          color: Color(0xFFF97316),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              // Text area
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: SelectableText(
                          provider.transcribedText.isEmpty
                              ? (provider.isRecording
                                  ? 'Listening... speak in Malayalam'
                                  : provider.isProcessing
                                      ? 'Processing your speech...'
                                      : 'Tap the mic button and start speaking')
                              : provider.transcribedText,
                          style: GoogleFonts.notoSansMalayalam(
                            fontSize: 20,
                            height: 1.6,
                            color: provider.transcribedText.isEmpty
                                ? Colors.white38
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Recording indicator
                    if (provider.isRecording)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Recording',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Processing indicator
                    if (provider.isProcessing)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF97316),
                        ),
                      ),
                  ],
                ),
              ),

              // Action bar
              if (provider.transcribedText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF334155)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => provider.clearText(),
                        tooltip: 'Clear',
                        color: Colors.white54,
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: provider.transcribedText),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: 'Copy',
                        color: Colors.white54,
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          Share.share(provider.transcribedText);
                        },
                        tooltip: 'Share',
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<TranscriptionProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            border: Border(
              top: BorderSide(color: Color(0xFF334155)),
            ),
          ),
          child: Column(
            children: [
              // Error message
              if (provider.error.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.error,
                          style: const TextStyle(color: Color(0xFFEF4444)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => provider.clearError(),
                        color: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),

              // Language indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF334155)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Malayalam (ml-IN)',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mic button
              GestureDetector(
                onTap: () {
                  if (provider.isRecording) {
                    provider.stopRecording();
                  } else if (!provider.isProcessing) {
                    provider.startRecording();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: provider.isRecording ? 80 : 72,
                  height: provider.isRecording ? 80 : 72,
                  decoration: BoxDecoration(
                    color: provider.isRecording
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFF97316),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (provider.isRecording
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFF97316))
                            .withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    provider.isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                provider.isRecording
                    ? 'Tap to stop'
                    : provider.isProcessing
                        ? 'Processing...'
                        : 'Tap to speak',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
