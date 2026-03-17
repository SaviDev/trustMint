import 'api_client.dart';

class BandoRemote {
  final ApiClient apiClient;

  BandoRemote(this.apiClient);

  Future<List<dynamic>> fetchBandi() async {
    final response = await apiClient.dio.get('/bandi');
    return response.data as List<dynamic>;
  }

  Future<void> enroll(String bandoId) async {
    await apiClient.dio.post('/bandi/$bandoId/enroll');
  }
}
