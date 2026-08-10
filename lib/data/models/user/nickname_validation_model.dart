enum NicknameValidationState { idle, checking, available, duplicate, error }

typedef NicknameAvailabilityValidator = Future<bool> Function(String nickname);
