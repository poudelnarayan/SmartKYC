import 'package:flutter_bloc/flutter_bloc.dart';
import './user_detail_form_event.dart';
import './user_detail_form_state.dart';

class UserDetailFormBloc extends Bloc<UserDetailFormEvent, UserDetailFormState> {
  UserDetailFormBloc() : super(UserDetailFormInitial()) {
    // Add event handlers here
  }
}