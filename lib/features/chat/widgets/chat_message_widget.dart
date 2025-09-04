import 'dart:async';
import 'package:chat_drop/features/chat/widgets/retro_play_pause_button.dart';
import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/features/chat/domain/message.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class ChatMessageWidget extends StatefulWidget {
  final Message message;
  final bool isMe;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  FlutterSoundPlayer? _player;
  bool _isPlaying = false;
  bool _isPlayerInitialized = false;
  String? _localAudioPath;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _durationLoaded = false;
  Timer? _progressTimer;
  DateTime? _playbackStartTime;

  //  Stream subscription to manage properly
  StreamSubscription<PlaybackDisposition>? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _checkIfVoiceMessage();
  }

  @override
  void dispose() {
    // Canel subscription before cleanup
    _progressTimer?.cancel();
    _progressSubscription?.cancel();
    _cleanupPlayer();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    try {
      _player = FlutterSoundPlayer();
      await _player!.openPlayer();
      setState(() {
        _isPlayerInitialized = true;
      });
    } catch (e) {
      print('Error initializing player: $e');
    }
  }

  Future<void> _cleanupPlayer() async {
    try {
      // Cancel any active subscription
      await _progressSubscription?.cancel();
      _progressSubscription = null;

      if (_player != null && _player!.isOpen()) {
        await _player!.closePlayer();
      }
    } catch (e) {
      print('Error cleaning up player: $e');
    }
  }

  void _checkIfVoiceMessage() {
    if (_isVoiceMessage()) {
      _prepareVoiceMessage();
    }
  }

  bool _isVoiceMessage() {
    try {
      final data = jsonDecode(widget.message.content);
      return data['type'] == 'voice';
    } catch (e) {
      return false;
    }
  }

  Future<void> _prepareVoiceMessage() async {
    try {
      final voiceData = jsonDecode(widget.message.content);

      //  Load duration from the stored data first
      final storedDuration = voiceData['duration'] as int?;
      if (storedDuration != null && storedDuration > 0) {
        setState(() {
          _duration = Duration(milliseconds: storedDuration);
          _durationLoaded = true;
        });
        print('✅ Duration loaded from data: ${storedDuration}ms');
      }

      // Check if file already exists locally
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          voiceData['fileName'] ??
          'voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      final localFile = File('${directory.path}/$fileName');

      // Create file if it doesn't exist
      if (!await localFile.exists()) {
        final audioBytes = base64Decode(voiceData['audioData']);
        await localFile.writeAsBytes(audioBytes);
        print('📁 Voice file created: ${localFile.path}');
      } else {
        print('📁 Voice file exists: ${localFile.path}');
      }

      setState(() {
        _localAudioPath = localFile.path;
      });
      if (!_durationLoaded) {
        await _loadAudioDurationFromFile();
      }
    } catch (e) {
      print('Error preparing voice message: $e');
    }
  }

  Future<void> _loadAudioDurationFromFile() async {
    if (!_isPlayerInitialized || _localAudioPath == null) return;

    try {
      print('📏 Loading duration from audio file...');

      await _player!.startPlayer(
        fromURI: _localAudioPath!,
        whenFinished: () {},
      );

      // Create a temporary subscription to get duration
      StreamSubscription<PlaybackDisposition>? tempSubscription;
      bool durationFound = false;

      tempSubscription = _player!.onProgress!.listen((event) {
        if (event.duration.inMilliseconds > 0 && !durationFound) {
          durationFound = true;
          setState(() {
            _duration = event.duration;
            _durationLoaded = true;
          });

          print(
            '✅ Duration loaded from file: ${event.duration.inMilliseconds}ms',
          );

          // Stop playback and cancel subscription
          _player!.stopPlayer().then((_) {
            tempSubscription?.cancel();
          });
        }
      });

      // Fallback: Cancel subscription after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (!durationFound) {
          tempSubscription?.cancel();
          _player!.stopPlayer();
        }
      });
    } catch (e) {
      print('❌ Error loading duration from file: $e');
    }
  }

  Future<void> _togglePlayback() async {
    if (!_isPlayerInitialized || _localAudioPath == null) return;

    try {
      if (_isPlaying) {
        print('⏸️ Stopping playback');
        // Stop playback
        _progressTimer?.cancel();
        _progressTimer = null;
        await _progressSubscription?.cancel();
        _progressSubscription = null;

        await _player!.stopPlayer();
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      } else {
        print('▶️ Starting playback: $_localAudioPath');

        // Record start time
        _playbackStartTime = DateTime.now();

        // Start playback
        await _player!.startPlayer(
          fromURI: _localAudioPath!,
          whenFinished: () {
            print('🏁 Playback finished - cleaning up');
            _progressTimer?.cancel();
            _progressTimer = null;
            if (mounted) {
              setState(() {
                _isPlaying = false;
                _position = Duration.zero;
              });
            }
          },
        );

        setState(() {
          _isPlaying = true;
        });

        // MANUAL TIMER: Update progress every 100ms
        _progressTimer?.cancel();
        _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (
          timer,
        ) {
          if (!_isPlaying || !mounted || _playbackStartTime == null) {
            timer.cancel();
            return;
          }

          // Calculate elapsed time since playback started
          final elapsed = DateTime.now().difference(_playbackStartTime!);

          if (elapsed <= _duration) {
            setState(() {
              _position = elapsed;
            });

            final progress =
                _duration.inMilliseconds > 0
                    ? (elapsed.inMilliseconds / _duration.inMilliseconds).clamp(
                      0.0,
                      1.0,
                    )
                    : 0.0;

            print(
              '⏱️ Manual progress: ${elapsed.inMilliseconds}ms / ${_duration.inMilliseconds}ms (${(progress * 100).toStringAsFixed(1)}%)',
            );
          } else {
            // Playback should be finished
            print('⏰ Manual timer detected end of playback');
            timer.cancel();
            _progressTimer = null;
            if (mounted) {
              setState(() {
                _isPlaying = false;
                _position = Duration.zero;
              });
            }
          }
        });

        print('✅ Playback started with manual timer tracking');
      }
    } catch (e) {
      print('❌ Error toggling playback: $e');
      _progressTimer?.cancel();
      _progressTimer = null;
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    }
  }

  Widget _buildVoiceMessageContent() {
    if (!_isVoiceMessage()) {
      return _buildTextMessage();
    }

    // Print current state
    double currentProgress = 0.0;
    if (_durationLoaded && _duration.inMilliseconds > 0) {
      if (_isPlaying && _position.inMilliseconds > 0) {
        currentProgress = (_position.inMilliseconds / _duration.inMilliseconds)
            .clamp(0.0, 1.0);
      }
    }

    // Debug current state
    print('🎵 Voice Message State:');
    print('  - isPlaying: $_isPlaying');
    print('  - position: ${_position.inMilliseconds}ms');
    print('  - duration: ${_duration.inMilliseconds}ms');
    print('  - durationLoaded: $_durationLoaded');
    print('  - progress: $currentProgress');
    print('  - localPath exists: ${_localAudioPath != null}');

    return Container(
      constraints: const BoxConstraints(minWidth: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause Button with Retro Style
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: RetroPlayPauseButton(
              isPlaying: _isPlaying,
              isMe: widget.isMe,
              onTap: _togglePlayback,
              size: 42,
            ),
          ),

          const SizedBox(width: 12),

          // Waveform and Duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                // Use the calculated progress
                SizedBox(
                  height: 26,
                  child: CustomPaint(
                    painter: VoiceWavePainter(
                      progress: currentProgress,
                      isMe: widget.isMe,
                    ),
                    size: const Size(double.infinity, 30),
                  ),
                ),
                const SizedBox(height: 4),

                // Duration
                Text(
                  _getDurationText(),
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        widget.isMe
                            ? AppColors.textDark.withOpacity(0.8)
                            : AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),

          // Mic Icon
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Icon(
              Icons.mic,
              color:
                  widget.isMe
                      ? AppColors.textDark.withOpacity(0.3)
                      : AppColors.textGrey,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  String _getDurationText() {
    if (_durationLoaded) {
      return _formatDuration(_isPlaying ? _position : _duration);
    } else if (_isPlaying) {
      return _formatDuration(_position);
    } else {
      // Try to extract duration from voice data
      try {
        final voiceData = jsonDecode(widget.message.content);
        final storedDuration = voiceData['duration'] as int?;
        if (storedDuration != null) {
          return _formatDuration(Duration(milliseconds: storedDuration));
        }
      } catch (e) {
        // Ignore
      }
      return "Voice message";
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildTextMessage() {
    return Text(
      widget.message.content,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textDark,
        fontFamily: "ZillaSlab",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!widget.isMe) const SizedBox(width: 0),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
              minWidth: 60,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    widget.isMe
                        ? AppColors.accentPink
                        : AppColors.primaryYellow,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft:
                      widget.isMe
                          ? const Radius.circular(12)
                          : const Radius.circular(4),
                  bottomRight:
                      widget.isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(12),
                ),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.border,
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: _buildVoiceMessageContent(),
            ),
          ),
          if (widget.isMe) const SizedBox(width: 0),
        ],
      ),
    );
  }
}

class VoiceWavePainter extends CustomPainter {
  final double progress;
  final bool isMe;

  VoiceWavePainter({required this.progress, required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    print('🎨 VoiceWavePainter: progress=$progress, isMe=$isMe, size=$size');

    // Clamp progress to valid range
    final clampedProgress = progress.clamp(0.0, 1.0);

    // Use retro color palette for played waves
    final retroColors = [
      AppColors.retroTeal,
      AppColors.retroOrange,
      AppColors.retroBlue,
      AppColors.retroLavender,
    ];

    final unplayedPaint =
        Paint()
          ..color =
              isMe
                  ? AppColors.textDark.withOpacity(0.3)
                  : AppColors.textGrey.withOpacity(0.3)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

    final heights = [
      16,
      8,
      24,
      12,
      20,
      6,
      16,
      10,
      22,
      14,
      18,
      8,
      12,
      16,
      10,
      20,
      14,
      18,
    ];
    final spacing = size.width / heights.length;
    final playedWidth = size.width * clampedProgress;

    print(
      '🎨 playedWidth=$playedWidth, totalWidth=${size.width}, clampedProgress=$clampedProgress',
    );

    for (int i = 0; i < heights.length; i++) {
      final x = i * spacing + spacing / 2;
      final height = heights[i].toDouble();
      final centerY = size.height / 2;

      late Paint paint;

      if (x <= playedWidth) {
        // Use cycling retro colors for played portion
        final colorIndex = i % retroColors.length;
        paint =
            Paint()
              ..color =
                  retroColors[colorIndex] // Use retro colors for received messages
              ..strokeWidth = 3
              ..strokeCap = StrokeCap.round;
      } else {
        paint = unplayedPaint;
      }

      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! VoiceWavePainter) return true;

    final shouldRepaint =
        oldDelegate.progress != progress || oldDelegate.isMe != isMe;
    print(
      '🎨 shouldRepaint: $shouldRepaint (oldProgress=${oldDelegate.progress}, newProgress=$progress)',
    );
    return shouldRepaint;
  }
}
