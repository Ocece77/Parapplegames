import SwiftUI

struct ParaSportDetailsView: View {
    var title: String
    var description: String
    var rules: [String]
    var equipment: [String]
    var funFact: String
    var famousPlayers: [String]
    var tutorial: [String]
    var gameView: AnyView
    var color: Color
    var image : [String]
    private let cornerSize: CGFloat = 20.0
    @EnvironmentObject var appModel: AppModel
    @StateObject var gameModel: GameModel = GameModel()
    @State private var animate: Bool = false
    

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.black)
                    
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack {
                            sportDetailsCard(geometry: geometry, title: "What is \(title)", content: description , image : image[0])
                            sportDetailsCard(geometry: geometry, title: "Game Rules  📜 ", content: rules.joined(separator: "\n- "), image : image[1])
                            sportDetailsCard(geometry: geometry, title: "Valid Equipment 🦿", content: equipment.joined(separator: ", "), image : image[2])
                            sportDetailsCard(geometry: geometry, title: "-> Fun Fact about it", content: funFact ,image : image[3])
                            sportDetailsCard(geometry: geometry, title: "Some Famous Players ", content: famousPlayers.joined(separator: ", "), image : image[4])
                            sportDetailsCard(geometry: geometry, title: " How to Play ", content: tutorial.joined(separator: "\n- "),image : "happyAthlete")
                        }
                    }
                    
                    // Play Section
                    Text("You got it? Now try playing \(title)!")
                        .font(.headline)
                        .padding(.top, 10)
                        .padding(.horizontal)
                        .foregroundColor(.black)
                    
                    playBtn()
                    
                    Spacer()
                }
                .padding(5)
            }
            .navigationTitle("ParApplesGames")
            .background(Color.white)
        }
    }
    
    // 🔹 Carte stylisée pour chaque section
    private func sportDetailsCard(geometry: GeometryProxy, title: String, content: String , image : String) -> some View {            
            ZStack{
                RoundedRectangle(cornerRadius: 20)
                    .fill(color)
                    .frame(width : geometry.size.width * 0.9, height: geometry.size.height * 0.75 )
                    .cornerRadius(20)
                
                LazyVGrid(columns : [GridItem(.flexible())]){
                    Spacer()
                        .frame(height: 40)
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width : .infinity , height: 260 , alignment : .topLeading)
                        .cornerRadius(20)
                        .padding(10)
                        .opacity(0)
                         .overlay{
                             Image(image)
                                 .resizable()
                                 .scaledToFit()
                                .frame(width : .infinity , height: 300 , alignment : .topLeading)
                                 .cornerRadius(20)
                                 .padding(10)
                         }
                    
                    VStack{
                        Text(title)
                            .font(.system(size: 28))
                            .underline()
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(width : .infinity , height: 30 , alignment : .topLeading)
                        Spacer()
                            .frame(height: 40 )
                        Text(content)
                            .font(.system(size: 21))
                            .lineSpacing(40 - 30)

                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(width : .infinity , height: 300 , alignment : .topLeading)
                   
                        
                    }.padding(20)
                        .foregroundColor(.black)
            
                }
            }
            
            
        }
    
    private func playBtn() -> some View {
        NavigationLink(destination: gameView.environmentObject(appModel)) {
            Text("Try \(title) 🎮")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(cornerSize)
                .shadow(radius: 5)
        }
        .padding(.top, 10)
    }
}

