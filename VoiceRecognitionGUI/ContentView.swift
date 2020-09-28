//
//  ContentView.swift
//  VoiceRecognitionGUI
//
//  Created by Dawid Walenciak on 28/09/2020.
//  Copyright © 2020 Dawid Walenciak. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack() {
            Text("Voice Recognition GUI")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            VStack {
                Text("TODO section")
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
