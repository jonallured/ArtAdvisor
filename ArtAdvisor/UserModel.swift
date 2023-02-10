import Foundation

struct Payload: Codable {
    var query: String
}

struct MpData: Codable {
    var data: MeData
}

struct MeData: Codable {
    var me: Me
    var artworksForUser: ArtworkConnection
}

struct ArtworkConnection: Codable {
    var edges: [ArtworkEdge]
}

struct ArtworkEdge: Codable {
    var node: Artwork
}

struct Artwork: Codable, Identifiable {
    var id: String
    var title: String
}

struct Me: Codable {
    var name: String
    
}

struct AuthData: Codable {
    var accessToken: String
}

struct User {
    static let suiteName = "group.ArtAdvisor"
    static let defaultsKey = "authData"
    
    let query: MpData
    
    var name: String {
        return query.data.me.name
    }
    
    var artworks: [Artwork] {
        let edges = query.data.artworksForUser.edges
        let artworkses = edges.map(\.node)
        return artworkses
    }
    
    init(query: MpData) {
        self.query = query
    }
    
    static func makeFake() -> User {
        let fakeMe = Me(name: "fake")
        let fakeConnection = ArtworkConnection(edges: [])
        let fakeData = MeData(me: fakeMe, artworksForUser: fakeConnection)
        let fakeQuery = MpData(data: fakeData)
        return User(query: fakeQuery)
    }
    
    static func makeMeQuery() async -> User {
        let rawAuthData = UserDefaults(suiteName: User.suiteName)!.object(forKey: User.defaultsKey) as! Data
        let decodedAuthData = try! JSONDecoder().decode(AuthData.self, from: rawAuthData)
        let mpUrl = "https://metaphysics-staging.artsy.net/v2"
        var request = URLRequest(url: URL(string: mpUrl)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(decodedAuthData.accessToken, forHTTPHeaderField: "X-Access-Token")
        
        let query = """
            query {
              me {
                name
              }
        
              artworksForUser(first: 10, includeBackfill: true) {
                edges {
                  node {
                    title
                    id
                  }
                }
              }
            }
        """
        
        let payload = Payload(query: query)
        request.httpBody = try? JSONEncoder().encode(payload)
                
        guard
            let (data, _) = try? await URLSession.shared.data(for: request),
            let query = try? JSONDecoder().decode(MpData.self, from: data)
        else { return User.makeFake() }
        
        return User(query: query)
    }
    
    static func setAuthData(accessToken: String) {
        let authData = AuthData(accessToken: accessToken)
        let encodedAuthData = try? JSONEncoder().encode(authData)
        
        UserDefaults(suiteName: suiteName)!.set(encodedAuthData, forKey: defaultsKey)
    }
}
