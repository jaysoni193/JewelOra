package com.example.jewel_ora;

import android.content.ComponentName;
import android.content.pm.PackageManager;

import androidx.annotation.NonNull;

import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "jewel_ora/app_icon";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
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
    }

    /** Enables [active] and disables every other alias in [all]. */
    private void setIcon(String active, List<String> all) {
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
