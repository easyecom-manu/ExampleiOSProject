//
//  MessageSheetView.swift
//  ExampleiOSProject
//
//  Created by Manu Mathew on 06/10/25.
//

import SwiftUI
import VudioLiveCalliOS

struct MessageSheetView: View {
    @Binding var messages: [String]
    @Binding var newMessage: String

    var body: some View {
        VStack {
            List(messages, id: \.self) { msg in
                Text(msg)
            }

            HStack {
                TextField("Enter message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    VudioLiveCall.sendMessage(message: newMessage)
                    messages.append("You: \(newMessage)")
                    newMessage = ""
                }
            }
            .padding()
        }
        .presentationDetents([.medium, .large])
    }
}
