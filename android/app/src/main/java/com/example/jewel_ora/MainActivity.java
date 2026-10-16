package com.example.jewel_ora;

import android.content.ComponentName;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.WindowManager;

import androidx.annotation.NonNull;

import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL_ICON = "jewel_ora/app_icon";
    private static final String CHANNEL_SECURITY = "jewel_ora/security";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Prevent screenshots, screen recordings, and recent app previews from app launch
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // App Icon Switcher Channel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_ICON)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("set")) {
                        String active = call.argument("alias");
                        List<String> all = call.argument("all");
                        if (active == null || all == null || !all.contains(active)) {
                            result.success(false);
                            return;
                        }
                        setIcon(active, all);
                        result.success(true);
                    } else {
                        result.notImplemented();
                    }
                });

        // Screen Security Channel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_SECURITY)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "enableSecure":
                            getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
                            result.success(true);
                            break;
                        case "disableSecure":
                            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SECURE);
                            result.success(true);
                            break;
                        case "isSecure":
                            int flags = getWindow().getAttributes().flags;
                            boolean isSecured = (flags & WindowManager.LayoutParams.FLAG_SECURE) != 0;
                            result.success(isSecured);
                            break;
                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }

    /** Enables [active] and disables every other alias in [all]. */
    private void setIcon(String active, List<String> all) {
        boolean isDebug = (getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
        if (isDebug) {
            return;
        }
        String pkg = MainActivity.class.getPackage().getName();
        PackageManager pm = getPackageManager();

        // Enable the new icon FIRST, so the app never has zero launcher icons.
        setState(pm, pkg + "." + active, true);
        for (String name : all) {
            if (!name.equals(active)) setState(pm, pkg + "." + name, false);
        }
    }

    private void setState(PackageManager pm, String className, boolean enable) {
        ComponentName component = new ComponentName(this, className);
        int wanted = enable
                ? PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                : PackageManager.COMPONENT_ENABLED_STATE_DISABLED;
        if (pm.getComponentEnabledSetting(component) != wanted) {
            pm.setComponentEnabledSetting(
                    component, wanted, PackageManager.DONT_KILL_APP);
        }
    }
}
