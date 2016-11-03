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
    var standardTableContents: [Any]?
    var filteredTableContents: [Any]?
    var tableContents: [Any]? {
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
    var nextPageParams: [String: Any] {
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
    
    func nextPageResponseReceived<T>(_ response: DataResponse<T>) {
        self.viewController.nextPageDidLoad(currentPage)
        
        switch response.result {
        case .success(let value):
            guard let objects = value as Any as? [Any] else {
                fatalError("Must be of type [Any]")
            }
            
            if currentPage == 0 {
                resetTableContents()
            }
            
            currentPage += 1
            allObjectsLoaded = isLastPage(objects)
            
            self.appendTableContents(objects)
            self.requestInProgress = false
        case .failure(let error):
            Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error as NSError])
            print(error)
        }
    }
    
    func refresh() {
        currentPage = 0
        allObjectsLoaded = false
        loadNextPageObjects()
    }
    
    func isLastPage(_ objects: [Any]) -> Bool {
        return objects.count < objectsPerPage
    }
    
    func objectForRow(_ row: Int) -> Any? {
        return tableContents!.optionalAtIndex(row)
    }
    
    func objectAfterRow(_ row: Int) -> Any? {
        return objectForRow(row + 1)
    }
    
    func resetTableContents() {
        standardTableContents = nil
        filteredTableContents = nil
    }
    
    func appendTableContents(_ objects: [Any]) {
        var shouldReloadTableView = false
        let filteredObjects = filterTableContents(objects)
        
        if standardTableContents == nil {
            standardTableContents = []
            filteredTableContents = []
            shouldReloadTableView = true
        }
        
        let objectsToAdd: [Any]
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
    
    func rowIndexSetForNewObjects(_ objects: [Any]) -> IndexSet {
        let rowRange = NSMakeRange(tableContents!.count, objects.count)
        return IndexSet(integersIn: rowRange.toRange() ?? 0..<0)
    }
    
    func filterTableContents(_ objects: [Any]) -> [Any] {
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
