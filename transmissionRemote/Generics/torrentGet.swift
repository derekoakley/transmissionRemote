//
//  torrentGet.swift
//  transmitRemote
//
//  Created by Derek Oakley on 18/08/2018.
//  Copyright © 2018 Derek Oakley. All rights reserved.
//

import AppKit

func torrentGet(completion: @escaping ([Torrent]) -> ()) {
    let endpoint = "http://192.168.1.11:9092/transmission/rpc"
    let endpointUrl = URL(string: endpoint)!
    
    var request = URLRequest(url: endpointUrl)
    request.httpMethod = "POST"
    request.httpBody = """
        {
            "arguments": {
                "fields": [
                    "id",
                    "isFinished",
                    "files",
                    "name",
                    "percentDone",
                    "totalSize"
                ]
            },
            "method": "torrent-get"
        }
        """.data(using: .utf8)
    
    let transmissionSessionId = UserDefaults.standard.string(forKey: "transmissionSessionId")  ?? ""
    request.addValue(transmissionSessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
    
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let httpResponse = response as? HTTPURLResponse {
            if (httpResponse.statusCode == 200) {
                do {
                    let result = try JSONDecoder().decode(TorrentGet.self, from: data!)
                    completion(result.arguments.torrents)
                } catch {
                    print(error)
                    completion([])
                }
            }
        }
    }.resume()
}
