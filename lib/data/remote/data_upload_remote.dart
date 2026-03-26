import 'api_client.dart';

class DataUploadRemote {
  final ApiClient apiClient;

  DataUploadRemote(this.apiClient);

  /// Upload a single chunk (10s batch) to the backend.
  Future<void> uploadChunk({
    required String sessionId,
    required String chunkHash,
    required String dataPayload,
  }) async {
    await apiClient.dio.post('/sensor-data/chunk', data: {
      'sessionId': sessionId,
      'chunkHash': chunkHash,
      'payload': dataPayload,
    });
  }

  /// Finalize the session by sending the final rolling hash.
  Future<void> finalizeSession({
    required String sessionId,
    required String finalHash,
  }) async {
    await apiClient.dio.post('/sensor-data/finalize', data: {
      'sessionId': sessionId,
      'finalHash': finalHash,
    });
  }

  /// Legacy: upload raw sensor batch (kept for compatibility)
  Future<void> uploadSensorBatch(List<Map<String, dynamic>> payload) async {
    await apiClient.dio.post('/sensor-data', data: payload);
  }
}
