namespace backend.Entities
{
    // n8n tarafından dış kaynaklardan (TradeMap, pazar araştırmaları vb.) toplanan verilerin saklandığı tablo
    public class RadarData
    {
        public long Id { get; set; }                           // Benzersiz kayıt kimliği (Primary Key)
        public string SourceName { get; set; } = string.Empty; // Verinin çekildiği kaynak (Örn: "TradeMap", "CustomsPortal")
        public string Title { get; set; } = string.Empty;      // Firma adı, fırsat başlığı veya pazar özeti
        public string Country { get; set; } = string.Empty;    // Hedef ülke (Örn: "Almanya", "DE")
        public string Category { get; set; } = string.Empty;   // Sektör veya GTİP / HS Kodu
        public double? OpportunityScore { get; set; }        // Sistem/n8n tarafından atanan fırsat puanı (opsiyonel)

        // n8n'den gelen dinamik ve değişkendeki tüm ek detayları esnek tutmak için JSON formatında saklarız
        public string RawData { get; set; } = "{}"; 

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Kaydın sisteme eklendiği tarih

        // İlişki: Bu radar verisini favorilerine ekleyen kullanıcıların listesi
        public ICollection<UserFavorite> Favorites { get; set; } = new List<UserFavorite>();
    }
}