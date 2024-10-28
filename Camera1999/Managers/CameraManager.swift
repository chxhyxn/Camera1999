//
//  CameraManager.swift
//  Camera1999
//
//  Created by Sean Cho on 4/5/24.
//

import AVFoundation

class CameraManager: ObservableObject {
    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }
    
    static let shared = CameraManager()
    
    @Published var error: CameraError?
    
    let session = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let videoOutput = AVCaptureVideoDataOutput()
    
    private var status = Status.unconfigured
    var currentCameraPosition: AVCaptureDevice.Position = .back
    
    @Published var currentZoomFactor: Double = 1.0
    
    private init() {
        configure()
    }
    
    private func set(error: CameraError?) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
    
    func switchCamera() {
        sessionQueue.async {
            // 현재 카메라 위치 변경
            let newPosition: AVCaptureDevice.Position = (self.currentCameraPosition == .back) ? .front : .back
            self.currentCameraPosition = newPosition
            
            // Zoom 리셋
            self.resetZoom()
            
            // 새 카메라 디바이스 찾기
            guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
                self.set(error: .cameraUnavailable)
                return
            }
            
            // 세션 구성 시작
            self.session.beginConfiguration()
            
            // 현재 입력 제거
            self.session.inputs.forEach { input in
                self.session.removeInput(input)
            }
            
            // 새 카메라로 입력 추가 시도
            do {
                let newInput = try AVCaptureDeviceInput(device: newCamera)
                if self.session.canAddInput(newInput) {
                    self.session.addInput(newInput)
                } else {
                    throw CameraError.cannotAddInput
                }
            } catch {
                self.set(error: error as? CameraError ?? .unknownAuthorization)
                self.session.commitConfiguration()
                return
            }
            
            // 필요한 경우 비디오 출력 설정 조정
            if let videoOutput = self.session.outputs.first(where: { $0 is AVCaptureVideoDataOutput }) as? AVCaptureVideoDataOutput {
                let videoConnection = videoOutput.connection(with: .video)
                videoConnection?.videoOrientation = .portrait
            }
            
            // 세션 구성 완료
            self.session.commitConfiguration()
        }
    }

    
    // 프라이버시 동의 여부
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if !authorized {
                    self.status = .unauthorized
                    self.set(error: .deniedAuthorization)
                }
                self.sessionQueue.resume()
            }
        case .restricted:
            status = .unauthorized
            set(error: .restrictedAuthorization)
        case .denied:
            status = .unauthorized
            set(error: .deniedAuthorization)
        case .authorized:
            break
        @unknown default:
            status = .unauthorized
            set(error: .unknownAuthorization)
        }
    }
    
    private func configureCaptureSession() {
        guard status == .unconfigured else {
            return
        }
        session.beginConfiguration()
        
        // 세션 프리셋을 HD1280x720으로 설정
        if session.canSetSessionPreset(.hd1280x720) {
            session.sessionPreset = .hd1280x720
        } else {
            status = .failed
            session.commitConfiguration()
            return
        }
        
        // 함수가 종료될 때 세션 구성을 커밋
        defer {
            session.commitConfiguration()
        }
        
        // 카메라 설정
        // 카메라 디바이스 선택
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else {
            set(error: .cameraUnavailable)
            status = .failed
            return
        }
        
        // 세션에 Input 추가
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            } else {
                set(error: .cannotAddInput)
                status = .failed
                return
            }
        } catch {
            set(error: .createCaptureInput(error))
            status = .failed
            return
        }
        
        // 세션에 Output 추가
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            
            videoOutput.videoSettings =
            [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            
            let videoConnection = videoOutput.connection(with: .video)
            videoConnection?.videoOrientation = .portrait
            
        } else {
            set(error: .cannotAddOutput)
            status = .failed
            return
        }
        
        status = .configured
    }
    
    private func configure() {
        checkPermissions()
        
        sessionQueue.async {
            self.configureCaptureSession()
            self.session.startRunning()
        }
    }
    
    func set(
        _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
        queue: DispatchQueue
    ) {
        sessionQueue.async {
            self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
        }
    }
        
    func setZoomLevel(to zoomFactor: CGFloat) {
        sessionQueue.async {
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: self.currentCameraPosition) else {
                return
            }
            
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                
                let maxZoomFactor = min(device.activeFormat.videoMaxZoomFactor, CGFloat(10)) // 최대 줌 팩터 제한
                // 현재 줌 팩터에 변경 요청된 줌 스케일을 곱합니다.
                self.currentZoomFactor = min(maxZoomFactor, max(1.0, self.currentZoomFactor * zoomFactor))
                device.videoZoomFactor = self.currentZoomFactor
            } catch {
            }
        }
    }
    
    // 줌 리셋 메소드도 추가할 수 있습니다.
    func resetZoom() {
        currentZoomFactor = 1.0
    }
}
