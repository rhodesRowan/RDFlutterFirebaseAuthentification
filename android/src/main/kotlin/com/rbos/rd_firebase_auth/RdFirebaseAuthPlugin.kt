package com.rbos.rd_firebase_auth

import android.app.Activity
import android.os.Build
import android.text.TextUtils
import android.util.Log
import androidx.annotation.NonNull
import com.aboutyou.dart_packages.sign_in_with_apple.TAG
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.OAuthProvider
import com.snapchat.kit.sdk.SnapLogin
import com.snapchat.kit.sdk.core.controller.LoginStateController
import com.snapchat.kit.sdk.login.models.UserDataResponse
import com.snapchat.kit.sdk.login.networking.FetchUserDataCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


/** RdFirebaseAuthPlugin */
class RdFirebaseAuthPlugin(activity: Activity?): FlutterPlugin, MethodCallHandler, LoginStateController.OnLoginStateChangedListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private var _activity: Activity? = null
  private var _result: Result? = null

  fun registerWith(registrar: Registrar) {
    val channel = MethodChannel(registrar.messenger(), "rd_firebase_auth")
    channel.setMethodCallHandler(RdFirebaseAuthPlugin(registrar.activity()))
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "rd_firebase_auth")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android " + Build.VERSION.RELEASE)
    } else if (call.method == "snap_chat_login") {
      SnapLogin.getLoginStateController(_activity).addOnLoginStateChangedListener(this)
      SnapLogin.getAuthTokenManager(_activity).startTokenGrant()
      _result = result
    } else if (call.method == "snap_chat_logout") {
      SnapLogin.getLoginStateController(_activity).removeOnLoginStateChangedListener(this)
      SnapLogin.getAuthTokenManager(_activity).clearToken()
      _result = result
    }  else if (call.method == "apple_login") {

    } else {
      result.notImplemented()
    }
  }

  fun fetchUserData() {
    val query = "{me{bitmoji{avatar},displayName,externalId}}"
    SnapLogin.fetchUserData(_activity!!, query, null, object : FetchUserDataCallback {
      override fun onSuccess(userDataResponse: UserDataResponse?) {
        if (userDataResponse == null || userDataResponse.data == null) {
          return
        }
        val meData = userDataResponse.data.me
        if (meData == null) {
          _result!!.error("400", "Error in login", null)
          return
        }
        val data: MutableMap<String, Any> = HashMap()
        data["fullName"] = meData.displayName
        data["_id"] = meData.externalId
        data["token"] = SnapLogin.getAuthTokenManager(_activity).accessToken as Any
        if (meData.bitmojiData != null) {
          if (!TextUtils.isEmpty(meData.bitmojiData.avatar)) {
            data["avatar"] = meData.bitmojiData.avatar
          }
        }
        _result!!.success(data)
      }

      override fun onFailure(isNetworkError: Boolean, statusCode: Int) {
        _result!!.error("400", "Error in login", null)
      }
    })
  }

  override fun onLoginSucceeded() {
    fetchUserData()
  }

  override fun onLoginFailed() {}

  override fun onLogout() {
    _result!!.success("logout")
  }

  private fun loginWithApple() {
    val provider = OAuthProvider.newBuilder("apple.com")
    provider.setScopes(arrayOf("email", "name").toMutableList())

    // check if pending auth
    val pending = FirebaseAuth.getInstance().pendingAuthResult
    if (pending != null) {
      pending.addOnSuccessListener { authResult ->
        Log.d(TAG, "checkPending:onSuccess:$authResult")
        _result!!.success(authResult.user)
      }.addOnFailureListener { exception ->
        throw exception
      }
    } else {
      // login with apple
      FirebaseAuth.getInstance().startActivityForSignInWithProvider(this._activity!!, provider.build())
              .addOnSuccessListener { authResult ->
                // Sign-in successful!
                Log.d(TAG, "activitySignIn:onSuccess:${authResult.user}")
                val user = authResult.user
                _result!!.success(authResult.user)
              }
              .addOnFailureListener { exception ->
                throw exception
              }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
