//
//  VotographerViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 10/24/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit
import TwilioVideo
import SwiftSpinner

class VotographerViewController: UIViewController {
  
    // MARK: View Controller Members

    var accessToken = ""
    var vshootId: NSInteger = 0
    var roomName:String = ""

    
    // Configure remote URL to fetch token from
    var tokenUrl = "http://localhost:8000/token.php"
    
    // Video SDK components
    var room: TVIRoom?
    var camera: TVICameraSource?
    var localVideoTrack: TVILocalVideoTrack?
    var localAudioTrack: TVILocalAudioTrack?
    var remoteParticipant: TVIRemoteParticipant?
    var remoteView: TVIVideoView?
    var flashOn:Bool = false
    // MARK: UI Element Outlets and handles
    
    // `TVIVideoView` created from a storyboard
    @IBOutlet weak var previewView: TVIVideoView!

    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var microphoneBtn: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SocketIOManager.sharedInstance.socket.on("VShootEnded"){ dataResults, ack in
            print("votographer is ending vshoot")
            let alertController = UIAlertController(title: "The Vmodel has ended the VShoot", message:
                nil, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                self.disconnectOnServerRequest() }))
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        SocketIOManager.sharedInstance.socket.on("vmodelInBackground"){ dataResults, ack in
            print("vmodel is going to background")
            let alertController = UIAlertController(title: "Wait a Sec...", message:
                "Vmodel has temporarily left the shooting room, most likely to view photos. They should be back shortly!", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                self.waitForVmodel() }))
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        SocketIOManager.sharedInstance.socket.on("vmodelIsBack"){data, ack in
            print("Votographer is Back")
            SwiftSpinner.hide()
            let alertController = UIAlertController(title: "Vmodel is Back!", message: "If you are not automatically connected back to the virtual shoot, press the capture button to reconnect.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: {(action) in
                
            }))
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        //self.title = "QuickStart"
        self.messageLabel.adjustsFontSizeToFitWidth = true;
        self.messageLabel.minimumScaleFactor = 0.75;
        self.disconnectButton.layer.cornerRadius = CGFloat(Float(8.0))
        
        // Disconnect and mic button will be displayed when the Client is connected to a Room.
        //self.disconnectButton.isHidden = true
        //self.micButton.isHidden = true
        
        self.connect()
    }
    
    func waitForVmodel(){
        //show a spinner
        self.showSpinner(receiver: "vmodel")
    }
    
    func showSpinner(receiver:String){
        SwiftSpinner.show("Waiting for " + receiver + "...").addTapHandler({
            SwiftSpinner.hide()
            let alertController = UIAlertController(title: "Cancel?", message: "Are you sure you want to cancel?", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default,handler: {(action) in
                //SwiftSpinner.hide()
                self.disconnectWhileWaiting()
                
            }))
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default,handler: {(action) in
                self.showSpinner(receiver: receiver)
                
                
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }, subtitle: "Tired of waiting? Tap screen to end vshoot!")
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return self.room != nil
    }
    
    func setupRemoteVideoView() {
        // Creating `TVIVideoView` programmatically
        self.remoteView = TVIVideoView.init(frame: CGRect.zero, delegate:self)
        
        self.view.insertSubview(self.remoteView!, at: 0)
        
        // `TVIVideoView` supports scaleToFill, scaleAspectFill and scaleAspectFit
        // scaleAspectFit is the default mode when you create `TVIVideoView` programmatically.
        self.remoteView!.contentMode = .scaleAspectFit;
        
        let centerX = NSLayoutConstraint(item: self.remoteView!,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerX)
        let centerY = NSLayoutConstraint(item: self.remoteView!,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerY)
        let width = NSLayoutConstraint(item: self.remoteView!,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                       toItem: self.view,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       multiplier: 1,
                                       constant: 0);
        self.view.addConstraint(width)
        let height = NSLayoutConstraint(item: self.remoteView!,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        relatedBy: NSLayoutConstraint.Relation.equal,
                                        toItem: self.view,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        multiplier: 1,
                                        constant: 0);
        self.view.addConstraint(height)
    }
    
    /* This function handles the case where the votographer opts to cancel the vshoot */
    func disconnectOnServerRequest(){
        if (room != nil){
            self.room!.disconnect()
        }

        //dismiss(animated: true, completion: nil)
        
        self.performSegue(withIdentifier: "backToTBFromVotographer", sender: self)
    }
    
    func disconnectWhileWaiting(){
        if (room != nil){
            self.room!.disconnect()
        }
        
        SocketIOManager.sharedInstance.endVShoot(vsId: self.vshootId, endInitiator: self.title!)
        
        self.performSegue(withIdentifier: "backToTBFromVotographer", sender: self)
    }
    
    func connect() {
        // Configure access token either from server or manually.
        // If the default wasn't changed, try fetching from server.
        print("I am inside of connect function for votographer")
        if (accessToken == "TWILIO_ACCESS_TOKEN") {
            do {
                accessToken = try TokenUtils.fetchToken(url: tokenUrl)
            } catch {
                let message = "Failed to fetch access token"
                logMessage(messageText: message)
                return
            }
        }
        
        // Prepare local media which we will share with Room Participants.
        self.prepareLocalMedia()
        
        // Preparing the connect options with the access token that we fetched (or hardcoded).
        let connectOptions = TVIConnectOptions.init(token: accessToken) { (builder) in
            
            // Use the local media that we prepared earlier.
            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [TVILocalAudioTrack]()
            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [TVILocalVideoTrack]()
            
            // Use the preferred audio codec
            if let preferredAudioCodec = Settings.shared.audioCodec {
                builder.preferredAudioCodecs = [preferredAudioCodec]
            }
            
            // Use the preferred video codec
            if let preferredVideoCodec = Settings.shared.videoCodec {
                builder.preferredVideoCodecs = [preferredVideoCodec]
            }
            
            // Use the preferred encoding parameters
            if let encodingParameters = Settings.shared.getEncodingParameters() {
                builder.encodingParameters = encodingParameters
            }
            
            // The name of the Room where the Client will attempt to connect to. Please note that if you pass an empty
            // Room `name`, the Client will create one for you. You can get the name or sid from any connected Room.
            builder.roomName = self.roomName
        }
        
        // Connect to the Room using the options we provided.
        room = TwilioVideo.connect(with: connectOptions, delegate: self)
        
        logMessage(messageText: "Attempting to connect to room \(String(describing: self.roomName))")
        
        self.showRoomUI(inRoom: true)
        //self.dismissKeyboard()
    }
     // MARK: IBActions
    @IBAction func takePhoto(_ sender: Any) {
        //emit an event to server through socket manager
        SocketIOManager.sharedInstance.triggerPhotoCapture(takePhoto: self.flashOn)
        self.performSegue(withIdentifier: "photoProcessingSegue", sender: self)
    }
    
    @IBAction func disconnect(_ sender: Any) {
        self.room!.disconnect()
        logMessage(messageText: "Attempting to disconnect from room \(room!.name)")
        SocketIOManager.sharedInstance.endVShoot(vsId: self.vshootId, endInitiator: self.title!)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//        let vc = storyboard.instantiateViewController(withIdentifier: "VSHome") ; // MySecondSecreen the storyboard ID
//        self.present(vc, animated: true, completion: nil);
        //dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "backToTBFromVotographer", sender: self)
    }
 
    
    @IBAction func toggleMic(_ sender: Any) {
        print("trying to toggle mic")
        if (self.localAudioTrack != nil) {
            self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
            
            // Update the button title
            if (self.localAudioTrack?.isEnabled == true) {
                //self.microphoneBtn.setTitle("Mute", for: .normal)
                let soundon: UIImage = UIImage(named: "soundon")!
                self.microphoneBtn.setImage(soundon, for: .normal)
            } else {
                let soundoff: UIImage = UIImage(named: "soundoff")!
                self.microphoneBtn.setImage(soundoff, for: .normal)
                //self.microphoneBtn.setTitle("Unmute", for: .normal)
            }
        }
    }
    
    @IBAction func toggleFlash(_ sender: Any) {
        self.flashOn = !(self.flashOn)
        if (self.flashOn){
            let flashon: UIImage = UIImage(named: "flashOn")!
            self.flashButton.setImage(flashon, for: .normal)
        }
        else {
            let flashoff: UIImage = UIImage(named: "flashOff")!
            self.flashButton.setImage(flashoff, for: .normal)
        }
    }
    
    
    
    // MARK: Private
    func startPreview() {
        if PlatformUtils.isSimulator {
            return
        }
        
        let frontCamera = TVICameraSource.captureDevice(for: .front)
        let backCamera = TVICameraSource.captureDevice(for: .back)
        
        if (frontCamera != nil || backCamera != nil) {
            // Preview our local camera track in the local video preview view.
            camera = TVICameraSource(delegate: self)
            localVideoTrack = TVILocalVideoTrack.init(source: camera!, enabled: true, name: "Camera")
            
            // Add renderer to video track for local preview
            localVideoTrack!.addRenderer(self.previewView)
            logMessage(messageText: "Video track created")
            
            if (frontCamera != nil && backCamera != nil) {
                // We will flip camera on tap.
                let tap = UITapGestureRecognizer(target: self, action: #selector(VotographerViewController.flipCamera))
                self.previewView.addGestureRecognizer(tap)
            }
            
            camera!.startCapture(with: backCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
                if let error = error {
                    self.logMessage(messageText: "Capture failed with error.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                } else {
                    self.previewView.shouldMirror = (captureDevice.position == .front)
                }
            }
        }
        else {
            self.logMessage(messageText:"No front or back capture device found!")
        }
    }
    
    @objc func flipCamera() {
        var newDevice: AVCaptureDevice?
        
        if let camera = self.camera, let captureDevice = camera.device {
            if captureDevice.position == .front {
                newDevice = TVICameraSource.captureDevice(for: .back)
            } else {
                newDevice = TVICameraSource.captureDevice(for: .front)
            }
            
            if let newDevice = newDevice {
                camera.select(newDevice) { (captureDevice, videoFormat, error) in
                    if let error = error {
                        self.logMessage(messageText: "Error selecting capture device.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                    } else {
                        self.previewView.shouldMirror = (captureDevice.position == .front)
                    }
                }
            }
        }
    }
    
    func prepareLocalMedia() {
        
        // We will share local audio and video when we connect to the Room.
        
        // Create an audio track.
        if (localAudioTrack == nil) {
            localAudioTrack = TVILocalAudioTrack.init(options: nil, enabled: true, name: "Microphone")
            
            if (localAudioTrack == nil) {
                logMessage(messageText: "Failed to create audio track")
            }
        }
        
        // Create a video track which captures from the camera.
//        if (localVideoTrack == nil) {
//            self.startPreview()
//        }
    }
    
    // Update our UI based upon if we are in a Room or not
    func showRoomUI(inRoom: Bool) {
//        self.connectButton.isHidden = inRoom
        //self.roomTextField.isHidden = inRoom
        //self.roomLine.isHidden = inRoom
        //self.roomLabel.isHidden = inRoom
        //self.micButton.isHidden = !inRoom
        self.disconnectButton.isHidden = !inRoom
        self.navigationController?.setNavigationBarHidden(inRoom, animated: true)
        UIApplication.shared.isIdleTimerDisabled = inRoom
        
        // Show / hide the automatic home indicator on modern iPhones.
        if #available(iOS 11.0, *) {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
    }
    
//    @objc func dismissKeyboard() {
//        if (self.roomTextField.isFirstResponder) {
//            self.roomTextField.resignFirstResponder()
//        }
//    }
    
    func cleanupRemoteParticipant() {
        if ((self.remoteParticipant) != nil) {
            if ((self.remoteParticipant?.videoTracks.count)! > 0) {
                let remoteVideoTrack = self.remoteParticipant?.remoteVideoTracks[0].remoteTrack
                remoteVideoTrack?.removeRenderer(self.remoteView!)
                self.remoteView?.removeFromSuperview()
                self.remoteView = nil
            }
        }
        self.remoteParticipant = nil
    }
    
    func logMessage(messageText: String) {
        messageLabel.text = messageText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "backToTBFromVotographer"){
            let barViewControllers = segue.destination as! UITabBarController
            barViewControllers.selectedIndex = 1
            
            
        }
        
    }
}

// MARK: UITextFieldDelegate
//extension VotographerViewController : UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.connect(sender: textField)
//        return true
//    }
//}

// MARK: TVIRoomDelegate
extension VotographerViewController : TVIRoomDelegate {
    func didConnect(to room: TVIRoom) {
        
        // At the moment, this example only supports rendering one Participant at a time.
        
        logMessage(messageText: "Connected to room \(room.name) as \(String(describing: room.localParticipant?.identity))")
        
        if (room.remoteParticipants.count > 0) {
            self.remoteParticipant = room.remoteParticipants[0]
            self.remoteParticipant?.delegate = self
        }
    }
    
    func room(_ room: TVIRoom, didDisconnectWithError error: Error?) {
        logMessage(messageText: "Disconncted from room \(room.name), error = \(String(describing: error))")
        
        self.cleanupRemoteParticipant()
        self.room = nil
        
        self.showRoomUI(inRoom: false)
    }
    
    func room(_ room: TVIRoom, didFailToConnectWithError error: Error) {
        logMessage(messageText: "Failed to connect to room with error")
        self.room = nil
        
        self.showRoomUI(inRoom: false)
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIRemoteParticipant) {
        if (self.remoteParticipant == nil) {
            self.remoteParticipant = participant
            self.remoteParticipant?.delegate = self
        }
        logMessage(messageText: "Participant \(participant.identity) connected with \(participant.remoteAudioTracks.count) audio and \(participant.remoteVideoTracks.count) video tracks")
    }
    
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIRemoteParticipant) {
        if (self.remoteParticipant == participant) {
            cleanupRemoteParticipant()
        }
        logMessage(messageText: "Room \(room.name), Participant \(participant.identity) disconnected")
    }
}

// MARK: TVIRemoteParticipantDelegate
extension VotographerViewController : TVIRemoteParticipantDelegate {
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           publishedVideoTrack publication: TVIRemoteVideoTrackPublication) {
        
        // Remote Participant has offered to share the video Track.
        
        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) video track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           unpublishedVideoTrack publication: TVIRemoteVideoTrackPublication) {
        
        // Remote Participant has stopped sharing the video Track.
        
        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) video track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           publishedAudioTrack publication: TVIRemoteAudioTrackPublication) {
        
        // Remote Participant has offered to share the audio Track.
        
        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) audio track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           unpublishedAudioTrack publication: TVIRemoteAudioTrackPublication) {
        
        // Remote Participant has stopped sharing the audio Track.
        
        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) audio track")
    }
    
    func subscribed(to videoTrack: TVIRemoteVideoTrack,
                    publication: TVIRemoteVideoTrackPublication,
                    for participant: TVIRemoteParticipant) {
        
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's video frames now.
        
        logMessage(messageText: "Subscribed to \(publication.trackName) video track for Participant \(participant.identity)")
        
        if (self.remoteParticipant == participant) {
            setupRemoteVideoView()
            videoTrack.addRenderer(self.remoteView!)
        }
    }
    
    func unsubscribed(from videoTrack: TVIRemoteVideoTrack,
                      publication: TVIRemoteVideoTrackPublication,
                      for participant: TVIRemoteParticipant) {
        
        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
        // remote Participant's video.
        
        logMessage(messageText: "Unsubscribed from \(publication.trackName) video track for Participant \(participant.identity)")
        
        if (self.remoteParticipant == participant) {
            videoTrack.removeRenderer(self.remoteView!)
            self.remoteView?.removeFromSuperview()
            self.remoteView = nil
        }
    }
    
    func subscribed(to audioTrack: TVIRemoteAudioTrack,
                    publication: TVIRemoteAudioTrackPublication,
                    for participant: TVIRemoteParticipant) {
        
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's audio now.
        
        logMessage(messageText: "Subscribed to \(publication.trackName) audio track for Participant \(participant.identity)")
    }
    
    func unsubscribed(from audioTrack: TVIRemoteAudioTrack,
                      publication: TVIRemoteAudioTrackPublication,
                      for participant: TVIRemoteParticipant) {
        
        // We are unsubscribed from the remote Participant's audio Track. We will no longer receive the
        // remote Participant's audio.
        
        logMessage(messageText: "Unsubscribed from \(publication.trackName) audio track for Participant \(participant.identity)")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           enabledVideoTrack publication: TVIRemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) video track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           disabledVideoTrack publication: TVIRemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) video track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           enabledAudioTrack publication: TVIRemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) audio track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           disabledAudioTrack publication: TVIRemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) audio track")
    }
    
    func failedToSubscribe(toAudioTrack publication: TVIRemoteAudioTrackPublication,
                           error: Error,
                           for participant: TVIRemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) audio track, error = \(String(describing: error))")
    }
    
    func failedToSubscribe(toVideoTrack publication: TVIRemoteVideoTrackPublication,
                           error: Error,
                           for participant: TVIRemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) video track, error = \(String(describing: error))")
    }
}

// MARK: TVIVideoViewDelegate
extension VotographerViewController : TVIVideoViewDelegate {
    func videoView(_ view: TVIVideoView, videoDimensionsDidChange dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

// MARK: TVICameraCapturerDelegate
extension VotographerViewController : TVICameraSourceDelegate {
    func cameraSource(_ source: TVICameraSource, didFailWithError error: Error) {
    }
}



