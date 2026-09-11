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

const List<String> neverHaveIEverLight = [
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
  'Hiç yapmadım... bir toplantıda kamerayı kapalı sanıp yanlış bir şey yapmadım.',
  'Hiç yapmadım... yalan yere "yoldayım" demedim.',
  'Hiç yapmadım... bir arkadaşımın doğum gününü unutmadım.',
  'Hiç yapmadım... alışverişte fiyat etiketini görüp vazgeçmedim.',
  'Hiç yapmadım... bir dizi/film karakterine gerçekten aşık olmadım.',
  'Hiç yapmadım... aynı şakayı ikinci kez anlattığımı fark etmedim.',
  'Hiç yapmadım... bir toplantıyı yanlış anlayıp hazırlıksız gelmedim.',
  'Hiç yapmadım... birine "seni görmedim" diye yalan söylemedim.',
  'Hiç yapmadım... telefonuma yanlışlıkla bir şey siparişi vermedim.',
  "Hiç yapmadım... bu masadaki birinin Instagram'ını gizlice stalklamadım.",
  'Hiç yapmadım... bir konuşmada "aynen" deyip hiçbir şey anlamadığım halde başımı sallamadım.',
  'Hiç yapmadım... uykuya dalıp önemli bir bildirimi kaçırmadım.',
  'Hiç yapmadım... bir yerde kaybolup rota sormaya utanmadım.',
  'Hiç yapmadım... bir gruba yanlışlıkla özel bir mesaj göndermedim.',
  'Hiç yapmadım... bir randevuya/toplantıya yanlış günde gitmedim.',
];

const List<String> neverHaveIEverHard = [
  'Hiç yapmadım... eski sevgilimi gizli bir hesaptan takip etmedim.',
  'Hiç yapmadım... birinin telefonunu izinsiz karıştırmadım.',
  'Hiç yapmadım... yalandan hastayım deyip işe/okula gitmedim.',
  'Hiç yapmadım... bu masadaki birine küçük de olsa yalan söylemedim.',
  'Hiç yapmadım... tanımadığım biriyle sabaha kadar mesajlaşmadım.',
  'Hiç yapmadım... bir ilişkiyi mesajla bitirmedim.',
  'Hiç yapmadım... arkadaşımın sevgilisini/eski sevgilisini gizlice beğenmedim.',
  'Hiç yapmadım... birine "seni özledim" deyip aslında sıkıldığım için yazmadım.',
  'Hiç yapmadım... bu masadaki birinin telefonuna göz atmak istemedim.',
  'Hiç yapmadım... bir arkadaşımı gıyabında eleştirmedim.',
  'Hiç yapmadım... sosyal medyada eski bir aşkın profiline saatlerce bakmadım.',
  'Hiç yapmadım... bir yalanı o kadar çok tekrarladım ki kendim de inanmaya başlamadım.',
  'Hiç yapmadım... birine kırıcı bir şey söyleyip "şaka yapıyordum" demedim.',
  'Hiç yapmadım... bu masadaki birine karşı kıskançlık hissetmedim.',
  'Hiç yapmadım... bir arkadaşımın sırrını başka birine anlatmadım.',
  'Hiç yapmadım... geçmişte biriyle "sadece arkadaşız" deyip aslında öyle olmadığı bir şey yaşamadım.',
  'Hiç yapmadım... bir gece eve gelirken nerede olduğumu tam olarak hatırlamadım.',
  'Hiç yapmadım... birine "meşgulüm" deyip aslında canım istemediği için cevap vermedim.',
  'Hiç yapmadım... bu masadaki birini bir konuda kıskandım ve belli etmedim.',
  'Hiç yapmadım... eski bir mesaj yazışmasını geri dönüp okumadım.',
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
  'Bu grupta kim en çok plan yapıp hiçbirini uygulamaz?',
  'Bu grupta kim bir gün stand-up yapar?',
  'Bu grupta kim tatile giderken en çok eşya götürür?',
  'Bu grupta kim en çok "ben söylemiştim" der?',
  'Bu grupta kim bir gün maratona katılır?',
  'Bu grupta kim en çok arabada şarkı söyler?',
  'Bu grupta kim en çok grup tatilini organize eder?',
  'Bu grupta kim en kolay ağlar (mutluluktan da olsa)?',
  'Bu grupta kim en çok "diyetteyim" deyip sonra yemeği bitirir?',
  'Bu grupta kim gece yarısı en garip fikirleri ortaya atar?',
  'Bu grupta kim bir gün podcast açar?',
  'Bu grupta kim en çok telefonunu kaybeder/arar?',
  'Bu grupta kim en çabuk yeni bir hobiye atlar ve bırakır?',
  'Bu grupta kim en iyi taklit yapar?',
  'Bu grupta kim bu masadan en son ayrılır?',
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
  WheelSegment('Taklit Yap\nYoksa İç', 0xFFFFBE0B),
  WheelSegment('3 Yudum İç', 0xFF9B5DE5),
];
