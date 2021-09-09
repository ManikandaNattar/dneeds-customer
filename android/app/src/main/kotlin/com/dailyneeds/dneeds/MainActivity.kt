package com.dailyneeds.dneeds
import androidx.annotation.NonNull
//import androidx.annotation.NonNull
import androidx.appcompat.app.AppCompatActivity
import androidx.coordinatorlayout.widget.CoordinatorLayout
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
//import androidx.lifecycle.ProcessLifecycleOwner
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.engine.FlutterEngine
import com.twilio.http.TwilioRestClient
import com.twilio.rest.api.v2010.account.MessageCreator
import com.twilio.type.PhoneNumber
import com.koushikdutta.ion.Ion
import com.twilio.voice.Call
import com.twilio.voice.Call.Listener
import com.twilio.voice.CallException
import com.twilio.voice.ConnectOptions
import com.twilio.voice.Voice
import com.twilio.Twilio
import java.util.*
import android.media.AudioManager
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.content.Context
import android.content.Context.AUDIO_SERVICE
import android.content.pm.PackageManager
import android.Manifest
import android.media.SoundPool


class MainActivity: FlutterActivity() {
    private val CHANNEL = "TwilioChannel";
    private val TWILIO_ACCESS_TOKEN_SERVER_URL = "http://3.20.145.140/twilio/accesstoken.php" //"http://3.7.111.196/twilio/voice_server/accessToken.php"
    val ACCOUNT_SID = "ACc7f9ae044c6d75aeb255e83759fb4419"
    private var accessToken: String? = null
    private var activeCall: Call? = null
    private var mobile = ""
    private var countrycode = "+91"
    private var mobileNumber: String?=null
    internal var params = HashMap<String, String>()
    private val TAG = "VoiceActivity"
    private val identity = "alice"
    private var audioManager: AudioManager? = null
    private var savedAudioMode = AudioManager.MODE_INVALID
    internal var callListener = callListener()
    private val MIC_PERMISSION_REQUEST_CODE = 1
    private var permissions: Array<String> = arrayOf(Manifest.permission.RECORD_AUDIO)

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
            super.configureFlutterEngine(flutterEngine)
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
                if (call.method == "twilio_call")

                {
                   // var numberFromFlutter=call.arguments<String>("vendor_mob_number")
                   /// mobile=numberFromFlutter.get("vendor_mob_number")
                    val argus=call.arguments<Map<String,Any>>()
                    val numberFromFlutter=argus["vendor_mob_number"]
                    mobileNumber=numberFromFlutter.toString()
                    mobile=countrycode+mobileNumber
                    retrieveAccessToken()
                    result.success("this is native")
                }
                else if(call.method =="hangup")
                {
                       disconnect()
                }
                else if(call.method =="mute")
                {
                      mute()
                }
                else if(call.method =="hold")
                {
                     hold()
                }
                else
                {
                    result.error("error", "error occur", "error")
                }
            }

        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        //audioManager.setSpeakerphoneOn(true)

 if (!checkPermissionForMicrophone())
 {
     requestPermissionForMicrophone()
 }
 else
 {
     //retrieveAccessToken()
 }

    }



    //audioManager.setSpeakerphoneOn(true);
    private fun  checkPermissionForMicrophone():Boolean
    {
       val resultMic = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
        return resultMic == PackageManager.PERMISSION_GRANTED
    }

    private fun requestPermissionForMicrophone()
    {
        if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                        Manifest.permission.RECORD_AUDIO))
        {

        }
        else
        {
            ActivityCompat.requestPermissions(this, permissions, MIC_PERMISSION_REQUEST_CODE)
        }
    }



    private fun retrieveAccessToken()
   {
       Ion.with(this).load(TWILIO_ACCESS_TOKEN_SERVER_URL).asString().setCallback(
               {
                   e, result ->
                   if(e==null)
                   {
                       Log.d("Voice Activity","Access token:$result")
                       params["to"] = mobile//"+919962437567"
                       val connectOptions = ConnectOptions.Builder(result)
                               .params(params)
                               .build()
                       activeCall = Voice.connect(this.context, connectOptions, callListener)
                   }
                   else
                   {
                       Log.d("Not Accepted","Access:$result")
                   }
               }
       )

    }
    private fun callListener(): Call.Listener {
        return object : Call.Listener {
            /*
             * This callback is emitted once before the Call.Listener.onConnected() callback when
             * the callee is being alerted of a Call. The behavior of this callback is determined by
             * the answerOnBridge flag provided in the Dial verb of your TwiML application
             * associated with this client. If the answerOnBridge flag is false, which is the
             * default, the Call.Listener.onConnected() callback will be emitted immediately after
             * Call.Listener.onRinging(). If the answerOnBridge flag is true, this will cause the
             * call to emit the onConnected callback only after the call is answered.
             * See answeronbridge for more details on how to use it with the Dial TwiML verb. If the
             * twiML response contains a Say verb, then the call will emit the
             * Call.Listener.onConnected callback immediately after Call.Listener.onRinging() is
             * raised, irrespective of the value of answerOnBridge being set to true or false
             */
            override fun onRinging(call: Call) {
                Log.d(TAG, "Ringing")
            }

            override fun onConnectFailure(call: Call, error: CallException) {
               // setAudioFocus(false)

                Log.d(TAG, "Connect failure")
                val message = String.format(
                        Locale.US,
                        "Call Error: %d, %s",
                        error.errorCode,
                        error.message)
                Log.e(TAG, message)
                //Snackbar.make(coordinatorLayout, message, Snackbar.LENGTH_LONG).show()
               // resetUI()
            }

            override fun onConnected(call: Call) {
                setAudioFocus(true)
               // applyFabState(inputSwitchFab, fileAndMicAudioDevice.isMusicPlaying())
                Log.d(TAG, "Connected " + call.sid!!)
                activeCall = call
            }

            override fun onReconnecting(call: Call, callException: CallException) {
                Log.d(TAG, "onReconnecting")
            }

            override fun onReconnected(call: Call) {
                Log.d(TAG, "onReconnected")
            }

            override fun onDisconnected(call: Call, error: CallException?) {
                //setAudioFocus(false)
                Log.d(TAG, "Disconnected")
                if (error != null) {
                    val message = String.format(
                            Locale.US,
                            "Call Error: %d, %s",
                            error.errorCode,
                            error.message)
                    Log.e(TAG, message)
                    //Snackbar.make(coordinatorLayout, message, Snackbar.LENGTH_LONG).show()
                }
                //resetUI()
            }
        }
    }
    private fun disconnect()
    {
        val checkActiveCall=activeCall
        if(checkActiveCall != null)
        {
            checkActiveCall.disconnect()
            //checkActiveCall=null
        }
//        if (activeCall != null) {
//            activeCall.disconnect();
//            activeCall = null;
//            println(activeCall)
//        }
    }
    private fun mute()
    {
        val checkMuteCall=activeCall
        if (checkMuteCall !=null)
        {
            checkMuteCall.mute(!checkMuteCall.isMuted())
        }
//      if (activeCall != null)
//      {
//          val mute = !activeCall.isMuted()
//          activeCall.mute(mute);
//      }
    }
    private fun hold()
    {
        val checkHoldCall=activeCall
        if (checkHoldCall !=null)
        {

            checkHoldCall.hold(!checkHoldCall.isOnHold())
        }
//        if (activeCall != null)
//        {
//        val hold = !activeCall.isOnHold()
//        activeCall.hold(hold);
//
//         }

    }
    private fun setAudioFocus(setFocus: Boolean?)
  {
      if (audioManager != null)
      {


      }
  }

//    @Override
//    protected void onCreate(Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
//        GeneratedPluginRegistrant.registerWith(this);
//        String value = parseIntent(getIntent());
//    }
//
//    private String parseIntent(Intent intent){
//        Bundle bundle = intent.getExtra();
//        if(bundle == null) return "";
//        System.out.println(bundle);
//    }
}