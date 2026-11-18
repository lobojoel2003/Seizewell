package io.github.lobojoel2003.seizewell

import android.annotation.SuppressLint
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

/**
 * Quick Settings tile. It is reachable from the lock screen, so a caregiver
 * can start the timer without unlocking the phone first. Seizewell then
 * shows only the timer until the phone is unlocked.
 */
class StartTimerTileService : TileService() {
    override fun onStartListening() {
        super.onStartListening()
        qsTile?.apply {
            state = Tile.STATE_INACTIVE
            label = getString(R.string.tile_label)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                subtitle = getString(R.string.tile_subtitle)
            }
            updateTile()
        }
    }

    @SuppressLint("StartActivityAndCollapseDeprecated")
    override fun onClick() {
        super.onClick()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(LaunchIntents.startTimerPending(this, REQUEST_CODE))
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(LaunchIntents.startTimer(this))
        }
    }

    private companion object {
        const val REQUEST_CODE = 2
    }
}
