//
//  AudioRecorderManager.swift
//  kotalojz
//
//  Created by Hubert Guzera on 30/10/2025.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

class AudioRecorderManager: NSObject, ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    var recordings: [Recording] = [] {
        willSet { objectWillChange.send() }
    }
    
    var isRecording = false {
        willSet { objectWillChange.send() }
    }
    
    var isPlaying = false {
        willSet { objectWillChange.send() }
    }
    
    var currentPlayingId: UUID? {
        willSet { objectWillChange.send() }
    }
    
    var recordingTime: TimeInterval = 0 {
        willSet { objectWillChange.send() }
    }
    
    var playbackTime: TimeInterval = 0 {
        willSet { objectWillChange.send() }
    }
    
    var audioLevel: Float = 0.0 {
        willSet { objectWillChange.send() }
    }
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var playbackTimer: Timer?
    
    private let recordingsKey = "SavedRecordings"
    
    override init() {
        super.init()
        setupAudioSession()
        loadRecordings()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func startRecording() {
        requestPermission { [weak self] granted in
            guard granted else {
                print("Recording permission denied")
                return
            }
            
            self?.beginRecording()
        }
    }
    
    private func beginRecording() {
        let fileName = "recording_\(Date().timeIntervalSince1970).m4a"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            recordingTime = 0
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.recordingTime += 0.05
                self.audioRecorder?.updateMeters()
                let power = self.audioRecorder?.averagePower(forChannel: 0) ?? -160
                // Convert dB to normalized 0-1 scale
                let normalizedLevel = max(0.0, min(1.0, (power + 60) / 60))
                self.audioLevel = normalizedLevel
            }
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false
        
        if let recorder = audioRecorder {
            let duration = recordingTime
            let fileName = recorder.url.lastPathComponent
            let newRecording = Recording(fileName: fileName, duration: duration)
            recordings.insert(newRecording, at: 0)
            saveRecordings()
        }
        
        audioRecorder = nil
        recordingTime = 0
        audioLevel = 0.0
    }
    
    func playRecording(_ recording: Recording) {
        if isPlaying && currentPlayingId == recording.id {
            pausePlayback()
            return
        }
        
        let fileURL = getDocumentsDirectory().appendingPathComponent(recording.fileName)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            isPlaying = true
            currentPlayingId = recording.id
            playbackTime = 0
            
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let player = self.audioPlayer else { return }
                self.playbackTime = player.currentTime
            }
        } catch {
            print("Failed to play recording: \(error.localizedDescription)")
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        currentPlayingId = nil
        playbackTime = 0
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    func deleteRecording(_ recording: Recording) {
        if currentPlayingId == recording.id {
            stopPlayback()
        }
        
        let fileURL = getDocumentsDirectory().appendingPathComponent(recording.fileName)
        try? FileManager.default.removeItem(at: fileURL)
        
        recordings.removeAll { $0.id == recording.id }
        saveRecordings()
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func saveRecordings() {
        if let encoded = try? JSONEncoder().encode(recordings) {
            UserDefaults.standard.set(encoded, forKey: recordingsKey)
        }
    }
    
    private func loadRecordings() {
        if let data = UserDefaults.standard.data(forKey: recordingsKey),
           let decoded = try? JSONDecoder().decode([Recording].self, from: data) {
            recordings = decoded
        }
    }
}

extension AudioRecorderManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
}

extension AudioRecorderManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.stopPlayback()
        }
    }
}

