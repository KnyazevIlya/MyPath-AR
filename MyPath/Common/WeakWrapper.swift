//
//  WeakWrapper.swift
//  MyPath
//
//  Created by Illia Kniaziev on 16.05.2022.
//

class Weak<T: AnyObject> {
    weak var value: T?
    init(_ value: T) {
        self.value = value
    }
}
