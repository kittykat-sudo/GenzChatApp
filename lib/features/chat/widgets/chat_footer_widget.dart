import 'dart:async';
import 'dart:io';
import 'package:chat_drop/core/theme/app_text_styles.dart';
import 'package:chat_drop/core/utils/retro_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:chat_drop/core/theme/app_colors.dart';
import 'package:chat_drop/core/widgets/retro_button.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class ChatFooterWidget extends StatefulWidget {
  final TextEditingController messageController;
  final VoidCallback onSendMessage;
  final Function(String)? onVoiceMessageSent;
  final VoidCallback? onAttachmentPressed;

  const ChatFooterWidget({
    super.key,
    required this.messageController,
    required this.onSendMessage,
    this.onVoiceMessageSent,
    this.onAttachmentPressed,
  });

  @override
  State<ChatFooterWidget> createState() => _ChatFooterWidgetState();
}

class _ChatFooterWidgetState extends State<ChatFooterWidget>
    with WidgetsBindingObserver {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordingPath;
  bool _isInitialized = false;
  bool _isRecorderBusy = false;
  final int _maxRetries = 3;
  DateTime? _recordingStartTime;
  Duration? _recordingDuration;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initRecorderWithRetry();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanupRecorder();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _forceStopRecording();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize when app resumes
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_isInitialized) {
          _initRecorderWithRetry();
        }
      });
    }
  }

  Future<void> _initRecorderWithRetry() async {
    if (_isRecorderBusy) return;

    for (int i = 0; i < _maxRetries; i++) {
      try {
        await _initRecorder();
        if (_isInitialized) break;

        // Wait before retry
        if (i < _maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
        }
      } catch (e) {
        print('Init attempt ${i + 1} failed: $e');
        if (i == _maxRetries - 1) {
          print('All initialization attempts failed');
        }
      }
    }
  }

  Future<void> _initRecorder() async {
    if (_isRecorderBusy) return;

    try {
      _isRecorderBusy = true;

      // Complete cleanup first
      await _cleanupRecorder();

      // Small delay to let system cleanup
      await Future.delayed(const Duration(milliseconds: 200));

      _recorder = FlutterSoundRecorder();
      _player = FlutterSoundPlayer();

      // Initialize with Android-specific session configuration
      await _recorder!.openRecorder();
      await _player!.openPlayer();

      setState(() {
        _isInitialized = true;
      });

      print('✅ Audio recorder initialized successfully');
    } catch (e) {
      print('❌ Error initializing recorder: $e');
      setState(() {
        _isInitialized = false;
      });

      // Force cleanup on init failure
      await _forceCleanup();
      rethrow;
    } finally {
      _isRecorderBusy = false;
    }
  }

  Future<void> _cleanupRecorder() async {
    try {
      if (_isRecording) {
        await _forceStopRecording();
      }

      if (_isPlaying) {
        await _stopPlayback();
      }

      await _forceCleanup();
    } catch (e) {
      print('Cleanup error: $e');
      await _forceCleanup();
    }
  }

  Future<void> _forceCleanup() async {
    try {
      if (_recorder != null) {
        try {
          await _recorder!.closeRecorder();
        } catch (e) {
          print('Force close recorder error (expected): $e');
        }
      }

      if (_player != null) {
        try {
          await _player!.closePlayer();
        } catch (e) {
          print('Force close player error (expected): $e');
        }
      }
    } finally {
      _recorder = null;
      _player = null;
    }
  }

  Future<void> _forceStopRecording() async {
    if (_recorder != null && _isRecording) {
      try {
        await _recorder!.stopRecorder();
      } catch (e) {
        print('Force stop error (expected): $e');
      } finally {
        if (mounted) {
          setState(() {
            _isRecording = false;
          });
        }
      }
    }
  }

  Future<void> _startRecording() async {
    if (_isRecorderBusy) return;

    try {
      _isRecorderBusy = true;

      // Check and request permissions
      final micPermission = await Permission.microphone.status;
      if (micPermission != PermissionStatus.granted) {
        final result = await Permission.microphone.request();
        if (result != PermissionStatus.granted) {
          if (mounted) {
            showRetroSnackbar(
              context: context,
              message: 'Microphone permission denied',
              type: SnackbarType.error,
            );
          }
          return;
        }
      }

      // Ensure clean state
      if (_isRecording) {
        await _forceStopRecording();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Reinitialize if needed
      if (!_isInitialized || _recorder == null) {
        await _initRecorderWithRetry();
        if (!_isInitialized) {
          if (mounted) {
            showRetroSnackbar(
              context: context,
              message: 'Unable to initialize recorder',
              type: SnackbarType.error,
            );
          }
          return;
        }
      }

      if (_isPlaying) {
        await _stopPlayback();
      }

      // Create recording path
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = '${directory.path}/voice_$timestamp.aac';

      // Start recording with conservative settings for Android compatibility
      await _recorder!.startRecorder(
        toFile: _recordingPath,
        codec: Codec.aacADTS, // Most compatible for Android
        bitRate: 16000, // Conservative bitrate
        sampleRate: 16000, // Standard sample rate
        numChannels: 1, // Mono recording
      );

      _recordingStartTime = DateTime.now();

      setState(() {
        _isRecording = true;
      });

      if (mounted) {
        showRetroSnackbar(
          context: context,
          message: 'Recording... Tap to stop',
          type: SnackbarType.info,
        );
      }
    } catch (e) {
      print('❌ Error starting recording: $e');

      // Handle specific platform exceptions
      String errorMessage = 'Failed to start recording';
      if (e.toString().contains('startRecorder')) {
        errorMessage = 'Recorder busy. Please try again';
      } else if (e.toString().contains('Permission')) {
        errorMessage = 'Microphone permission required';
      }

      if (mounted) {
        showRetroSnackbar(
          context: context,
          message: errorMessage,
          type: SnackbarType.error,
        );
      }

      // Reset state and attempt reinit
      setState(() {
        _isRecording = false;
        _isInitialized = false;
      });

      // Schedule reinit for next attempt
      Future.delayed(const Duration(milliseconds: 1000), () {
        _initRecorderWithRetry();
      });
    } finally {
      _isRecorderBusy = false;
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _recorder == null || _isRecorderBusy) return;

    try {
      _isRecorderBusy = true;

      final path = await _recorder!.stopRecorder();

      // Calculate recording duration
      if (_recordingStartTime != null) {
        _recordingDuration = DateTime.now().difference(_recordingStartTime!);
        print('📏 Recording duration: ${_recordingDuration!.inMilliseconds}ms');
      }

      setState(() {
        _isRecording = false;
      });

      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          final fileSize = await file.length();
          if (fileSize > 1000) {
            // Check if file has content (>1KB)
            print('✅ Recording saved: $path (${fileSize} bytes)');
            _showPlaybackDialog(path);
          } else {
            if (mounted) {
              showRetroSnackbar(
                context: context,
                message: 'Recording too short',
                type: SnackbarType.info,
              );
            }
          }
        } else {
          if (mounted) {
            showRetroSnackbar(
              context: context,
              message: 'Recording file not found',
              type: SnackbarType.error,
            );
          }
        }
      } else {
        if (mounted) {
          showRetroSnackbar(
            context: context,
            message: 'Recording failed',
            type: SnackbarType.error,
          );
        }
      }
    } catch (e) {
      print('❌ Error stopping recording: $e');
      if (mounted) {
        showRetroSnackbar(
          context: context,
          message: 'Failed to save recording',
          type: SnackbarType.error,
        );
      }

      setState(() {
        _isRecording = false;
      });
    } finally {
      _isRecorderBusy = false;
    }
  }

  Future<void> _handleMicPressed() async {
    if (_isRecorderBusy) return;

    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _playRecording(String path) async {
    try {
      if (_player == null || !_isInitialized) {
        await _initRecorderWithRetry();
        if (!_isInitialized) {
          if (mounted) {
            showRetroSnackbar(
              context: context,
              message: 'Player not available',
              type: SnackbarType.error,
            );
          }
          return;
        }
      }

      if (_isPlaying) {
        await _player!.stopPlayer();
      }

      await _player!.startPlayer(
        fromURI: path,
        whenFinished: () {
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        },
      );

      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      print('❌ Error playing recording: $e');
      if (mounted) {
        showRetroSnackbar(
          context: context,
          message: 'Failed to play recording',
          type: SnackbarType.error,
        );
      }
    }
  }

  Future<void> _stopPlayback() async {
    try {
      if (_player != null) {
        await _player!.stopPlayer();
      }
    } catch (e) {
      print('Stop playback error (expected): $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  void _showPlaybackDialog(String audioPath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.retroPink,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.border,
                      offset: Offset(6, 6),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with retro style
                    Text(
                      'Voice Message',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Message
                    Text(
                      'Listen to your recording:',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Playback controls with retro buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Play/Stop button - icon only
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.accentPink,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.stop : Icons.play_arrow,
                              color: AppColors.textDark,
                              size: 28,
                            ),
                            onPressed: () async {
                              if (_isPlaying) {
                                await _stopPlayback();
                                setDialogState(() {
                                  _isPlaying = false;
                                });
                              } else {
                                await _playRecording(audioPath);
                                setDialogState(() {
                                  _isPlaying = true;
                                });
                              }
                            },
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                              backgroundColor: AppColors.accentPink,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Re-record button - icon only
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: AppColors.textDark,
                              size: 28,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  _startRecording();
                                },
                              );
                            },
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                              backgroundColor: AppColors.primaryYellow,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: RetroButton(
                            text: 'Cancel',
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (_isPlaying) _stopPlayback();
                            },
                            backgroundColor: AppColors.textGrey,
                            textColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RetroButton(
                            text: 'Send',
                            onPressed: () async {
                              Navigator.of(context).pop();
                              if (_isPlaying) _stopPlayback();

                              // Use enhanced voice message sending
                              await _sendVoiceMessageWithData(audioPath);
                            },
                            backgroundColor: AppColors.accentPink,
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // void _sendVoiceMessage(String audioPath) {
  //   if (widget.onVoiceMessageSent != null) {
  //     // Send the actual file path/data, not just text
  //     widget.onVoiceMessageSent!(audioPath);
  //     _showSnackBar('Voice message sent!', Colors.green);
  //   } else {
  //     _showSnackBar('Voice message handler not set.', Colors.red);
  //   }
  // }

  // Add this method to convert audio to base64 for transmission
  Future<String?> _convertAudioToBase64(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        return base64String;
      }
      return null;
    } catch (e) {
      print('Error converting audio to base64: $e');
      return null;
    }
  }

  // Enhanced voice message sending with file data
  // Enhanced voice message sending with file data
  Future<void> _sendVoiceMessageWithData(String audioPath) async {
    try {
      final file = File(audioPath);
      if (!await file.exists()) {
        if (mounted) {
          showRetroSnackbar(
            context: context,
            message: 'Voice note not found',
            type: SnackbarType.error,
          );
        }
        return;
      }

      // Get file info
      final fileSize = await file.length();
      final fileName = audioPath.split('/').last;

      // Convert to base64 for transmission
      final base64Audio = await _convertAudioToBase64(audioPath);

      if (base64Audio == null) {
        if (mounted) {
          showRetroSnackbar(
            context: context,
            message: 'Failed to send voice message',
            type: SnackbarType.error,
          );
        }
        return;
      }

      final duration =
          _recordingDuration?.inMilliseconds ??
          (fileSize / 2000).round() * 1000;

      // Create voice message data object with duration
      final voiceMessageData = {
        'type': 'voice',
        'fileName': fileName,
        'fileSize': fileSize,
        'duration': duration,
        'audioData': base64Audio,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (widget.onVoiceMessageSent != null) {
        // Send the voice message data as JSON string
        widget.onVoiceMessageSent!(jsonEncode(voiceMessageData));
        if (mounted) {
          showRetroSnackbar(
            context: context,
            message: 'Voice message sent!',
            type: SnackbarType.success,
          );
        }
      }
    } catch (e) {
      print('Error sending voice message: $e');
      if (mounted) {
        showRetroSnackbar(
          context: context,
          message: 'Failed to send voice message $e',
          type: SnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border, width: 2)),
        ),
        child: Row(
          children: [
            RetroButton(
              text: '',
              icon: Icons.attach_file,
              onPressed: widget.onAttachmentPressed ?? () {},
              backgroundColor: AppColors.primaryYellow,
              width: 48,
              height: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.border, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.border,
                      offset: const Offset(3, 3),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.messageController,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontFamily: "ZillaSlab",
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Type Messages......',
                          hintStyle: TextStyle(
                            color: AppColors.textGrey,
                            fontFamily: "ZillaSlab",
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => widget.onSendMessage(),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap:
                            (_isInitialized && !_isRecorderBusy)
                                ? _handleMicPressed
                                : null,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration:
                              _isRecording
                                  ? BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  )
                                  : null,
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color:
                                (_isInitialized && !_isRecorderBusy)
                                    ? (_isRecording
                                        ? Colors.red
                                        : AppColors.textDark)
                                    : AppColors.textGrey,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            RetroButton(
              text: '',
              icon: Icons.send,
              onPressed: widget.onSendMessage,
              backgroundColor: AppColors.accentPink,
              width: 48,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}
