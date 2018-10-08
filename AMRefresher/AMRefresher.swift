//
//  AMRefresher.swift
//  AMRefresher
//
// The MIT License (MIT)
//
//  Created by arturdev on 10/4/18.
//  Copyright © 2018 arturdev. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

import UIKit

fileprivate struct AssociatedKeys {
    static var am = "_am"
}

public protocol AMExtensionsProvider: class {
    associatedtype T
    var am: T { get set }
}

public extension AMExtensionsProvider {
    /// A proxy which hosts reactive extensions for `self`.
    public var am: AM {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.am) as? AM ?? AM(self as! UIScrollView)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.am, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIScrollView: AMExtensionsProvider {}

public struct AM {
    public struct State: OptionSet, Hashable {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let stopped   = State(rawValue: 1 << 0)
        public static let triggered = State(rawValue: 1 << 1)
        public static let loading   = State(rawValue: 1 << 2)
        
        public static let all: State  = [.stopped, .triggered, .loading]
        
        public var stringValue: String {
            switch self {
            case .stopped:
                return "stopped"
            case .loading:
                return "loading"
            case .triggered:
                return "triggered"
            case .all:
                return "all"
            default:
                return ""
            }
        }
        
        public var hashValue: Int {
            return self.rawValue
        }
    }
    
    internal weak var scrollView: UIScrollView?
    public var pullToRefreshView: AMPullToRefreshView?
    public var infiniteScrollingView: AMInfiniteScrollingView?
    
    fileprivate init(_ scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
}
