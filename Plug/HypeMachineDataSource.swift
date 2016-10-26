//
//  PlugDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 10/22/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import Alamofire

class HypeMachineDataSource: NSObject, NSTableViewDataSource {
    var viewController: DataSourceViewController
    var filtering: Bool = false {
        didSet { viewController.tableView.reloadData() }
    }
    var standardTableContents: [AnyObject]?
    var filteredTableContents: [AnyObject]?
    var tableContents: [AnyObject]? {
        if standardTableContents == nil { return nil }
        
        if filtering {
            return filteredTableContents!
        } else {
            return standardTableContents!
        }
    }
    var requestInProgress: Bool = false
    var allObjectsLoaded: Bool = false
    var currentPage: Int = 0
    var objectsPerPage: Int {
        return 100
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
    
    func nextPageResultReceived<T>(_ result: Result<T>) {
        self.viewController.nextPageDidLoad(currentPage)
        
        switch result {
        case .Success(let value):
            guard let objects = value as Any as? AnyObject as? [AnyObject] else {
                fatalError("Must be of type [AnyObject]")
            }
            
            if currentPage == 0 {
                resetTableContents()
            }
            
            currentPage += 1
            allObjectsLoaded = isLastPage(objects)
            
            self.appendTableContents(objects)
            self.requestInProgress = false
        case .Failure(_, let error):
            Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error as NSError])
            print(error)
        }
    }
    
    func refresh() {
        currentPage = 0
        allObjectsLoaded = false
        loadNextPageObjects()
    }
    
    func isLastPage(_ objects: [AnyObject]) -> Bool {
        return objects.count < objectsPerPage
    }
    
    func objectForRow(_ row: Int) -> AnyObject? {
        return tableContents!.optionalAtIndex(row)
    }
    
    func objectAfterRow(_ row: Int) -> AnyObject? {
        return objectForRow(row + 1)
    }
    
    func resetTableContents() {
        standardTableContents = nil
        filteredTableContents = nil
    }
    
    func appendTableContents(_ objects: [AnyObject]) {
        var shouldReloadTableView = false
        let filteredObjects = filterTableContents(objects)
        
        if standardTableContents == nil {
            standardTableContents = []
            filteredTableContents = []
            shouldReloadTableView = true
        }
        
        let objectsToAdd: [AnyObject]
        if filtering {
            objectsToAdd = filteredObjects
        } else {
            objectsToAdd = objects
        }
        
        let rowIndexSet = rowIndexSetForNewObjects(objectsToAdd)

        // Need to calc the row index set first so that we can count the number of existing objects
        standardTableContents! += objects
        filteredTableContents! += filteredObjects
        
        if shouldReloadTableView {
            viewController.tableView.reloadData()
        } else {
            viewController.tableView.insertRows(at: rowIndexSet, withAnimation: NSTableViewAnimationOptions())
        }
    }
    
    func rowIndexSetForNewObjects(_ objects: [AnyObject]) -> IndexSet {
        let rowRange = NSMakeRange(tableContents!.count, objects.count)
        return IndexSet(integersIn: rowRange.toRange() ?? 0..<0)
    }
    
    func filterTableContents(_ objects: [AnyObject]) -> [AnyObject] {
        print("filterTableContents() not implemented")
        return objects
    }
    
    func refilterTableContents() {
        filteredTableContents = filterTableContents(standardTableContents!)
    }
    
    // MARK: NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return objectForRow(row)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableContents?.count ?? 0
    }
}
