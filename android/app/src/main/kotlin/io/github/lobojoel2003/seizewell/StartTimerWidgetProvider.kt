package io.github.lobojoel2003.seizewell

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

/** Home-screen widget: a single button that starts the seizure timer. */
class StartTimerWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_start_timer)
            views.setOnClickPendingIntent(
                R.id.widget_root,
                LaunchIntents.startTimerPending(context, REQUEST_CODE),
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private companion object {
        const val REQUEST_CODE = 1
    }
}
