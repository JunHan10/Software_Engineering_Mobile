// lib/services/auth_service.dart
//
// Central place to manage "who is logged in" for the app.
// - We authenticate using SharedPrefsUserRepository (local JSON in SharedPreferences).
// - The active userId is stored in SharedPreferences under 'activeUserId'.
// - Other screens (Dashboard/Profile/Active Loans) can read that id.

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../repositories/shared_prefs_user_repository.dart';
import '../api/api.dart';

class AuthService {
  static const _activeUserKey = 'activeUserId';
  final _repo = SharedPrefsUserRepository();
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Attempt to log in with email + password via server API.
  /// Returns true on success, false on failure.
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Store user session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_activeUserKey, data['userId'] ?? email);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Attempt to log in with email + password (local fallback).
  /// Returns the User on success, or null if credentials are invalid.
  Future<User?> loginWithEmailPassword(String email, String password) async {
    final user = await _repo.findByEmailAndPassword(email, password);
    if (user != null && user.id != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeUserKey, user.id!);
    }
    return user;
  }

  /// Clear session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeUserKey);
  }

  /// Returns the active user id if someone is logged in, else null.
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeUserKey);
  }

  /// Convenience: fetch the full active User (or null)
  Future<User?> getCurrentUser() async {
    final id = await getCurrentUserId();
    if (id == null) return null;
    return _repo.findById(id);
  }

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Check if Google Sign-In is available
      if (!await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut(); // Clear any cached state
      }
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final firebase_auth.UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);
      
      final firebase_auth.User? firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // Create or update user in local repository
      final user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        password: '', // No password for Google sign-in
        firstName: firebaseUser.displayName?.split(' ').first ?? 'User',
        lastName: firebaseUser.displayName?.split(' ').skip(1).join(' ') ?? '',
        currency: 0.0,
        assets: const [],
        hippoBalanceCents: 0,
      );

      // Save user to local repository
      await _repo.save(user);
      
      // Set as active user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeUserKey, firebaseUser.uid);

      return user;
    } catch (e) {
      return null;
    }
  }

  /// Sign out from both Google and Firebase
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    await logout(); // Clear local session
  }
}
