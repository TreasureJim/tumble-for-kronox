import 'package:flutter/foundation.dart';

/* Can be implemented by abstract
   classes to enfore common methods found in repositories. */
@immutable
abstract class IGenericService<T> {
  Future<void> add(T data);

  Future<void> update(T data);

  Future<void> remove(String id, String accessStores);

  Future<void> removeAll();

  Future<void> getAll();
}
