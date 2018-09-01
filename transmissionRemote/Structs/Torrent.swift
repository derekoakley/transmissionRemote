//
//  Torrent.swift
//  transmitRemote
//
//  Created by Derek Oakley on 18/08/2018.
//  Copyright © 2018 Derek Oakley. All rights reserved.
//

struct TorrentGet: Decodable {
    let arguments: TorrentGetArgument
    let result: String
}

struct TorrentGetArgument: Decodable {
    let torrents: [Torrent]
}

struct Torrent: Decodable {
    let id: Int
    let isFinished: Bool
    let name: String
    let files: [Files]
    let percentDone: Double
    let totalSize: Int
}

struct Files: Decodable {
    let bytesCompleted: Int
    let length: Int
    let name: String
}
