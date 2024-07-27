import 'package:ecostep/domain/date.dart';
import 'package:ecostep/domain/user.dart';

final dummyUser = User(
  id: '1233434',
  ecoBucksBalance: 123,
  personalization: false,
  joinedOn: Date.today().toString(),
);
