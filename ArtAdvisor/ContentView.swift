import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var greeting = "loading..."
    @State private var password: String = ""
    @State private var email: String = ""
    
    @State var currentUser: User
    
    var body: some View {
        VStack {
            Text(greeting).font(.system(size: 36)).lineLimit(1)
            TextField("Email", text: $email)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
            Button(action: updateKeychain) {
                Text("Sign In")
            }
            ForEach(currentUser.artworks) { artwork in
                Text(artwork.title).lineLimit(1)
            }
        }
        .padding()
        .onAppear(perform: updateGreeting)
    }
    
    func updateGreeting() {
        Task {
            User.getAuthDataInKeychain()
            let user = await User.makeMeQuery()
            currentUser = user
            greeting = user.name
        }
    }
    
    func updateKeychain() {
        User.setAuthDataInKeychain(email: email, password: password)
        updateGreeting()
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(currentUser: User.makeFake())
    }
}
