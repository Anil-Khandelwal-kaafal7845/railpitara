package com.ott.railpitara

import android.app.Application
import com.moengage.core.MoEngage
import com.moengage.core.DataCenter
import com.moengage.flutter.MoEInitializer
import com.moengage.core.LogLevel
import com.moengage.core.config.FcmConfig
import com.moengage.core.config.LogConfig
import com.moengage.core.config.NotificationConfig
import com.moengage.inapp.MoEInAppHelper
import com.moengage.pushbase.MoEPushHelper
import com.moengage.core.analytics.MoEAnalyticsHelper // ✅ Required for setAppStatus
import com.moengage.core.model.AppStatus // ✅ Required for AppStatus

class ChullApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        val moEngage = MoEngage.Builder(
            this,
            "F2Z5P8P67ZG4GWG42469CTWX", // Your actual Workspace ID
            DataCenter.DATA_CENTER_3 // India region
        )
            .configureLogs(LogConfig(LogLevel.VERBOSE, true))
            .configureFcm(FcmConfig(true))
            .configureNotificationMetaData(
                NotificationConfig(
                    R.drawable.small_icon,
                    R.drawable.large_icon
                )
            )
            .build()

        MoEngage.initialiseDefaultInstance(moEngage)

        // ✅ Use 'this' instead of 'context'
//        MoEAnalyticsHelper.setAppStatus(this, AppStatus.INSTALL)
//        MoEAnalyticsHelper.setAppStatus(this, AppStatus.UPDATE)

        MoEInAppHelper.getInstance().showInApp(this)
        MoEInAppHelper.getInstance().showNudge(this)


    }




}