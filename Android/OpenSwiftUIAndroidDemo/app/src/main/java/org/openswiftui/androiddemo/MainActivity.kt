package org.openswiftui.androiddemo

import android.os.Bundle
import com.flowkey.uikit.UIKitActivity

class MainActivity : UIKitActivity() {
    companion object {
        init {
            System.loadLibrary("OpenSwiftUIAndroidDemo")
        }
    }

    private external fun configureOpenSwiftUI()

    override fun onCreate(savedInstanceState: Bundle?) {
        configureOpenSwiftUI()
        super.onCreate(savedInstanceState)
    }
}
