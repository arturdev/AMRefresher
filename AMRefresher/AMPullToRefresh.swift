//
//  AMPullToRefresh.swift
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

open class AMPullToRefreshView: UIView {
    
    //MARK: - Public vars
    
    open var pullToRefreshViewHeight: CGFloat = 40.0 {
        didSet {
            refreshFrame()
        }
    }
    
    public var state: AM.State = .stopped {
        didSet {
            guard state != oldValue else { return }
            reloadUIForState()
            if state == .loading {
                self.actionHandler?()
                adjustContentInsetForLoading {
                    self.animationsCompletionHandler?()
                }
            } else if state == .stopped {
                resetContentInset {
                    self.animationsCompletionHandler?()
                }
            }
        }
    }
    
    public var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    public var animationsCompletionHandler: (()->Void)?
    
    //MARK: - Private vars
    
    fileprivate weak var scrollView: UIScrollView? {
        didSet {
            guard let scrollView = scrollView else { return }
            originalContentInset = scrollView.contentInset
            originalAdjustedContentInset = adjustedContentInset
            scrollView.addSubview(self)
            setupListeners()
        }
    }
    
    fileprivate var threshold: CGFloat {
        return -((originalAdjustedContentInset.top + pullToRefreshViewHeight) + (originalAdjustedContentInset.top - originalContentInset.top))
    }
    
    fileprivate var actionHandler: (()->Void)?
    private var observerContext = 0
    private var originalContentInset: UIEdgeInsets = UIEdgeInsets()
    private var originalAdjustedContentInset: UIEdgeInsets = UIEdgeInsets()    
    private var adjustedContentInset: UIEdgeInsets {
        guard let scrollView = scrollView else { return UIEdgeInsets() }
        if #available(iOS 11.0, *) {
            return scrollView.adjustedContentInset
        }
        return scrollView.contentInset
    }
    private var scrollViewSafeAreaInset: UIEdgeInsets {
        guard let scrollView = scrollView else { return UIEdgeInsets() }
        if #available(iOS 11.0, *) {
            return scrollView.safeAreaInsets
        }
        return UIEdgeInsets()
    }
    
    internal var customViewsForStates: [AM.State : UIView] = [:]
    
    //MARK: - Public methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUI()
    }
    
    public func trigger() {
        state = .loading
    }
    
    public func stopRefreshing() {
        state = .stopped
    }
    
    public func setCustomView(_ view: UIView, for state: AM.State) {
        customViewsForStates[state] = view
        reloadUIForState()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == "contentOffset" {
            let newPoint = change?[.newKey] as! CGPoint
            scrollViewDidScroll(newPoint)
        } else if keyPath == "contentSize" {
            layoutSubviews()
            refreshFrame()
        } else if keyPath == "frame" {
            layoutSubviews()
        } else if keyPath == "safeAreaInsets" {
            let originalInset = originalContentInset
            let safeAreaInset = scrollViewSafeAreaInset
            originalAdjustedContentInset = UIEdgeInsets(top: originalInset.top + safeAreaInset.top,
                                                        left: originalInset.left + safeAreaInset.left,
                                                        bottom: originalInset.bottom + safeAreaInset.bottom,
                                                        right: originalInset.right + safeAreaInset.right)
            refreshFrame()
            if self.state == .loading {
                adjustContentInsetForLoading {}
            }
        }
    }
    
    deinit {
        removeListeners()
    }
    
    //MARK: - Private methods
    
    fileprivate  func configureUI() {
        addSubview(contentView)
        contentView.frame = bounds
        state = .stopped
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        setCustomView(activityIndicator, for: .loading)
    }
    
    fileprivate func refreshFrame() {
        var yOrigin = -pullToRefreshViewHeight
        yOrigin -= originalAdjustedContentInset.top
        self.frame = CGRect(x: 0.0, y: yOrigin, width: (superview?.bounds.size.width ?? UIScreen.main.bounds.size.width), height: pullToRefreshViewHeight)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func reloadUIForState() {
        contentView.subviews.forEach({$0.removeFromSuperview()})
        guard let view = customViewsForStates[self.state] else {return}
        
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1).isActive = true
        view.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1).isActive = true
        view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        view.layoutIfNeeded()
    }
    
    private func setupListeners() {
        self.scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: &observerContext)
        self.scrollView?.addObserver(self, forKeyPath: "contentSize", options: [.new], context: &observerContext)
        self.scrollView?.addObserver(self, forKeyPath: "frame", options: [.new], context: &observerContext)
        if #available(iOS 11.0, *) {
            self.scrollView?.addObserver(self, forKeyPath: "safeAreaInsets", options: [.new], context: &observerContext)
        }
    }
    
    private func removeListeners() {
        self.scrollView?.removeObserver(self, forKeyPath: "contentOffset")
        self.scrollView?.removeObserver(self, forKeyPath: "contentSize")
        self.scrollView?.removeObserver(self, forKeyPath: "frame")
        if #available(iOS 11.0, *) {
            self.scrollView?.removeObserver(self, forKeyPath: "safeAreaInsets")
        }
    }
    
    private func scrollViewDidScroll(_ contentOffset: CGPoint) {
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        
        if state.contains(.loading) {
            return
        }
        
        if scrollView.am.infiniteScrollingView?.state.contains(.loading) ?? false {
            return
        }
        
        if state.contains(.stopped) && scrollView.isDragging {
            if contentOffset.y <= threshold {
                state = .triggered
            }
        } else if state == .triggered {
            if !scrollView.isDragging { //this means that scrollView was pulled and released.
                state = .loading
            } else { //this means that scrollView was pulled enough but the user didn't release yet.
                if contentOffset.y > threshold { //this means that scrollView was dragged back to initial state without releasing.
                    state = .stopped
                }
            }
        }
    }
    
    private func adjustContentInsetForLoading(completion handler: @escaping () -> Void) {
        if scrollView?.am.infiniteScrollingView?.state.contains(.loading) ?? false {
            return
        }
        var inset = originalContentInset
        inset.top += pullToRefreshViewHeight + (originalAdjustedContentInset.top - originalContentInset.top)
        self.setContentInset(inset, animated: true, completion: handler)
    }
    
    private func resetContentInset(completion handler: @escaping () -> Void) {
        self.setContentInset(originalContentInset, animated: true, completion: handler)
    }
    
    private func setContentInset(_ inset: UIEdgeInsets, animated: Bool, completion handler: @escaping () -> Void) {
        guard let scrollView = scrollView else { return }
        
        let delta = self.originalAdjustedContentInset.top - self.originalContentInset.top
        
        let contentOffset = scrollView.contentOffset
        scrollView.contentInset = inset
        scrollView.contentOffset = contentOffset
        
        if scrollView.isTracking {
            handler()
            return
        }
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            handler()
        }
        scrollView.setContentOffset(CGPoint(x: contentOffset.x, y: -inset.top - delta), animated: animated)
        CATransaction.commit()
    }
}

public extension AM {
    public mutating func addPullToRefresh(action handler: @escaping () -> Void) {
        pullToRefreshView?.removeFromSuperview()
        pullToRefreshView = AMPullToRefreshView()
        pullToRefreshView?.actionHandler = handler
        pullToRefreshView?.scrollView = scrollView
    }
}
