import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/transcription_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          Consumer<TranscriptionProvider>(
            builder: (context, provider, _) {
              if (provider.history.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () => _showClearDialog(context, provider),
                tooltip: 'Clear all',
              );
            },
          ),
        ],
      ),
      body: Consumer<TranscriptionProvider>(
        builder: (context, provider, _) {
          if (provider.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transcriptions yet',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your transcriptions will appear here',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.history.length,
            itemBuilder: (context, index) {
              final text = provider.history[index];
              return _HistoryCard(
                text: text,
                onTap: () {
                  provider.loadFromHistory(index);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Loaded to editor'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onShare: () {
                  Share.share(text);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context, TranscriptionProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to delete all transcription history? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('History cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _HistoryCard({
    required this.text,
    required this.onTap,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: GoogleFonts.notoSansMalayalam(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white54,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white54,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Load'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFF97316),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
