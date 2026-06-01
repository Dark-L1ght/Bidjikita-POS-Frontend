import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits the initial connectivity state immediately, then streams changes.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) async* {
  yield await Connectivity().checkConnectivity();
  yield* Connectivity().onConnectivityChanged;
});

/// Simple boolean: true = at least one non-none interface is active.
final isConnectedProvider = Provider<bool>((ref) {
  return ref
      .watch(connectivityProvider)
      .when(
        data: (results) => results.any((r) => r != ConnectivityResult.none),
        loading: () => true, // optimistic while initialising
        error: (err, st) => false,
      );
});
