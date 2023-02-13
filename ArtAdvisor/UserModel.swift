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
    var email: String
}

struct AuthData: Codable {
    var accessToken: String
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
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
        let fakeMe = Me(name: "fake", email: "fake@example.com")
        let fakeConnection = ArtworkConnection(edges: [])
        let fakeData = MeData(me: fakeMe, artworksForUser: fakeConnection)
        let fakeQuery = MpData(data: fakeData)
        return User(query: fakeQuery)
    }
    
    static func makeMeQuery() async -> User {
        guard
            let rawAuthData = UserDefaults(suiteName: User.suiteName)?.object(forKey: User.defaultsKey) as? Data
        else { return User.makeFake() }
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
    
    static func setAuthDataInKeychain(accessToken: String, email: String) {
        let account = email
        let password = accessToken.data(using: .utf8)!
        let server = "https://staging.artsy.net" // maybe this should be an MP url instead?
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: account,
            kSecAttrServer as String: server,
            kSecValueData as String: password,
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            let errorDescription = SecCopyErrorMessageString(status, nil) as? String
            print("SecItemAdd status")
            print(errorDescription)
            return
        }
        
        print(status)
    }
    
    static func getAuthDataInKeychain() {
        let server = "https://staging.artsy.net" // maybe this should be an MP url instead?
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            print(KeychainError.noPassword)
            return
        }
        guard status == errSecSuccess else {
            print(KeychainError.unhandledError(status: status))
            return
        }
        
        print(status)
        print(item)
        
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: .utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
        else {
            print(KeychainError.unexpectedPasswordData)
            return
        }
        
        print(password, account)
    }
}
