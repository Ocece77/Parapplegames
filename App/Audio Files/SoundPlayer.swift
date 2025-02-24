import AVFoundation

class SoundPlayer: ObservableObject {
    var beepPlayer: AVAudioPlayer?
    
    init() {
        initBeep()
    }
    
    /// 📌 Fonction pour initialiser le son
    func initBeep() {
        guard let sourceDir = URL.soundDirectory else {
            print("❌ Erreur : Impossible de trouver le dossier Sources.")
            return
        }
        
        let soundURL = sourceDir.appendingPathComponent("sound.mp3") // 🔥 Remplace par le bon nom
        
        guard soundURL.fileExists else {
            print("❌ Erreur : Fichier son introuvable à l’emplacement \(soundURL.path)")
            return
        }
        
        do {
            beepPlayer = try AVAudioPlayer(contentsOf: soundURL)
            beepPlayer?.prepareToPlay()
        } catch {
            print("❌ Erreur : Impossible de charger le fichier son - \(error.localizedDescription)")
        }
    }
    
    /// 📌 Fonction pour jouer le son
    func playBeepSound() {
        beepPlayer?.play()
    }
    
    /// 📌 Action sur bouton pour jouer le son
    @IBAction func btnPlayBeepSound(sender: AnyObject) {
        playBeepSound()
    }
}
