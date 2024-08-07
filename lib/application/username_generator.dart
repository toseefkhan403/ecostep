import 'dart:math';

class UsernameGenerator {
  final List<String> _adjectives = [
    'flexible',
    'green',
    'quick',
    'brave',
    'happy',
    'silent',
    'bright',
    'clever',
    'shiny',
    'blue',
    'bold',
    'calm',
    'eager',
    'gentle',
    'jolly',
    'kind',
    'strong',
    'swift',
    'mighty',
    'wise',
    'fierce',
    'noble',
    'proud',
    'gentle',
    'valiant',
    'fearless',
    'sturdy',
    'serene',
    'radiant',
    'vivid',
    'loyal',
    'faithful',
  ];

  final List<String> _nouns = [
    'spy',
    'raccoon',
    'lion',
    'tiger',
    'eagle',
    'fox',
    'bear',
    'dolphin',
    'panda',
    'wolf',
    'shark',
    'whale',
    'cheetah',
    'penguin',
    'koala',
    'owl',
    'hawk',
    'falcon',
    'dragon',
    'unicorn',
    'phoenix',
    'griffin',
    'panther',
    'lynx',
    'bobcat',
    'mustang',
    'orca',
    'puma',
    'leopard',
    'jaguar',
    'lynx',
    'cougar',
  ];

  String _capitalize(String word) {
    return '${word[0].toUpperCase()}${word.substring(1)}';
  }

  String generateUsername() {
    final random = Random();
    final adjective =
        _capitalize(_adjectives[random.nextInt(_adjectives.length)]);
    final noun = _capitalize(_nouns[random.nextInt(_nouns.length)]);
    return '$adjective$noun';
  }
}
