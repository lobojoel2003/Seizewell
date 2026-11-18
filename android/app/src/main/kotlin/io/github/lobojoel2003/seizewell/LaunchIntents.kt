package io.github.lobojoel2003.seizewell

import android.app.PendingIntent
import android.content.Context
import android.content.Intent

/** Intents that open Seizewell straight into the seizure timer. */
object LaunchIntents {
    const val ACTION_START_TIMER = "io.github.lobojoel2003.seizewell.action.START_TIMER"

    fun startTimer(context: Context): Intent =
        Intent(context, MainActivity::class.java).apply {
            action = ACTION_START_TIMER
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }

    fun startTimerPending(context: Context, requestCode: Int): PendingIntent =
        PendingIntent.getActivity(
            context,
            requestCode,
            startTimer(context),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
}
