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

import FirebaseStorage
import FirebaseAuth

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
    
    // Firebase services
    private let storage = Storage.storage()
    private let realtimeManager = FirebaseRealtimeManager()
    
    private let recordingsKey = "SavedRecordings"
    
    override init() {
        super.init()
        setupAudioSession()
        loadRecordings()
        
        // Listen for auth state changes to sync recordings
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if user != nil {
                self?.syncRecordings()
            }
        }
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
            var newRecording = Recording(fileName: fileName, duration: duration)
            recordings.insert(newRecording, at: 0)
            saveRecordings()
            
            // Upload if user is logged in
            if let user = Auth.auth().currentUser {
                // Create the storage path that will be used for upload
                let storagePath = "users/\(user.uid)/\(newRecording.id.uuidString).m4a"
                
                // Create the database record first with "incomplete" status
                let recordingRecord = RecordingRecord(
                    id: newRecording.id,
                    fileName: fileName,
                    storagePath: storagePath,
                    duration: duration,
                    status: .incomplete
                )
                
                // Create database record
                Task {
                    do {
                        try await realtimeManager.createRecordingRecord(recordingRecord)
                        print("✅ Recording record created in database")
                        
                        // Update status to uploading
                        try await realtimeManager.updateRecordingStatus(newRecording.id.uuidString, status: .uploading)
                        print("✅ Recording status updated to uploading")
                        
                    } catch {
                        print("❌ Failed to create recording record: \(error.localizedDescription)")
                        // Even if database fails, continue with storage upload
                    }
                }
                
                uploadRecording(newRecording, userId: user.uid) { [weak self] url in
                    if let url = url {
                        // Update local recording with download URL
                        if let index = self?.recordings.firstIndex(where: { $0.id == newRecording.id }) {
                            self?.recordings[index] = Recording(
                                id: newRecording.id,
                                fileName: newRecording.fileName,
                                date: newRecording.date,
                                duration: newRecording.duration,
                                downloadURL: url
                            )
                            self?.saveRecordings()
                        }
                        
                        // Update database record status to complete
                        Task {
                            do {
                                try await self?.realtimeManager.updateRecordingStatus(
                                    newRecording.id.uuidString,
                                    status: .complete,
                                    downloadURL: url.absoluteString
                                )
                                print("✅ Recording status updated to complete")
                            } catch {
                                print("❌ Failed to update recording status to complete: \(error.localizedDescription)")
                            }
                        }
                    } else {
                        // Update database record status to failed
                        Task {
                            do {
                                try await self?.realtimeManager.updateRecordingStatus(
                                    newRecording.id.uuidString,
                                    status: .failed
                                )
                                print("⚠️ Recording status updated to failed")
                            } catch {
                                print("❌ Failed to update recording status to failed: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
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
        
        // Check if file exists locally
        if FileManager.default.fileExists(atPath: fileURL.path) {
            startPlayback(url: fileURL, recordingId: recording.id)
        } else if let downloadURL = recording.downloadURL {
            // Download and play
            downloadRecording(from: downloadURL, to: fileURL) { [weak self] success in
                if success {
                    self?.startPlayback(url: fileURL, recordingId: recording.id)
                }
            }
        }
    }
    
    private func startPlayback(url: URL, recordingId: UUID) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            isPlaying = true
            currentPlayingId = recordingId
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
        
        // Delete from Storage if logged in
        if let user = Auth.auth().currentUser {
            let storageRef = storage.reference().child("users/\(user.uid)/\(recording.id.uuidString).m4a")
            storageRef.delete { error in
                if let error = error {
                    print("Error deleting from storage: \(error.localizedDescription)")
                }
            }
        }
        
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
    
    // MARK: - Firebase Storage
    
    func uploadRecording(_ recording: Recording, userId: String, completion: @escaping (URL?) -> Void) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(recording.fileName)
        let storageRef = storage.reference().child("users/\(userId)/\(recording.id.uuidString).m4a")
        
        // Create metadata
        let metadata = StorageMetadata()
        metadata.customMetadata = [
            "fileName": recording.fileName,
            "duration": String(recording.duration),
            "date": String(recording.date.timeIntervalSince1970)
        ]
        
        storageRef.putFile(from: fileURL, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading recording: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url)
            }
        }
    }
    
    func syncRecordings() {
        guard let user = Auth.auth().currentUser else { return }
        let storageRef = storage.reference().child("users/\(user.uid)")
        
        storageRef.listAll { [weak self] result, error in
            if let error = error {
                print("Error listing recordings: \(error.localizedDescription)")
                return
            }
            
            guard let result = result else { return }
            
            for item in result.items {
                // Check if we already have this recording locally (by ID, assuming ID is in filename)
                // Filename format in storage: UUID.m4a
                let uuidString = item.name.replacingOccurrences(of: ".m4a", with: "")
                if let uuid = UUID(uuidString: uuidString) {
                    if self?.recordings.contains(where: { $0.id == uuid }) == true {
                        continue
                    }
                    
                    // Fetch metadata to create Recording object
                    item.getMetadata { metadata, error in
                        if let error = error {
                            print("Error getting metadata: \(error.localizedDescription)")
                            return
                        }
                        
                        if let customMetadata = metadata?.customMetadata,
                           let fileName = customMetadata["fileName"],
                           let durationString = customMetadata["duration"],
                           let duration = TimeInterval(durationString),
                           let dateString = customMetadata["date"],
                           let timeInterval = TimeInterval(dateString) {
                            
                            item.downloadURL { url, error in
                                if let url = url {
                                    let date = Date(timeIntervalSince1970: timeInterval)
                                    let recording = Recording(
                                        id: uuid,
                                        fileName: fileName,
                                        date: date,
                                        duration: duration,
                                        downloadURL: url
                                    )
                                    
                                    DispatchQueue.main.async {
                                        self?.recordings.append(recording)
                                        self?.recordings.sort(by: { $0.date > $1.date })
                                        self?.saveRecordings()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func downloadRecording(from url: URL, to localURL: URL, completion: @escaping (Bool) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { localFile, response, error in
            if let error = error {
                print("Error downloading file: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let localFile = localFile else {
                completion(false)
                return
            }
            
            do {
                try FileManager.default.moveItem(at: localFile, to: localURL)
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print("Error moving downloaded file: \(error.localizedDescription)")
                completion(false)
            }
        }
        task.resume()
    }
    
    // MARK: - Firebase Realtime Database
    
    func getRecordingRecords() async throws -> [RecordingRecord] {
        return try await realtimeManager.getAllRecordingRecords()
    }
    
    func deleteRecordingRecord(_ recordId: String) async throws {
        try await realtimeManager.deleteRecordingRecord(recordId)
    }
    
    func updateRecordingRecordStatus(_ recordId: String, status: RecordingRecord.RecordingStatus, downloadURL: String? = nil) async throws {
        try await realtimeManager.updateRecordingStatus(recordId, status: status, downloadURL: downloadURL)
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

