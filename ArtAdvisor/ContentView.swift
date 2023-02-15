import SwiftUI
import WidgetKit

struct ArtworkList: View {
    let artworks: [Artwork]
    
    var body: some View {
        VStack(alignment: .leading) {
            Divider()
            ForEach(artworks) { artwork in
                Text(artwork.title)
            }
        }
    }
}

struct NotificationList: View {
    let notifications: [ArtsyNotification]
    
    var body: some View {
        VStack(alignment: .leading) {
            Divider()
            ForEach(notifications) { notification in
                Text("\(notification.title): \(notification.message)")
            }
            Divider()
        }
    }
}

struct ContentView: View {
    @State private var accessToken: String = ""
    @State private var userEmail: String = ""
    
    @State var currentUser: User {
        didSet {
            userEmail = currentUser.email
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(
                "Email",
                text: $userEmail
            )
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
            
            SecureField(
                "Token",
                text: $accessToken
            )
            
            Button(
                "Set Token",
                action: handleSetTokenPress
            )
            
            Divider()
            
            Text(
                "name: \(currentUser.name)"
            )
            .lineLimit(1)
            
            Text(
                "email: \(currentUser.email)"
            )
            .lineLimit(1)
            
            ArtworkList(artworks: currentUser.artworks)
            
            NotificationList(notifications: currentUser.notifications)
            
            Button(
                "Reload Timeline",
                action: handleReloadTimelinePress
            )
            
            Spacer()
        }
        .padding()
        .onAppear(perform: handleOnAppear)
    }
    
    func handleOnAppear() {
        setCurrentUser()
    }
    
    func handleSetTokenPress() {
        KeychainStore.setAccessToken(accessToken, email: userEmail)
        setCurrentUser()
    }
    
    func handleReloadTimelinePress() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func setCurrentUser() {
        Task {
            let user = await User.load() ?? User.makeFake()
            currentUser = user
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(currentUser: User.makeFake())
    }
}
