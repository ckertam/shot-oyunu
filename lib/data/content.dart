// Oyun modlarının statik içerikleri: kartlar, sorular ve çark seçenekleri.
// Hepsi Türkçe ve parti/shot oyunu bağlamına uygun, zararsız içerikler.

class PlayingCard {
  final String rank;
  final String suit;
  final String rule;

  const PlayingCard(this.rank, this.suit, this.rule);

  bool get isRed => suit == 'Kupa' || suit == 'Karo';
}

const Map<String, String> kingsCupRules = {
  'A': 'Herkes içer!',
  '2': 'Sen iç.',
  '3': 'Solundaki içer.',
  '4': 'Kızlar içer.',
  '5': 'Erkekler içer.',
  '6': 'Sağındaki içer.',
  '7': 'Gökyüzüne bak! Son bakan içer.',
  '8': 'Bir "eş" seç — sen her içtiğinde o da içer.',
  '9': 'Bir kural koy. Kurala uymayan içer.',
  '10': 'Bir kategori söyle, sırayla örnek verin. Tıkanan içer.',
  'J': 'Başparmak ustası ol — istediğin an parmağını masaya koy, son koyan içer.',
  'Q': 'Soru ustası ol — sana soru sorana cevap veremeyen içer.',
  'K': 'Ortadaki kadehe biraz dök ve bir kural koy. Son papazı çeken bu kadehi içer!',
};

const List<String> _ranks = [
  'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K',
];
// Not: ♠♥♦♣ unicode sembolleri Flutter web'in CanvasKit yazı tipinde tofu
// (□) olarak render oluyor; platformdan bağımsız güvenilir çalışması için
// takım adları Türkçe yazı olarak tutuluyor.
const List<String> _suits = ['Maça', 'Kupa', 'Karo', 'Sinek'];

List<PlayingCard> buildDeck() {
  final deck = <PlayingCard>[];
  for (final suit in _suits) {
    for (final rank in _ranks) {
      deck.add(PlayingCard(rank, suit, kingsCupRules[rank]!));
    }
  }
  return deck;
}

const List<String> neverHaveIEver = [
  'Hiç yapmadım... yanlış kişiye mesaj atmadım.',
  'Hiç yapmadım... halka açık bir yerde düşmedim.',
  'Hiç yapmadım... bir yalanı unutup kendimi ele vermedim.',
  'Hiç yapmadım... sınavdan/işten kaçmak için bahane uydurmadım.',
  'Hiç yapmadım... eski sevgilimi gizlice takip etmedim.',
  'Hiç yapmadım... bir konuda tamamen yalan söylemedim.',
  'Hiç yapmadım... arkadaşımın kıyafetini izinsiz giymedim.',
  'Hiç yapmadım... bir toplantıda/derste uyuklamadım.',
  'Hiç yapmadım... yanlışlıkla birinin özel mesajını herkese göndermedim.',
  'Hiç yapmadım... bir şarkıyı sözlerini bilmeden bağıra bağıra söylemedim.',
  'Hiç yapmadım... geç kaldığım için sahte bir mazeret uydurmadım.',
  'Hiç yapmadım... aynı kıyafeti üst üste 3 gün giymedim.',
  'Hiç yapmadım... bir filmi/diziyi izlemiş gibi yapmadım.',
  'Hiç yapmadım... telefonumun şarjı bittiği için birinden özür dilemedim.',
  'Hiç yapmadım... bir grup sohbetinde yanlış kişiyle dalga geçmedim.',
  'Hiç yapmadım... gece yarısı acıkıp bir şeyler pişirmedim.',
  'Hiç yapmadım... bir yabancıyla tanıdığımı sanıp selam vermedim.',
  'Hiç yapmadım... sosyal medyada eski fotoğraflarımı silmedim.',
  'Hiç yapmadım... bir yalan söyleyip hemen unuttum sanmadım.',
  'Hiç yapmadım... bu masadaki birine gizli bir sırrım olmadı.',
];

const List<String> mostLikelyTo = [
  'Bu grupta kim daha çok geç kalır?',
  'Bu grupta kim daha çok yalan söyler (zararsız da olsa)?',
  'Bu grupta kim daha çok magazin haberi takip eder?',
  'Bu grupta kim bir gün ünlü olur?',
  'Bu grupta kim daha çok dram yaratır?',
  'Bu grupta kim en kolay ikna olur?',
  'Bu grupta kim gece yarısı en çok mesaj atar?',
  'Bu grupta kim tatilde en çok fotoğraf çeker?',
  'Bu grupta kim bir gün kendi işini kurar?',
  'Bu grupta kim en çok "bir dakika sonra geliyorum" der ve gelmez?',
  'Bu grupta kim en tatlı dilli olanı?',
  'Bu grupta kim bir realite şovda oynardı?',
  'Bu grupta kim en çabuk küser?',
  'Bu grupta kim en çok "ben hallederim" der?',
  'Bu grupta kim gizli bir yeteneği saklıyor olabilir?',
  'Bu grupta kim en çok grup sohbetini susturur (spam atar)?',
  'Bu grupta kim bir gün kitap yazar?',
  'Bu grupta kim en çabuk pes eder?',
  'Bu grupta kim en iyi yalan atar (şaka amaçlı)?',
  'Bu grupta kim en çok "son bir tane daha" der?',
];

class WheelSegment {
  final String label;
  final int colorValue;

  const WheelSegment(this.label, this.colorValue);
}

const List<WheelSegment> wheelSegments = [
  WheelSegment('2 Yudum İç', 0xFFEF476F),
  WheelSegment('Sağındakine Ver', 0xFFFFD166),
  WheelSegment('Bir Kural Koy', 0xFF06D6A0),
  WheelSegment('Herkes İçsin', 0xFF118AB2),
  WheelSegment('1 Yudum İç', 0xFF8338EC),
  WheelSegment('Şarkı Söyle\nYoksa İç', 0xFFFB5607),
  WheelSegment('Bedava!\nKimse İçmesin', 0xFF3A86FF),
  WheelSegment('Komşunu Seç\nO İçsin', 0xFFFF006E),
];
