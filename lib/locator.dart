import 'package:get_it/get_it.dart';
import 'models/CRUDModel.dart';
import 'models/authentication.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => FirebaseCRUDModel());
  locator.registerLazySingleton(() => AuthenticationService());
}