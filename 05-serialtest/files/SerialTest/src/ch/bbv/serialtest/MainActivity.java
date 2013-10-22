package ch.bbv.serialtest;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;

public class MainActivity extends Activity {
	private FileInputStream mSerialIn;
	private FileOutputStream mSerialOut;
	private Thread mAsyncReader;
	private TextView mTextOutput;
	private EditText mTextInput;
	private final static String LOG = "ch.bbv.serialtest";
	

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        Process p;
        try {
        	/* the cryptical settings parameter can be retrieved by
        	 * reading the current state of /dev/ttyS0 via
        	 * stty --save --file=/dev/ttyO0 */
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

        if(mSerialOut != null) {
        	mTextInput.setOnEditorActionListener( new OnEditorActionListener() {
				
				@Override
				public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
					if(actionId == EditorInfo.IME_ACTION_SEND) {
						try {
							mSerialOut.write(mTextInput.getText().toString().getBytes("UTF-8"));
							mTextInput.setText("");
						} catch (IOException e) {
				        	Log.e(LOG, "writing output", e);
						}
						return true;
					}
					return false;
				}
			});
        } else {
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
							Log.v(LOG, "Read len: " + len);
							if(len == -1) {
					        	Log.w(LOG, "EOF while reading");
					        	MainActivity.this.runOnUiThread(new Runnable() {
									@Override
									public void run() {
							        	mTextOutput.setEnabled(false);
									}
								});
					        	break;
							}
							
							final String seq = new String(buffer, 0, len, "UTF-8");
				        	MainActivity.this.runOnUiThread(new Runnable() {
								@Override
								public void run() {
									mTextOutput.append(seq);
								}
							});

						} catch (IOException e) {
				        	Log.e(LOG, "IOException while reading", e);
				        	MainActivity.this.runOnUiThread(new Runnable() {
								@Override
								public void run() {
						        	mTextOutput.setEnabled(false);
								}
							});
							break;
						}
					}
				}
			});
        	mAsyncReader.start();
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
