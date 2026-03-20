# Kod İnceleme Raporu — Third iOS Oyun Uygulaması

Bu belge, projenin tamamının endüstri standartlarına göre kapsamlı bir incelemesini içerir. Her madde; sorunun ne olduğunu, nerede olduğunu, neden riskli olduğunu ve nasıl düzeltilebileceğini açıklar.

---

## 1. Güvenlik Sorunları

### 1.1 — UserDefaults ile Şifrelenmemiş Veri Depolama

**Dosyalar:**
- `third/Models/UserProfile.swift:20-29` — Kullanıcı profili
- `third/Services/SessionManager.swift:79-80` — Oyun oturumu
- `third/Services/GameStatsManager.swift:43-63` — Oyun istatistikleri

**Sorun:** Tüm kullanıcı verileri (profil, oturum, istatistikler) `UserDefaults`'a düz metin olarak kaydediliyor. UserDefaults, plist dosyası olarak diske yazılır ve cihaza fiziksel erişimi olan biri veya jailbreak yapılmış bir cihazda kolayca okunabilir/değiştirilebilir.

**Risk:** Oyun istatistikleri kolayca manipüle edilebilir (high score hilesi). Gelecekte hassas veri eklenirse (örneğin premium üyelik durumu) ciddi güvenlik açığına dönüşür.

**Düzeltme Önerisi:**
- Rekabetçi istatistikler için `Keychain` veya en azından veri bütünlüğü kontrolü (checksum/hash) ekleyin.
- `FileProtection.complete` kullanarak verinin cihaz kilitliyken okunamaz olmasını sağlayın.

---

### 1.2 — Kullanıcı Adı Girişinde Yetersiz Input Validasyonu

**Dosya:** `third/Views/ProfileView.swift:257`

```swift
viewModel.userProfile.username = usernameText.trimmingCharacters(in: .whitespacesAndNewlines)
```

**Sorun:** Kullanıcı adı yalnızca whitespace temizliğinden geçiriliyor. Özel karakterler, emoji, kontrol karakterleri veya aşırı uzun Unicode dizileri için hiçbir filtreleme yok. Ayrıca `ProfileView` ve `ProfileViewModel` arasında iki farklı kaydetme yolu var — `ProfileView:257-258`'de doğrudan `viewModel.userProfile` üzerinden, `ProfileViewModel:40-46`'da ise `saveUsername()` metodu ile. Bu tutarsızlık validasyon bypass'ına yol açabilir.

**Risk:** UI rendering sorunları, potansiyel crash'ler, ve validasyon kurallarının atlanması.

**Düzeltme Önerisi:**
- Karakter allowlist'i tanımlayın (alfanumerik + belirli özel karakterler).
- Kaydetme işlemini tek bir noktadan (`ProfileViewModel.saveUsername()`) geçirin, View'dan doğrudan model manipülasyonunu kaldırın.

---

### 1.3 — Gereksiz Background Mode Tanımı

**Dosya:** `third/Info.plist:12-15`

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

**Sorun:** Uygulama `remote-notification` background mode'u tanımlıyor ama hiçbir yerde push notification handling implementasyonu yok. Bu, App Store review sürecinde ret sebebi olabilir.

**Risk:** App Store reddi, gereksiz yetki talebi.

**Düzeltme Önerisi:** Push notification kullanılmıyorsa bu tanımı `Info.plist`'ten kaldırın.

---

## 2. Mimari ve Tasarım Sorunları

### 2.1 — Global Mutable State: Static Enum Anti-Pattern

**Dosya:** `third/Models/GameData.swift:10-16`

```swift
enum GameData {
    private static var questions: [GameQuestion] = []
    private static var currentLanguage: AppLanguage = .turkish
    private static var usedQuestionIndices: Set<Int> = []
}
```

**Sorun:** `GameData`, static mutable property'lere sahip bir enum olarak tasarlanmış. Bu, global state oluşturur. Herhangi bir yerden çağrılabilir, bağımlılıklar gizlidir, test edilemez, ve thread-safety garantisi yoktur.

**Risk:**
- Unit test yazılamaz (state testler arasında sızar).
- Concurrency sorunlarına açık (bkz. Madde 5.1).
- Bağımlılık grafiği takip edilemez.

**Düzeltme Önerisi:** `GameData`'yı bir class'a dönüştürün, dependency injection ile view'lara enjekte edin. Mevcut `SessionManager` ve `GameStatsManager` gibi `@Observable` bir sınıf yapısı kullanılabilir.

---

### 2.2 — Singleton Anti-Pattern

**Dosyalar:**
- `third/Services/SessionManager.swift:38` — `static let shared = SessionManager()`
- `third/Services/GameStatsManager.swift:12` — `static let shared = GameStatsManager()`

**Sorun:** Her iki servis de singleton pattern kullanıyor. `private init()` ile dışarıdan instance oluşturma engellenmiş, bu da test sırasında mock/stub enjekte etmeyi imkansız kılıyor.

**Risk:**
- Unit test'lerde gerçek `UserDefaults`'a yazılır, testler birbirini etkiler.
- Bağımlılık grafiği gizlenir.
- Farklı konfigürasyonlarla çalışma imkanı ortadan kalkar.

**Düzeltme Önerisi:**
- Protocol tanımlayın (`SessionManaging`, `GameStatsManaging`).
- `init`'i `internal` yapın veya factory pattern kullanın.
- View'lara `@Environment` veya init injection ile enjekte edin.

---

### 2.3 — Monolitik GameView (334 satır)

**Dosya:** `third/Views/GameView.swift`

**Sorun:** `GameView` tek bir dosyada 334 satır kod barındırıyor ve çok fazla sorumluluğu var:
- Oyun durumu yönetimi (lives, score, question tracking)
- Input işleme ve validasyon
- Skor hesaplama
- Animasyon yönetimi (shake, box visibility)
- Haptic feedback
- Session kaydetme
- Game over mantığı

**Risk:** Bakımı zor, test edilemez, tek bir değişiklik birçok şeyi bozabilir. Single Responsibility Principle ihlali.

**Düzeltme Önerisi:**
- `GameViewModel` oluşturun (oyun mantığı, skor hesaplama, durum yönetimi).
- Animasyon mantığını ayrı modifier/helper'lara taşıyın.
- Input işleme ve answer matching mantığını ayrı bir servis yapın.

---

### 2.4 — String-Based Navigation

**Dosya:** `third/Views/MainMenuView.swift:101-113`

```swift
.navigationDestination(for: String.self) { destination in
    switch destination {
    case "game":
        GameViewWrapper()
    case "profile":
        ProfileView()
    case "settings":
        SettingsView()
    default:
        EmptyView()
    }
}
```

**Sorun:** Navigation, magic string'lerle yönetiliyor. Derleme zamanında tip güvenliği yok. Bir string'de yazım hatası yapılırsa sessizce `EmptyView` gösterilir.

**Risk:** Runtime hataları, refactoring sırasında fark edilmeyen kırılmalar.

**Düzeltme Önerisi:** Bir `enum Route: Hashable` tanımlayın ve `navigationDestination(for: Route.self)` kullanın. Bu sayede derleyici her route'un handle edildiğini garanti eder.

---

### 2.5 — reload() Metodu Hack Niteliğinde

**Dosya:** `third/Models/GameData.swift:37-40`

```swift
static func reload() {
    currentLanguage = .turkish // Farklı dil gibi görünsün diye
    load()
}
```

**Sorun:** Yorum açıkça bir hack olduğunu belirtiyor: "Farklı dil gibi görünsün diye" dili `.turkish`'e set edip tekrar `load()` çağırıyor. Bu, `load()` metodunun "dil değiştiyse yeniden yükle" guard'ını kandırmak için yapılmış.

**Risk:** Gelecekte dil mantığı değişirse beklenmeden kırılır. Kodun amacını anlamak zor.

**Düzeltme Önerisi:** `load()` metoduna `force: Bool = false` parametresi ekleyin veya `reload()` içinde guard'ı atlayan ayrı bir yükleme yolu sağlayın.

---

## 3. Bellek Yönetimi Sorunları

### 3.1 — Timer Memory Leak Riski

**Dosya:** `third/Views/GameOverView.swift:225-234, 253-262`

```swift
scoreTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [self] timer in
    currentStep += 1
    displayedScore = Int(stepValue * Double(currentStep))
    ...
}
```

**Sorun:** Timer closure'ları `[self]` ile capture ediliyor. SwiftUI struct View'larda `self` aslında bir value type olduğundan doğrudan retain cycle oluşmaz, ancak Timer RunLoop'a eklenir ve `onDisappear` çağrılmadan view hierarchy'den çıkarılırsa timer çalışmaya devam eder.

**Risk:** Bellek sızıntısı, deallocate edilmiş view'da state mutation.

**Düzeltme Önerisi:** `TimelineView` veya SwiftUI'nin `.task` modifier'ı ile `withCheckedContinuation` kullanın. En azından `onDisappear`'daki cleanup'ın her durumda çağrıldığından emin olun.

---

### 3.2 — DispatchQueue.main.asyncAfter İptal Mekanizması Yok

**Dosyalar:**
- `third/Views/GameView.swift:215, 220, 231, 234, 277, 307, 327`
- `third/Views/MainMenuView.swift:159, 164, 170`
- `third/Views/GameOverView.swift:184, 195, 202`

**Sorun:** Proje genelinde en az 11 yerde `DispatchQueue.main.asyncAfter` kullanılıyor ve hiçbirinde iptal mekanizması yok. View kapatıldığında veya kullanıcı hızla geri döndüğünde bu closure'lar hala çalışır.

```swift
// GameView.swift:215 — View kapanmış olabilir ama bu hala çalışır
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    viewStatus = .lost
}
```

**Risk:** Deallocate edilmiş view üzerinde state mutation, beklenmeyen UI güncellemeleri, potansiyel crash.

**Düzeltme Önerisi:**
- `DispatchWorkItem` kullanıp `onDisappear`'da `.cancel()` çağırın.
- Veya modern SwiftUI: `.task` modifier içinde `Task.sleep` kullanın — view kaybolduğunda task otomatik iptal edilir.

---

## 4. Hata İşleme Sorunları

### 4.1 — Sessiz Hata Yutma (Silent Failure)

**Dosya:** `third/Models/GameData.swift:26-32`

```swift
do {
    questions = try QuestionLoader.loadQuestions(for: language)
    print("✅ Loaded \(questions.count) questions for \(language.displayName)")
} catch {
    print("❌ Failed to load questions: \(error.localizedDescription)")
    questions = []  // Sessiz hata — kullanıcıya bilgi verilmiyor
}
```

**Sorun:** Soru yükleme başarısız olduğunda `questions` boş diziye set ediliyor ve yalnızca console'a print ediliyor. Kullanıcı herhangi bir hata mesajı görmez. Oyun, fallback sorularla devam eder ve kullanıcı neyin yanlış gittiğini anlayamaz.

**Risk:** Kötü kullanıcı deneyimi, debug zorluğu (production'da print görünmez).

**Düzeltme Önerisi:** Bir `@Published` error state ekleyin ve UI'da kullanıcıya anlamlı bir hata mesajı gösterin. Ayrıca `os.log` veya crash reporting servisi kullanın.

---

### 4.2 — UserProfile Kaydetme Hatası Sessizce Yutulması

**Dosya:** `third/Models/UserProfile.swift:27-31`

```swift
func save() {
    if let data = try? JSONEncoder().encode(self) {
        UserDefaults.standard.set(data, forKey: UserProfile.userDefaultsKey)
    }
}
```

**Sorun:** `try?` ile encoding hatası tamamen yutulmuş. Kaydetme başarısız olursa ne kullanıcı bilgilendirilir ne de hata loglanır. Kullanıcı adını değiştirdiğini sanır ama değişiklik kaybolur.

**Risk:** Veri kaybı, kötü kullanıcı deneyimi.

**Düzeltme Önerisi:** `try?` yerine `do-catch` kullanın, hatayı loglayın ve kullanıcıya geri bildirim sağlayın.

---

### 4.3 — Fallback Soru Dili Sabitlenmiş

**Dosya:** `third/Models/GameData.swift:45-55`

```swift
let fallbackQuestion = GameQuestion(
    id: 0,
    text: "Sorular yüklenemedi. Lütfen uygulamayı yeniden başlatın.",
    answers: [
        AnswerOption(keywords: ["hata"], displayWord: "Hata", type: .trap),
        ...
    ]
)
```

**Sorun:** Uygulama İngilizce modda çalışırken bile fallback sorusu Türkçe. İngilizce kullanan bir kullanıcı bu metni anlayamaz.

**Risk:** Kötü kullanıcı deneyimi, lokalizasyon tutarsızlığı.

**Düzeltme Önerisi:** `currentLanguage`'e göre dinamik fallback metni oluşturun veya `NSLocalizedString` kullanın.

---

## 5. Concurrency / Thread Safety Sorunları

### 5.1 — GameData Static State Thread Safety Yok

**Dosya:** `third/Models/GameData.swift:12-16`

```swift
private static var questions: [GameQuestion] = []
private static var currentLanguage: AppLanguage = .turkish
private static var usedQuestionIndices: Set<Int> = []
```

**Sorun:** Mutable static property'ler herhangi bir senkronizasyon mekanizması olmadan kullanılıyor. Proje `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` ile yapılandırılmış olsa da, `GameData` enum'u bir actor değil ve `@MainActor` annotation'ı yok. Background thread'den erişim olursa data race oluşur.

**Risk:** Data race, undefined behavior, potansiyel crash.

**Düzeltme Önerisi:** `GameData`'ya `@MainActor` ekleyin veya bir actor'e dönüştürün. Ya da bir class yapıp dependency injection kullanın.

---

### 5.2 — Modern Swift Concurrency Kullanılmamış

**Proje geneli**

**Sorun:** Tüm asenkron işlemler `DispatchQueue.main.asyncAfter` ve `Timer` ile yönetiliyor. Proje Swift 5.0 hedefliyor ve modern `async/await`, `Task`, `.task` modifier gibi yapılardan hiç yararlanmıyor.

**Risk:** İptal mekanizması eksikliği (bkz. Madde 3.2), daha karmaşık hata yönetimi, kodun okunabilirliğinin düşmesi.

**Düzeltme Önerisi:** `DispatchQueue.main.asyncAfter` kullanımlarını `.task` modifier + `Task.sleep` ile değiştirin. Bu otomatik iptal sağlar.

---

## 6. Okunabilirlik ve Bakım Sorunları

### 6.1 — Dağınık Magic String UserDefaults Key'leri

**Dosyalar:**
- `third/Models/UserProfile.swift:13` — `"userProfile"`
- `third/Models/UserSettings.swift:34,42` — `"soundEffectsEnabled"`, `"selectedLanguage"`
- `third/Services/SessionManager.swift:41` — `"currentGameSession"`
- `third/Services/GameStatsManager.swift:15-19` — `"gameHighScore"`, `"furthestQuestionReached"`, `"totalGamesPlayed"`, `"totalScoreAccumulated"`, `"longestStreak"`

**Sorun:** UserDefaults key'leri 4 farklı dosyada magic string olarak tanımlı. Key çakışması veya yazım hatası derleme zamanında yakalanamaz.

**Risk:** Key çakışması, yazım hatası kaynaklı veri kaybı, refactoring zorluğu.

**Düzeltme Önerisi:** Merkezi bir `enum UserDefaultsKey: String` tanımlayın ve tüm key'leri buradan referans alın.

---

### 6.2 — Kırılgan Index-Tabanlı Cevap Tipi Atama

**Dosya:** `third/Services/QuestionLoader.swift:54-60`

```swift
let type: AnswerType
switch index {
case 0: type = .trap
case 2: type = .target
default: type = .normal
}
```

**Sorun:** Cevap tipi, JSON dizisindeki sıraya (index) göre belirleniyor. Index 0 her zaman trap, index 2 her zaman target. Bu, JSON dosyasındaki sıralama ile doğrudan bağlantılı ve son derece kırılgan.

**Risk:** JSON'daki sıra değişirse (yeni cevap eklenir, sıra değişir) oyun mantığı sessizce bozulur. Hata kaynağını bulmak çok zor olur.

**Düzeltme Önerisi:** JSON dosyasına `"type"` alanı ekleyin ve her cevabın tipini açıkça belirtin:
```json
{ "keywords": ["..."], "displayWord": "...", "type": "trap" }
```

---

### 6.3 — Hardcoded Türkçe UI Metinleri

**Dosyalar:**
- `third/Views/GameView.swift:119` — `"Sıradaki Soru"`
- `third/Views/GameOverView.swift:92` — `"OYUN BİTTİ!"`
- `third/Views/GameOverView.swift:103` — `"SKOR"`
- `third/Views/GameOverView.swift:129` — `"En Yüksek:"`
- `third/Views/GameOverView.swift:160` — `"Tekrar Oyna"`
- `third/Views/ProfileView.swift:68` — `"Düzenle"`
- `third/Views/ProfileView.swift:81-106` — Tüm stat başlıkları
- `third/Views/ProfileView.swift:119` — `"İstatistik Sıfırla"`
- `third/Services/SessionManager.swift:25-31` — Hata mesajları
- `third/Services/QuestionLoader.swift:17` — `"Soru dosyası bulunamadı"`

**Sorun:** Uygulama İngilizce dil desteği sunuyor (soru dosyaları İngilizce) ancak tüm UI metinleri Türkçe olarak hardcoded. İngilizce modu seçen kullanıcı, İngilizce sorulara Türkçe arayüzle karşılaşır.

**Risk:** Tutarsız kullanıcı deneyimi, gerçek çokdillilik desteği yok.

**Düzeltme Önerisi:** `NSLocalizedString` veya Swift'in yeni `String(localized:)` API'sini kullanın. `Localizable.strings` dosyaları oluşturup tüm UI metinlerini lokalize edin.

---

### 6.4 — `UserSettings` Her Oluşturulduğunda UserDefaults Okuyor

**Dosya:** `third/Models/UserSettings.swift:51-57`

```swift
init() {
    self.soundEffectsEnabled = UserDefaults.standard.object(forKey: "soundEffectsEnabled") as? Bool ?? true
    let languageRaw = UserDefaults.standard.string(forKey: "selectedLanguage") ?? AppLanguage.turkish.rawValue
    self.selectedLanguage = AppLanguage(rawValue: languageRaw) ?? .turkish
}
```

Ve `GameData.load()` her çağrıldığında yeni bir `UserSettings` instance'ı oluşturuyor:

```swift
// GameData.swift:20
let userSettings = UserSettings()
```

**Sorun:** `UserSettings` bir singleton değil, her kullanıldığında yeni instance oluşturulup UserDefaults'tan okunuyor. Bu tutarsız state'e yol açabilir — bir yerde ayar değiştirilirken başka bir instance eski değeri okuyabilir.

**Risk:** State tutarsızlığı, gereksiz UserDefaults okumaları.

**Düzeltme Önerisi:** `UserSettings`'i singleton yapın veya `@Environment` ile paylaşılan tek bir instance kullanın.

---

### 6.5 — GameState'te Duplike Alan

**Dosyalar:**
- `third/Models/GameModels.swift:61` — `GameState.currentQuestionIndex`
- `third/Models/GameSession.swift:12` — `GameSession.currentQuestionIndex`
- `third/Views/GameView.swift:26` — `@Binding var currentQuestionIndex: Int`

**Sorun:** `currentQuestionIndex` hem `GameState` içinde hem `GameSession` içinde hem de `GameView`'da ayrı bir `@Binding` olarak var. Üç farklı yerde tutulan aynı veri, senkronizasyon hatalarına davetiye çıkarıyor.

**Risk:** Hangi `currentQuestionIndex`'in doğru olduğu belirsiz, state uyumsuzluğu.

**Düzeltme Önerisi:** `currentQuestionIndex`'i tek bir yerde tutun (`GameState` içinde) ve diğer yerlerde buraya referans verin.

---

### 6.6 — Haptic Feedback Her Çağrıda Yeni Generator Oluşturuyor

**Dosya:** `third/Views/GameView.swift:282-285`

```swift
private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}
```

**Sorun:** Apple'ın dokümantasyonuna göre, `UIImpactFeedbackGenerator` önceden oluşturulup `prepare()` çağrılmalıdır. Her seferinde yeni instance oluşturmak gecikmeye yol açar.

**Risk:** Haptic feedback gecikmesi, düşük performans.

**Düzeltme Önerisi:** Generator'ü view'da bir property olarak tutun ve `prepare()` ile hazırlayın.

---

## 7. Test Eksikliği

### 7.1 — Sıfır Test Coverage

**Dosya:** `thirdTests/thirdTests.swift:11-16`

```swift
struct thirdTests {
    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
}
```

**Sorun:** Proje, Xcode tarafından otomatik oluşturulan boş test scaffold'u dışında hiçbir test içermiyor. Kritik iş mantığı (skor hesaplama, cevap eşleştirme, session yönetimi, soru döngüsü) hiç test edilmemiş.

**Risk:**
- Regresyon hataları fark edilmez.
- Refactoring güvensizdir.
- Skor hesaplama gibi kritik mantıkta gizli hata olabilir.

**Düzeltme Önerisi:**
Öncelikli test edilmesi gereken alanlar:
1. **Skor hesaplama** (`GameView.calculateScore`) — base score × multiplier doğruluğu
2. **Cevap eşleştirme** (`submitAnswer` mantığı) — case sensitivity, trim, keyword matching
3. **Session yönetimi** — kaydetme/yükleme/süre aşımı
4. **GameData soru döngüsü** — tüm sorular kullanıldığında sıfırlama
5. **GameStatsManager** — istatistik güncelleme ve sıfırlama

Not: Singleton pattern ve static state test yazmayı zorlaştırıyor (bkz. Madde 2.1 ve 2.2). Protocol-based dependency injection bu engeli kaldırır.

---

## 8. Diğer Sorunlar

### 8.1 — print() ile Logging

**Dosyalar:**
- `third/Models/GameData.swift:28, 30, 58`
- `third/Services/QuestionLoader.swift:42-43`
- `third/Services/SessionManager.swift:84, 110` (sadece DEBUG)

**Sorun:** Logging, `print()` ile yapılıyor. Production build'lerde `print()` çıktısı görünmez (SessionManager'daki `#if DEBUG` blokları hariç) ve yapılandırılabilir log seviyeleri yok.

**Risk:** Production'da debugging imkansız, performans etkisi (print I/O maliyeti).

**Düzeltme Önerisi:** `os.log` (OSLog / Logger) framework'ünü kullanın. Seviye bazlı logging (debug, info, error) yapın.

---

### 8.2 — AnswerOption'da Her Decode'da Yeni UUID

**Dosya:** `third/Models/GameModels.swift:29-36`

```swift
init(from decoder: Decoder) throws {
    ...
    self.id = UUID()  // Her decode'da yeni UUID
}
```

**Sorun:** `AnswerOption`, `Identifiable` protokolüne uyuyor ve `id` olarak `UUID` kullanıyor. Ancak decode sırasında her zaman yeni UUID üretiyor. Bu, session'dan geri yüklendiğinde aynı cevabın farklı identity'ye sahip olmasına neden olur.

**Risk:** SwiftUI'nin diff algoritması aynı cevabı farklı öğe olarak algılar, gereksiz view yeniden çizimi, animasyon sorunları.

**Düzeltme Önerisi:** `id`'yi encode/decode edin veya `keywords + displayWord` kombinasyonundan deterministik bir ID türetin.

---

### 8.3 — Placeholder Offset Hack

**Dosya:** `third/Views/ProfileView.swift:236-239`

```swift
.overlay(
    Text(usernameText.isEmpty ? "Kullanıcı adı" : "")
        .foregroundStyle(Color.appPrimaryText.opacity(0.3))
        .font(.title2)
        .offset(x: usernameText.isEmpty ? 0 : -1000)  // Ekran dışına taşıma
)
```

**Sorun:** Placeholder metni gizlemek için `offset(x: -1000)` kullanılıyor. Bu bir görsel hack'tir — metin render edilmeye devam eder, sadece ekran dışına itilir.

**Risk:** Accessibility sorunları (VoiceOver hala görebilir), gereksiz render maliyeti.

**Düzeltme Önerisi:** SwiftUI'nin `prompt` parametresini kullanın: `TextField("Kullanıcı adı", text: $usernameText)` veya `.opacity(usernameText.isEmpty ? 1 : 0)`.

---

## Öncelik Sıralaması

| Öncelik | Madde | Kategori | Açıklama |
|---------|-------|----------|----------|
| Kritik | 2.1 | Mimari | GameData static enum → class + DI |
| Kritik | 2.2 | Mimari | Singleton → Protocol + DI |
| Kritik | 7.1 | Test | Sıfır test coverage |
| Yüksek | 3.2 | Bellek | DispatchQueue iptal mekanizması |
| Yüksek | 3.1 | Bellek | Timer memory leak |
| Yüksek | 6.2 | Okunabilirlik | Index-tabanlı cevap tipi atama |
| Yüksek | 6.3 | Okunabilirlik | Hardcoded Türkçe metinler |
| Yüksek | 2.3 | Mimari | Monolitik GameView → ViewModel |
| Orta | 4.1 | Hata İşleme | Sessiz hata yutma |
| Orta | 1.1 | Güvenlik | UserDefaults şifreleme |
| Orta | 6.1 | Okunabilirlik | Magic string key'ler |
| Orta | 6.5 | Okunabilirlik | Duplike currentQuestionIndex |
| Orta | 5.1 | Concurrency | GameData thread safety |
| Orta | 2.4 | Mimari | String-based navigation |
| Düşük | 1.2 | Güvenlik | Input validasyonu |
| Düşük | 1.3 | Güvenlik | Gereksiz background mode |
| Düşük | 8.1 | Diğer | print() logging |
| Düşük | 8.2 | Diğer | UUID regeneration |
| Düşük | 8.3 | Diğer | Placeholder offset hack |
| Düşük | 6.6 | Okunabilirlik | Haptic generator reuse |
