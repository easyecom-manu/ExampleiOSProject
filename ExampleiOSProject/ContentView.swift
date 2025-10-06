import SwiftUI
import VudioLiveCalliOS

struct ContentView: View {
    @State private var navigateToCall = false
    @State private var callPayload: [String: Any] = [:]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Button("Make Instant Call") {
                    Task { await makeInstantCall() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                
                Button("Schedule Call") {
                    Task { await scheduleCall() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                NavigationLink("", destination: CallView(), isActive: $navigateToCall)
            }
            .padding()
            .navigationTitle("Vudio Live Call Demo")
            .task {
                await fetchData()
            }
        }
    }
    
    func fetchData() async {
        VudioLiveCall.setBrandId(brandId: "1c451a4868")
        VudioLiveCall.setProductURL(product: "https://example.com/product")

        // Fetch country codes
        switch await VudioLiveCall.getCountryCodes() {
        case .success(let result): print("Country Codes: \(result)")
        case .failure(let error): print("Country code error: \(error)")
        }

        // Fetch time slots
        switch await VudioLiveCall.getTimeSlots() {
        case .success(let result): print("Time Slots: \(result)")
        case .failure(let error): print("Time slots error: \(error)")
        }
    }
    
    func makeInstantCall() async {
        let payload: [String: Any] = [
            "name": "John Doe",
            "mobile_no": "9876543210",
            "is_whatsapp_subscribed": false,
            "ext": "+91",
            "customer_timezone": "Asia/Calcutta"
        ]
        
        await VudioLiveCall.makeInstantCall(payload: payload, callSessionEvent: self)
    }
    
    func scheduleCall() async {
        let payload: [String: Any] = [
            "name": "John Doe",
            "mobile_no": "9876543210",
            "scheduled_time": ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600)), // 1 hour later
            "is_whatsapp_subscribed": false,
            "ext": "+91",
            "customer_timezone": "Asia/Calcutta"
        ]
        
        let result = await VudioLiveCall.scheduleCall(payload: payload)
        switch result {
        case .success(let data):
            print("Scheduled call successfully: \(data)")
        case .failure(let error):
            print("Error scheduling call: \(error)")
        }
    }
}

extension ContentView: CallSessionCallback {
    func onRoomReady(message: String) {
        print("Room ready: \(message)")
        navigateToCall = true
    }
    
    func onAgentNotAvailable(message: String) { print(message) }
    func onAgentDeclined(message: String) { print(message) }
    func onConnectingToAgent(message: String) { print(message) }
    func onAgentAssigned(message: String) { print(message) }
    func onCallWaitingTimeout(message: String) { print(message) }
    func onCallCancelledByUser(message: String) { print(message) }
    func onError(message: String) { print(message) }
}
