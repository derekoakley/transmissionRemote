//
//  Torrent.swift
//  transmitRemote
//
//  Created by Derek Oakley on 18/08/2018.
//  Copyright © 2018 Derek Oakley. All rights reserved.
//

struct SessionStats: Decodable {
    let arguments: SessionStatsArgument
    let result: String
}

struct SessionStatsArgument: Decodable {
    let activeTorrentCount: Int
    let downloadSpeed: Int
    let pausedTorrentCount: Int
    let torrentCount: Int
    let uploadSpeed: Int
}
