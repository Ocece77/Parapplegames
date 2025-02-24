import SwiftUI
import Vision

struct ParabikeGameView: View {
    @EnvironmentObject var appModel: AppModel
    @StateObject var gameModel: GameModel = GameModel()
    
    @State private var gameResultText: String = "Turn around your hand to make your player move"
    @State private var tutorialPopUp: Bool = true

    private let padding: CGFloat = 30

    
    @State private var frameTutoIndex = 0
    private var tutoFrame : [String] = [  "rotate1" ,  "rotate2" ]
    
    @State private var handState: ParabikeHandState = .isStatic
    @State private var currHand: ParabikeHandCharility = .undefined
    @State private var prevHand: ParabikeHandCharility = .undefined
    @State private var resetTimer: DispatchWorkItem?
    @State private var isAnimating = false
    @State private var frameIndex = 0
    private var parabikerFrame : [String] = ["pb1", "pb2" , "pb3" , "pb4" , "pb5"]
    //-----------------------------------
    
    private var previewImageSize: CGSize {
        appModel.camera.previewImageSize
    }
    
    private var handJointPoints: [CGPoint] {
        appModel.nodePoints
    }
    
    private var previousHandJointPoints: [CGPoint] {
        appModel.previousPoints
    }
    
    private var handJointTips: [CGPoint] {
        appModel.tipsPoints
    }
    
    //----------------------------------
    // Camera view
    private func camera() -> some View {
        CameraView()
            .environmentObject(appModel)
    }
    
    //----------------------------------
    // Game model
    private func detectWavingGesture() {
        currHand = appModel.chirality == .right ? .right : .left
        if currHand != prevHand {
            resetTimer?.cancel()
            
            handState = .isRotating
            isAnimating = true
            
            let newResetTimer = DispatchWorkItem {
                handState = .isStatic
                isAnimating = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: newResetTimer)
            resetTimer = newResetTimer
        }
        
        prevHand = currHand
    }
    
    
    //----------------
    //animation
    func startTutoAnimation(){
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            frameTutoIndex = (frameTutoIndex + 1) % tutoFrame.count 
        }
    }
    
    private func athleteAnimation() -> some View{
        VStack {
            Image(parabikerFrame[frameIndex]) 
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
                .background(Color.paleYellow)
        }
    }
    
    func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            if !isAnimating {
                timer.invalidate() 
            } else {
                frameIndex = (frameIndex + 1) % parabikerFrame.count 
            }
        }
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
            Text("Turn around your hand to make your athlete move")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("- Turn around your hand to make your athlete move ")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal , 20)
            Text("- Your hand must be in the frame in order to detect your move ⚠️")
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
    //----------------------------------
    // Game interface
    var body: some View {
        GeometryReader { geometry in
            VStack {
             athleteAnimation()
                    .frame(maxHeight: geometry.size.height , alignment: .center)
                    .overlay {
                        VStack {
                            Spacer() 
                            Text(" \(handState != .isRotating ? "Turn around your hand to make the parabiker move" : "GO GO GO!")")
                                .font(.title)
                                .padding(20)
                                .multilineTextAlignment(.center)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .background(Color.white)
                                .cornerRadius(10)
                        }            .padding(30)
                    }


                camera()
                    .frame(maxHeight: geometry.size.height / 2, alignment: .center)
                    .overlay{
                        HStack{
                            tutorialBtn() 
                            Spacer()
                            
                        }
                    }
                
            }  .background(Color.paleOrange)
                .overlay{
                    if tutorialPopUp{
                        tutorialView()
                            .frame(maxWidth : geometry.size.width , maxHeight: geometry.size.height / 2, alignment: .center)    
                    }
                }
                .onAppear {
                    startTutoAnimation()
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                        detectWavingGesture()
                        startAnimation()
                    }
                }
            }.background(Color.paleYellow)
        }
    

    
}


struct ParabikeGameView_Previews: PreviewProvider {
    static var previews: some View {
       ParabikeGameView()
            .environmentObject(AppModel())
    }
}

enum ParabikeHandState {
    case isRotating
    case isStatic
}

enum ParabikeHandCharility {
    case right
    case left
    case undefined
}
