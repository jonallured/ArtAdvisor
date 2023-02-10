import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var greeting = "loading..."
    @State private var accessToken: String = ""
    
    @State var currentUser: User
    
    var body: some View {
        VStack {
            Text(greeting).font(.system(size: 36)).lineLimit(1)
            SecureField("Access Token", text: $accessToken)
                .onSubmit(updateToken)
            ForEach(currentUser.artworks) { artwork in
                Text(artwork.title).lineLimit(1)
            }
        }
        .padding()
        .onAppear(perform: updateGreeting)
    }
    
    func updateGreeting() {
        Task {
            let user = await User.makeMeQuery()
            currentUser = user
            greeting = user.name
        }
    }
    
    func updateToken() {
        User.setAuthData(accessToken: accessToken)
        updateGreeting()
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(currentUser: User.makeFake())
    }
}
