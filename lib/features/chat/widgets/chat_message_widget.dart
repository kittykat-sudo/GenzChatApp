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

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _checkIfVoiceMessage();
  }

  @override
  void dispose() {
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
      if (_player != null) {
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

      // Check if file already exists locally
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          voiceData['fileName'] ??
          'voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      final localFile = File('${directory.path}/$fileName');

      if (!await localFile.exists()) {
        // Decode and save the audio file
        final audioBytes = base64Decode(voiceData['audioData']);
        await localFile.writeAsBytes(audioBytes);
      }

      setState(() {
        _localAudioPath = localFile.path;
      });
    } catch (e) {
      print('Error preparing voice message: $e');
    }
  }

  Future<void> _togglePlayback() async {
    if (!_isPlayerInitialized || _localAudioPath == null) return;

    try {
      if (_isPlaying) {
        await _player!.stopPlayer();
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      } else {
        await _player!.startPlayer(
          fromURI: _localAudioPath!,
          whenFinished: () {
            setState(() {
              _isPlaying = false;
              _position = Duration.zero;
            });
          },
        );
        setState(() {
          _isPlaying = true;
        });

        // Update position during playback
        _player!.onProgress!.listen((event) {
          setState(() {
            _position = event.position;
            _duration = event.duration;
          });
        });
      }
    } catch (e) {
      print('Error toggling playback: $e');
    }
  }

  Widget _buildVoiceMessageContent() {
    if (!_isVoiceMessage()) {
      return _buildTextMessage();
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause Button
          GestureDetector(
            onTap: _togglePlayback,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    widget.isMe
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.retroTeal.withOpacity(
                          0.1,
                        ), // Use retro color
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      widget.isMe
                          ? Colors.white.withOpacity(0.3)
                          : AppColors.retroTeal.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color:
                    widget.isMe
                        ? Colors.white
                        : AppColors.retroTeal, // Use retro color
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Waveform and Duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform
                Container(
                  height: 30,
                  child: CustomPaint(
                    painter: VoiceWavePainter(
                      progress:
                          _duration.inMilliseconds > 0
                              ? _position.inMilliseconds /
                                  _duration.inMilliseconds
                              : 0.0,
                      isMe: widget.isMe,
                    ),
                    size: Size(double.infinity, 30),
                  ),
                ),
                const SizedBox(height: 4),

                // Duration
                Text(
                  _formatDuration(_isPlaying ? _position : _duration),
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        widget.isMe
                            ? Colors.white.withOpacity(0.8)
                            : AppColors.textGrey,
                    fontFamily: "ZillaSlab",
                  ),
                ),
              ],
            ),
          ),

          // Mic Icon
          Icon(
            Icons.mic,
            color:
                widget.isMe
                    ? Colors.white.withOpacity(0.6)
                    : AppColors.textGrey,
            size: 16,
          ),
        ],
      ),
    );
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
    // Use retro color palette for played waves
    final retroColors = [
      AppColors.retroTeal,
      AppColors.retroOrange,
      AppColors.retroBlue,
      AppColors.accentPink,
    ];

    final unplayedPaint =
        Paint()
          ..color =
              isMe
                  ? Colors.white.withOpacity(0.3)
                  : AppColors.textGrey.withOpacity(0.3)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

    final heights = [8, 4, 12, 6, 10, 3, 8, 5, 11, 7, 9, 4, 6, 8, 5, 10, 7, 9];
    final spacing = size.width / heights.length;
    final playedWidth = size.width * progress;

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
                  isMe
                      ? Colors
                          .white // Keep white for sent messages
                      : retroColors[colorIndex] // Use retro colors for received messages
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
    return oldDelegate is VoiceWavePainter && oldDelegate.progress != progress;
  }
}
