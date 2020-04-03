//
//  VmodelViewController.swift
//  VShootApplication
//
//  Created by Candice Wright on 10/23/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit
import TwilioVideo
import SwiftSpinner
import ReplayKit


class VmodelViewController: UIViewController {
    
    // MARK: View Controller Members
    
    // Configure access token manually for testing, if desired! Create one manually in the console
    // at https://www.twilio.com/console/video/runtime/testing-tools
    var accessToken = ""
    var vshootId: NSInteger = 0
    var roomName:String = ""
    //new capture session attributes for photos
    var captureSession = AVCaptureSession()
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    var position: AVCaptureDevice.Position?
    var photoOutput: AVCapturePhotoOutput!
    var cameraPosition = AVCaptureDevice.Position.back
    var micStateTxt:String = ""
    
    // Configure remote URL to fetch token from
    var tokenUrl = "http://localhost:8000/token.php"
    
    // Video SDK components
    var room: Room?
    var camera: CameraSource?
    var localVideoTrack: LocalVideoTrack?
    var localAudioTrack: LocalAudioTrack?
    var remoteParticipant: RemoteParticipant?
    var remoteView: VideoView?
    
    // Conference state.
    var screenTrack: LocalVideoTrack?
    var videoSource: ReplayKitVideoSource?
    var conferenceRoom: Room?
    var videoPlayer: AVPlayer?
    
    let recorder = RPScreenRecorder.shared()
    
    // An application has a much higher memory limit than an extension. You may choose to deliver full sized buffers instead.
    static let kDownscaleBuffers = false

    
    // MARK: UI Element Outlets and handles
    
    // `TVIVideoView` created from a storyboard
    @IBOutlet weak var previewView: VideoView!
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var soundButtonIV: UIImageView!
    @IBOutlet weak var camPreview: UIView!
    
    @IBOutlet weak var isoSlider: UISlider!
    
    
    //@IBOutlet weak var roomTextField: UITextField!
    //@IBOutlet weak var roomLine: UIView!
    //@IBOutlet weak var roomLabel: UILabel!
   
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var capturedImage: UIImageView!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        print(roomName)
        
        if PlatformUtils.isSimulator {
            self.previewView.removeFromSuperview()
        }
        
        self.messageLabel.adjustsFontSizeToFitWidth = true;
        self.messageLabel.minimumScaleFactor = 0.75;
        //self.disconnectButton.layer.cornerRadius = CGFloat(Float(8.0))
        
        // Disconnect and mic button will be displayed when the Client is connected to a Room.
        //self.disconnectButton.isHidden = true
        //self.micButton.isHidden = true
        
        //camera setup
        self.setupCaptureSession()
        self.setupDevice()
        self.setupInputOutput()
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.captureSession.startRunning()
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = .portrait
        camPreview.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
        self.cameraPreviewLayer?.frame = camPreview.frame
        //view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
        //self.cameraPreviewLayer?.frame = view.frame
        
        self.isoSlider.minimumValue = (self.currentDevice?.activeFormat.minISO)!
        self.isoSlider.maximumValue = (self.currentDevice?.activeFormat.maxISO)!
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(VmodelViewController.showPhotoMsg))
        capturedImage.isUserInteractionEnabled = true
        self.capturedImage.addGestureRecognizer(tap)
        
        SocketIOManager.sharedInstance.socket.on("VShootEnded"){ dataResults, ack in
            let alertController = UIAlertController(title: "The Votographer has ended the VShoot", message:
                nil, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
                self.disconnectOnServerRequest() }))
            self.present(alertController, animated: true, completion: nil)
            
            
        }
        
        SocketIOManager.sharedInstance.socket.on("takephoto") { dataArray, ack in
            print("just got notified to take photo")
            //self.localVideoTrack?.isEnabled = false;
            
            //get the settings for what the picture should be taken with
            let data = dataArray[0] as! Dictionary<String,AnyObject>
            let flash = data["flashSetting"] as! Bool
            self.takePhoto(flashSet: flash)
        }
        
        SocketIOManager.sharedInstance.socket.on("votographerInBackground"){ dataResults, ack in
            print("votographer is going to background")
            self.waitForVotographer()
//            let alertController = UIAlertController(title: "Wait a Sec...", message:
//                "Votographer has temporarily left the shooting room. They should be back shortly!", preferredStyle: UIAlertController.Style.alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in
//                self.waitForVmodel() }))
//            self.present(alertController, animated: true, completion: nil)
            
        }
        
        SocketIOManager.sharedInstance.socket.on("votographerIsBack"){data, ack in
            print("Votographer is Back")
            SwiftSpinner.hide()
//            let alertController = UIAlertController(title: "Votographer is Back!", message: "You will be automatically connected back to the virtual shoot.", preferredStyle: UIAlertController.Style.alert)
//            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: {(action) in
//
//            }))
//
//            self.present(alertController, animated: true, completion: nil)
        }
        
        self.connect()
        //self.prepareLocalMedia()
    }
    
    // MARK: IBActions
    @IBAction func ShowVShootOptions(_ sender: Any) {
        let alertController = UIAlertController(title: "VShoot Options", message: "", preferredStyle: UIAlertController.Style.alert)
                  alertController.addAction(UIAlertAction(title: "End VShoot", style: UIAlertAction.Style.default,handler: {(action) in
                      self.endVShoot() }))
        alertController.addAction(UIAlertAction(title: "Mute Mic", style: UIAlertAction.Style.default,handler: {(action) in self.muteMic(alert: alertController) }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default,handler: {(action) in alertController.dismiss(animated: true, completion: nil) }))
                  
                  self.present(alertController, animated: true, completion: nil)
    }
    
    func muteMic(alert: UIAlertController){
        print("trying to toggle mic")
        //print(self.localAudioTrack)

                if (self.localAudioTrack != nil) {
                    print("found audio that is ")
                    print(self.localAudioTrack?.isEnabled)
                    self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
                    print("just switched audio to")
                    print(self.localAudioTrack?.isEnabled)

                    // Update the button title
                    if (self.localAudioTrack?.isEnabled == true) {
                        //self.micButton.setTitle("Mute", for: .normal)
                        let soundon: UIImage = UIImage(named: "soundon")!
                        //self.micButton.imageView?.image = soundon
                        //self.micButton.setImage(soundon, for: .normal)
                        self.micStateTxt = "Mute Mic"
                    } else {
                        //self.micButton.setTitle("Unmute", for: .normal)
                        let soundoff: UIImage = UIImage(named: "soundoff")!
                        //self.micButton.imageView?.image = soundoff
                        //self.micButton.setImage(soundoff, for: .normal)
                        self.micStateTxt = "Mute Mic"
                    }
                    alert.dismiss(animated: true, completion: nil)
                }
    }
    
    func endVShoot(){
        if (room != nil){
                    self.room!.disconnect()
                }
                recorder.stopCapture { (captureError) in
                    if let error = captureError {
                        print("Screen capture stop error: ", error as Any)
                    } else {
                        print("Screen capture stopped.")
                        self.videoSource = nil
                        self.screenTrack = nil
                    }
                }
                UserDefaults.standard.set(false, forKey: "freeTrialAvailable")
                logMessage(messageText: "Attempting to disconnect from room \(room!.name)")
                SocketIOManager.sharedInstance.endVShoot(vsId: self.vshootId, endInitiator: self.title!)
        //        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        //        let vc = storyboard.instantiateViewController(withIdentifier: "VSHome") ; // MySecondSecreen the storyboard ID
        //        self.present(vc, animated: true, completion: nil);
                //dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "backToTBFromVmodel", sender: self)
    }
    
    @IBAction func disconnect(_ sender: Any) {
        if (room != nil){
            self.room!.disconnect()
        }
        recorder.stopCapture { (captureError) in
            if let error = captureError {
                print("Screen capture stop error: ", error as Any)
            } else {
                print("Screen capture stopped.")
                self.videoSource = nil
                self.screenTrack = nil
            }
        }
        UserDefaults.standard.set(false, forKey: "freeTrialAvailable")
        logMessage(messageText: "Attempting to disconnect from room \(room!.name)")
        SocketIOManager.sharedInstance.endVShoot(vsId: self.vshootId, endInitiator: self.title!)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//        let vc = storyboard.instantiateViewController(withIdentifier: "VSHome") ; // MySecondSecreen the storyboard ID
//        self.present(vc, animated: true, completion: nil);
        //dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "backToTBFromVmodel", sender: self)
    }
    
    
    @IBAction func toggleMic(_ sender: Any) {
        print("trying to toggle mic")
        //print(self.localAudioTrack)

                if (self.localAudioTrack != nil) {
                    print("found audio that is ")
                    print(self.localAudioTrack?.isEnabled)
                    self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
                    print("just switched audio to")
                    print(self.localAudioTrack?.isEnabled)

                    // Update the button title
                    if (self.localAudioTrack?.isEnabled == true) {
                        //self.micButton.setTitle("Mute", for: .normal)
                        let soundon: UIImage = UIImage(named: "soundon")!
                        self.micButton.imageView?.image = soundon
                        self.micButton.setImage(soundon, for: .normal)
                    } else {
                        self.micButton.setTitle("Unmute", for: .normal)
                        let soundoff: UIImage = UIImage(named: "soundoff")!
                        self.micButton.imageView?.image = soundoff
                        self.micButton.setImage(soundoff, for: .normal)
                    }
                }
    }
    
    @IBAction func toggleCam(_ sender: Any) {
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
    
    @IBAction func changeISO(_ sender: UISlider) {
        print(self.isoSlider.value);
        self.updateExposure(isoValue: self.isoSlider.value)
    }
    
    
    
    func updateExposure(isoValue: Float){
        do {
            try currentDevice?.lockForConfiguration()
        } catch {
                   //do things here
        }
        self.currentDevice?.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: isoValue, completionHandler: nil)
        self.currentDevice?.unlockForConfiguration()
    }
    
    
    func setupCaptureSession() {
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
        
        func setupDevice() {
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
            let devices = deviceDiscoverySession.devices

            for device in devices {
                if device.position == AVCaptureDevice.Position.back {
                    backCamera = device
                } else if device.position == AVCaptureDevice.Position.front {
                    frontCamera = device
                }
            }
            currentDevice = backCamera
            
            
        }
        
        func setupInputOutput() {
            do {
                let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
                self.captureSession.addInput(captureDeviceInput)
                photoOutput = AVCapturePhotoOutput()
                photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
                self.captureSession.addOutput(photoOutput!)
                
                
            } catch {
                print(error)
            }
        }
    
    func takePhoto(flashSet:Bool) {
        do {
            try currentDevice?.lockForConfiguration()
        } catch {
            //do things here
        }
        
        //currentDevice?.exposureMode = .autoExpose
        //currentDevice?.exposureMode = .continuousAutoExposure
        
        currentDevice?.exposureMode = .custom
        currentDevice?.unlockForConfiguration()
        photoOutput.isHighResolutionCaptureEnabled = true
        let photoSettings = AVCapturePhotoSettings()
        //photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        if (flashSet){
            photoSettings.flashMode = .on
        }
        print("printing capture session status")
        print(self.captureSession.isRunning)
        if (self.captureSession.isRunning){
            self.photoOutput?.capturePhoto(with: photoSettings, delegate: self)
        }
    }
        
        @objc func showPhotoMsg(){
            print("in photo msg func")
            let alertController = UIAlertController(title: "View New Photos", message:
                "Go to your iphone photo library to view your new photos. You will be able to talk to the votographer while you're out of the app. When back, the video will resume.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: {(action) in }))
            self.present(alertController, animated: true, completion: nil)
        }
        
        /* This function handles the case where the votographer opts to cancel the vshoot */
        func disconnectOnServerRequest(){
            if (room != nil){
               self.room!.disconnect()
                logMessage(messageText: "Attempting to disconnect from room \(room!.name)")
            }
            recorder.stopCapture { (captureError) in
                if let error = captureError {
                    print("Screen capture stop error: ", error as Any)
                } else {
                    print("Screen capture stopped.")
                    self.videoSource = nil
                    self.screenTrack = nil
                }
            }
            
            UserDefaults.standard.set(false, forKey: "freeTrialAvailable")

            //dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "backToTBFromVmodel", sender: self)
            
        }
        
        func disconnectWhileWaiting(){
            if (room != nil){
                self.room!.disconnect()
            }
            
            SocketIOManager.sharedInstance.endVShoot(vsId: self.vshootId, endInitiator: self.title!)
            
            self.performSegue(withIdentifier: "backToTBFromVmodel", sender: self)
        }
        
        func waitForVotographer(){
            //show a spinner
            self.showSpinner(receiver: "votographer")
        }
        
        func showSpinner(receiver:String){
            SwiftSpinner.show("Waiting for " + receiver + " to return...").addTapHandler({
                SwiftSpinner.hide()
                let alertController = UIAlertController(title: "Are you ", message: "Are you sure you want to cancel?", preferredStyle: UIAlertController.Style.alert)
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
        
        func connect() {
            // Configure access token either from server or manually.
            // If the default wasn't changed, try fetching from server.
            print("I am in connect function for vmodel")
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
                //builder.audioTracks = [LocalAudioTrack()!]
                builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [LocalAudioTrack]()

                if let videoTrack = self.screenTrack {
                    print("successfully made screentrack the videotrack")
                    builder.videoTracks = [videoTrack]
                }
                
                // Use the preferred audio codec
                if let preferredAudioCodec = Settings.shared.audioCodec {
                    builder.preferredAudioCodecs = [preferredAudioCodec]
                }
                
                // Use the preferred video codec
                if let preferredVideoCodec = Settings.shared.videoCodec {
                    builder.preferredVideoCodecs = [preferredVideoCodec]
                }
                
                // Use the preferred encoding parameters
                //builder.encodingParameters = encodingParameters
                
    //            // Use the preferred encoding parameters
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
        
        func prepareLocalMedia() {
                print("I am preparing local media in vmodel")
                // We will share local audio and video when we connect to the Room.
                
        //        // Create an audio track.
                if (localAudioTrack == nil) {
                    print("adding audio")
                    localAudioTrack = LocalAudioTrack.init(options: nil, enabled: true, name: "Microphone")

                    if (localAudioTrack == nil) {
                        logMessage(messageText: "Failed to create audio track")
                    }
                }
        //
        //        // Create a video track which captures from the camera.
        //        if (localVideoTrack == nil) {
        //            self.startPreview()
        //        }
                
                // Start recording the screen.
                //let recorder = RPScreenRecorder.shared()
                recorder.isMicrophoneEnabled = false
                recorder.isCameraEnabled = false

                // The source produces either downscaled buffers with smoother motion, or an HD screen recording.
                let options = VmodelViewController.kDownscaleBuffers ? ReplayKitVideoSource.TelecineOptions.p60to24or25or30 : ReplayKitVideoSource.TelecineOptions.disabled
                videoSource = ReplayKitVideoSource(isScreencast: !VmodelViewController.kDownscaleBuffers,
                                                   telecineOptions: options)

                screenTrack = LocalVideoTrack(source: videoSource!,
                                              enabled: true,
                                              name: "Screen")

                let videoCodec = Settings.shared.videoCodec ?? Vp8Codec()!
                let (encodingParams, outputFormat) = ReplayKitVideoSource.getParametersForUseCase(codec: videoCodec,
                                                                                                  isScreencast: !VmodelViewController.kDownscaleBuffers,
                                                                                               telecineOptions:options)
                videoSource?.requestOutputFormat(outputFormat)

                recorder.startCapture(handler: { (sampleBuffer, type, error) in
                    if error != nil {
                        print("Capture error: ", error as Any)
                        return
                    }

                    switch type {
                    case RPSampleBufferType.video:
                        self.videoSource?.processFrame(sampleBuffer: sampleBuffer)
                        break
                    case RPSampleBufferType.audioApp:
                        break
                    case RPSampleBufferType.audioMic:
                        // We use `TVIDefaultAudioDevice` to capture and playback audio for conferencing.
                        break
                    }


                }) { (error) in
                    if error != nil {
                        print("Screen capture error: ", error as Any)
                    } else {
                        print("Screen capture started.")
                        //self.connect(encodingParameters: encodingParams)
                    }
                }
            }
    
    // MARK: Private
    
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
    
    // Update our UI based upon if we are in a Room or not
    func showRoomUI(inRoom: Bool) {
        //self.connectButton.isHidden = inRoom
        //self.roomTextField.isHidden = inRoom
        //self.roomLine.isHidden = inRoom
        //self.roomLabel.isHidden = inRoom
        //self.micButton.isHidden = !inRoom
        //self.disconnectButton.isHidden = !inRoom
        self.navigationController?.setNavigationBarHidden(inRoom, animated: true)
        UIApplication.shared.isIdleTimerDisabled = inRoom
        
        // Show / hide the automatic home indicator on modern iPhones.
        if #available(iOS 11.0, *) {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
        
        //print("I am done with connect function in vmodel")
    }
    
//    @objc func dismissKeyboard() {
//        if (self.roomTextField.isFirstResponder) {
//            self.roomTextField.resignFirstResponder()
//        }
//    }
    
    func startPreview() {
        print("I am starting preview in vmodel")
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
            print("video track created")
            
            if (frontCamera != nil && backCamera != nil) {
                // We will flip camera on tap.
                let tap = UITapGestureRecognizer(target: self, action: #selector(VmodelViewController.flipCamera))
                self.previewView.addGestureRecognizer(tap)
            }
            //with: backCamera != nil ? frontCamera! : backCamera!
            camera!.startCapture(device: backCamera!) { (captureDevice, videoFormat, error) in
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
        if (segue.identifier == "backToTBFromVmodel"){
            let barViewControllers = segue.destination as! UITabBarController
            barViewControllers.selectedIndex = 1
            
            //let VSViewController = barViewControllers.viewControllers?[1] as! InitiateVSViewController
            //VSViewController.username = UsernameField.text!
            //            let FriendsViewController = barViewControllers.viewControllers?[0] as! FriendsViewController
            //            FriendsViewController.username = UsernameField.text!
            //            let ProfileViewController = barViewControllers.viewControllers?[2] as! ProfileViewController
            //            ProfileViewController.username = UsernameField.text!
            
        }
        
    }
}

// MARK: UITextFieldDelegate
//extension VmodelViewController : UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.connect(sender: textField)
//        return true
//    }
//}

// MARK:- RoomDelegate
extension VmodelViewController : RoomDelegate {
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
extension VmodelViewController : RemoteParticipantDelegate {

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
extension VmodelViewController : VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

// MARK: TVICameraCapturerDelegate
extension VmodelViewController : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
    }
}

extension VmodelViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            self.capturedImage.image = UIImage(data: imageData)
            UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
            
            //self.captureSession.stopRunning()
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
//                self.connect()
//            })
            //self.localVideoTrack?.isEnabled = true;
        }
        else {
            print(error as Any)
        }
    }
}
