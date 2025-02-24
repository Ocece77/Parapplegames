import SwiftUI

struct BasketBallGameView: View {
    @EnvironmentObject var appModel: AppModel
    @StateObject var gameModel: GameModel = GameModel()
    
    @State private var countDown: Int = 1
    @State private var gameResultText: String = "Throw the basketball"
    @State private var tutorialPopUp: Bool = true
    
    @State private var canThrowAgain: Bool = true
    @State private var handState: HandThrow = .isStatic
    @State private var isCountdownActive: Bool = false
    @State private var frameIndex = 0
    @State private var subframeIndex = 0
    @State private var count = 0
    private var basketballFrame : [String] = (1...34).map { "bsk\($0)" }
    private var athleticsBasketFrame : [String] = (1...13).map { "bskply\($0)" }

    private let padding: CGFloat = 30
    
 
    
    @State private var frameTutoIndex = 0
    private var tutoFrame : [String] = [ "leftHand" , "handdown"]
    
    private var previewImageSize: CGSize {
        appModel.camera.previewImageSize
    }
    
    private var handJointTips: [CGPoint] {
        appModel.tipsPoints
    }
    
    private var shouldDisablePlayButton: Bool {
        return !appModel.isHandInFrame || !appModel.isGatheringObservations || !gameResultText.isEmpty
    }
    //----------------
    //animation
    
    func startTutoAnimation(){
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            frameTutoIndex = (frameTutoIndex + 1) % tutoFrame.count 
        }
    }
    
    private func athleteAnimation() -> some View{
        VStack {
            Image(athleticsBasketFrame[subframeIndex]) 
                .resizable()
                .scaledToFit()
                .frame(  alignment : .center )
        }
    }
    private func basketAnimation() -> some View{
        VStack {
            Image(basketballFrame[frameIndex]) 
                .resizable()
                .scaledToFit()
                .frame(  alignment : .center )
        }
    }
    
    
    func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if frameIndex == basketballFrame.count-1 {
                timer.invalidate() 
                subframeIndex = 0
                frameIndex = 0
                count = 0
            } else {
                frameIndex = (frameIndex + 1) % basketballFrame.count 
                if  count == 0 {
                     startPlayerAnimation()
                    count += 1
                }
            }
            
        }
        
    }
    func startPlayerAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            
            if subframeIndex ==  athleticsBasketFrame.count-1 {
                timer.invalidate() 
            } else {
              subframeIndex =  (subframeIndex + 1) % athleticsBasketFrame.count 
            }
            
        }
        
    }
    //----------------------------------
    // Camera view
    private func camera() -> some View {
        CameraView()
            .environmentObject(appModel)
    }
    
    //----------------------------------
    // Game model
    
    private func detectHandGesture() {
        guard handJointTips.count > 2 else { return }
        
        let wrist = handJointTips[0]
        let tipsIndex = handJointTips[2]
        
        let yDistance = tipsIndex.y - wrist.y
        
        if yDistance > 0, canThrowAgain, !isCountdownActive {
            startAnimation()
            
            handState = .isThrowing
            gameResultText = "Boom! 💥"
            canThrowAgain = false
            isCountdownActive = true
            startCountdown()
        }
    }
    
    //----------------------------------
    // Set the countdown
    
    private func startCountdown() {
        countDown = 2
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
        handState = .isStatic
        canThrowAgain = true
        isCountdownActive = false
        gameResultText = "Throw the basketball"
    }
    
 
    private func startGestureDetection() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if appModel.isHandInFrame && canThrowAgain {
                detectHandGesture()
            
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
            Text("Swipe your hand to play throw")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("- Rise your hand")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal , 20)
            Text("- Do a throw mouvement to send the ball")
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
                VStack{
                    basketAnimation()
                        .overlay {
                            VStack {
                                Spacer() 
                                Text(gameResultText)
                                    .font(.title)
                                    .padding(20)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }            .padding(30)
                        }
                }
                VStack{
                    camera()
                        .frame(maxHeight: geometry.size.height, alignment: .center)   
                }
                
                .overlay{
                    HStack{
                        tutorialBtn() 
                        Spacer() 
                    }
                    athleteAnimation()
                        .frame(width:geometry.size.width * 0.8 ,height:geometry.size.height / 2, alignment: .bottom)
                    
                }.padding(.bottom, 5)
            }
            
            .onAppear {
                startTutoAnimation()
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    startGestureDetection()
                    
                }
            }
            .overlay{
                if tutorialPopUp{
                    tutorialView()
                        .frame(maxWidth : geometry.size.width , maxHeight: geometry.size.height / 2, alignment: .center)    
                }
            }
        }.background(Color.lightViolet)
    }
}

// Enumération des états de la main
enum HandThrow {
    case isThrowing
    case isStatic
}
struct BasketBallGameView_Previews: PreviewProvider {
    static var previews: some View {
         BasketBallGameView()
            .environmentObject(AppModel())
    }
}
