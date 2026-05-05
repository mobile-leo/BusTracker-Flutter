import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:http/http.dart' as http;
import '../models/bus_line_model.dart';
import '../models/bus_position_model.dart';
import '../models/bus_stop_model.dart';
import '../models/arrival_forecast_model.dart';

class SPTransRemoteDataSource {
  static const String _baseUrl = 'https://api.olhovivo.sptrans.com.br/v2.1';

  final String apiToken;
  final CookieJar _cookieJar = CookieJar();
  late final Dio _dio;
  bool _isAuthenticating = false;

  SPTransRemoteDataSource({required this.apiToken}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.plain,
      ),
    );
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  Future<bool> authenticate() async {
    if (apiToken.isEmpty) return false;
    if (_isAuthenticating) return false;
    _isAuthenticating = true;
    try {
      final encodedToken = Uri.encodeComponent(apiToken);
      final uri = Uri.parse('$_baseUrl/Login/Autenticar?token=$encodedToken');

      final httpClient = http.Client();
      final response = await httpClient.post(
        uri,
        headers: {'Content-Length': '0'},
      );
      httpClient.close();

      final body = response.body.trim().toLowerCase();
      final success = response.statusCode == 200 && body == 'true';

      if (success) {
        final cookieHeader = response.headers['set-cookie'];
        if (cookieHeader != null) {
          final cookieObjects = <Cookie>[];
          for (final cookieStr
              in cookieHeader.split(',').map((c) => c.trim())) {
            final nameValue = cookieStr.split(';').first.trim();
            if (nameValue.contains('=')) {
              final eqIdx = nameValue.indexOf('=');
              final name = nameValue.substring(0, eqIdx).trim();
              final value = nameValue.substring(eqIdx + 1).trim();
              if (name.isNotEmpty) cookieObjects.add(Cookie(name, value));
            }
          }
          await _cookieJar.saveFromResponse(Uri.parse(_baseUrl), cookieObjects);
        }
      }

      return success;
    } catch (_) {
      return false;
    } finally {
      _isAuthenticating = false;
    }
  }

  Future<T?> _get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T? Function(dynamic data) parser,
  }) async {
    Future<Response<dynamic>> doRequest() => _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(responseType: ResponseType.plain),
    );

    Response response;
    try {
      response = await doRequest();
    } catch (_) {
      return null;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      final ok = await authenticate();
      if (!ok) return null;
      try {
        response = await doRequest();
      } catch (_) {
        return null;
      }
    }

    if (response.statusCode != 200) return null;

    final raw = response.data?.toString().trim() ?? '';
    if (raw.isEmpty || raw == 'false' || raw == 'null') return null;

    try {
      return parser(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<List<BusLineModel>> searchLines(String query) async {
    final result = await _get<List<BusLineModel>>(
      '/Linha/Buscar',
      queryParameters: {'termosBusca': query},
      parser: (data) {
        if (data is! List) return [];
        return data
            .map((e) => BusLineModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return result ?? [];
  }

  Future<AllBusPositionsResponse?> getAllBusPositions() async {
    return _get<AllBusPositionsResponse>(
      '/Posicao',
      parser: (data) {
        if (data is! Map<String, dynamic>) return null;
        return AllBusPositionsResponse.fromJson(data);
      },
    );
  }

  Future<List<LineBusPositionsModel>> getBusPositionsByLine(
    int lineCode,
  ) async {
    final result = await _get<List<LineBusPositionsModel>>(
      '/Posicao/Linha',
      queryParameters: {'codigoLinha': lineCode},
      parser: (data) {
        if (data is List) {
          return data
              .map(
                (e) =>
                    LineBusPositionsModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        }
        if (data is Map<String, dynamic>) {
          return [LineBusPositionsModel.fromJson(data)];
        }
        return [];
      },
    );
    return result ?? [];
  }

  Future<List<BusStopModel>> getStopsByLine(int lineCode) async {
    final result = await _get<List<BusStopModel>>(
      '/Parada/BuscarParadasPorLinha',
      queryParameters: {'codigoLinha': lineCode},
      parser: (data) {
        if (data is! List) return [];
        return data
            .map((e) => BusStopModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return result ?? [];
  }

  Future<List<BusStopModel>> searchStops(String query) async {
    final result = await _get<List<BusStopModel>>(
      '/Parada/Buscar',
      queryParameters: {'termosBusca': query},
      parser: (data) {
        if (data is! List) return [];
        return data
            .map((e) => BusStopModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return result ?? [];
  }

  Future<ArrivalForecastModel?> getArrivalForecast(
    int stopCode,
    int lineCode,
  ) async {
    return _get<ArrivalForecastModel>(
      '/Previsao',
      queryParameters: {'codigoParada': stopCode, 'codigoLinha': lineCode},
      parser: (data) {
        if (data is! Map<String, dynamic>) return null;
        return ArrivalForecastModel.fromJson(data);
      },
    );
  }

  Future<ArrivalForecastModel?> getArrivalForecastByStop(int stopCode) async {
    return _get<ArrivalForecastModel>(
      '/Previsao/Parada',
      queryParameters: {'codigoParada': stopCode},
      parser: (data) {
        if (data is! Map<String, dynamic>) return null;
        return ArrivalForecastModel.fromJson(data);
      },
    );
  }
}

class AllBusPositionsResponse {
  final String timestamp;
  final List<LineBusPositionsModel> lines;

  AllBusPositionsResponse({required this.timestamp, required this.lines});

  factory AllBusPositionsResponse.fromJson(Map<String, dynamic> json) {
    final rawLines = json['l'] as List<dynamic>? ?? [];
    return AllBusPositionsResponse(
      timestamp: json['hr'] as String? ?? '',
      lines: rawLines
          .map((l) => LineBusPositionsModel.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}
