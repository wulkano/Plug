//
//  Array+contains.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

extension Array {
    
    func first () -> Element? {
        return count > 0 ? self[0] : nil
    }
    
    func last () -> Element? {
        return count > 0 ? self[count - 1] : nil
    }
    
    func optionalAtIndex(_ index: Int) -> Element? {
        if self.count > index && index >= 0 {
            return self[index]
        } else {
            return nil
        }
    }
}
