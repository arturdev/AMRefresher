//
//  AMRefresher.swift
//  AMRefresher
//
//  Created by Artur Mkrtchyan on 10/3/18.
//  Copyright © 2018 arturdev. All rights reserved.
//

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
