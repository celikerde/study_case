# lucida

A new Flutter project.

## Kurulum
Uygulama çalıştırılmadan önce, speech_to_text, flutter_tts, provider ve avatar_glow paketlerinin kurulumu yapılmalıdır. Speech_to_text paketinin kurulması esnasında ios için <project root>/ios/Runner/Info.plist, android için <project root>/android/app/src/main/AndroidManifest.xml dosyalarında bu linkte belirtilen [https://pub.dev/packages/speech_to_text] değişiklikler yapılmalıdır. Ayrıca bu paketin çalışması için android/app/build.gradle'da belirtilen minSdk version 21, targetSdk ise 28 olmalıdır. Son olarak çalışılan sanal cihazda mikrofon izinlerinin verildiğinden emin olun.

Speech_to_text paketi, mikrofonla konuşmanızı ve belirleyeceği confidence seviyesiyle, konuştuklarınızı text metnine dönüştürmeyi sağlar. Flutter_tts ise program içinde belirlediğiniz hazır cevaplarınızı konuştuklarınıza cevap olarak okumayı sağlar. Mikrofon ikonuna basıldığında mikrofon ikonu kırmızı olur ve kayıt başlar. Bu esnada uygulama Listening durumundadır ve bu durum ekran üzerinde belirtilir. Mikrofon ikonuna bir kez daha basıldığında mikrofon kapanır ve daha önceden belirlenen hazır cevabınız, konuştuğunuza karşılık yanıt olarak okunur. Bu esnada durum Answering olarak güncellenir. Ayrıca cevap metninin tümü okunduğunda Answering durumu sonlanır ve buna karşılık ekranda yazı olarak herhangi bir şey olmaz. Bu değişen durumlar Provider paketi ile atanır ve kontrol edilir. Ayrıca UI ekranında AppBar kısmının sağında bulunan SwithListTile ikonu ile tema geçişi sağlanabilir. Yine bu geçiş de ilgili provider ile sağlanmış olur. Avatar_glow paketi ise mikrofon için küçük bir animasyon sağlar.   




## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
