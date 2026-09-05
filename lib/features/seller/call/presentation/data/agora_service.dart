import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';

const String kAgoraAppId = "3e096f1084dd4cecb840c2aba8b04493";

class AgoraService {
  static final AgoraService _instance = AgoraService._internal();
  AgoraService._internal();
  static AgoraService get instance => _instance;

  RtcEngine? _engine;
  bool _isInitialized = false;

  RtcEngine? get engine => _engine;

  final remoteUid = Rxn<int>();
  final isJoined = false.obs;
  String? currentChannelId;

  Future<void> initEngine() async {
    if (_isInitialized) return;

    // Ask for microphone and camera permissions
    await [Permission.microphone, Permission.camera].request();

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: kAgoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Register generic event handler for logging
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            log("Agora: Local user ${connection.localUid} joined channel ${connection.channelId}");
            isJoined.value = true;
          },
          onUserJoined: (RtcConnection connection, int uid, int elapsed) {
            log("Agora: Remote user $uid joined channel");
            remoteUid.value = uid;
          },
          onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
            log("Agora: Remote user $uid went offline because of $reason");
            remoteUid.value = null;
          },
          onError: (ErrorCodeType err, String msg) {
            log("Agora Error: $err, Message: $msg");
          },
        ),
      );

      // Enable audio and video components
      await _engine!.enableAudio();
      await _engine!.enableVideo();
      await _engine!.startPreview();

      _isInitialized = true;
      log("Agora RTC Engine initialized successfully with Video.");
    } catch (e) {
      log("Agora Initialization Error: $e");
    }
  }

  Future<void> joinChannel({
    required String channelId,
    String? token,
    int uid = 0,
  }) async {
    await initEngine();
    if (_engine == null) return;

    try {
      log("Agora: Attempting to join channel '$channelId' with UID: $uid");
      currentChannelId = channelId;
      isJoined.value = false;
      remoteUid.value = null;

      // Force camera activation and preview
      await _engine!.enableVideo();
      await _engine!.startPreview();

      await _engine!.joinChannel(
        token: token ?? "",
        channelId: channelId,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          publishCameraTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
    } catch (e) {
      log("Agora: Join Channel Error: $e");
    }
  }

  Future<void> leaveChannel() async {
    if (_engine == null) return;
    try {
      await _engine!.leaveChannel();
      log("Agora: Left channel successfully.");
      isJoined.value = false;
      remoteUid.value = null;
    } catch (e) {
      log("Agora: Leave Channel Error: $e");
    }
  }

  Future<void> toggleCamera(bool isCameraOff) async {
    if (_engine == null) return;
    try {
      await _engine!.muteLocalVideoStream(isCameraOff);
      log("Agora: Camera toggled (isCameraOff: $isCameraOff)");
    } catch (e) {
      log("Agora: Toggle Camera Error: $e");
    }
  }

  Future<void> switchCamera() async {
    if (_engine == null) return;
    try {
      await _engine!.switchCamera();
      log("Agora: Camera switched (front/back)");
    } catch (e) {
      log("Agora: Switch Camera Error: $e");
    }
  }

  Future<void> toggleMute(bool mute) async {
    if (_engine == null) return;
    try {
      await _engine!.muteLocalAudioStream(mute);
      log("Agora: Local audio stream muted: $mute");
    } catch (e) {
      log("Agora: Mute Error: $e");
    }
  }

  Future<void> toggleSpeaker(bool speaker) async {
    if (_engine == null) return;
    try {
      await _engine!.setEnableSpeakerphone(speaker);
      log("Agora: Speakerphone enabled: $speaker");
    } catch (e) {
      log("Agora: Speakerphone Error: $e");
    }
  }

  Future<void> dispose() async {
    if (_engine == null) return;
    try {
      await leaveChannel();
      await _engine!.release();
      _engine = null;
      _isInitialized = false;
      log("Agora RTC Engine released.");
    } catch (e) {
      log("Agora: Release Error: $e");
    }
  }
}
