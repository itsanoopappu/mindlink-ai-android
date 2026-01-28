import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/transcription_service.dart';

class TranscriptionProvider extends ChangeNotifier {
  final TranscriptionService _service = TranscriptionService();

  String _transcribedText = '';
  bool _isRecording = false;
  bool _isProcessing = false;
  String _error = '';
  List<String> _history = [];
  int _recordingDuration = 0;

  // Getters
  String get transcribedText => _transcribedText;
  bool get isRecording => _isRecording;
  bool get isProcessing => _isProcessing;
  String get error => _error;
  List<String> get history => _history;
  int get recordingDuration => _recordingDuration;

  TranscriptionProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _history = prefs.getStringList('transcription_history') ?? [];
    notifyListeners();
  }

  Future<void> _saveToHistory(String text) async {
    if (text.trim().isEmpty) return;

    _history.insert(0, text);
    if (_history.length > 50) {
      _history = _history.sublist(0, 50); // Keep only last 50
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('transcription_history', _history);
    notifyListeners();
  }

  void startRecording() async {
    _error = '';
    _isRecording = true;
    _recordingDuration = 0;
    notifyListeners();

    try {
      await _service.startRecording();

      // Update duration every second
      _updateDuration();
    } catch (e) {
      _error = e.toString();
      _isRecording = false;
      notifyListeners();
    }
  }

  void _updateDuration() async {
    while (_isRecording) {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording) {
        _recordingDuration++;
        notifyListeners();
      }
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;

    _isRecording = false;
    _isProcessing = true;
    notifyListeners();

    try {
      final audioPath = await _service.stopRecording();
      if (audioPath != null) {
        final transcript = await _service.transcribeAudio(audioPath);
        if (transcript.isNotEmpty) {
          _transcribedText = _transcribedText.isEmpty
              ? transcript
              : '$_transcribedText $transcript';
          await _saveToHistory(transcript);
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isProcessing = false;
    _recordingDuration = 0;
    notifyListeners();
  }

  void clearText() {
    _transcribedText = '';
    notifyListeners();
  }

  void setText(String text) {
    _transcribedText = text;
    notifyListeners();
  }

  void appendText(String text) {
    _transcribedText = _transcribedText.isEmpty ? text : '$_transcribedText $text';
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transcription_history');
    notifyListeners();
  }

  void loadFromHistory(int index) {
    if (index >= 0 && index < _history.length) {
      _transcribedText = _history[index];
      notifyListeners();
    }
  }
}
