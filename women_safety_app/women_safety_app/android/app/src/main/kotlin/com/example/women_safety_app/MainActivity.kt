package com.example.women_safety_app

import android.content.Intent
import android.net.Uri
import android.telephony.SmsManager
import android.Manifest
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "com.example.women_safety_app/emergency"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"sendSms" -> {
					val number: String? = call.argument("number")
					val message: String? = call.argument("message")
					if (number == null || message == null) {
						result.error("ARG_ERROR", "Missing number or message", null)
						return@setMethodCallHandler
					}
					try {
						val smsManager = SmsManager.getDefault()
						smsManager.sendTextMessage(number, null, message, null, null)
						result.success(true)
					} catch (e: Exception) {
						result.error("SMS_ERROR", e.message, null)
					}
				}
				"callNumber" -> {
					val number: String? = call.argument("number")
					if (number == null) {
						result.error("ARG_ERROR", "Missing number", null)
						return@setMethodCallHandler
					}
					Log.d("MainActivity", "callNumber requested for: $number")
					try {
						val hasPermission = ContextCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE) == PackageManager.PERMISSION_GRANTED
						Log.d("MainActivity", "CALL_PHONE permission granted: $hasPermission")
						if (hasPermission) {
							val intent = Intent(Intent.ACTION_CALL)
							intent.data = Uri.parse("tel:$number")
							intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
							Log.d("MainActivity", "Starting ACTION_CALL intent with tel:$number")
							startActivity(intent)
							Log.d("MainActivity", "startActivity completed")
							result.success(true)
						} else {
							Log.e("MainActivity", "CALL_PHONE permission not granted")
							result.error("PERMISSION_DENIED", "CALL_PHONE permission not granted", null)
						}
					} catch (e: Exception) {
						Log.e("MainActivity", "Exception during call: ${e.message}", e)
						result.error("CALL_ERROR", e.message, null)
					}
				}
				else -> result.notImplemented()
			}
		}
	}
}
