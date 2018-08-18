//
//  Torrent.swift
//  transmitRemote
//
//  Created by Derek Oakley on 18/08/2018.
//  Copyright © 2018 Derek Oakley. All rights reserved.
//

struct Root: Decodable {
    let arguments: Argument
    let result: String
}

struct Argument: Decodable {
    let torrents: [Torrent]
}

struct Torrent: Decodable {
    let id: Int
    let name: String
    let totalSize: Int
    let percentDone: Double
}
