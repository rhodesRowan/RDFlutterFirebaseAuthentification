
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:convert' as convert;
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class RdFirebaseAuth {

  static const MethodChannel _channel =
      const MethodChannel('rd_firebase_auth');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<User> loginWithSnapchat(String url) async {
    try {
      var snapchatAuthToken = await snapchatLogin;
      var firebaseAuthToken = await getFirebaseToken(url, snapchatAuthToken);
      return signInWithSnapchat(firebaseAuthToken);
    } on Exception catch(exception) {
      throw exception;
    }
    // login with credential
  }

  static Future<String> get snapchatLogin async {
    try {
      final Map<dynamic, dynamic> result =
      await _channel.invokeMethod('snap_chat_login');
      final String token = result["token"];
      return (token);
    } on PlatformException catch(exception) {
      // handle error
      throw exception;
    }
  }

  static Future<String> getFirebaseToken(String url, String snapchatAuthToken) async {
    try {
      var response = await http.get(url);
      var jsonResponse = convert.jsonDecode(response.body);
      var token = jsonResponse["token"];
      return token;
    } on Exception catch (exception) {
      // handle exceptiion
      throw exception;
    }
  }

  static Future<User> signInWithSnapchat(firebaseAuthToken) async {
    try {
       var signIn = await FirebaseAuth.instance.signInWithCustomToken(firebaseAuthToken);
       return signIn.user;
    } on FirebaseAuthException catch (exception) {
      // handle exception
      throw exception;
    }
  }

  static Future<String> get snapchatLogout async {
    return await _channel.invokeMethod('snap_chat_logout');
  }


  static Future<User> signInWithApple(String clientID, String redirectUri) async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    var appleCredential = await getAppleCredential(clientID, redirectUri, nonce);
    // create oauth provider
      var credential = getAppleOAuthCredential(appleCredential, nonce);
      return await signInWithAppleCredential(appleCredential);
  }

  static Future<User> signInWithAppleCredential(appleCredential) async {
    try {
       var credential = await FirebaseAuth.instance.signInWithCredential(appleCredential);
       return credential.user;
    } on Exception catch (exception) {
        throw exception;
    }
  }

  static OAuthCredential getAppleOAuthCredential(AuthorizationCredentialAppleID credential, String nonce) {
      final provider = OAuthProvider("apple.com").credential(
        accessToken: credential.authorizationCode,
        idToken: credential.identityToken,
        rawNonce: nonce,
      );
      return provider;
  }

  static Future<AuthorizationCredentialAppleID> getAppleCredential(String clientID, String redirectUri, String nonce) async {
    try {

      return await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.fullName
      ],webAuthenticationOptions: WebAuthenticationOptions(
        clientId: // serviceID
        clientID,
        redirectUri: Uri.parse(
            redirectUri
        ),
      ),
        nonce: nonce,
      );
    } on Exception catch (exception) {
      throw exception;
    }
  }

  static String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

}
