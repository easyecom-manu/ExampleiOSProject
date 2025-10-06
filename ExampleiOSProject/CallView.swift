//
//  CallView.swift
//  ExampleiOSProject
//
//  Created by Manu Mathew on 06/10/25.
//

import SwiftUI
import VudioLiveCalliOS

struct CallView: View {
    @State private var showMessages = false
    @State private var messages: [String] = []
    @State private var newMessage = ""

    var body: some View {
        ZStack {
            RemoteVideoView()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    LocalVideoView()
                        .frame(width: 120, height: 160)
                        .cornerRadius(12)
                        .padding()
                }
                Spacer()
                
                HStack(spacing: 24) {
                    Button(action: { VudioLiveCall.muteMicrophone(mute: true) }) {
                        Label("Mute", systemImage: "mic.slash.fill")
                    }
                    Button(action: { VudioLiveCall.enableCamera(enable: false) }) {
                        Label("Camera", systemImage: "video.slash.fill")
                    }
                    Button(action: { VudioLiveCall.useBackCamera(enable: true) }) {
                        Label("Flip", systemImage: "arrow.triangle.2.circlepath.camera")
                    }
                    Button(action: { showMessages.toggle() }) {
                        Label("Chat", systemImage: "message.fill")
                    }
                    Button(role: .destructive, action: { VudioLiveCall.endCall() }) {
                        Label("End", systemImage: "phone.down.fill")
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.bottom)
            }
        }
        .sheet(isPresented: $showMessages) {
            MessageSheetView(messages: $messages, newMessage: $newMessage)
        }
        .onAppear {
            VudioLiveCall.joinCall(
                selfView: LocalVideoView.shared,
                remoteView: RemoteVideoView.shared,
                callback: self
            )
        }
    }
}

extension CallView: CallInteractionCallback {
    func onReceivingMessage(message: Message) {
        messages.append(message.message ?? "Message")
    }
    func onRemoteMicUpdate(muted: Bool) { print("Remote mic: \(muted)") }
    func onRemoteCameraUpdate(enabled: Bool) { print("Remote cam: \(enabled)") }
    func onCallEnded() { print("Call ended") }
    func onPermissionError(message: String) { print("Permission error: \(message)") }
}

// Wrappers for UIKit Views
struct RemoteVideoView: UIViewRepresentable {
    static let shared = UIView()
    func makeUIView(context: Context) -> UIView { RemoteVideoView.shared }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct LocalVideoView: UIViewRepresentable {
    static let shared = UIView()
    func makeUIView(context: Context) -> UIView { LocalVideoView.shared }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
