package ch.bbv.serialtest;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

public class MainActivity extends Activity {
	private FileInputStream mSerialIn;
	private FileOutputStream mSerialOut;
	private Thread mAsyncReader;
	private TextView mTextOutput;
	private EditText mTextInput;
	private Button mSendButton;
	private final static String LOG = "ch.bbv.serialtest";
	

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        Process p;
        try {
			p = Runtime.getRuntime().exec("/system/xbin/busybox stty -F /dev/ttyO0 500:5:1cb2:8a3b:3:1c:7f:15:4:0:1:0:11:13:1a:0:12:f:17:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0");
			p.waitFor();
			int exit = p.exitValue();
			if(exit != 0) {
				Log.d(LOG, "busybox stty returned " + exit);
			}
		} catch (IOException e) {
			Log.e(LOG, "busybox stty failed", e);
		} catch (InterruptedException e) {
        	Log.w(LOG, "busybox stty wait failed", e);
		}
        
        try {
        	mSerialOut = null;
			mSerialOut = new FileOutputStream("/dev/ttyO0");
        } catch (FileNotFoundException e) {
        	Log.e(LOG, "opening for output", e);
		}
        
        try {
        	mSerialIn = null;
			mSerialIn = new FileInputStream("/dev/ttyO0");
        } catch (FileNotFoundException e) {
        	Log.e(LOG, "opening for input", e);
		}
        
		mTextInput = (EditText) findViewById(R.id.editText1);
		mTextOutput = (TextView) findViewById(R.id.textView1);
        mSendButton = (Button) findViewById(R.id.button1);
        
        if(mSerialOut != null) {
	        mSendButton.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					try {
						mSerialOut.write(mTextInput.getText().toString().getBytes("UTF-8"));
						mTextInput.setText("");
					} catch (IOException e) {
			        	Log.e(LOG, "writing output", e);
					}
				}
			});
        } else {
        	mSendButton.setEnabled(false);
        	mTextInput.setEnabled(false);
        }
        
        
        if(mSerialOut != null) {
        	mAsyncReader = new Thread(new Runnable() {
				
				@Override
				public void run() {
					byte[] buffer = new byte[1024];
					while(true) {
						try {
							int len = mSerialIn.read(buffer);
							if(len == -1) {
					        	Log.w(LOG, "EOF while reading");
					        	mTextOutput.setEnabled(false);
					        	break;
							}
							
							String seq = new String(buffer, 0, len, "UTF-8");
							mTextOutput.append(seq);
						} catch (IOException e) {
				        	Log.e(LOG, "IOException while reading", e);
				        	mTextOutput.setEnabled(false);
							break;
						}
					}
				}
			});
        } else {
        	mTextOutput.setEnabled(false);
        }
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
    
    @Override
    protected void onDestroy() {
    	try {
			mSerialIn.close();
		} catch (IOException e) {
		}
    	try {
			mSerialOut.close();
		} catch (IOException e) {
		}
    	mAsyncReader.interrupt();
    	super.onDestroy();
    }
}
