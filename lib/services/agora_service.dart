import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService extends GetxService {
  static AgoraService get to => Get.find();

  static const String appId = '3e096f1084dd4cecb840c2aba8b04493';

  RtcEngine? _engine;
  RtcEngine? get engine => _engine;

  var isInitialized = false.obs;
  var remoteUid = Rxn<int>();
  var isJoined = false.obs;
  String? currentChannelId;

  /// Request microphone and camera permissions
  Future<bool> requestPermissions() async {
    final statuses = await [Permission.microphone, Permission.camera].request();
    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;
    final camGranted = statuses[Permission.camera]?.isGranted ?? false;
    
    if (micGranted && camGranted) {
      return true;
    } else {
      log('Permissions not granted for audio/video calling');
      return false;
    }
  }

  /// Initialize Agora Rtc Engine
  Future<void> initAgora() async {
    if (isInitialized.value) return;

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Register Event Handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            log('Agora Joined channel: ${connection.channelId}, local uid: ${connection.localUid}');
            isJoined.value = true;
          },
          onUserJoined: (RtcConnection connection, int remoteUserUid, int elapsed) {
            log('Agora Remote user joined: $remoteUserUid');
            remoteUid.value = remoteUserUid;
          },
          onUserOffline: (RtcConnection connection, int remoteUserUid, UserOfflineReasonType reason) {
            log('Agora Remote user offline: $remoteUserUid, reason: $reason');
            remoteUid.value = null;
          },
          onError: (ErrorCodeType err, String msg) {
            log('Agora Error: $err, message: $msg');
          },
        ),
      );

      // Enable video and audio configurations
      await _engine!.enableAudio();
      await _engine!.enableVideo();
      await _engine!.startPreview();
      
      isInitialized.value = true;
      log('Agora Engine Initialized Successfully');
    } catch (e) {
      log('Error initializing Agora: $e');
    }
  }

  /// Join a call channel
  Future<void> joinCallChannel({required String channelId, String? token, int uid = 0}) async {
    await requestPermissions();
    await initAgora();

    try {
      log('Joining Agora Channel: $channelId with UID: $uid');
      currentChannelId = channelId;
      isJoined.value = false;
      remoteUid.value = null;

      // Force camera activation and preview
      await _engine!.enableVideo();
      await _engine!.startPreview();

      await _engine!.joinChannel(
        token: token ?? '', // Use empty string for temp/testing tokenless AppID
        channelId: channelId,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
    } catch (e) {
      log('Error joining channel: $e');
    }
  }

  /// Mute or unmute local audio
  Future<void> muteLocalAudio(bool mute) async {
    if (!isInitialized.value) return;
    await _engine!.muteLocalAudioStream(mute);
  }

  /// Toggle speakerphone
  Future<void> enableSpeakerphone(bool speaker) async {
    if (!isInitialized.value) return;
    await _engine!.setEnableSpeakerphone(speaker);
  }

  /// Mute or unmute local video stream (enable/disable camera)
  Future<void> muteLocalVideo(bool mute) async {
    if (!isInitialized.value) return;
    await _engine!.muteLocalVideoStream(mute);
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    if (!isInitialized.value) return;
    await _engine!.switchCamera();
  }

  /// Leave the call channel
  Future<void> leaveCallChannel() async {
    if (!isInitialized.value) return;
    
    try {
      log('Leaving Agora Channel');
      await _engine!.leaveChannel();
      isJoined.value = false;
      remoteUid.value = null;
    } catch (e) {
      log('Error leaving channel: $e');
    }
  }

  @override
  void onClose() {
    _engine?.release();
    super.onClose();
  }
}
