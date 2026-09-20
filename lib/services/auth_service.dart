import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  // Local fallback user for offline development/testing
  final ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier<UserModel?>(null);

  bool get isFirebaseAvailable => _auth != null;

  void initialize({FirebaseAuth? auth, FirebaseFirestore? firestore}) {
    _auth = auth;
    _firestore = firestore;
  }

  UserModel? get currentUser => currentUserNotifier.value;

  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (_auth != null && _firestore != null) {
      try {
        final credential = await _auth!.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        final uid = credential.user!.uid;

        // Fetch user role and details from Firestore users collection
        final doc = await _firestore!.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final user = UserModel.fromMap(doc.data()!, documentId: uid);
          currentUserNotifier.value = user;
          return user;
        } else {
          // Default fallback if profile document doesn't exist yet
          final fallback = UserModel(
            uid: uid,
            name: credential.user!.displayName ?? cleanEmail.split('@').first,
            email: cleanEmail,
            phone: '',
            role: UserRoles.customer,
            createdAt: DateTime.now(),
          );
          currentUserNotifier.value = fallback;
          return fallback;
        }
      } on FirebaseAuthException catch (e) {
        throw _handleAuthException(e);
      } catch (e) {
        throw 'Login failed: ${e.toString()}';
      }
    } else {
      // Offline student demo simulation mode
      await Future.delayed(const Duration(milliseconds: 600));

      // Determine role from email keywords if demo login
      String role = UserRoles.customer;
      if (cleanEmail.contains('admin')) {
        role = UserRoles.admin;
      } else if (cleanEmail.contains('waiter')) {
        role = UserRoles.waiter;
      } else if (cleanEmail.contains('kitchen')) {
        role = UserRoles.kitchen;
      }

      final demoUser = UserModel(
        uid: 'demo_${cleanEmail.replaceAll('@', '_').replaceAll('.', '_')}',
        name: cleanEmail.split('@').first.toUpperCase(),
        email: cleanEmail,
        phone: '9876543210',
        role: role,
        createdAt: DateTime.now(),
      );

      currentUserNotifier.value = demoUser;
      return demoUser;
    }
  }

  // Register new user with email, password, and role
  Future<UserModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String phone,
    required String role,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (_auth != null && _firestore != null) {
      try {
        final credential = await _auth!.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        final uid = credential.user!.uid;
        await credential.user!.updateDisplayName(name.trim());

        final newUser = UserModel(
          uid: uid,
          name: name.trim(),
          email: cleanEmail,
          phone: phone.trim(),
          role: role,
          createdAt: DateTime.now(),
        );

        // Store user details in Firestore 'users' collection
        await _firestore!.collection('users').doc(uid).set(newUser.toMap());

        currentUserNotifier.value = newUser;
        return newUser;
      } on FirebaseAuthException catch (e) {
        throw _handleAuthException(e);
      } catch (e) {
        throw 'Registration failed: ${e.toString()}';
      }
    } else {
      // Offline student demo simulation mode
      await Future.delayed(const Duration(milliseconds: 600));

      final newUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        email: cleanEmail,
        phone: phone.trim(),
        role: role,
        createdAt: DateTime.now(),
      );

      currentUserNotifier.value = newUser;
      return newUser;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (_auth != null) {
      try {
        await _auth!.sendPasswordResetEmail(email: cleanEmail);
      } on FirebaseAuthException catch (e) {
        throw _handleAuthException(e);
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
    currentUserNotifier.value = null;
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}
