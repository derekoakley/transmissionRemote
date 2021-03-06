//
//  updateTransmissionSessionId.swift
//  transmitRemote
//
//  Created by Derek Oakley on 18/08/2018.
//  Copyright © 2018 Derek Oakley. All rights reserved.
//

import AppKit

func GetTransmissionSessionId(completion: @escaping (Bool) -> ()) {
    let endpoint = "http://192.168.1.11:9092/transmission/rpc"
    let endpointUrl = URL(string: endpoint)!
    
    var request = URLRequest(url: endpointUrl)
    request.httpMethod = "POST"
    
    let transmissionSessionId = UserDefaults.standard.string(forKey: "transmissionSessionId")  ?? ""
    request.addValue(transmissionSessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
    
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let httpResponse = response as? HTTPURLResponse {
            if (httpResponse.statusCode == 409) {
                UserDefaults.standard.set(httpResponse.allHeaderFields[AnyHashable("X-Transmission-Session-Id")] as! String, forKey: "transmissionSessionId")
                completion(true)
            }
            if (httpResponse.statusCode == 200) {
                completion(true)
            }
        }
    }.resume()
}
