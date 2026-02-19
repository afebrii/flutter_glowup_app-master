import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/datasources/auth_remote_datasource.dart';
import '../../../../data/models/requests/login_request_model.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDatasource _remoteDatasource;
  final AuthLocalDatasource _localDatasource;

  LoginBloc({
    AuthRemoteDatasource? remoteDatasource,
    AuthLocalDatasource? localDatasource,
  })  : _remoteDatasource = remoteDatasource ?? AuthRemoteDatasource(),
        _localDatasource = localDatasource ?? AuthLocalDatasource(),
        super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>(_onLoginReset);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    // Validate inputs
    if (event.email.isEmpty) {
      emit(LoginError('Email tidak boleh kosong'));
      return;
    }

    if (event.password.isEmpty) {
      emit(LoginError('Password tidak boleh kosong'));
      return;
    }

    final request = LoginRequestModel(
      email: event.email,
      password: event.password,
    );

    final result = await _remoteDatasource.login(request);

    await result.fold(
      (error) async => emit(LoginError(error)),
      (data) async {
        // Save auth data to local storage
        await _localDatasource.saveAuthData(
          token: data.token,
          user: data.user,
        );
        emit(LoginSuccess(data));
      },
    );
  }

  void _onLoginReset(LoginReset event, Emitter<LoginState> emit) {
    emit(LoginInitial());
  }
}
