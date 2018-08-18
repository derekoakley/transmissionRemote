//
//  ViewController.swift
//  transmitRemote
//
//  Created by Derek Oakley on 18/08/2018.
//  Copyright © 2018 Derek Oakley. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var Torrents: [Torrent] = []
    var timer: DispatchSourceTimer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(torrentGetAndUpdateTableView), name: Notification.Name("torrentGetAndUpdateTableView"), object: nil)
        
        timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now(), repeating: .seconds(5), leeway: .seconds(5))
        timer.setEventHandler {
            self.torrentGetAndUpdateTableView()
        }
        
        // TODO: Try DispatchQueue.main.async everywhere
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        timer.activate()
    }
    
    override func viewDidDisappear() {
        super.viewDidAppear()
        timer.suspend()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc private func torrentGetAndUpdateTableView() {
        getTransmissionSessionId() { result in
            torrentGet() { result in
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

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    private struct TableColumns {
        static let id = NSUserInterfaceItemIdentifier("id")
        static let name = NSUserInterfaceItemIdentifier("name")
        static let totalSize = NSUserInterfaceItemIdentifier("totalSize")
        static let percentDone = NSUserInterfaceItemIdentifier("percentDone")
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
        } else if (tableColumn!.identifier == TableColumns.totalSize) {
            tableCell.textField?.stringValue = Torrents[row].totalSize.description
        } else if (tableColumn!.identifier == TableColumns.percentDone) {
            tableCell.textField?.stringValue = Torrents[row].percentDone.description
        }
        return tableCell
    }
}

