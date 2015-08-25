//
//  PlugDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 10/22/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HypeMachineDataSource: NSObject, NSTableViewDataSource {
    var viewController: DataSourceViewController
    var filtering: Bool = false {
        didSet { viewController.tableView.reloadData() }
    }
    var standardTableContents: [AnyObject]?
    var tableContents: [AnyObject]? {
        if standardTableContents == nil { return nil }
        
        if filtering {
            return filterTableContents(standardTableContents!)
        } else {
            return standardTableContents!
        }
    }
    var requestInProgress: Bool = false
    var allObjectsLoaded: Bool = false
    var currentPage: Int = 0
    var objectsPerPage: Int {
        return 20
    }
    var nextPageParams: [String: AnyObject] {
        return [ "page": currentPage + 1, "count": objectsPerPage]
    }
    var singlePage: Bool {
        return false
    }
    
    init(viewController: DataSourceViewController) {
        self.viewController = viewController
        super.init()
    }
    
    func loadNextPageObjects() {
        if singlePage && currentPage >= 1 { return }
        if requestInProgress { return }
        if allObjectsLoaded { return }
        
        requestInProgress = true
        requestNextPageObjects()
    }
    
    func requestNextPageObjects() {
        fatalError("requestNextPage() not implemented")
    }
    
    func nextPageObjectsReceived(objects: [AnyObject]?, error: NSError?) {
        self.viewController.nextPageDidLoad(currentPage)
        if error != nil {
            Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
            println(error!)
            return
        }
        
        if currentPage == 0 {
            resetTableContents()
        }
        
        currentPage++
        allObjectsLoaded = isLastPage(objects!)
        
        self.appendTableContents(objects!)
        self.requestInProgress = false
    }
    
    func refresh() {
        currentPage = 0
        allObjectsLoaded = false
        loadNextPageObjects()
    }
    
    func isLastPage(objects: [AnyObject]) -> Bool {
        return objects.count < objectsPerPage
    }
    
    func objectForRow(row: Int) -> AnyObject? {
        return tableContents!.optionalAtIndex(row)
    }
    
    func objectAfterRow(row: Int) -> AnyObject? {
        return objectForRow(row + 1)
    }
    
    func resetTableContents() {
        standardTableContents = nil
    }
    
    func appendTableContents(objects: [AnyObject]) {
        var shouldReloadTableView = false
        
        if standardTableContents == nil {
            standardTableContents = []
            shouldReloadTableView = true
        }
        
        let objectsToAdd: [AnyObject]
        if filtering {
            objectsToAdd = filterTableContents(objects)
        } else {
            objectsToAdd = objects
        }
        
        let rowIndexSet = rowIndexSetForNewObjects(objectsToAdd)

        standardTableContents! += objects
        
        if shouldReloadTableView {
            viewController.tableView.reloadData()
        } else {
            viewController.tableView.insertRowsAtIndexes(rowIndexSet, withAnimation: .EffectNone)
        }
    }
    
    func rowIndexSetForNewObjects(objects: [AnyObject]) -> NSIndexSet {
        let rowRange = NSMakeRange(tableContents!.count, objects.count)
        return NSIndexSet(indexesInRange: rowRange)
    }
    
    func filterTableContents(objects: [AnyObject]) -> [AnyObject] {
        println("filterTableContents() not implemented")
        return objects
    }
    
    // MARK: NSTableViewDelegate
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return objectForRow(row)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return tableContents?.count ?? 0
    }
}
