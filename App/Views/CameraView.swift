import SwiftUI

struct CameraView: View {
    @EnvironmentObject var appModel: AppModel
    
    private var showWarning: Bool {
        appModel.viewfinderImage != nil && !appModel.isHandInFrame
    }
    
    private var previewImageSize: CGSize {
        appModel.camera.previewImageSize
    }
    
    private var handJointPoints: [CGPoint] {
        appModel.nodePoints
    }
    
    var body: some View {
        ZStack {
            if let viewfinderImage = appModel.viewfinderImage {
                ViewfinderView(image: .constant(viewfinderImage))
               
                    .overlay {
                        HandPoseNodeOverlay(size: previewImageSize,
                                            points: handJointPoints)
                        
                        if showWarning {
                            CameraFrameOverlay()
                                .animation(.default, value: appModel.isHandInFrame)
                        }
                    }
            } else {
                ProgressView("Loading the camera...") 
            }
        }
        .task {
            await appModel.camera.start()
        }
        .onReceive(appModel.predictionTimer) { _ in
            if !appModel.canPredict {
                appModel.canPredict = true 
            }
        }
        .onDisappear {
            appModel.canPredict = false
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
            .environmentObject(AppModel())
    }
}
