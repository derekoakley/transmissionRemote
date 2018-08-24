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

struct Torrent: Decodable, Hashable {
    let id: Int
    let isFinished: Bool
    let name: String
    let percentDone: Double
    let totalSize: Int
}
