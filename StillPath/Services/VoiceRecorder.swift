import AVFoundation
import Observation

@MainActor @Observable
final class VoiceRecorder: NSObject, AVAudioRecorderDelegate {
    private var recorder: AVAudioRecorder?
    private(set) var isRecording = false
    private(set) var recordedFileURL: URL?
    var errorMessage: String?

    func toggle() async {
        if isRecording { stop(); return }
        guard await AVAudioApplication.requestRecordPermission() else {
            errorMessage = String(localized: "voice.permissionDenied")
            return
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
            let directory = try recordingsDirectory()
            let url = directory.appending(path: "\(UUID().uuidString).m4a")
            recorder = try AVAudioRecorder(url: url, settings: [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ])
            recorder?.delegate = self
            guard recorder?.record() == true else { throw VoiceError.couldNotStart }
            isRecording = true; recordedFileURL = url
        } catch { errorMessage = error.localizedDescription }
    }

    func stop() {
        recorder?.stop(); recorder = nil; isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false)
        if let url = recordedFileURL { try? FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: url.path) }
    }

    func discard() {
        stop(); if let url = recordedFileURL { try? FileManager.default.removeItem(at: url) }; recordedFileURL = nil
    }

    private func recordingsDirectory() throws -> URL {
        let root = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let directory = root.appending(path: "PrivateRecordings", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.protectionKey: FileProtectionType.complete])
        return directory
    }

    enum VoiceError: LocalizedError { case couldNotStart; var errorDescription: String? { String(localized: "voice.startError") } }
}

