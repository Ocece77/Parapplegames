import SwiftUI

struct ArcheryGameView: View {
    @EnvironmentObject var appModel: AppModel
    @StateObject var gameModel: GameModel = GameModel()
    @State private var gameResultText: String = "Pinch to send an arrow"
    @State private var tutorialPopUp: Bool = true
    @State private var currPoints: Int = 0
    
    @State private var arrows: [CGPoint] = []
    @State private var arrowState: ArrowState = .undefined
    @State private var countDown: Int = 1
    @State private var canThrowAgain: Bool = true
    @State private var isCountdownActive: Bool = false
    @State private var randomSpeed: Int = Int.random(in: 1...20)

    @State private var viewSize: CGSize = .zero     
    
    @State private var frameTutoIndex = 0
    private var tutoFrame : [String] = ["pinch1", "pinch2" , "pinch3"]

    //----------------------------
    private let padding: CGFloat = 30
    
    struct ViewSizeKey: PreferenceKey {
        static var defaultValue: CGSize = .zero
        
        static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
            value = nextValue()
        }
    }
    
    private var imageAspectRatio: CGFloat {
        previewImageSize.width / previewImageSize.height
    }
    
    private var previewImageSize: CGSize {
        appModel.camera.previewImageSize
    }
    
    private var handJointPoints: [CGPoint] {
        appModel.nodePoints
    }
    
    private var handJointTips: [CGPoint] {
        appModel.tipsPoints
    }
    
    private var shouldDisablePlayButton: Bool {
        !appModel.isHandInFrame || !appModel.isGatheringObservations || !gameResultText.isEmpty
    }
    
    
    //-------------------------
    // Animation
    func startTutoAnimation(){
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            frameTutoIndex = (frameTutoIndex + 1) % tutoFrame.count 
        }
    }
    //--------------------------
    //Game Model
    private func resetGame() {
        countDown = 1
        gameResultText = "Pinch to send an arrow"
        arrowState = .undefined
        arrows.removeAll()  
    }
    
    func handleStatePinched() {
        guard handJointTips.count > 4 else { return }
        let thumbsTipPoint = handJointTips[1]
        let middleTipPoint = handJointTips[3]
        
        let distance = abs(thumbsTipPoint.x - middleTipPoint.x)
        let definedMaxDistance: CGFloat = 0.015
        if distance < definedMaxDistance {
            self.arrowState = .hasBeenThrow
            addArrow()
            randomSpeed = Int.random(in: 1...20)
            canThrowAgain = false
            isCountdownActive = true
            startCountdown()
        } else {
            self.arrowState = .hasNotBeenThrow
        }
    }
    
    private func startCountdown() {
        countDown = 1
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.countDown > 0 {
                self.countDown -= 1
            } else {
                timer.invalidate() //stop the timer
                self.resetThrowState()
            }
        }
    }
    
    private func resetThrowState() {
        self.arrowState = .hasNotBeenThrow
        canThrowAgain = true
        isCountdownActive = false
        gameResultText = "Good 😎"
    }
    
    private func addArrow() {
        guard handJointTips.count > 2 else { return }
        let indexTipPoint = handJointTips[2]
        arrows.append(updatePoint(indexTipPoint, viewSize: viewSize)) // Utilisation de viewSize ici
    }
    
    private func startGestureDetection() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if appModel.isHandInFrame && canThrowAgain {
                handleStatePinched()
            }
        }
    }
    
    // To put the arrow where the index was aiming
    private func updatePoint(_ point: CGPoint, viewSize: CGSize) -> CGPoint {
        let currentFrameAspectRatio = viewSize.width / viewSize.height
        if currentFrameAspectRatio > imageAspectRatio {
            return CGPoint(x: (point.x * viewSize.width  + CGFloat(randomSpeed * 4 )),
                           y: ((1 - point.y) * scaledHeight(viewSize)) - yOffset(viewSize)  + CGFloat(randomSpeed * 4 ))
        }
        return CGPoint(x: (point.x * scaledWidth(viewSize)) - xOffset(viewSize)  + CGFloat(randomSpeed * 4 ),
                       y: (1 - point.y) * viewSize.height + CGFloat(randomSpeed * 4))
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
    

    @ViewBuilder
    private func camera() -> some View {
        CameraView()
            .environmentObject(appModel)
    }
    
    private func targetView(geometry: GeometryProxy) -> some View {
        GeometryReader { geometry in
            
            ZStack {
                let circleSizes: [(Color, CGFloat)] = [
                    (.white, 0.95),
                    (.black, 0.8),
                    (.blue, 0.65),
                    (.teal, 0.5),
                    (.red, 0.35),
                    (.yellow, 0.2)
                ]
     
                ForEach(0..<circleSizes.count, id: \.self) { index in
                    Circle()
                        .fill(circleSizes[index].0)
                        .frame(
                            width: geometry.size.width * circleSizes[index].1,
                            height: geometry.size.height / 1.2 * circleSizes[index].1
                        )
                        .shadow(color: .black.opacity(0.3) , radius: 3.0)
                }
                      
                // Dessiner les flèches
                ForEach(arrows, id: \.self) { arrow in
                    Image("arrow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100, alignment: .top)
                        .position(arrow )
                }
                
            }
             .preference(key: ViewSizeKey.self, value: geometry.size)
            .onAppear {
                self.viewSize = geometry.size 
            }
        }
        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height / 2)
        .background(background())
        
        .onPreferenceChange(ViewSizeKey.self) { size in
            self.viewSize = size // Mets à jour la taille de la vue dans la vue parent
  
        }
       
    }
    
    private func background() -> some View {
        Image("mypixelart")
            .resizable()
            .scaledToFill()
    }
    //--------------------
    // tutorial view
    private func tutorialView() -> some View {
        
        VStack {
            Spacer()
                .frame(height:50)
            Text("Tutorial")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Rectangle()
                .frame(width : .infinity , height: 300)
                .overlay{
                    Image(tutoFrame[frameTutoIndex])
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                    
                }
                .padding(padding)
            Text("Use your fingers to play Para Archery ")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("- Use your index tips to aim ")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal , 20)
            Text("- Pinch with your middle and thumb tips")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal , 20)
            Text("- Becareful ⚠️ The wind move your arrow")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal , 20)
            VStack {
                Spacer()
                
                Button {
                    closePopUp()
                } label: {
                    Text("Understand !")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .font(.title3)
                        .padding(10)  // Padding à l'intérieur du texte
                        .background(Color.blue)  // Fond derrière le texte
                        .cornerRadius(30)  // Coins arrondis sur le fond
                }
                
                Spacer()
            }
            .background(.white)  
            .cornerRadius(3.0)  
            .padding(10)  
            
        }.background(.white)
            .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
            .padding(10)
        
    }
    
    private func tutorialBtn() -> some View{
        
        VStack {
            Spacer()
            
            Button {
                openPopUp()
            } label: {
                Text("Tutorial !")
                    .foregroundColor(.blue)
                    .padding()
            }
        }.padding(.bottom, 30)
    }
    
    func closePopUp(){
        tutorialPopUp = false
    }
    func openPopUp(){
        tutorialPopUp = true
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                
                targetView(geometry: geometry)
                    .overlay{
                        if handJointTips.count > 2 {
                            CursorView(size: previewImageSize,
                                       points: handJointTips[2])
                            VStack {
                                Spacer() 
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) 
                              {
                                    Text(gameResultText)
                                        .font(.title)
                                        .padding(5)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                    Spacer()
                                    Text("\(randomSpeed) km/h")
                                        .font(.title)
                                        .padding(10)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                  
                          
                                }
                              
                            }     .padding(20)
                        }
             
                        
                    }
                
                camera()
                    .frame(maxHeight: geometry.size.height / 2, alignment: .center)
                    .overlay{
                        HStack{
                            tutorialBtn() 
                            Spacer() 
                        }
                        VStack{
                            Spacer()
                            Button(action: { resetGame()} 
                                   ,label: {
                                Text("Reset")
                                    .padding()
                                    .background(.white)
                                    .cornerRadius(padding)
                                    .foregroundStyle(.red)
                            })
                            Spacer()
                                .frame(height: 20)
                        }
                    }
            }
            .overlay{
                if tutorialPopUp{
                    tutorialView()
                        .frame(maxWidth : geometry.size.width , maxHeight: geometry.size.height / 2, alignment: .center)    
                }
            }
            .onAppear {
                startGestureDetection()
                  startTutoAnimation()
            }
            .onChange(of: previewImageSize){
                resetGame()
            }
            
        }
    }
}

struct ArcheryGameView_Previews: PreviewProvider {
    static var previews: some View {
        ArcheryGameView()
            .environmentObject(AppModel())
    }
}

enum ArrowState {
    case hasBeenThrow
    case hasNotBeenThrow
    case undefined
}


