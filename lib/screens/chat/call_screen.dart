import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/theme.dart';

class CallScreen extends StatefulWidget {
  final String contactName;
  final String contactId;
  final bool isVideo;
  final bool isIncoming;

  const CallScreen({
    super.key,
    required this.contactName,
    required this.contactId,
    required this.isVideo,
    required this.isIncoming,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isCallConnected = false;
  bool isMuted = false;
  bool isSpeakerOn = false;
  bool isVideoEnabled = true;
  bool isCameraFront = true;
  Timer? _callTimer;
  Duration callDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    
    if (widget.isIncoming) {
      // Pour un appel entrant, on attend la réponse
      _showIncomingCallInterface();
    } else {
      // Pour un appel sortant, on simule la connexion
      _startOutgoingCall();
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  void _showIncomingCallInterface() {
    // Interface d'appel entrant (sonnerie)
  }

  void _startOutgoingCall() {
    // Simuler la connexion après 3 secondes
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isCallConnected = true;
        });
        _startCallTimer();
      }
    });
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          callDuration = Duration(seconds: callDuration.inSeconds + 1);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isVideo ? Colors.black : AppTheme.primaryBlue,
      body: Stack(
        children: [
          // Fond vidéo ou avatar
          _buildVideoBackground(),
          
          // Interface de contrôle
          _buildCallInterface(),
        ],
      ),
    );
  }

  Widget _buildVideoBackground() {
    if (widget.isVideo && isVideoEnabled) {
      return Stack(
        children: [
          // Vidéo principale (contact distant)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.videocam_off,
                size: 100,
                color: Colors.white54,
              ),
            ),
          ),
          
          // Aperçu vidéo local (petit)
          if (isCallConnected)
            Positioned(
              top: 60,
              right: 20,
              child: GestureDetector(
                onTap: _switchCamera,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      // Interface audio avec avatar
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue,
              AppTheme.primaryBlue.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  widget.contactName[0],
                  style: const TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                widget.contactName,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getCallStatusText(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildCallInterface() {
    return Column(
      children: [
        // Barre de statut en haut
        _buildTopBar(),
        
        const Spacer(),
        
        // Contrôles d'appel en bas
        _buildCallControls(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: Row(
        children: [
          if (widget.isVideo && isCallConnected)
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.minimize,
                color: Colors.white,
              ),
            ),
          
          const Spacer(),
          
          if (isCallConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formatDuration(callDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    if (widget.isIncoming && !isCallConnected) {
      return _buildIncomingCallControls();
    } else {
      return _buildActiveCallControls();
    }
  }

  Widget _buildIncomingCallControls() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Bouton rejeter
          GestureDetector(
            onTap: _declineCall,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          
          // Bouton accepter
          GestureDetector(
            onTap: _acceptCall,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCallControls() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Première rangée de contrôles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: isMuted ? Icons.mic_off : Icons.mic,
                isActive: !isMuted,
                onPressed: _toggleMute,
              ),
              
              if (widget.isVideo) ...[
                _buildControlButton(
                  icon: isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  isActive: isVideoEnabled,
                  onPressed: _toggleVideo,
                ),
                
                _buildControlButton(
                  icon: Icons.cameraswitch,
                  isActive: true,
                  onPressed: _switchCamera,
                ),
              ],
              
              _buildControlButton(
                icon: isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                isActive: isSpeakerOn,
                onPressed: _toggleSpeaker,
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Bouton raccrocher
          GestureDetector(
            onTap: _endCall,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: isActive 
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  String _getCallStatusText() {
    if (!isCallConnected) {
      return widget.isIncoming ? 'Appel entrant...' : 'Connexion en cours...';
    }
    return _formatDuration(callDuration);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  void _acceptCall() {
    setState(() {
      isCallConnected = true;
    });
    _startCallTimer();
  }

  void _declineCall() {
    Navigator.pop(context);
  }

  void _endCall() {
    _callTimer?.cancel();
    Navigator.pop(context);
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });
  }

  void _toggleSpeaker() {
    setState(() {
      isSpeakerOn = !isSpeakerOn;
    });
  }

  void _toggleVideo() {
    if (widget.isVideo) {
      setState(() {
        isVideoEnabled = !isVideoEnabled;
      });
    }
  }

  void _switchCamera() {
    if (widget.isVideo && isVideoEnabled) {
      setState(() {
        isCameraFront = !isCameraFront;
      });
    }
  }
}