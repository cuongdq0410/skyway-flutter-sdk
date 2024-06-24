import 'package:bloc/bloc.dart';
import 'base_state.dart';

abstract class BaseCubit<S extends BaseCubitState> extends Cubit<S> {
  BaseCubit(S initialState) : super(initialState);
}
