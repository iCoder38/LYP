//
//  ViewController.swift
//  Agora-RTC-QuickStart-iOS
//
//  Created by CP on 2023/12/15.
//

import UIKit
import AgoraRtcKit
import AVKit
import GrowingTextView
import Firebase

class liveStreamingController: UIViewController {
    
    var str_audience:String!
    var str_channel_name:String!
    
    @IBOutlet weak var btn_back:UIButton! {
        didSet {
            btn_back.tintColor = .black
            btn_back.addTarget(self, action: #selector(back_click_method), for: .touchUpInside)
        }
    }
    
    // The main entry point for Video SDK
    var agoraEngine: AgoraRtcEngineKit!
    
    
    // By default, set the current user role to broadcaster to both send and receive streams.
    var userRole: AgoraClientRole = .broadcaster

    let appID = AGORA_APP_ID
    var token = AGORA_TEMP_TOKEN
    var channelName = "iOS_Testing_LYV"
    
    @IBOutlet weak var inputToolbar: UIView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var localView:UIView!
    @IBOutlet weak var remoteView:UIView!
    @IBOutlet weak var joinButton: UIButton!
    
    // Track if the local user is in a call
    var joined: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.joinButton.setTitle( self.joined ? "Leave" : "Join", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.str_channel_name = String(self.channelName)
        print(self.str_channel_name as Any)
        
        initViews()
        
        initializeAgoraEngine()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       super.viewDidDisappear(animated)
       leaveChannel()
       DispatchQueue.global(qos: .userInitiated).async {AgoraRtcEngineKit.destroy()}
    }
    
    private func initViews() {
        joinButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    private func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        // Pass in your App ID here.
        config.appId = appID
        // Use AgoraRtcEngineDelegate for the following delegate parameter.
        agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        if !joined {
            sender.isEnabled = false
            Task {
                // ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "creating live panel...")
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                generator.impactOccurred()
                
                await joinChannel()
                sender.isEnabled = true
                
                if (self.str_audience != "yes") {
                    self.userJoinAndConnected()
                }
                
            }
        } else {
            leaveChannel()
        }
    }
    
    @objc func userJoinAndConnected() {
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String: Any] {
            
//            let db = Firestore.firestore()
//            let messagesRef = db.collection("mode/lyv/live_streaming")
//            
//            let randomString = generateRandomAlphanumericString(length: 10)
//            
//            let timestamp = getCurrentTimestampInMilliseconds()
//            
//            // Create a dictionary with message data
//            let messageData: [String: Any] = [
//                "liveId"        : randomString,
//                "userId"        : "\(person["userId"]!)",
//                "channelName"   : "Satish@123",
//                "timeStamp"     : timestamp,
//            ]
//            
//            // Add a new document with a generated ID
//            messagesRef.addDocument(data: messageData) { error in
//                if let error = error {
//                    print("Error adding message: \(error)")
//                    // completion(error)
//                } else {
//                    print("Live stream added successfully")
//                    // completion(nil)
//                }
//            }
            let db = Firestore.firestore()
            let messagesRef = db.collection(COLLECTION_PATH_LIVE_STREAM)

            let randomString = generateRandomAlphanumericString(length: 10)
            let timestamp = getCurrentTimestampInMilliseconds()

            print(person as Any)
            
            let messageData: [String: Any] = [
                // "liveId"        : randomString,
                "userId"        : "\(person["userId"]!)",
                "userName"      : "\(person["fullName"]!)",
                "userImage"     : "\(person["image"]!)",
                "userEmail"     : "\(person["email"]!)",
                "userDevice"    : "iOS",
                "userDeviceToken"    : "\(person["deviceToken"]!)",
                "channelName"   : String(self.str_channel_name),
                "timeStamp"     : timestamp,
                "active"        : true,
                
            ]

            messagesRef.document("\(person["userId"]!)").setData(messageData) { error in
                if let error = error {
                    print("Error setting message: \(error)")
                } else {
                    print("Live stream added successfully")
                    ERProgressHud.sharedInstance.hide()
                }
            }

        }
    }
    
    private func setupLocalVideo() {
        // Enable the video module
        agoraEngine.enableVideo()
        // Start the local video preview
        agoraEngine.startPreview()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        // Set the local video view
        agoraEngine.setupLocalVideo(videoCanvas)
    }
    
    private func setupLocalVideoForAudience() {
        // Enable the video module
        agoraEngine.enableVideo()
        // Start the local video preview
        agoraEngine.startPreview()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        // Set the local video view
        agoraEngine.setupLocalVideo(videoCanvas)
    }
    
    func joinChannel() async {
        if await !self.checkForPermissions() {
            showMessage(title: "Error", text: "Permissions were not granted")
            return
        }

        let option = AgoraRtcChannelMediaOptions()

        /*if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String: Any] {
            
            if (person["email"] as! String) == "purnimaevs@gmail.com" {
                option.clientRoleType = .broadcaster
                setupLocalVideo()
            } else {
                option.clientRoleType = .audience
                setupLocalVideoForAudience()
            }
            
        }*/
        if (self.str_audience == "yes") {
            option.clientRoleType = .audience
            setupLocalVideoForAudience()
        } else {
            option.clientRoleType = .broadcaster
            setupLocalVideo()
        }
         
         
        print("USER ROLE IS: ====> \(option.clientRoleType)")

        option.channelProfile = .liveBroadcasting

        // Join the channel with a temp token. Pass in your token and channel name here
        let result  = agoraEngine.joinChannel(
            byToken: token, channelId: String(self.str_channel_name), uid: 0, mediaOptions: option,
            joinSuccess: nil
        )
        
        print(result)
    }

    func leaveChannel() {
        if let person = UserDefaults.standard.value(forKey: str_save_login_user_data) as? [String: Any] {
            let db = Firestore.firestore()
            let messagesRef = db.collection(COLLECTION_PATH_LIVE_STREAM)
            
            // Delete the document with the specified ID (documentId)
            messagesRef.document("\(person["userId"]!)").delete() { error in
                if let error = error {
                    print("Error deleting document: \(error.localizedDescription)")
                    // Handle the error appropriately (e.g., notify the user, retry, etc.)
                } else {
                    print("Live stream ended successfully")
                    self.agoraEngine.stopPreview()
                    let result = self.agoraEngine.leaveChannel(nil)
                    // Check if leaving the channel was successful and set joined Bool accordingly
                    if result == 0 { self.joined = false }
                }
            }
            
        }
        
    }

    /*override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // remoteView.frame = CGRect(x: 20, y: 50, width: 350, height: 330)
        // localView.frame = CGRect(x: 20, y: 400, width: 350, height: 330)
    }*/
    
    private func checkForPermissions() async -> Bool {
        var hasPermissions = await self.avAuthorization(mediaType: .video)
        // Break out, because camera permissions have been denied or restricted.
        if !hasPermissions { return false }
        hasPermissions = await self.avAuthorization(mediaType: .audio)
        return hasPermissions
    }

    private func avAuthorization(mediaType: AVMediaType) async -> Bool {
        let mediaAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch mediaAuthorizationStatus {
        case .denied, .restricted: return false
        case .authorized: return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: mediaType) { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default: return false
        }
    }
    
    private func showMessage(title: String, text: String, delay: Int = 2) -> Void {
        let deadlineTime = DispatchTime.now() + .seconds(delay)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            self.present(alert, animated: true)
            alert.dismiss(animated: true, completion: nil)
        })
    }
}

extension liveStreamingController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        joined = true
        // showMessage(title: "Success", text: "Successfully joined the channel as \(self.userRole)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        print("didLeaveChannelWithStats == \(stats)")
    }
    
    /// callback when a remote user is joinning the channel, note audience in live broadcast mode will NOT trigger this event
    /// @param uid uid of remote joined user
    /// @param elapsed time elapse since current sdk instance join the channel in ms
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print("Broadcaster joined with uid: \(uid)")
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        agoraEngine.setupRemoteVideo(videoCanvas)
    }
    
    /// callback when a remote user is leaving the channel, note audience in live broadcast mode will NOT trigger this event
    /// @param uid uid of remote joined user
    /// @param reason reason why this user left, note this event may be triggered when the remote user
    /// become an audience in live broadcasting profile
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = nil
        agoraEngine.setupRemoteVideo(videoCanvas)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoFrameOfUid uid: UInt, size: CGSize, elapsed: Int) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = localView
        videoCanvas.renderMode = .hidden
        agoraEngine?.setupRemoteVideo(videoCanvas)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, networkQuality uid: UInt, txQuality: AgoraNetworkQuality, rxQuality: AgoraNetworkQuality) {
        print("uid == \(uid)  txQuality == \(txQuality.rawValue) rxQuality == \(rxQuality.rawValue)")
    }
    
    /// Reports the statistics of the current call. The SDK triggers this callback once every two seconds after the user joins the channel.
    /// @param stats stats struct
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
        print("reportRtcStats == \(stats)")
    }
    
    /// Reports the statistics of the uploading local audio streams once every two seconds.
    /// @param stats stats struct
    func rtcEngine(_ engine: AgoraRtcEngineKit, localAudioStats stats: AgoraRtcLocalAudioStats) {
        print("reportRtcStats == \(stats)")
    }
    
    /// Reports the statistics of the video stream from each remote user/host.
    /// @param stats stats struct
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
        print("remoteVideoStats == \(stats)")
    }
    
    /// Reports the statistics of the audio stream from each remote user/host.
    /// @param stats stats struct for current call statistics
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStats stats: AgoraRtcRemoteAudioStats) {
        print("remoteAudioStats == \(stats)")
    }
}
