package io.github.lobojoel2003.seizewell

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * FlutterFragmentActivity is required by the biometric app lock.
 *
 * The activity also receives "start timer" requests from the home-screen
 * widget and the Quick Settings tile and forwards them to Dart. When the
 * phone is locked, it shows itself above the lock screen for the timer only.
 */
class MainActivity : FlutterFragmentActivity() {
    private var channel: MethodChannel? = null
    private var pendingAction: Map<String, Any>? = null
    private var shownOverLockScreen = false

    /** True once Dart has asked for the initial action, i.e. it is listening. */
    private var dartReady = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
                setMethodCallHandler { call, result ->
                    when (call.method) {
                        "initialAction" -> {
                            dartReady = true
                            result.success(pendingAction)
                            pendingAction = null
                        }
                        "isDeviceLocked" -> result.success(keyguard().isKeyguardLocked)
                        "requestUnlock" -> requestUnlock(result)
                        else -> result.notImplemented()
                    }
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // A START_TIMER intent re-delivered from Recents (after Android killed
        // the process) or with restored state is stale: don't start a timer.
        val fromHistory = (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0
        if (savedInstanceState == null && !fromHistory) {
            handleIntent(intent)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    override fun onStop() {
        super.onStop()
        // Never stay above the lock screen once the user leaves the timer.
        if (shownOverLockScreen && !isChangingConfigurations) showOverLockScreen(false)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent?.action != LaunchIntents.ACTION_START_TIMER) return
        // Consume the action so recreating the activity doesn't repeat it.
        intent.action = Intent.ACTION_MAIN
        val overLockScreen = keyguard().isKeyguardLocked
        if (overLockScreen) showOverLockScreen(true)
        val payload = mapOf("action" to "start_timer", "overLockScreen" to overLockScreen)
        val ch = channel
        if (dartReady && ch != null) {
            ch.invokeMethod("onAction", payload)
        } else {
            // Dart is still starting (opening the encrypted database); it
            // collects this with "initialAction" once it is listening.
            pendingAction = payload
        }
    }

    private fun showOverLockScreen(show: Boolean) {
        shownOverLockScreen = show
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(show)
            setTurnScreenOn(show)
        } else {
            @Suppress("DEPRECATION")
            val flags =
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (show) window.addFlags(flags) else window.clearFlags(flags)
        }
    }

    private fun requestUnlock(result: MethodChannel.Result) {
        val km = keyguard()
        if (!km.isKeyguardLocked) {
            showOverLockScreen(false)
            result.success(true)
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            result.success(false)
            return
        }
        km.requestDismissKeyguard(
            this,
            object : KeyguardManager.KeyguardDismissCallback() {
                override fun onDismissSucceeded() {
                    showOverLockScreen(false)
                    result.success(true)
                }

                override fun onDismissCancelled() = result.success(false)

                override fun onDismissError() = result.success(false)
            },
        )
    }

    private fun keyguard() = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager

    private companion object {
        const val CHANNEL = "io.github.lobojoel2003.seizewell/launch"
    }
}
