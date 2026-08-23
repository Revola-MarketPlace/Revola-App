import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/storage_service.dart';
import 'api_exception.dart';

class ApiClient {
  late final Dio dio;
  final StorageService storageService;

  ApiClient(this.storageService) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          String message =
              'Something went wrong. Please check your connection.';
          if (e.response?.data != null && e.response?.data is Map) {
            message =
                e.response?.data['message'] ??
                e.response?.data['error'] ??
                message;
          }
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: ApiException(
                message: message,
                statusCode: e.response?.statusCode,
                data: e.response?.data,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw e.error as ApiException;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw e.error as ApiException;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw e.error as ApiException;
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw e.error as ApiException;
    }
  }
}
