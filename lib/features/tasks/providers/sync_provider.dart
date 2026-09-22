import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/remote/firestore_sync_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../lists/providers/lists_provider.dart';

final firestoreSyncServiceProvider = Provider<FirestoreSyncService>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return FirestoreSyncService(isarService);
});

final syncStateProvider =
    StateNotifierProvider<SyncNotifier, SyncStatus>((ref) {
  final syncService = ref.watch(firestoreSyncServiceProvider);
  return SyncNotifier(syncService, ref);
});

class SyncNotifier extends StateNotifier<SyncStatus> {
  final FirestoreSyncService _syncService;
  final Ref _ref;

  SyncNotifier(this._syncService, this._ref) : super(SyncStatus.idle) {
    _init();
  }

  void _init() {
    _ref.listen(authNotifierProvider, (previous, next) {
      if (next.user != null) {
        _syncService.startRealtimeSync(next.user!.uid);
        syncNow();
      } else {
        _syncService.stopRealtimeSync();
        state = SyncStatus.unauthenticated;
      }
    });
  }

  Future<void> syncNow() async {
    final authState = _ref.read(authNotifierProvider);
    if (authState.user == null) {
      state = SyncStatus.unauthenticated;
      return;
    }

    state = SyncStatus.syncing;
    try {
      await _syncService.syncAll(authState.user!.uid);
      state = SyncStatus.synced;
    } catch (e) {
      state = SyncStatus.error;
    }
  }
}
