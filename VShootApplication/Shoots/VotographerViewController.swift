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
    var room: Room?
    var camera: CameraSource?
    var localVideoTrack: LocalVideoTrack?
    var localAudioTrack: LocalAudioTrack?
    var remoteParticipant: RemoteParticipant?
    var remoteView: VideoView?
    var flashOn:Bool = false
    // MARK: UI Element Outlets and handles
    
    // `TVIVideoView` created from a storyboard
    @IBOutlet weak var previewView: VideoView!

    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var microphoneBtn: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    @IBOutlet weak var remoteParticipantView: UIView!
    
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
            self.waitForVmodel()
//            let alertController = UIAlertController(title: "Wait a Sec...", message:
//                "Vmodel has temporarily left the shooting room, most likely to view photos. They should be back shortly!", preferredStyle: UIAlertController.Style.alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
//                self.waitForVmodel() }))
//            self.present(alertController, animated: true, completion: nil)
            
        }
        
        SocketIOManager.sharedInstance.socket.on("vmodelIsBack"){data, ack in
            print("vmodel is Back")
            SwiftSpinner.hide()
//            let alertController = UIAlertController(title: "Vmodel is Back!", message: "If you are not automatically connected back to the virtual shoot, press the capture button to reconnect.", preferredStyle: UIAlertController.Style.alert)
//            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: {(action) in
//
//            }))
//
//            self.present(alertController, animated: true, completion: nil)
            
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
    
     // MARK: IBActions
    @IBAction func takePhoto(_ sender: Any) {
        //emit an event to server through socket manager
        SocketIOManager.sharedInstance.triggerPhotoCapture(takePhoto: self.flashOn)
        //self.performSegue(withIdentifier: "photoProcessingSegue", sender: self)
    }
    
    @IBAction func disconnect(_ sender: Any) {
        self.room!.disconnect()
        UserDefaults.standard.set(false, forKey: "freeTrialAvailable")
        logMessage(messageText: "Attempting to disconnect from room \(room!.name)")
        SocketIOManager.sharedInstance.endVShoot(vsId: self.vshootId, endInitiator: self.title!)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//        let vc = storyboard.instantiateViewController(withIdentifier: "VSHome") ; // MySecondSecreen the storyboard ID
//        self.present(vc, animated: true, completion: nil);
        //dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "backToTBFromVotographer", sender: self)
    }
 
    @IBAction func zoom(_ sender: Any) {
        let alertController = UIAlertController(title: "Camera Zoom", message: "Select a zoom factor below.", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "1x (Default)", style: UIAlertAction.Style.default,handler: {(action) in
            SocketIOManager.sharedInstance.changeZoomFactor(zoomFactor: 1.0)
            
        }))
        alertController.addAction(UIAlertAction(title: "2x", style: UIAlertAction.Style.default,handler: {(action) in
            SocketIOManager.sharedInstance.changeZoomFactor(zoomFactor: 2.0)
        }))
        alertController.addAction(UIAlertAction(title: "3x", style: UIAlertAction.Style.default,handler: {(action) in
            SocketIOManager.sharedInstance.changeZoomFactor(zoomFactor: 3.0)
            
        }))
        self.present(alertController, animated: true, completion: nil)
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
    
    func waitForVmodel(){
        //show a spinner
        self.showSpinner(receiver: "vmodel")
    }
    
    func showSpinner(receiver:String){
        SwiftSpinner.show("Waiting for " + receiver + " to return...").addTapHandler({
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
        self.remoteView = VideoView.init(frame: CGRect.zero, delegate:self)
        
        self.remoteParticipantView.insertSubview(self.remoteView!, at: 0)
        
        // `TVIVideoView` supports scaleToFill, scaleAspectFill and scaleAspectFit
        // scaleAspectFit is the default mode when you create `TVIVideoView` programmatically.
        //self.remoteView!.contentMode = .scaleAspectFit;
        self.remoteView?.contentMode = .scaleToFill
        
        let centerX = NSLayoutConstraint(item: self.remoteView!,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: self.remoteParticipantView,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         multiplier: 1,
                                         constant: 0);
        self.remoteParticipantView.addConstraint(centerX)
        let centerY = NSLayoutConstraint(item: self.remoteView!,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: self.remoteParticipantView,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         multiplier: 1,
                                         constant: 0);
        self.remoteParticipantView.addConstraint(centerY)
        let width = NSLayoutConstraint(item: self.remoteView!,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                       toItem: self.remoteParticipantView,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       multiplier: 1,
                                       constant: 0);
        self.remoteParticipantView.addConstraint(width)
        let height = NSLayoutConstraint(item: self.remoteView!,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        relatedBy: NSLayoutConstraint.Relation.equal,
                                        toItem: self.remoteParticipantView,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        multiplier: 1,
                                        constant: 0);
        self.remoteParticipantView.addConstraint(height)
        
//        // Creating `TVIVideoView` programmatically
//        self.remoteView = VideoView.init(frame: CGRect.zero, delegate:self)
//
//        self.view.insertSubview(self.remoteView!, at: 0)
//
//        // `TVIVideoView` supports scaleToFill, scaleAspectFill and scaleAspectFit
//        // scaleAspectFit is the default mode when you create `TVIVideoView` programmatically.
//        self.remoteView!.contentMode = .scaleAspectFit;
//
//        let centerX = NSLayoutConstraint(item: self.remoteView!,
//                                         attribute: NSLayoutConstraint.Attribute.centerX,
//                                         relatedBy: NSLayoutConstraint.Relation.equal,
//                                         toItem: self.view,
//                                         attribute: NSLayoutConstraint.Attribute.centerX,
//                                         multiplier: 1,
//                                         constant: 0);
//        self.view.addConstraint(centerX)
//        let centerY = NSLayoutConstraint(item: self.remoteView!,
//                                         attribute: NSLayoutConstraint.Attribute.centerY,
//                                         relatedBy: NSLayoutConstraint.Relation.equal,
//                                         toItem: self.view,
//                                         attribute: NSLayoutConstraint.Attribute.centerY,
//                                         multiplier: 1,
//                                         constant: 0);
//        self.view.addConstraint(centerY)
//        let width = NSLayoutConstraint(item: self.remoteView!,
//                                       attribute: NSLayoutConstraint.Attribute.width,
//                                       relatedBy: NSLayoutConstraint.Relation.equal,
//                                       toItem: self.view,
//                                       attribute: NSLayoutConstraint.Attribute.width,
//                                       multiplier: 1,
//                                       constant: 0);
//        self.view.addConstraint(width)
//        let height = NSLayoutConstraint(item: self.remoteView!,
//                                        attribute: NSLayoutConstraint.Attribute.height,
//                                        relatedBy: NSLayoutConstraint.Relation.equal,
//                                        toItem: self.view,
//                                        attribute: NSLayoutConstraint.Attribute.height,
//                                        multiplier: 1,
//                                        constant: 0);
//        self.view.addConstraint(height)
    }
    
    /* This function handles the case where the votographer opts to cancel the vshoot */
    func disconnectOnServerRequest(){
        if (room != nil){
            self.room!.disconnect()
        }
        
        UserDefaults.standard.set(false, forKey: "freeTrialAvailable")

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
        let connectOptions = ConnectOptions.init(token: accessToken) { (builder) in
            
            // Use the local media that we prepared earlier.
            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [LocalAudioTrack]()
            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [LocalVideoTrack]()
            
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
        room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
        
        logMessage(messageText: "Attempting to connect to room \(String(describing: self.roomName))")
        
        self.showRoomUI(inRoom: true)
        //self.dismissKeyboard()
    }
    
    func startPreview() {
        if PlatformUtils.isSimulator {
            return
        }
        
        let frontCamera = CameraSource.captureDevice(position: .front)
        let backCamera = CameraSource.captureDevice(position: .back)
        
        if (frontCamera != nil || backCamera != nil) {
            // Preview our local camera track in the local video preview view.
            camera = CameraSource(delegate: self)
            localVideoTrack = LocalVideoTrack.init(source: camera!, enabled: true, name: "Camera")
            
            // Add renderer to video track for local preview
            localVideoTrack!.addRenderer(self.previewView)
            logMessage(messageText: "Video track created")
            
            if (frontCamera != nil && backCamera != nil) {
                // We will flip camera on tap.
                let tap = UITapGestureRecognizer(target: self, action: #selector(VotographerViewController.flipCamera))
                self.previewView.addGestureRecognizer(tap)
            }
            
            camera!.startCapture(device: backCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
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
                newDevice = CameraSource.captureDevice(position: .back)
            } else {
                newDevice = CameraSource.captureDevice(position: .front)
            }
            
            if let newDevice = newDevice {
                camera.selectCaptureDevice(newDevice) { (captureDevice, videoFormat, error) in
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
            localAudioTrack = LocalAudioTrack.init(options: nil, enabled: true, name: "Microphone")
            
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
    
    func logMessage(messageText: String) {
        NSLog(messageText)
        messageLabel.text = messageText
    }

    func renderRemoteParticipant(participant : RemoteParticipant) -> Bool {
        // This example renders the first subscribed RemoteVideoTrack from the RemoteParticipant.
        let videoPublications = participant.remoteVideoTracks
        for publication in videoPublications {
            if let subscribedVideoTrack = publication.remoteTrack,
                publication.isTrackSubscribed {
                setupRemoteVideoView()
                subscribedVideoTrack.addRenderer(self.remoteView!)
                self.remoteParticipant = participant
                return true
            }
        }
        return false
    }

    func renderRemoteParticipants(participants : Array<RemoteParticipant>) {
        for participant in participants {
            // Find the first renderable track.
            if participant.remoteVideoTracks.count > 0,
                renderRemoteParticipant(participant: participant) {
                break
            }
        }
    }

    func cleanupRemoteParticipant() {
        if self.remoteParticipant != nil {
            self.remoteView?.removeFromSuperview()
            self.remoteView = nil
            self.remoteParticipant = nil
        }
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

// MARK:- RoomDelegate
extension VotographerViewController : RoomDelegate {
    func roomDidConnect(room: Room) {
        logMessage(messageText: "Connected to room \(room.name) as \(room.localParticipant?.identity ?? "")")

        // This example only renders 1 RemoteVideoTrack at a time. Listen for all events to decide which track to render.
        for remoteParticipant in room.remoteParticipants {
            remoteParticipant.delegate = self
        }
    }

    func roomDidDisconnect(room: Room, error: Error?) {
        logMessage(messageText: "Disconnected from room \(room.name), error = \(String(describing: error))")
        
        self.cleanupRemoteParticipant()
        self.room = nil
        
        self.showRoomUI(inRoom: false)
    }

    func roomDidFailToConnect(room: Room, error: Error) {
        logMessage(messageText: "Failed to connect to room with error = \(String(describing: error))")
        self.room = nil
        
        self.showRoomUI(inRoom: false)
    }

    func roomIsReconnecting(room: Room, error: Error) {
        logMessage(messageText: "Reconnecting to room \(room.name), error = \(String(describing: error))")
    }

    func roomDidReconnect(room: Room) {
        logMessage(messageText: "Reconnected to room \(room.name)")
    }

    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        // Listen for events from all Participants to decide which RemoteVideoTrack to render.
        participant.delegate = self

        logMessage(messageText: "Participant \(participant.identity) connected with \(participant.remoteAudioTracks.count) audio and \(participant.remoteVideoTracks.count) video tracks")
    }

    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        logMessage(messageText: "Room \(room.name), Participant \(participant.identity) disconnected")

        // Nothing to do in this example. Subscription events are used to add/remove renderers.
    }
}

// MARK:- RemoteParticipantDelegate
extension VotographerViewController : RemoteParticipantDelegate {

    func remoteParticipantDidPublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has offered to share the video Track.
        
        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) video track")
    }

    func remoteParticipantDidUnpublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has stopped sharing the video Track.
        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) video track")
    }

    func remoteParticipantDidPublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has offered to share the audio Track.
        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) audio track")
    }

    func remoteParticipantDidUnpublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has stopped sharing the audio Track.
        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) audio track")
    }

    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // The LocalParticipant is subscribed to the RemoteParticipant's video Track. Frames will begin to arrive now.
        logMessage(messageText: "Subscribed to \(publication.trackName) video track for Participant \(participant.identity)")

        if (self.remoteParticipant == nil) {
            _ = renderRemoteParticipant(participant: participant)
        }
    }
    
    func didUnsubscribeFromVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
        // remote Participant's video.
        
        logMessage(messageText: "Unsubscribed from \(publication.trackName) video track for Participant \(participant.identity)")

        if self.remoteParticipant == participant {
            cleanupRemoteParticipant()

            // Find another Participant video to render, if possible.
            if var remainingParticipants = room?.remoteParticipants,
                let index = remainingParticipants.index(of: participant) {
                remainingParticipants.remove(at: index)
                renderRemoteParticipants(participants: remainingParticipants)
            }
        }
    }

    func didSubscribeToAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's audio now.
       
        logMessage(messageText: "Subscribed to \(publication.trackName) audio track for Participant \(participant.identity)")
    }
    
    func didUnsubscribeFromAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's audio Track. We will no longer receive the
        // remote Participant's audio.
        
        logMessage(messageText: "Unsubscribed from \(publication.trackName) audio track for Participant \(participant.identity)")
    }

    func remoteParticipantDidEnableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) video track")
    }

    func remoteParticipantDidDisableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) video track")
    }

    func remoteParticipantDidEnableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) audio track")
    }

    func remoteParticipantDidDisableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) audio track")
    }

    func didFailToSubscribeToAudioTrack(publication: RemoteAudioTrackPublication, error: Error, participant: RemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) audio track, error = \(String(describing: error))")
    }

    func didFailToSubscribeToVideoTrack(publication: RemoteVideoTrackPublication, error: Error, participant: RemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) video track, error = \(String(describing: error))")
    }
}

// MARK:- VideoViewDelegate
extension VotographerViewController : VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

// MARK: TVICameraCapturerDelegate
extension VotographerViewController : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
    }
}



