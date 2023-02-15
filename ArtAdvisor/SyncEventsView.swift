import SwiftUI

struct SyncEvent {
    let state: String
}

class SyncEventStore {
    var syncEvents: [SyncEvent] = []
    
    static let shared = SyncEventStore()
    
    static func trigger() {
        let syncEvent = SyncEvent(state: "Created")
        shared.syncEvents.append(syncEvent)
    }
}

struct SyncEventsView: View {
    var body: some View {
        VStack() {
            Text("Sync Events")
            Button("Trigger Sync", action: handleTriggerSyncPress)
        }
    }
    
    func handleTriggerSyncPress() {
        SyncEventStore.trigger()
    }
}

struct SyncEventsView_Previews: PreviewProvider {
    static var previews: some View {
        SyncEventsView()
    }
}
