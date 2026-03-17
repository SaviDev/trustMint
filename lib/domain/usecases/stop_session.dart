class StopSessionUseCase {
  Future<void> execute(String sessionId) async {
    // TODO: Ferma raccolta, marca session_dao come 'stopped'
    // Trigger sync su WorkManager
  }
}
