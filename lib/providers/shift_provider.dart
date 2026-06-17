import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shift.dart';
import '../services/api_service.dart';

// ---------------------------------------------------------------------------
// Shift state
// ---------------------------------------------------------------------------

@immutable
class ShiftState {
  final Shift? activeShift;
  final bool isLoading;
  final String? error;

  const ShiftState({this.activeShift, this.isLoading = false, this.error});

  bool get hasActiveShift => activeShift != null;

  ShiftState copyWith({
    Shift? activeShift,
    bool? isLoading,
    String? error,
    bool clearShift = false,
    bool clearError = false,
  }) {
    return ShiftState(
      activeShift: clearShift ? null : activeShift ?? this.activeShift,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// ---------------------------------------------------------------------------
// Shift notifier
// ---------------------------------------------------------------------------

class ShiftNotifier extends Notifier<ShiftState> {
  @override
  ShiftState build() => const ShiftState();

  /// Check for an active shift.
  Future<void> checkActive(String token) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ApiService.getActiveShift(token: token);
      if (data != null) {
        state = state.copyWith(
          activeShift: Shift.fromJson(data),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, clearShift: true);
      }
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal terhubung ke server',
      );
    }
  }

  /// Clock in with starting cash.
  Future<void> clockIn(String token, int startingCash) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final shift = await ApiService.clockIn(
        token: token,
        startingCash: startingCash,
      );
      state = state.copyWith(activeShift: shift, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal terhubung ke server',
      );
    }
  }

  /// Clock out with actual cash/QRIS counts.
  Future<void> clockOut(
    String token, {
    int? actualCash,
    int? actualQris,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ApiService.clockOut(
        token: token,
        actualCash: actualCash,
        actualQris: actualQris,
      );
      state = state.copyWith(isLoading: false, clearShift: true);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal terhubung ke server',
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final shiftProvider = NotifierProvider<ShiftNotifier, ShiftState>(
  ShiftNotifier.new,
);
