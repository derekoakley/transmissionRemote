//
//  ViewController.swift
//  transmitRemote
//
//  Created by Derek Oakley on 18/08/2018.
//  Copyright © 2018 Derek Oakley. All rights reserved.
//

import AppKit

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
        torrentGetAndUpdateTableView()
        
        // TODO: Try DispatchQueue.main.async everywhere
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        timer.resume()
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
    private struct torrentSubViews {
        static let files = NSUserInterfaceItemIdentifier("files")
        static let name = NSUserInterfaceItemIdentifier("name")
        static let percentDone = NSUserInterfaceItemIdentifier("percentDone")
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Torrents.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // One or two columns only and iterate through subviews, e.g. progress indicator.
        let tableCell = tableView.makeView(withIdentifier: (tableColumn?.identifier)!, owner: self) as! NSTableCellView
        
        for view in tableCell.subviews {
            print(view)
            if (view.identifier == torrentSubViews.files) {
                let imageView = view as! NSImageView
                if (Torrents[row].files.count > 1) {
                    imageView.image = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
                }
            }
            if (view.identifier == torrentSubViews.name) {
                let label = view as! NSTextField
                if (Torrents[row].files.count > 1) {
                    label.stringValue = Torrents[row].name
                }
            }
            if (view.identifier == torrentSubViews.percentDone) {
                let progressIndicator = view as! NSProgressIndicator
                progressIndicator.doubleValue = Torrents[row].percentDone * 100
            }
        }
        
        return tableCell
    }
}

