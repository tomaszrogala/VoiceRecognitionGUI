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

extension Data {
    mutating func append<T>(values: [T]) -> Bool {
        var newData = Data()
        var status = true
 
        if T.self == String.self {
            for value in values {
                guard let convertedString = (value as! String).data(using: .utf8) else { status = false; break }
                newData.append(convertedString)
            }
        } else if T.self == Data.self {
            for value in values {
                newData.append(value as! Data)
            }
        } else {
            status = false
        }
 
        if status {
            self.append(newData)
        }
 
        return status
    }
}

struct RestEntity {
    private var values: [String: String] = [:]
    
       mutating func add(value: String, forKey key: String) {
           values[key] = value
       }
    
       func value(forKey key: String) -> String? {
           return values[key]
       }
    
       func allValues() -> [String: String] {
           return values
       }
    
       func totalItems() -> Int {
           return values.count
       }
}

struct ServerMessage : Decodable {
    let status: Bool
    let name: String
}

class ServerManager : ObservableObject {
    
    static private var SERVER_HOST = "localhost"
    static private var SERVER_PORT = "8081"
    
    //@Published var voiceStatus = false
    //@Published var voiceName = ""
    

    var requestHttpHeaders = RestEntity()
    var urlQueryParameters = RestEntity()
    var httpBodyParameters = RestEntity()
    
    func callServerWithAudioFile(filePath: URL, completion: @escaping (ServerMessage)->()) {
        guard let url = URL(string: "http://" + ServerManager.SERVER_HOST + ":" + ServerManager.SERVER_PORT + "/vc/check") else { completion(ServerMessage(status: false, name: "")); return }
        
        guard let boundary = self.createBoundary() else { print("Error! Cannot create boundary for request.");  completion(ServerMessage(status: false, name: "")); return }
        self.requestHttpHeaders.add(value: "multipart/form-data; boundary=\(boundary)", forKey: "Content-Type")
        
        var body = self.getHttpBody(withBoundary: boundary)
        
        self.addAudioFile(fileUrl: filePath, filename: filePath.lastPathComponent, toBody: &body, withBoundary: boundary)
               
        self.close(body: &body, usingBoundary: boundary)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("audio/mp4", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil, let data = data, let response = response as? HTTPURLResponse {
                
                if response.statusCode != 200 {
                    print("Error! Status code: ", response.statusCode)
                }
                else if !data.isEmpty {
                    let resData = try! JSONDecoder().decode(ServerMessage.self, from: data)
                    
                    DispatchQueue.main.async {
                        //self.voiceStatus = resData.status
                        //self.voiceName = resData.name
                        completion(ServerMessage(status: resData.status, name: resData.name))
                    }
                }
                else {
                    print("Error! response is empty")
                }
            }
        }
        
        task.resume()
        completion(ServerMessage(status: false, name: ""))
    }
    
    private func getHttpBody(withBoundary boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in httpBodyParameters.allValues() {
            let values = ["--\(boundary)\r\n",
            "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n",
            "\(value)\r\n"]
            
            _ = body.append(values: values)
        }
        
        return body
    }
    
    private func addAudioFile(fileUrl: URL, filename: String, toBody body: inout Data, withBoundary boundary: String) {
        
        let content = try? Data(contentsOf: fileUrl)
        let mimetype = "audio/mp4"
        let name = (filename as NSString).deletingPathExtension
        
        var data = Data()
           
        let formattedFileInfo = ["--\(boundary)\r\n",
                      "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n",
                      "Content-Type: \(mimetype)\r\n\r\n"]
           
        if data.append(values: formattedFileInfo) {
            if data.append(values: [content]) {
                if data.append(values: ["\r\n"]) {
                    body.append(data)
                }
            }
        }
    }
    
    private func close(body: inout Data, usingBoundary boundary: String) {
        _ = body.append(values: ["\r\n--\(boundary)--\r\n"])
    }
    
    private func createBoundary() -> String? {
        let lowerCaseLettersInASCII = UInt8(ascii: "a")...UInt8(ascii: "z")
        let upperCaseLettersInASCII = UInt8(ascii: "A")...UInt8(ascii: "Z")
        let digitsInASCII = UInt8(ascii: "0")...UInt8(ascii: "9")
     
        let sequenceOfRanges = [lowerCaseLettersInASCII, upperCaseLettersInASCII, digitsInASCII].joined()
        guard let toString = String(data: Data(sequenceOfRanges), encoding: .utf8) else { return nil }
     
        var randomString = ""
        for _ in 0..<20 { randomString += String(toString.randomElement()!) }
     
        let boundary = String(repeating: "-", count: 20) + randomString + "\(Int(Date.timeIntervalSinceReferenceDate))"
     
        return boundary
    }
}
