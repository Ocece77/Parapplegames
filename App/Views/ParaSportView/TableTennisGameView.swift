import SwiftUI


struct TableTennisGameView: View {
    
    @EnvironmentObject var appModel: AppModel
    @StateObject var gameModel: GameModel = GameModel()
    
    @State private var countDown: Int = 1
    @State private var gameResultText: String = ""
    @State private var tutorialPopUp: Bool = true
    
    @State private var canThrowAgain: Bool = true
    @State private var handState: HandSwing = .isStatic
    @State private var isCountdownActive: Bool = false
    @State private var frameIndex = 0

    private let padding: CGFloat = 30
    
    private var tableTennisFrame : [String] = (1...39).map { "pg\($0)" }

    
    @State private var frameTutoIndex = 0
    private var tutoFrame : [String] = [  "handopen" ,  "handswap" ]
    
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
            Image(tableTennisFrame[frameIndex]) 
                .resizable()
                .scaledToFit()
      
            
        }
    }
    
    func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if frameIndex == tableTennisFrame.count-1 {
                timer.invalidate() 
                frameIndex = 0
            } else {
                frameIndex = (frameIndex + 1) % tableTennisFrame.count 
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
        
        let yDistance = tipsIndex.x - wrist.x
        if yDistance > 0, canThrowAgain, !isCountdownActive {
            startAnimation()
            handState = .isSwinging
            gameResultText = "Yey you did it !"
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
        gameResultText = "Swing the paddle"
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
            Text("Your hand is the paddle ! 🏓")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("- Rise your hand in horizontal")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal , 20)
            Text("- Throw your hand  in horizontal")
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
                        .padding(10)  
                        .background(Color.blue)  
                        .cornerRadius(30) 
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
                
                camera()
                    .frame(maxHeight: geometry.size.height / 2, alignment: .center)
                
                VStack{
                     athleteAnimation()
                      .frame(maxHeight: geometry.size.height )
                     .background( Color(red: 198/255, green: 255/255, blue: 233/255))
                }.overlay {
                    HStack{
                        tutorialBtn() 
                        Spacer() 
                    }
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
            .onAppear {
                  startTutoAnimation()
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                        startGestureDetection()
                    }
                
            }.overlay{
                if tutorialPopUp{
                    tutorialView()
                        .frame(maxWidth : geometry.size.width , maxHeight: geometry.size.height / 2, alignment: .center)    
                }
            }.background(Color.lightGreen)
        }
    }
}

// Enumération des états de la main
enum HandSwing {
    case isSwinging
    case isStatic
}

struct TableTennisGameView_Previews: PreviewProvider {
    static var previews: some View {
        TableTennisGameView()
            .environmentObject(AppModel())
    }
}
