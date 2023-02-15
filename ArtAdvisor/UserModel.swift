import Foundation

struct UserData: Codable {
    var artworksForUser: ArtworksConnection
    var me: MeData
    var notificationsConnection: NotificationsConnection
}

struct ArtworksConnection: Codable {
    var edges: [ArtworkEdge]
}

struct ArtworkEdge: Codable {
    var node: Artwork
}

struct Artwork: Codable, Identifiable {
    var id: String
    var title: String
}

struct MeData: Codable {
    var email: String
    var name: String
}

struct NotificationsConnection: Codable {
    var edges: [NotificationEdge]
}

struct NotificationEdge: Codable {
    var node: ArtsyNotification
}

struct ArtsyNotification: Codable, Identifiable {
    var id: String
    var message: String
    var title: String
}

struct User {
    let userData: UserData
    
    var email: String {
        return userData.me.email
    }
    
    var name: String {
        return userData.me.name
    }
    
    var artworks: [Artwork] {
        let edges = userData.artworksForUser.edges
        let artworkses = edges.map(\.node)
        return artworkses
    }
    
    var notifications: [ArtsyNotification] {
        let edges = userData.notificationsConnection.edges
        let notificationses = edges.map(\.node)
        return notificationses
    }
    
    init(userData: UserData) {
        self.userData = userData
    }
    
    static func makeFake() -> User {
        let fakeMeData = MeData(
            email: "fake@example.com",
            name: "Fake Person"
        )
        
        let fakeArtworksConnection = ArtworksConnection(edges: [])
        let fakeNotificationsConnection = NotificationsConnection(edges: [])
        
        let fakeUserData = UserData(
            artworksForUser: fakeArtworksConnection,
            me: fakeMeData,
            notificationsConnection: fakeNotificationsConnection
        )
        
        return User(userData: fakeUserData)
    }
    
    static func load() async -> User? {
        guard
            let userData = await MetaphysicsClient.loadUserData()
        else {
            return nil
        }
                
        return User(userData: userData)
    }
    
    static func read() -> User? {
        guard
            let userData = MetaphysicsClient.readUserData()
        else {
            return nil
        }
                
        return User(userData: userData)
    }
}
