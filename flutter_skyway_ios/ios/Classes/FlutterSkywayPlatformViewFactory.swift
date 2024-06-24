//
//  FlutterSkywayPlatformViewFactory.swift
//  flutter_skyway_ios
//
//  Created by Quốc Cường on 16/10/2023.
//

import Flutter
import UIKit

class FlutterSkywayPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var view: UIView
    
    init(messenger: FlutterBinaryMessenger, view: UIView) {
        self.messenger = messenger
        self.view = view
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FlutterSkywayPlatformView(
            frame: frame,
            viewIdentifier: viewId,
            view: view,
            arguments: args,
            binaryMessenger: messenger)
    }
    
    /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
class FlutterSkywayPlatformView: NSObject, FlutterPlatformView {
    private var _view: UIView
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        view: UIView,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = view
        super.init()
    }
    
    func view() -> UIView {
        return _view
    }
}
