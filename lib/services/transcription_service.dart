import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class TranscriptionService {
  static const String _apiUrl = 'https://mindlink-ai.com/api/transcribe';

  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;

  Future<bool> requestPermissions() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    // Check permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }

    // Check if recorder is available
    if (!await _recorder.hasPermission()) {
      throw Exception('Recording not available on this device');
    }

    // Get temp directory for recording
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _currentRecordingPath = '${directory.path}/recording_$timestamp.m4a';

    // Configure recorder for high quality audio
    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: 44100,
      bitRate: 128000,
      numChannels: 1,
    );

    // Start recording
    await _recorder.start(config, path: _currentRecordingPath!);
  }

  Future<String?> stopRecording() async {
    if (!await _recorder.isRecording()) {
      return null;
    }

    final path = await _recorder.stop();
    return path;
  }

  Future<void> cancelRecording() async {
    await _recorder.stop();

    // Delete the file if it exists
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _currentRecordingPath = null;
  }

  Future<String> transcribeAudio(String audioPath) async {
    try {
      final file = File(audioPath);
      if (!await file.exists()) {
        throw Exception('Audio file not found');
      }

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

      // Add the audio file
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioPath,
          filename: 'recording.m4a',
        ),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transcript = data['transcript'] as String? ?? '';

        // Clean up the temp file
        await file.delete();

        return transcript;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Transcription failed');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('No internet connection');
      }
      rethrow;
    }
  }

  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  void dispose() {
    _recorder.dispose();
  }
}
