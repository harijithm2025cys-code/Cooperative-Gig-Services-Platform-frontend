import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
  debugPrint("Handling background FCM message: ${message.messageId} - ${message.notification?.title}");
}

class FirebaseRealtimeService {
  static final FirebaseRealtimeService _instance = FirebaseRealtimeService._internal();
  factory FirebaseRealtimeService() => _instance;
  FirebaseRealtimeService._internal();

  FirebaseFirestore? _firestore;
  FirebaseMessaging? _messaging;
  String? _fcmToken;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Core, Firestore, and Cloud Messaging
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _firestore = FirebaseFirestore.instance;
      _messaging = FirebaseMessaging.instance;

      // Request FCM Permissions (Android 13+ & iOS)
      final settings = await _messaging?.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM Notification permission status: ${settings?.authorizationStatus}');

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Get device FCM registration token
      try {
        _fcmToken = await _messaging?.getToken();
        debugPrint('Device FCM Token: $_fcmToken');
      } catch (e) {
        debugPrint('Could not fetch FCM token: $e');
      }

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Received foreground FCM message: ${message.notification?.title} - ${message.notification?.body}');
      });

      _isInitialized = true;
      debugPrint('Firebase Realtime & Messaging layer initialized successfully.');
    } catch (e) {
      debugPrint('Firebase initialization notice (running in resilient mode): $e');
      _isInitialized = false;
    }
  }

  // --------------------------------------------------------------------------
  // FIRESTORE LIVE STREAMS (In-App Live Status & Location Watching)
  // --------------------------------------------------------------------------

  /// Stream live status changes for a booking (e.g. pending -> accepted -> in_progress -> completed)
  Stream<Map<String, dynamic>?> streamBooking(String bookingId) {
    if (_firestore == null) {
      return const Stream.empty();
    }
    return _firestore!
        .collection('live_bookings')
        .doc(bookingId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  /// Update live booking status in Firestore so subscribed clients react instantly
  Future<void> updateLiveBookingState({
    required String bookingId,
    required String status,
    String? workerId,
    String? householdId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    Map<String, dynamic>? extra,
  }) async {
    if (_firestore == null) return;
    try {
      final docRef = _firestore!.collection('live_bookings').doc(bookingId);
      final payload = <String, dynamic>{
        'booking_id': bookingId,
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      };
      if (workerId != null) payload['worker_id'] = workerId;
      if (householdId != null) payload['household_id'] = householdId;
      if (checkInTime != null) payload['check_in_time'] = checkInTime.toIso8601String();
      if (checkOutTime != null) payload['check_out_time'] = checkOutTime.toIso8601String();
      if (extra != null) payload.addAll(extra);

      await docRef.set(payload, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore updateLiveBookingState error: $e');
    }
  }

  /// Stream live worker GPS location (for real-time map tracking when on active gig)
  Stream<Map<String, dynamic>?> streamWorkerLocation(String workerId) {
    if (_firestore == null) {
      return const Stream.empty();
    }
    return _firestore!
        .collection('worker_locations')
        .doc(workerId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  /// Publish worker's live GPS coordinates to Firestore
  Future<void> updateWorkerLiveLocation({
    required String workerId,
    required double latitude,
    required double longitude,
    double? heading,
  }) async {
    if (_firestore == null) return;
    try {
      await _firestore!.collection('worker_locations').doc(workerId).set({
        'worker_id': workerId,
        'latitude': latitude,
        'longitude': longitude,
        'heading': heading ?? 0.0,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore updateWorkerLiveLocation error: $e');
    }
  }

  /// Listen for new dispatch alerts targeted at a worker or skill category
  Stream<QuerySnapshot<Map<String, dynamic>>>? streamIncomingJobAlerts(String workerSkill) {
    if (_firestore == null) return null;
    return _firestore!
        .collection('live_bookings')
        .where('status', isEqualTo: 'pending')
        .where('skill', isEqualTo: workerSkill)
        .snapshots();
  }
}
