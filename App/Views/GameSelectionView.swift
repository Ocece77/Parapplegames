import SwiftUI

struct GameSelectionView: View {
    @EnvironmentObject var appModel: AppModel
    let customColumns = Array(repeating: GridItem(.flexible()) , count : 1 )

    var pastelColors: [Color] {
        [Color.paleBlue, Color.paleYellow, Color.paleViolet, Color.palePink, Color.paleOrange, Color.pastelGreen]
    }
    private var sportImage : [String] =
    [
        "goalballer2" ,  "pararchery1" , "pararunner2" ,  "parabiker3"  , "tabletennis1"  , "parabasket5" 
    ]
    private let sportsView: [String: AnyView] = [
        "Para Archery 🏹": AnyView(ParaSportDetailsView(
            title: "Para Archery 🏹", 
            description: "Precision, focus, and strength – Para Archery is all about hitting the bullseye! Athletes compete in individual or team events using adapted bows. 🎯", 
            rules: [
                "Athletes use adaptive bows: recurve, compound, or longbow.",
                "Competitions are held in both indoor and outdoor events.",
                "There are different classifications based on the level of disability."
            ],
            equipment: [
                "Recurve bow 🎯 – a traditional bow for athletes with upper body impairments.",
                "Compound bow 🏹 – provides power and precision.",
                "Adaptive archery equipment, like mouth or chin triggers."
            ],
            funFact: "Did you know? Archery is over 5,000 years old! 🏹",
            famousPlayers: ["Sheetal Devi 🇮🇳", "Danielle Brown 🇬🇧"],
            tutorial: [
                "1️⃣ Set up your bow and adjust your draw weight.",
                "2️⃣ Focus and aim at your target.",
                "3️⃣ Draw the string back and aim for the bullseye.",
                "4️⃣ Release the arrow to hit the target!"
            ],
            gameView: AnyView(ArcheryGameView()),
            color: Color.paleYellow,
            image: ["pararchery1","pararchery2","pararchery3", "pararchery4", "pararchery5"]
        ))
,
        "Para Cycling 🚴‍♂️": AnyView(ParaSportDetailsView(
            title: "Para Cycling 🚴‍♂️", 
            description: "Speed, endurance, and adapted bikes – Para Cycling is all about pushing limits! Whether on a hand cycle, tandem bike, or tricycle, athletes race like lightning! ⚡", 
            rules: [
                "Athletes use adaptive bikes: hand cycles, recumbent cycles, or tricycles.",
                "Races take place on roads and tracks, just like the Olympics! 🏁",
                "Different categories exist based on the type of disability."
            ],
            equipment: [
                "Hand cycle 🖐️🚲 – powered by arms instead of legs!",
                "Tandem bike 🚴‍♀️🚴 – for visually impaired athletes with a guide.",
                "Recumbent tricycle 🔥 – low to the ground for extra stability!"
            ],
            funFact: "Did you know? Some para cyclists reach speeds of over 50 km/h (31 mph)! 🚀",
            famousPlayers: ["Sarah Storey 🇬🇧", "Oksana Masters 🇺🇸", "Jozef Metelka 🇸🇰"],
            tutorial: [
                "1️⃣ Get on your adaptive bike and adjust your seating or handles. 🏎️",
                "2️⃣ Start pedaling (or hand-cranking) to build up speed! 💨",
                "3️⃣ Stay aerodynamic and manage your turns carefully! 🚴‍♂️",
                "4️⃣ Sprint to the finish line and feel the adrenaline! 🏆"
            ],
            gameView: AnyView(ParabikeGameView()),
            color: Color.palePink,
            image:[ "parabiker1" , "parabiker2" , "parabiker3" , "parabiker4" , "parabiker5" ]
        )),
        
        "Goalball 🏐": AnyView(ParaSportDetailsView(
            title: "Goalball 🏐", 
            description: "Blindfolds on, ears sharp! In this intense sport, you dive, block, and score – all by sound alone. 🎧🔥", 
            rules: [
                "Players wear blindfolds to ensure fairness – no peeking! 👀❌",
                "The ball has bells inside so athletes can hear it coming. 🔔",
                "Three players per team, and the goal is to score while defending like a wall!"
            ],
            equipment: [
                "Blindfold 🕶️ – levels the playing field for all athletes.",
                "Bells ball 🔔 – makes sound so players can track it.",
                "Knee & elbow pads 🏐 – for all those epic diving saves!"
            ],
            funFact: "Goalball is one of the few sports designed *exclusively* for visually impaired athletes! 👏",
            famousPlayers: ["Sevda Altunoluk 🇹🇷", "Calvin-Klein Braund 🇦🇺", "Asya Miller 🇺🇸"],
            tutorial: [
                "1️⃣ Put on your blindfold – no exceptions! 🕶️",
                "2️⃣ Listen carefully for the ball’s sound. 🔔",
                "3️⃣ When defending, dive to block the ball with your body! 🛡️",
                "4️⃣ When attacking, roll the ball low and fast to score! ⚽🔥"
            ],
            gameView: AnyView(GoalballGameView()),
            color: Color.paleBlue,
            image:["goalballer1","goalballer2","goalballer3" ,"goalballer5","goalballer4"]
        )),
        
        "Para Athletics 🏃‍♂️": AnyView(ParaSportDetailsView(
            title: "Para Athletics 🏃‍♂️", 
            description: "Runners with different disabilities compete to be the fastest! Whether using prosthetics, racing wheelchairs, or pure muscle power – it’s all about speed and determination! 💪🏅", 
            rules: [
                "Events include sprints, marathons, long jump, and more! 🏁",
                "Athletes may use prosthetic blades, racing wheelchairs, or compete with a guide. 🏃‍♂️",
                "Races are divided into categories based on ability."
            ],
            equipment: [
                "Running blades 🦿 – super lightweight for max speed!",
                "Racing wheelchair 🏎️ – built for aerodynamics and agility.",
                "Guide runners 👥 – for visually impaired athletes who run together with a sighted partner!"
            ],
            funFact: "Paralympic sprinters using running blades can hit speeds of over 30 km/h (18 mph)! 🚀",
            famousPlayers: ["Markus Rehm 🇩🇪", "Tatyana McFadden 🇺🇸", "Omara Durand 🇨🇺"],
            tutorial: [
                "1️⃣ Warm up and stretch those muscles! 🔥",
                "2️⃣ Take your position at the starting line. 🚦",
                "3️⃣ Listen for the gunshot (or visual signal) and GO! 🏃‍♂️💨",
                "4️⃣ Sprint, push, or jump your way to victory! 🏆"
            ],
            gameView: AnyView(RunnerGameView()),
            color: Color.paleViolet,
            image:["pararunner1","pararunner2","pararunner3","pararunner4","pararunner5", ]
        )),
        
        "Wheelchair Basketball 🏀": AnyView(ParaSportDetailsView(
            title: "Wheelchair Basketball 🏀", 
            description: "Fast, dynamic, and full of action! Players zoom across the court, passing, shooting, and scoring big! 🏀🔥", 
            rules: [
                "Each team has 5 players on the court.",
                "Players must dribble the ball every two pushes of their wheelchair. 🏎️",
                "The hoop is at the same height as in regular basketball – no mercy! 💪"
            ],
            equipment: [
                "Sports wheelchair 🏎️ – designed for quick turns and stability.",
                "Basketball 🏀 – same size and weight as the standard game.",
                "Gloves 🧤 – for better grip and control while maneuvering!"
            ],
            funFact: "Wheelchair basketball was one of the first adaptive sports, created in the 1940s for injured war veterans! 🎖️",
            famousPlayers: ["Patrick Anderson 🇨🇦", "Annika Zeyen 🇩🇪", "Steve Serio 🇺🇸"],
            tutorial: [
                "1️⃣ Get into position and grip your wheels! 🏀",
                "2️⃣ Dribble by bouncing the ball every two pushes. 🚀",
                "3️⃣ Pass to teammates and look for a shot! 🎯",
                "4️⃣ Shoot and score – just like in regular basketball! 🏆"
            ],
            gameView: AnyView(BasketBallGameView()),
            color: Color.pastelGreen,
            image:["parabasket1","parabasket2","parabasket3","parabasket4","parabasket5"]
        )),
        
        "Para Table Tennis 🏓": AnyView(ParaSportDetailsView(
            title: "Para Table Tennis 🏓", 
            description: "An electrifying game of speed, precision, and reflexes! Athletes with disabilities face off, battling for every point! 😎🔥", 
            rules: [
                "Players compete in wheelchairs or standing, depending on their category.",
                "Matches are best of 3 or 5 sets, played to 11 points.",
                "The ball must bounce once on each side before returning it."
            ],
            equipment: [
                "Table tennis paddle 🏓 – customized grips for different abilities.",
                "Table tennis ball 🎾 – lightweight and fast-moving.",
                "Adjustable table height 🎯 – ensuring fair play for all!"
            ],
            funFact: "Para table tennis was one of the first sports added to the Paralympics in 1960! 🤩",
            famousPlayers: ["Natalia Partyka 🇵🇱", "Will Bayley 🇬🇧", "Mao Jingdian 🇨🇳"],
            tutorial: [
                "1️⃣ Grip your paddle and position yourself. 🏓",
                "2️⃣ Serve by tossing the ball and hitting it over the net! ",
                "3️⃣ Rally back and forth, aiming for tricky shots! 🔥",
                "4️⃣ Score points by outplaying your opponent! 🏆"
            ],
            gameView: AnyView(TableTennisGameView()),
            color: Color.paleOrange,
            image:[ "tabletennis1" ,"tabletennis2","tabletennis3","tabletennis4","tabletennis5"]
        ))
    ]

    private func gameLogo() -> some View {
        HStack{
            Image("logo")
                .resizable()
                .scaledToFill()
                .frame(width: 200 )
                .clipped()
            Spacer()
        }  .frame(height : 50)
      
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView{
                    Spacer()
                        .frame(height : 60)
                    
                    VStack{
                  
                     gameLogo()
                        Text("Hi there 👋")
                            .font(.system(size: 26))
                            .fontWeight(.bold)
                            .foregroundColor(Color.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                     
                        
                        Text("Come discover how cool paraSport are")
                            .font(.system(size: 38))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading) 

                    }.padding(.leading , 10)
            
                    Spacer()
                        .frame(height : 60)
                    LazyVGrid(columns: customColumns, spacing: 10) {
                      
                        
                        ForEach(Array(sportsView.keys.sorted()), id: \.self) { key in
                            if let view = sportsView[key] {
                                NavigationLink(destination: view.environmentObject(appModel)) {
                                    GameCardView(
                                        title: key,
                                        
                                        color: pastelColors[Array(sportsView.keys.sorted()).firstIndex(of: key)! % pastelColors.count],
                                        
                                        image :sportImage[Array(sportsView.keys.sorted()).firstIndex(of: key)! % sportImage.count]
                                        
                                    )
                                    
                                }
                            }
                            
                            
                            
                            
                        } 
                        .padding(.horizontal , geometry.size.width * 0.03 )                     
                        
                        
                    }
                    Spacer().frame(height: 30)
                } .background(.white)
                
                
            }
            
        }.background(.white)
       
        
        
    }
}


struct GameCardView: View {
    let title: String
    let color : Color
    let image : String
    var body: some View {
 
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color)
                        .frame(width:.infinity , height : 180)
                        .shadow(color: .black.opacity(0.3), radius: 2.5)
                    
            HStack(){
                Image(image)
                    .resizable()
                    .padding(5)
                    .scaledToFit()
                    .frame( height: 170)
                    .clipped()   
                    .cornerRadius( 30)
                
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                
                Spacer()
         
            }
                  
                 
                       
         
                }.background(.white)
        
    
    }
}

struct GameSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        GameSelectionView()
            .environmentObject(AppModel())
    }
}
