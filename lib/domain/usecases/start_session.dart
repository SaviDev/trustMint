class StartSessionUseCase {
  Future<void> execute(String bandoId, bool requiresForegroundService) async {
    // TODO: Istanzia o ripristina la Sessione
    // Se richiede FGS -> flutter_background_service start
    // Altrimenti raccolta foreground locale
  }
}
