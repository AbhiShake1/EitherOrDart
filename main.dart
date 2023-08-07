Future<void> main() async {
  final res = await repo();
  final processedRes = res.on(
    data: (data) {
      print('data::$data');
      return data;
    },
    error: (error) => () {
      print('errorOccurred::$error');
      return 'error::$error';
    },
  );
  print(processedRes?.data ?? 'error::${processedRes?.error?.call()}');
}

Future<EitherOr<String>> repo() async {
  return EitherOr.execute(
    () => clientFunction('a'),
    // orElse: () => null,
    // orElse: () => 'null',
  );
}

Future<String> clientFunction(String text) async {
  // throw Exception('$text');
  // throw text;
  return 'fromClient::$text';
}

class EitherOr<T> {
  final T? _data;
  final dynamic _error;

  const EitherOr._({T? data, dynamic error})
      : _data = data,
        _error = error;

  factory EitherOr.data(T? data) => EitherOr._(data: data);

  factory EitherOr.error(dynamic error) => EitherOr._(error: error);

  DataOrError<FT?, FE?>? on<FT, FE>({FT Function(T? data)? data, FE Function(dynamic error)? error}) {
    if (_data != null) {
      data ??= (data) => _data as FT;
      final res = data(_data);
      return (data: res, error: null);
    }
    if (_error != null && error != null) {
      final res = error(_error);
      return (data: null, error: res);
    }
    return null;
  }

  static Future<EitherOr<T>> execute<T>(Future<T> Function() function, {T? Function()? orElse}) async {
    var hasException = false;
    try {
      final res = await function();
      return EitherOr.data(res);
    } catch (e) {
      hasException = true;
      return EitherOr.error(e);
    } finally {
      if (hasException && orElse != null) {
        try {
          return EitherOr.data(orElse());
        } catch (e) {
          return EitherOr.error(e);
        }
      }
    }
  }
}

typedef DataOrError<T, E> = ({T? data, E? error});
