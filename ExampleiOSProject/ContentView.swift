//
//  ContentView.swift
//  ExampleiOSProject
//
//  Created by Manu Mathew on 03/10/25.
//

import SwiftUI
import VudioLiveCalliOS

struct ContentView: View {
    @State private var isLoading = true
    @State private var countryCodes: Any?
    @State private var timeSlots: Any?
    @State private var navigateToCall = false
    @State private var callPayload: [String: Any] = [:]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if isLoading {
                    ProgressView("Fetching configuration...")
                        .task {
                            await fetchData()
                        }
                } else {
                    Text("Country Codes: \(String(describing: countryCodes))")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("Time Slots: \(String(describing: timeSlots))")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Make Instant Call") {
                        Task { await makeInstantCall() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                
                NavigationLink("", destination: CallView(), isActive: $navigateToCall)
            }
            .padding()
            .navigationTitle("Vudio Live Call Demo")
        }
    }
    
    func fetchData() async {
        VudioLiveCall.setBrandId(brandId: "1c451a4868")
        VudioLiveCall.setProductURL(product: "https://example.com/product")

        async let codes = VudioLiveCall.getCountryCodes()
        async let slots = VudioLiveCall.getTimeSlots()
        
        switch await codes {
        case .success(let result): countryCodes = result
        case .failure(let error): print("Country code error: \(error)")
        }
        
        switch await slots {
        case .success(let result): timeSlots = result
        case .failure(let error): print("Time slots error: \(error)")
        }
        
        isLoading = false
    }
    
    func makeInstantCall() async {
        let payload: [String: Any] = [
            "name": "John Doe",
            "mobile_no": "9876543210",
            "scheduled_time": ISO8601DateFormatter().string(from: Date().addingTimeInterval(120)),
            "is_whatsapp_subscribed": false,
            "ext": "+91",
            "customer_timezone": "Asia/Calcutta"
        ]
        
        await VudioLiveCall.makeInstantCall(payload: payload, callSessionEvent: self)
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
