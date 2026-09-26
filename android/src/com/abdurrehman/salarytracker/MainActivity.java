package com.abdurrehman.salarytracker;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.JavascriptInterface;
import android.webkit.WebResourceRequest;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

/** Shows the salary tracker page (assets/index.html) full screen. */
public class MainActivity extends Activity {
    private static final int REQ_SAVE_BACKUP = 1;
    private static final int REQ_OPEN_BACKUP = 2;
    private static final String PREFS = "salary";
    private static final String DATA_KEY = "data";

    private WebView web;
    private ValueCallback<Uri[]> fileCallback;
    private String pendingBackup;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        web = new WebView(this);
        WebSettings settings = web.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);

        web.setWebViewClient(new WebViewClient() {
            // Call / WhatsApp links open the dialer or WhatsApp instead of loading inside the app
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                Uri uri = request.getUrl();
                if ("file".equals(uri.getScheme())) return false;
                try {
                    startActivity(new Intent(Intent.ACTION_VIEW, uri));
                } catch (Exception e) {
                    Toast.makeText(MainActivity.this, "No app found to open this link", Toast.LENGTH_SHORT).show();
                }
                return true;
            }
        });
        web.setWebChromeClient(new WebChromeClient() {
            // "Restore backup" button: let the user pick a backup file
            @Override
            public boolean onShowFileChooser(WebView view, ValueCallback<Uri[]> callback, FileChooserParams params) {
                if (fileCallback != null) fileCallback.onReceiveValue(null);
                fileCallback = callback;
                Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
                intent.addCategory(Intent.CATEGORY_OPENABLE);
                intent.setType("*/*");
                try {
                    startActivityForResult(intent, REQ_OPEN_BACKUP);
                } catch (Exception e) {
                    fileCallback = null;
                    return false;
                }
                return true;
            }
        });
        web.addJavascriptInterface(new Bridge(), "AndroidApp");
        web.loadUrl("file:///android_asset/index.html");
        setContentView(web);
    }

    /** Called from the page's JavaScript as window.AndroidApp. */
    private class Bridge {
        @JavascriptInterface
        public String load() {
            return getSharedPreferences(PREFS, MODE_PRIVATE).getString(DATA_KEY, null);
        }

        @JavascriptInterface
        public void store(String json) {
            SharedPreferences.Editor editor = getSharedPreferences(PREFS, MODE_PRIVATE).edit();
            editor.putString(DATA_KEY, json);
            editor.apply();
        }

        @JavascriptInterface
        public void saveBackup(final String json, final String fileName) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    pendingBackup = json;
                    Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
                    intent.addCategory(Intent.CATEGORY_OPENABLE);
                    intent.setType("application/json");
                    intent.putExtra(Intent.EXTRA_TITLE, fileName);
                    startActivityForResult(intent, REQ_SAVE_BACKUP);
                }
            });
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Uri uri = (resultCode == RESULT_OK && data != null) ? data.getData() : null;

        if (requestCode == REQ_OPEN_BACKUP && fileCallback != null) {
            fileCallback.onReceiveValue(uri != null ? new Uri[] { uri } : null);
            fileCallback = null;
        } else if (requestCode == REQ_SAVE_BACKUP && pendingBackup != null) {
            if (uri != null) {
                try (OutputStream out = getContentResolver().openOutputStream(uri)) {
                    out.write(pendingBackup.getBytes(StandardCharsets.UTF_8));
                    Toast.makeText(this, "Backup saved", Toast.LENGTH_SHORT).show();
                } catch (Exception e) {
                    Toast.makeText(this, "Could not save backup", Toast.LENGTH_LONG).show();
                }
            }
            pendingBackup = null;
        }
    }
}
