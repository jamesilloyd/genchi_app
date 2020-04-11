import 'package:get_it/get_it.dart';
import 'models/firebaseAPI.dart';
import 'models/CRUDModel.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => Api('products'));
  locator.registerLazySingleton(() => CRUDModel()) ;
}