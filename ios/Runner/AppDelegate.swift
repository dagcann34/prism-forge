import AVFoundation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let storageChannelName = "com.prismforge/storage"
  private let audioChannelName = "com.prismforge/audio"
  private let audioEngine = AVAudioEngine()
  private var isAudioEngineStarted = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let messenger = engineBridge.applicationRegistrar.messenger()

    // 1. Offline local progress storage (UserDefaults).
    let storageChannel = FlutterMethodChannel(
      name: storageChannelName,
      binaryMessenger: messenger
    )
    storageChannel.setMethodCallHandler { call, result in
      let defaults = UserDefaults.standard
      guard let args = call.arguments as? [String: String], let key = args["key"] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing key", details: nil))
        return
      }
      switch call.method {
      case "read":
        result(defaults.string(forKey: key))
      case "write":
        guard let value = args["value"] else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing value", details: nil))
          return
        }
        defaults.set(value, forKey: key)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // 2. Offline procedural PCM playback (AVAudioEngine, respects mute switch).
    let audioChannel = FlutterMethodChannel(
      name: audioChannelName,
      binaryMessenger: messenger
    )
    audioChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }
      if call.method == "playPcm",
         let args = call.arguments as? [String: Any],
         let typedData = args["pcm"] as? FlutterStandardTypedData {
        let sampleRate = (args["sampleRate"] as? Int) ?? 22050
        self.playPcm(data: typedData.data, sampleRate: Double(sampleRate))
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func playPcm(data: Data, sampleRate: Double) {
    let frameCount = data.count / MemoryLayout<Int16>.size
    guard frameCount > 0 else { return }

    do {
      if !isAudioEngineStarted {
        try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try AVAudioSession.sharedInstance().setActive(true)
      }
      guard let format = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: sampleRate,
        channels: 1,
        interleaved: false
      ),
      let buffer = AVAudioPCMBuffer(
        pcmFormat: format,
        frameCapacity: AVAudioFrameCount(frameCount)
      ),
      let channelData = buffer.floatChannelData?[0] else {
        return
      }

      buffer.frameLength = AVAudioFrameCount(frameCount)
      data.withUnsafeBytes { rawBuf in
        let int16Ptr = rawBuf.bindMemory(to: Int16.self)
        for i in 0..<frameCount {
          channelData[i] = Float(int16Ptr[i]) / 32768.0
        }
      }

      let player = AVAudioPlayerNode()
      audioEngine.attach(player)
      audioEngine.connect(player, to: audioEngine.mainMixerNode, format: format)

      if !audioEngine.isRunning {
        try audioEngine.start()
        isAudioEngineStarted = true
      }

      player.scheduleBuffer(buffer, at: nil, options: []) { [weak self, weak player] in
        DispatchQueue.main.async {
          guard let self = self, let player = player else { return }
          player.stop()
          self.audioEngine.detach(player)
        }
      }
      player.play()
    } catch {
      // Never interrupt gameplay if audio output is unavailable.
    }
  }
}
