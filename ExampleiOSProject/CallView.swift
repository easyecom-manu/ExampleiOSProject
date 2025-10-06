import SwiftUI
import VudioLiveCalliOS

struct CallView: View {
    @Environment(\.dismiss) var dismiss

    @State private var showMessages = false
    @State private var messages: [String] = []
    @State private var newMessage = ""

    @State private var isMicMuted = false
    @State private var isCameraEnabled = true
    @State private var isBackCamera = false

    // Remote user states
    @State private var remoteMicMuted = false
    @State private var remoteCameraEnabled = true

    var body: some View {
        ZStack {
            RemoteVideoView()
                .edgesIgnoringSafeArea(.all)
            
            // Remote mic/camera indicators
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        if !remoteCameraEnabled {
                            Image(systemName: "video.slash.fill")
                                .foregroundColor(.red)
                                .padding(6)
                                .background(Circle().fill(.white.opacity(0.7)))
                        }
                        if remoteMicMuted {
                            Image(systemName: "mic.slash.fill")
                                .foregroundColor(.red)
                                .padding(6)
                                .background(Circle().fill(.white.opacity(0.7)))
                        }
                    }
                    .padding()
                }
                Spacer()
            }
            
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
                    // Mic Button
                    Button(action: {
                        isMicMuted.toggle()
                        VudioLiveCall.muteMicrophone(mute: isMicMuted)
                    }) {
                        Image(systemName: isMicMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.title2)
                            .padding()
                            .background(Circle().fill(.white.opacity(isMicMuted ? 0.8 : 0.3)))
                            .foregroundColor(isMicMuted ? .red : .white)
                    }
                    
                    // Camera Button
                    Button(action: {
                        isCameraEnabled.toggle()
                        VudioLiveCall.enableCamera(enable: isCameraEnabled)
                    }) {
                        Image(systemName: isCameraEnabled ? "video.fill" : "video.slash.fill")
                            .font(.title2)
                            .padding()
                            .background(Circle().fill(.white.opacity(isCameraEnabled ? 0.3 : 0.8)))
                            .foregroundColor(isCameraEnabled ? .white : .red)
                    }
                    
                    // Flip Camera
                    Button(action: {
                        isBackCamera.toggle()
                        VudioLiveCall.useBackCamera(enable: isBackCamera)
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title2)
                            .padding()
                            .background(Circle().fill(.white.opacity(0.3)))
                            .foregroundColor(.white)
                    }
                    
                    // Chat Button
                    Button(action: { showMessages.toggle() }) {
                        Image(systemName: "message.fill")
                            .font(.title2)
                            .padding()
                            .background(Circle().fill(.white.opacity(0.3)))
                            .foregroundColor(.white)
                    }
                    
                    // End Call
                    Button(action: { endCallAndDismiss() }) {
                        Image(systemName: "phone.down.fill")
                            .font(.title2)
                            .padding()
                            .background(Circle().fill(Color.red))
                            .foregroundColor(.white)
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

    private func endCallAndDismiss() {
        VudioLiveCall.endCall()
        dismiss()
    }
}

extension CallView: CallInteractionCallback {
    func onReceivingMessage(message: Message) {
        messages.append(message.message ?? "Message")
    }
    
    func onRemoteMicUpdate(muted: Bool) {
        remoteMicMuted = muted
    }
    
    func onRemoteCameraUpdate(enabled: Bool) {
        remoteCameraEnabled = enabled
    }
    
    func onCallEnded() {
        endCallAndDismiss()
    }
    
    func onPermissionError(message: String) {
        print("Permission error: \(message)")
    }
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
