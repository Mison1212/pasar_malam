abstract class AuthRepository {
  
  Future<String> verifyFirebaseToken(String firebaseToken);
}
