import 'package:get_it/get_it.dart';
import 'models/firebaseAPI.dart';
import 'models/CRUDModel.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  //ToDo: how to implement more than one collection path
  locator.registerLazySingleton(() => Api("users"));
  //This is currently throwing an error
//  locator.registerLazySingleton(() => Api("messages"));
  locator.registerLazySingleton(() => CRUDModel()) ;
}