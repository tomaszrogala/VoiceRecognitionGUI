//
//  ContentView.swift
//  VoiceRecognitionGUI
//
//  Created by Dawid Walenciak on 28/09/2020.
//  Copyright © 2020 Dawid Walenciak. All rights reserved.
//

import SwiftUI
import AVKit

struct ContentView: View {
    var body: some View {
        AppView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AppView: View {
    
    @ObservedObject var audioManager = AudioManager()
    @ObservedObject var serverManager = ServerManager()
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @State var intialState = true
    @State var recordingState = false
    @State var alertState = false
    @State var playingState = false
    
    @State var statusText = "Ready"
    @State var resultText = ""
    
    var body: some View {

        NavigationView {

            VStack {
                Text("Status: ").padding(.top, 30)
                Text(self.statusText)
                Text(self.resultText)
                Spacer()
                HStack {
                    Button(action: {
                        self.statusText = "Checking..."

                        self.serverManager.callServerWithAudioFile(filePath: self.audioManager.audioFileUrl) {
                            serverMessage in
                            
                            self.statusText = "Checked."
                            if serverMessage.probability >= 50 {
                                self.resultText = "Voice known. Probability: " + String(serverMessage.probability) + "%. Hello " + serverMessage.name + "!"
                            }
                            else {
                                self.resultText = "Voice unknown. Probability: " + String(serverMessage.probability) + "%."
                            }
                        }
                        
                    }) {
                        ZStack{
                            Text("Verify")
                                .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                                .background(
                                Circle()
                                .fill(Color.green)
                                .frame(width: 60, height: 60)
                            )
                        }
                    }.padding(.trailing, 30.0).disabled(self.intialState || self.recordingState)
                    Button(action: {
                        self.intialState = false
                        
                        if(self.recordingState) {
                            self.audioManager.stopRecordingAudioClip()
                            self.recordingState.toggle()
                            self.statusText = "Recorded!"
                        }
                        else {
                            
                            self.audioManager.startRecordingAudioClip()

                            self.recordingState.toggle()
                            
                            self.statusText = "Recording..."
                            self.resultText = ""
                        }
                        
                    }) {
                        ZStack{
                            Circle()
                                .fill(Color.red)
                                .frame(width: 80, height: 80)
                            
                            if self.recordingState {
                                Circle()
                                    .fill(self.colorScheme == .dark ? Color.white : Color.black)
                                    .frame(width: 65, height: 65)
                            }
                        }
                    }
                    Button(action: {
                        self.audioManager.playAudioClip()
                    }) {
                        ZStack{
                            Text("Listen")
                                .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                                .background(
                                Circle()
                                .fill(Color.yellow)
                                .frame(width: 60, height: 60)
                            )
                            
                        }
                    }.padding(.leading, 30.0).disabled(self.intialState || self.recordingState)
                }.padding(.bottom, 50)
                
            }.navigationBarTitle("Voice Recognition GUI")
        }
        .alert(isPresented: $alertState, content: {
            Alert(title: Text("Error"), message: Text("Microfon access not granted, cannot proceed"))
        })
        .onAppear() {
            self.alertState = self.audioManager.initializeSession()
        }
    }
    
}
