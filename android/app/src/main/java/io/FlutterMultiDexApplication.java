package io.flutter.app;

import androidx.multidex.MultiDex;
import androidx.multidex.MultiDexApplication;

public class FlutterMultiDexApplication extends MultiDexApplication {
    @Override
    protected void attachBaseContext(android.content.Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }
}
