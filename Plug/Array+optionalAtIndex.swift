//
//  Array+optionalAtIndex.swift
//  Plug
//
//  Created by Alex Marchant on 10/22/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

extension Array {
    func optionalAtIndex(index: Int) -> T? {
        if self.count > index {
            return self[index]
        } else {
            return nil
        }
    }
}