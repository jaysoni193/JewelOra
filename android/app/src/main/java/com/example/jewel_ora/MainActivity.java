package com.example.jewel_ora;

import android.content.ComponentName;
import android.content.pm.PackageManager;

import androidx.annotation.NonNull;

import java.util.Arrays;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "jewel_ora/app_icon";
    private static final List<String> ALIASES =
            Arrays.asList("IconDefault", "IconDiwali", "IconChristmas");

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("set")) {
                        String alias = call.argument("alias");
                        setIcon(alias == null ? "IconDefault" : alias);
                        result.success(true);
                    } else {
                        result.notImplemented();
                    }
                });
    }

    private void setIcon(String active) {
        if (!ALIASES.contains(active)) return;

        String pkg = MainActivity.class.getPackage().getName();
        PackageManager pm = getPackageManager();

        for (String name : ALIASES) {
            ComponentName component = new ComponentName(this, pkg + "." + name);
            int wanted = name.equals(active)
                    ? PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                    : PackageManager.COMPONENT_ENABLED_STATE_DISABLED;

            if (pm.getComponentEnabledSetting(component) != wanted) {
                pm.setComponentEnabledSetting(
                        component, wanted, PackageManager.DONT_KILL_APP);
            }
        }
    }
}