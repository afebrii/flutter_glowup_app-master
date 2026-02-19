import '../../../../data/models/responses/auth_response_model.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final AuthResponseModel data;

  LoginSuccess(this.data);
}

class LoginError extends LoginState {
  final String message;

  LoginError(this.message);
}
