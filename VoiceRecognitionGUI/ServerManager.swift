//
//  ServerManager.swift
//  VoiceRecognitionGUI
//
//  Created by Dawid Walenciak on 08/10/2020.
//  Copyright © 2020 Dawid Walenciak. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct ServerMessage : Decodable {
    let probability: Int
    let name: String
}

class ServerManager : ObservableObject {
    
    static private var SERVER_HOST = "localhost"
    static private var SERVER_PORT = "8081"
    
    func callServerWithAudioFile(filePath: URL, completion: @escaping (ServerMessage)->()) {
        guard let url = URL(string: "http://" + ServerManager.SERVER_HOST + ":" + ServerManager.SERVER_PORT + "/vc/check") else { completion(ServerMessage(probability: 0, name: ""));
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? Data(contentsOf: filePath)
        request.setValue("audio/wav", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil, let data = data, let response = response as? HTTPURLResponse {
                
                if response.statusCode != 200 {
                    print("Error! Status code: ", response.statusCode)
                }
                else if !data.isEmpty {
                    let resData = try! JSONDecoder().decode(ServerMessage.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(ServerMessage(probability: resData.probability, name: resData.name))
                    }
                }
                else {
                    print("Error! response is empty")
                }
            }
        }
        
        task.resume()
        completion(ServerMessage(probability: 0, name: ""))
    }
}
