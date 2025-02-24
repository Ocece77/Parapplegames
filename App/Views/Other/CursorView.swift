import SwiftUI

struct CursorView: View {
    var size: CGSize
    var points: CGPoint = .zero
    
    private let radius: CGFloat = 7
    
    private var imageAspectRatio: CGFloat {
        size.width / size.height
    }
    
    var body: some View {
        GeometryReader { geo in
            if points != .zero{
                let updatedPoint = updatePoint(points, viewSize: geo.size)
                
                Circle()
                    .fill(Color.neonPurple)
                    .frame(width: radius * 2, height: radius * 2)
                    .position(updatedPoint) 
            } else{
                EmptyView()
            }
        }
    }
    private func updatePoint(_ point: CGPoint, viewSize: CGSize) -> CGPoint {
        let currentFrameAspectRatio = viewSize.width / viewSize.height
        if currentFrameAspectRatio > imageAspectRatio {
            return CGPoint(x: (point.x * viewSize.width),
                           y: ((1 - point.y) * scaledHeight(viewSize)) - yOffset(viewSize))
        }
        return CGPoint(x: (point.x * scaledWidth(viewSize)) - xOffset(viewSize),
                       y: (1 - point.y) * viewSize.height)
    }
    private func scaledWidth(_ viewSize: CGSize) -> CGFloat {
        return imageAspectRatio * viewSize.height
    }
    
    private func scaledHeight(_ viewSize: CGSize) -> CGFloat {
        return (1 / imageAspectRatio) * viewSize.width
    }
    
    private func xOffset(_ viewSize: CGSize) -> CGFloat {
        return (scaledWidth(viewSize) - viewSize.width) / 2
    }
    
    private func yOffset(_ viewSize: CGSize) -> CGFloat {
        return (scaledHeight(viewSize) - viewSize.height) / 2
    }
}
