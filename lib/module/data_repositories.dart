import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/kasie_exception.dart';
import 'package:dartz/dartz.dart';

import '../data/vehicle.dart';

abstract class DataRepositories {

  Future<Either<KasieException, List<User>>> getUsers({required String associationId});
  Future<Either<KasieException, List<Vehicle>>> getVehicles({required String associationId});
  Future<Either<KasieException, List<Vehicle>>> getOwnerVehicles({required String userId});

}


