//
//  MultiSet.swift
//  ProtonMail - Created on 2018/11/7.
//
//
//  Copyright (c) 2019 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.


import Foundation

class MultiSet<T: Hashable> {
    typealias DataType = [T:Int]
    private var data: DataType
    
    init() {
        data = DataType()
    }
    
    subscript(_ query: T) -> Int? {
        get {
            return data[query]
        }
    }
    
    /**
     Insert an element
     */
    func insert(_ newData: T) {
        if let count = data[newData] {
            data.updateValue(count + 1, forKey: newData)
        } else {
            data[newData] = 1
        }
    }
    
    /**
     Remove an element
     */
    func remove(_ removeData: T) {
        if let count = data[removeData] {
            if count <= 1 {
                data.removeValue(forKey: removeData)
            } else {
                data.updateValue(count - 1, forKey: removeData)
            }
        }
    }
    
    /**
     Remove all specified elements
     */
    func removeAll(of removeData: T) {
        if let _ = data[removeData] {
            data.removeValue(forKey: removeData)
        }
    }
    
    /**
     Clears the multiset
     */
    func removeAll() {
        data.removeAll()
    }
    
    func allObjectsWithDuplicates() -> [T] {
        var result: [T] = []
        for member in data {
            for _ in 0..<member.value {
                result.append(member.key)
            }
        }
        return result
    }
    
    func allObjectsWithoutDuplicates() -> [T] {
        return data.map{$0.key}
    }
}

extension MultiSet: Sequence {
    func makeIterator() -> DataType.Iterator {
        return data.makeIterator()
    }
}
