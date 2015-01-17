package com.greenspun.philip.facebooklet;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import org.json.JSONException;
import org.json.JSONObject;
import android.app.Activity;
import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import com.greenspun.philip.facebooklet.JSONParser;
import java.util.Timer;
import java.util.TimerTask;
import android.os.Handler;


public class MainActivity extends ActionBarActivity {

    // GUI text fields
    TextView users_value;
    TextView statuses_value;
    TextView friendships_value;

    // web service URL
    private static String url = "http://10.0.2.2:8080/~dev/php/rdbmsapp/pulse.php";

    // JSON field names
    private static final String TAG_USERS = "users";
    private static final String TAG_STATUSES = "statuses";
    private static final String TAG_FRIENDSHIPS = "friendships";
    private static final String TAG_ERROR = "error";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // grab the values every 3 seconds
        final Handler handler = new Handler();
        Timer timer = new Timer();
        TimerTask updateTask = new TimerTask() {
            @Override
            public void run() {
                handler.post(new Runnable() {
                    public void run() {
                        try {
                            new JSONParse().execute();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                });
            }
        };
        timer.schedule(updateTask, 0, 3000); // run every 3 seconds (3000 ms)
    }

    private class JSONParse extends AsyncTask<String, String, JSONObject> {
        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            users_value = (TextView)findViewById(R.id.users_value);
            statuses_value = (TextView)findViewById(R.id.statuses_value);
            friendships_value = (TextView)findViewById(R.id.friendships_value);
        }
        @Override
        protected JSONObject doInBackground(String... args) {
            JSONParser jParser = new JSONParser();
            // Getting JSON from URL
            JSONObject json = jParser.getJSONFromUrl(url);
            return json;
        }
        @Override
        protected void onPostExecute(JSONObject json) {
            try {
                // get the JSON data
                String usersCount = json.getString(TAG_USERS);
                String statusesCount = json.getString(TAG_STATUSES);
                String friendshipsCount = json.getString(TAG_FRIENDSHIPS);
                // populate the TextViews
                users_value.setText(usersCount);
                statuses_value.setText(statusesCount);
                friendships_value.setText(friendshipsCount);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
