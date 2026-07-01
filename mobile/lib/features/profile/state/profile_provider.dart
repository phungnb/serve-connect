import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../core/providers/api_provider.dart';

final profileApiProvider = Provider<ApiService>((ref) => ref.read(apiServiceProvider));