import SwiftUI

struct RunnerGameView: View {
    @EnvironmentObject var appModel: AppModel
    @StateObject var gameModel: GameModel = GameModel()
    
    @State private var gameResultText: String = "Turn around your hand to make your player move"
    @State private var tutorialPopUp: Bool = true
    
    private let padding: CGFloat = 30
    
    @State private var fingerState: FingerState = .isStatic
    @State private var resetTimer: DispatchWorkItem?
    @State private var currtipInTop : RunnerTips = .undefined
    @State private var prevtipInTop : RunnerTips = .undefined
    
    @State private var isAnimating = false
    @State private var frameIndex = 0
    private var pararunnerFrame : [String] = ["rn1", "rn2" , "rn3" , "rn4" , "rn5" ,"rn6", "rn7" , "rn8" , "rn9" , "rn10" ,"rn11", "rn12"  ]
    
    @State private var frameTutoIndex = 0
    private var tutoFrame : [String] = [  "walk1" ,  "walk2" ]
    
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
    
    //----------------
    //animation
    func startTutoAnimation(){
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            frameTutoIndex = (frameTutoIndex + 1) % tutoFrame.count 
        }
    }
    
    private func athleteAnimation() -> some View{
        VStack {
            Image(pararunnerFrame[frameIndex]) 
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
                .background(Color.paleOrange)
        }
    }
    
    func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if !isAnimating {
                timer.invalidate() 
            } else {
                frameIndex = (frameIndex + 1) % pararunnerFrame.count 
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
    private func detectWavingGesture() {
        guard handJointTips.count > 3 else { return }
        let indexTipPoint = handJointTips[2]
        let middleTipPoint = handJointTips[3]
        
        currtipInTop = indexTipPoint.y < middleTipPoint.y ? .middle : .index

        if  currtipInTop != prevtipInTop {
            resetTimer?.cancel()
            fingerState = .isWalking
            isAnimating = true
            let newResetTimer = DispatchWorkItem {
                fingerState = .isStatic
               isAnimating = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: newResetTimer)
            resetTimer = newResetTimer
        }
        
         prevtipInTop = currtipInTop
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
            Text("The athlete is your finger !")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("- Make a walking movement with your middle and index finger")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal , 20)
            Text("- Make sure that your index and middle finger are visible")
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
                Rectangle()
                    .background(Color.paleOrange)
                    .frame(maxHeight: geometry.size.height / 2, alignment: .center)
                    .overlay{
                        athleteAnimation() 
                      
                        VStack {
                            Spacer() 
                        Text("\(fingerState == .isWalking ? "Look who's running !" : "Move your middle and index finger to make your athlete run")")
                                .padding(20)
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
            }
            .onAppear {
                  startTutoAnimation()
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    detectWavingGesture()
                   startAnimation()
                }
                
            }.overlay{
                if tutorialPopUp{
                    tutorialView()
                        .frame(maxWidth : geometry.size.width , maxHeight: geometry.size.height / 2, alignment: .center)    
                }
            }
        }
    }
    

}

struct RunnerGameView_Previews: PreviewProvider {
    static var previews: some View {
        RunnerGameView()
            .environmentObject(AppModel())
    }
}

enum FingerState {
    case isWalking
    case isStatic
}

enum RunnerHandCharility {
    case right
    case left
    case undefined
}

enum RunnerTips {
    case index
    case middle
    case undefined
}
