import 'package:equatable/equatable.dart';

abstract class BaseCubitState extends Equatable {
  const BaseCubitState();

  @override
  List<Object> get props => [];
}

class BaseStateInit extends BaseCubitState {
  const BaseStateInit();
}
