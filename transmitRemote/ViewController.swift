//
//  ViewController.swift
//  transmitRemote
//
//  Created by Derek Oakley on 18/08/2018.
//  Copyright © 2018 Derek Oakley. All rights reserved.
//

import Cocoa

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
}

class ViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var Torrents: [Torrent] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let aem = NSAppleEventManager.shared();
        aem.setEventHandler(self, andSelector: #selector(handleGetURLEvent(event:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        updateTransmissionSessionId() { result in
            self.torrentGet() { result in
                if (result.count > 0)
                {
                    self.Torrents = result
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func updateTransmissionSessionId(completion: @escaping (Bool) -> ()) {
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
    
    private func torrentGet(completion: @escaping ([Torrent]) -> ()) {
        let endpoint = "http://192.168.1.11:9092/transmission/rpc"
        let endpointUrl = URL(string: endpoint)!
        
        var request = URLRequest(url: endpointUrl)
        request.httpMethod = "POST"
        request.httpBody = """
        {
            "arguments": {
                "fields": [
                    "id",
                    "name",
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
                        let result = try JSONDecoder().decode(Root.self, from: data!)
                        completion(result.arguments.torrents)
                    } catch {
                        print(error)
                        completion([])
                    }
                }
            }
        }.resume()
    }
    
    @objc private func handleGetURLEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue!
        updateTransmissionSessionId() { result in
            self.torrentAdd(filename: urlString!) { result in
                if (result == true) {
                    self.torrentGet() { result in
                        if (result.count > 0)
                        {
                            self.Torrents = result
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func torrentAdd(filename: String, completion: @escaping (Bool) -> ()) {
        let endpoint = "http://192.168.1.11:9092/transmission/rpc"
        let endpointUrl = URL(string: endpoint)!
        
        var request = URLRequest(url: endpointUrl)
        request.httpMethod = "POST"
        request.httpBody = """
            {
            "arguments": {
            "filename": "\(filename)"
            },
            "method": "torrent-add"
            }
            """.data(using: .utf8)
        
        let transmissionSessionId = UserDefaults.standard.string(forKey: "transmissionSessionId")  ?? ""
        request.addValue(transmissionSessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 200) {
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        }.resume()
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    private struct TableColumns {
        static let id = NSUserInterfaceItemIdentifier("id")
        static let name = NSUserInterfaceItemIdentifier("name")
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Torrents.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let tableCell = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        if (tableColumn!.identifier == TableColumns.id) {
            tableCell.textField?.stringValue = Torrents[row].id.description
        } else if (tableColumn!.identifier == TableColumns.name) {
            tableCell.textField?.stringValue = Torrents[row].name
        } else {
            tableCell.textField?.stringValue = Torrents[row].totalSize.description
        }
        return tableCell
    }
}

