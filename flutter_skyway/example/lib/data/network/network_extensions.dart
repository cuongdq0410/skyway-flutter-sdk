import 'dart:async';

extension NetworkExtensionsResponse<T> on Future<T> {
  easyCompose(
    Function(T data) response, {
    bool acceptNullData = false,
    required Function? onError,
  }) {
    then(
      (res) {
        if (!acceptNullData && res == null) {
          if (onError != null) {
            onError(Object());
          }
        } else {
          response(res);
        }
      },
      onError: (error) {
        if (onError != null) {
          onError(error);
        }
      },
    );
  }
}
