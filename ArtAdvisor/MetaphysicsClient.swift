import Foundation

struct Payload: Codable {
    var query: String
}

struct ResponseData: Codable {
    var data: UserData
}

struct MetaphysicsClient {
    static var baseUrl = "https://metaphysics-production.artsy.net/v2"
    
    static func loadUserData() async -> UserData? {
        guard
            let accessToken = KeychainStore.getAccessToken()
        else {
            return nil
        }
        
        var request = URLRequest(url: URL(string: baseUrl)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.addValue(accessToken, forHTTPHeaderField: "X-Access-Token")
        
        let query = """
            query {
              me {
                name
                email
              }
        
              artworksForUser(first: 10, includeBackfill: true) {
                edges {
                  node {
                    title
                    id
                  }
                }
              }
              
              notificationsConnection(first:10) {
                edges {
                  node {
                    notificationType
                      id
                      message
                      title
                  }
                }
              }
            }
        """
        
        let payload = Payload(query: query)
        request.httpBody = try? JSONEncoder().encode(payload)
                
        guard
            let (data, _) = try? await URLSession.shared.data(for: request),
            let decodedData = try? JSONDecoder().decode(ResponseData.self, from: data)
        else {
            return nil
        }
        
        write(data: data)
        
        return decodedData.data
    }
    
    static func write(data: Data) {
        let group = "group.ArtAdvisor"
                
        guard
            let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)
        else {
            print("didn't work")
            return
        }
        
        let file = url.appendingPathComponent("userData.json")
        
        do {
            try data.write(to: file)
        } catch {
            print("throw!")
        }
    }
    
    static func readUserData() -> UserData? {
        let group = "group.ArtAdvisor"
                
        guard
            let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)
        else {
            print("didn't work")
            return nil
        }
        
        let file = url.appendingPathComponent("userData.json")
                
        guard
            let data = try? Data(contentsOf: file, options: .mappedIfSafe),
            let decodedData = try? JSONDecoder().decode(ResponseData.self, from: data)
        else {
            return nil
        }
        
        return decodedData.data
    }
}

