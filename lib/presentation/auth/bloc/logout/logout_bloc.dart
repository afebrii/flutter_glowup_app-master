import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/auth_remote_datasource.dart';
import 'logout_event.dart';
import 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AuthRemoteDatasource _remoteDatasource;

  LogoutBloc({
    AuthRemoteDatasource? remoteDatasource,
  })  : _remoteDatasource = remoteDatasource ?? AuthRemoteDatasource(),
        super(LogoutInitial()) {
    on<LogoutSubmitted>(_onLogoutSubmitted);
  }

  Future<void> _onLogoutSubmitted(
    LogoutSubmitted event,
    Emitter<LogoutState> emit,
  ) async {
    emit(LogoutLoading());

    final result = await _remoteDatasource.logout();

    result.fold(
      (error) => emit(LogoutError(error)),
      (_) => emit(LogoutSuccess()),
    );
  }
}
