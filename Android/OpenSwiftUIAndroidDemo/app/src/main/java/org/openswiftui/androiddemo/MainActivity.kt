package org.openswiftui.androiddemo

import android.os.Bundle
import android.content.pm.ApplicationInfo
import android.system.Os
import android.system.OsConstants
import com.flowkey.uikit.UIKitActivity

class MainActivity : UIKitActivity() {
    companion object {
        init {
            System.loadLibrary("OpenSwiftUIAndroidDemo")
        }
    }

    private external fun configureOpenSwiftUI()

    override fun onCreate(savedInstanceState: Bundle?) {
        Os.setenv("OPENSWIFTUI_DEMO", intent.getStringExtra("demo") ?: "breathing", true)
        if (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0 &&
            intent.getBooleanExtra("printTree", false)) {
            Os.setenv("OPENSWIFTUI_PRINT_TREE", "1", true)
            val output = Os.open(
                "${filesDir.absolutePath}/display-list.log",
                OsConstants.O_WRONLY or OsConstants.O_CREAT or OsConstants.O_TRUNC,
                384
            )
            Os.dup2(output, OsConstants.STDOUT_FILENO)
            Os.dup2(output, OsConstants.STDERR_FILENO)
            Os.close(output)
        }
        configureOpenSwiftUI()
        super.onCreate(savedInstanceState)
    }
}
