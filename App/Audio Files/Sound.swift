import Foundation

typealias Sound = String

extension String {
    var urlSound: URL? {
        var resourceURL = Bundle.main.url(forResource: self, withExtension: "mp3")
        
#if DEBUG
        if resourceURL == nil {
            for framework in Bundle.allFrameworks {
                resourceURL = framework.url(forResource: self, withExtension: "mp3")
                
                if resourceURL != nil {
                    break
                }
            }
        }
#endif
        return resourceURL
    }
}
