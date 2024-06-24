package com.vuitv.flutter_skyway

import android.content.Context
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class FlutterSkywayPlatformViewFactory(
    private val renderer: ConstraintLayout,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return FlutterSkywayPlatformView(context, renderer, viewId, creationParams)
    }
}

class FlutterSkywayPlatformView(
    context: Context?,
    renderer: ConstraintLayout,
    id: Int,
    creationParams: Map<String?, Any?>?
) : PlatformView, MethodChannel.MethodCallHandler {


    private var parentView: ConstraintLayout? = renderer

    override fun getView(): View? {
        return parentView
    }

    override fun dispose() {
        parentView?.removeAllViews()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        TODO("Not yet implemented")
    }

}