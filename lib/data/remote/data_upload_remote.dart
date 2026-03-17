import 'api_client.dart';

class DataUploadRemote {
  final ApiClient apiClient;

  DataUploadRemote(this.apiClient);

  Future<void> uploadSensorBatch(List<Map<String, dynamic>> payload) async {
    // In produzione verrebbe compresso con Gzip
    await apiClient.dio.post('/sensor-data', data: payload);
  }
}
