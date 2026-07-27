# Backend güvenlik yapılandırması

Uygulamayı çalıştırmadan önce JWT imzalama anahtarını ortam değişkeni olarak tanımlayın. Anahtar en az 32 bayt, rastgele bir değer olmalıdır; kaynak koda veya `appsettings.json` dosyasına eklenmemelidir.

PowerShell örneği:

```powershell
$env:Jwt__Key = "rastgele-ve-en-az-32-baytlik-gizli-anahtar"
dotnet run
```

Giriş başarılı olduğunda `accessToken` döner. Korunan çağrılarda şu başlığı gönderin:

```text
Authorization: Bearer <accessToken>
```

Korunan uçlar:

- `GET /api/Users/me`
- `POST`, `GET`, `DELETE /api/UserFavorites`
- `POST`, `GET`, `DELETE /api/SavedSearches`

Favori ve kayıtlı arama istekleri artık `userId` kabul etmez; kullanıcı token’dan belirlenir. Daha önce düz metin parolayla oluşturulmuş hesapların parolası, ilk başarılı girişte BCrypt ile otomatik olarak güncellenir.
