import SwiftUI

struct CameraFrameOverlay: View {
    @ScaledMetric private var cornerRadius: CGFloat = 15
    @ScaledMetric private var padding: CGFloat = 100
    @ScaledMetric private var lineWidth: CGFloat = 4.0

    var body: some View {
            warningView()
    }
    
    private func warningView() -> some View {
        Text("Place your hand in the screen to play")
            .font(.caption)
            .padding()
            .foregroundColor(.white)
            .background(Color.black.opacity(0.4))
            .cornerRadius(5.0)
    }
}
