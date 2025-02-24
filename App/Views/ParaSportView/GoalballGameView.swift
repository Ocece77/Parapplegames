import SwiftUI
import AVFoundation
struct GoalballGameView: View {
    // TODO: correcting the counter to play
    @EnvironmentObject var appModel: AppModel
    @State private var countDown: Int = 3
    let gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var result: GameResult = .inconclusive
    @State private var gameBtnText: String = "Play"
    @State private var gameResultText: String = " "
    @State private var tutorialPopUp: Bool = true
    @State private var gameState: GameState = .notStarted
    @State private var randomBallDirection = BallPosition.allCases.randomElement()!
    @State private var frameIndex = 0
    @State private var frameTutoIndex = 0
    private var goalballFrame : [String] = ["gb1", "gb2" , "gb3" , "gb4" , "gb5" ,"gb6", "gb7" , "gb8" , "gb9" , "gb10" , "gb11"   ]
    private var tutoFrame : [String] = ["leftHand", "rightHand" ]
    private let padding: CGFloat = 30

    
    private var chiralityText: String {
        return appModel.chirality == .right ? "right 🤚" : "left ✋"
    }
    
    private var previewImageSize: CGSize {
        appModel.camera.previewImageSize
    }
    
    private var handJointPoints: [CGPoint] {
        appModel.nodePoints
    }
    
    @StateObject private var soundPlayer = SoundPlayer()
    
    //-------------
    //play sound


    func playSound() {
        soundPlayer.playBeepSound()
    }

    //----------------
    //animation
    private func athleteAnimation() -> some View{
        VStack {
            Image(goalballFrame[frameIndex]) 
                .resizable()
                .scaledToFit()
                .frame(  alignment : .center )
            
        }
    }
    
    func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                if frameIndex == goalballFrame.count-1 {
                      timer.invalidate() 
                } else {
                    frameIndex = (frameIndex + 1) % goalballFrame.count 
                }
               
            }
    }
    
    func startTutoAnimation(){
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            frameTutoIndex = (frameTutoIndex + 1) % tutoFrame.count 
        }
    }
    
    //----------------------------------
    // camera View 
    private func camera() -> some View {
        CameraView()
            .environmentObject(appModel)
            .overlay {
                handChiralityResult() 
            }
    }
    
    //----------------------------------
    // Game model
    
    

    private func startGame() {
        self.countDown = 3
        gameState = .onPlay
        randomBallDirection = BallPosition.allCases.randomElement()!
        startGameTimer()
    }
    
   
    private func startGameTimer() {
        gameState = .starting
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.countDown  > 0 {
                self.countDown -= 1
                gameResultText = "Chose your right hand or left hand"
            } else {
                timer.invalidate() 
                gameMove()
                 self.countDown = 3
            }
        }
    }
    
    private func gameMove() {
        if randomBallDirection == .left && appModel.chirality == .left {
            gameResultText = "You stopped the ball with your left hand"
            result = .win
        } else if randomBallDirection == .right && appModel.chirality == .right {
            gameResultText = "You stopped the ball with your right hand"
            result = .win
        } else {
            gameResultText = "Lose: You missed the ball that was in \(randomBallDirection)"
            result = .lose
        }
        gameState = .finished
        gameBtnText = "Play again!"
    }
    
    private func updateCountDown() -> some View {
        HStack {
            Text(String(countDown))
                .fontWeight(.bold)
                .font(.largeTitle)
        }
    }
    
    private func playBtn() -> some View {
        VStack {
            Spacer()
         
            Button {
                if gameState == .notStarted || gameState == .finished {
                    startAnimation()
                    startGameTimer()
                    playSound() 
                   randomBallDirection = BallPosition.allCases.randomElement()!
                }
            } label: {
                Text(gameBtnText)
                    .foregroundColor(.teal)
                    .fontWeight(.bold)
            }
            .padding()
            .background(.white)
            .cornerRadius(padding)
        }.padding(.bottom, 30)
        
    }
    
    
    private func resetGame() {
        self.countDown  = 3
        gameResultText = " "
        result = .inconclusive
        gameState = .notStarted
        gameBtnText = "Play"
    }
    
    private func handChiralityResult() -> some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 100, height: 60)
                    .padding()
                    .overlay {
                        Text(chiralityText)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
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
            Text("Determined the ball position using your hand ✌")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text("- The ball randomly send")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal , 20)
            Text("- Rise your right hand to chose right")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal , 20)
            Text("-  Rise your left hand to chose left")
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

    //-----------------------------------
    //Game interface
    var body: some View {
        GeometryReader { geometry in
            VStack {
                camera()
                    .frame(maxWidth : geometry.size.width , maxHeight: geometry.size.height / 2, alignment: .center)
                
                ZStack {
                    athleteAnimation()
                    .frame(maxWidth : geometry.size.width , maxHeight: geometry.size.height / 2, alignment: .center)
                    if gameState == .notStarted || gameState == .finished || !tutorialPopUp {
                        HStack{
                            tutorialBtn() 
                            Spacer()
               
                        }
                       playBtn()  
                    }
                }
                .overlay {
             
                    if gameState == .starting {
                        VStack{
                            Text("\(countDown)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Spacer()
                                .frame(height:20)
                            Text("Chose your right or left hand")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                        }
                    } else if gameState == .onPlay {
                        updateCountDown()
                    } else if gameState == .finished {
                        Text(gameResultText)
                            .fontWeight(.bold)
                            .foregroundColor(result == .win ? .green : .white)
                            .padding()
                        Spacer()
                    } 
                }  
            }   .background(Color.vividOrange)
                .onAppear {
                    startTutoAnimation()
                }
                .overlay{
                    if tutorialPopUp{
                        tutorialView()
                            .frame(maxWidth : geometry.size.width , maxHeight: geometry.size.height / 2, alignment: .center)    
                    }
                }
        }
    }
}


struct GoalballGameView_Previews: PreviewProvider {
    static var previews: some View {
        GoalballGameView()
            .environmentObject(AppModel())
    }
}

enum BallPosition: CaseIterable {
    case left
    case right
}

enum GameState {
    case starting 
    case onPlay
    case finished
    case notStarted
}

enum GameResult {
    case win
    case lose
    case inconclusive
}
