import SwiftUI
import Vision
import CoreML

final class AppModel: ObservableObject {
    let camera = MLCamera()
    private var countDownObservation = 10
    
    
    @Published var thumbTipPoint : CGPoint = .zero
    @Published var indexTipPoint  : CGPoint = .zero
    @Published var middleTipPoint : CGPoint =  .zero
    @Published var ringTipPoint : CGPoint =  .zero
    @Published var littleTipPoint : CGPoint =  .zero
    @Published var wristPoint : CGPoint =  .zero
    @Published var tipsPoints : [CGPoint] = []
    @Published var nodePoints: [CGPoint] = []
    @Published var previousPoints: [CGPoint] = []
    @Published var isHandInFrame: Bool = false
    @Published var viewfinderImage: Image?
    @Published var canPredict: Bool = true
    @Published var chirality : Chirality = .right
    @Published var isGatheringObservations: Bool = false
    @Published var predictionTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @Published var shouldPauseCamera: Bool = false {
    didSet {
        if shouldPauseCamera {
            camera.stop()
            isGatheringObservations = false
        } else {
            Task {
                await camera.start()
            }
        }
    }
}
    
    init() {
        camera.mlDelegate = self
        Task {
            await handleCameraPreviews()
        }
    }
    
    private func handleCameraPreviews() async {
        let imageStream = camera.previewStream.map { $0.image }
        for await image in imageStream {
            Task { @MainActor in
                self.viewfinderImage = image
                
            }
        }
    }
    
    
}

extension AppModel: MLDelegate {
    
    func gatherObservations(pixelBuffer: CVImageBuffer) async {
        // Vérifie si une prédiction est autorisée
        guard canPredict else {
            return
        }
        
        // Bloque les prédictions supplémentaires pendant le traitement
        await MainActor.run {
            canPredict = false
        }
        
        // Utilise un bloc `defer` pour réinitialiser `canPredict` à la fin
        defer {
            Task { @MainActor in
                canPredict = true
            }
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        do {
            try imageRequestHandler.perform([camera.handPoseRequest])
         
            
            guard let observation = camera.handPoseRequest.results?.first else {
                await updateNodes(points: [])
                await updateHandVisibility()
                return
            }
            let detectedHandPoses = camera.handPoseRequest.results!
    

            await MainActor.run {
                isHandInFrame = true
                isGatheringObservations = true
                for hand in detectedHandPoses {
                    if hand.chirality == .right{
                        self.chirality = .left
                    } else {
                        self.chirality = .right
                    }
                }
            }
            
            let thumbPoints = try observation.recognizedPoints(.thumb)
            let wristPoints = try observation.recognizedPoints(.all)
            let indexFingerPoints = try observation.recognizedPoints(.indexFinger)
            let middleFingerPoints = try observation.recognizedPoints(.middleFinger)
            let ringFingerPoints = try observation.recognizedPoints(.ringFinger)
            let littleFingerPoints = try observation.recognizedPoints(.littleFinger)
            
           guard let thumbTipPointLocation = thumbPoints[.thumbTip],
            let indexTipPointLocation = indexFingerPoints[.indexTip],
            let middleTipPointLocation = middleFingerPoints[.middleTip],
            let ringTipPointLocation = ringFingerPoints[.ringTip],
            let littleTipPointLocation = littleFingerPoints[.littleTip],
            let wristPointLocation = wristPoints[.wrist]
            else {
              await updateNodes(points: [])
               return
           }
            
            let confidenceThreshold: Float = 0.3
            guard   thumbTipPointLocation.confidence > confidenceThreshold &&
                        indexTipPointLocation.confidence > confidenceThreshold &&
                        middleTipPointLocation.confidence > confidenceThreshold &&
                        ringTipPointLocation.confidence > confidenceThreshold &&
                        littleTipPointLocation.confidence > confidenceThreshold &&
                        wristPointLocation.confidence > confidenceThreshold
            else {
                await updateNodes(points: [])
                return
            }
      
            await MainActor.run {
                self.thumbTipPoint = CGPoint(x: thumbTipPointLocation.location.x, y: 1 - thumbTipPointLocation.location.y)
                self.wristPoint = CGPoint(x: wristPointLocation.location.x, y: 1 - wristPointLocation.location.y)
                self.indexTipPoint = CGPoint(x: indexTipPointLocation.location.x, y: 1 - indexTipPointLocation.location.y)
                self.middleTipPoint = CGPoint(x: middleTipPointLocation.location.x, y: 1 - middleTipPointLocation.location.y)
                self.ringTipPoint = CGPoint(x: ringTipPointLocation.location.x, y: 1 - ringTipPointLocation.location.y)
                self.littleTipPoint = CGPoint(x: littleTipPointLocation.location.x, y: 1 - littleTipPointLocation.location.y)
            }
          
            
            let jointPoints = try gatherHandPosePoints(from: observation)
            await updateNodes(points: jointPoints)
            await MainActor.run { 
                self.tipsPoints =  [self.wristPoint ,self.thumbTipPoint , self.indexTipPoint ,self.middleTipPoint,self.ringTipPoint,self.littleTipPoint]

            }

        } catch {
            print("Error while detecting the hand: \(error)")
        }
    }
    
    
    private func gatherHandPosePoints(from observation: VNHumanHandPoseObservation) throws -> [CGPoint] {
        let allPointsDict = try observation.recognizedPoints(.all)
        var allPoints: [VNRecognizedPoint] = Array(allPointsDict.values)
        allPoints = allPoints.filter { $0.confidence > 0.5 }
        let points: [CGPoint] = allPoints.map { $0.location }
        return points
    }
    
    
    @MainActor
    private func updateHandVisibility(){
        isHandInFrame = false
    }
    
    @MainActor
    private func updateNodes(points: [CGPoint]) {
        self.countDownObservation -= 1
        if self.countDownObservation == 0{
            self.previousPoints =  self.nodePoints
            self.countDownObservation = 10
        }
        self.nodePoints = points
    }
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

extension AppModel: @unchecked Sendable {}
extension Image: @unchecked Sendable {}


