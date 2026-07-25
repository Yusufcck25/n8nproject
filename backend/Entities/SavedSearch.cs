namespace backend.Entities
{
    // Kullanıcıların sık yaptığı aramaları ve bildirim alarmlarını tutan tablo
    public class SavedSearch
    {
        public int Id { get; set; }

        // Aramayı kaydeden kullanıcı
        public Guid UserId { get; set; }
        public User User { get; set; } = null!;

        public string SearchQuery { get; set; } = string.Empty; // Örn: "Almanya Tekstil İhracatı"
        public string Filters { get; set; } = "{}";             // Seçilen filtreler (JSON formatında)
        public bool IsAlarmActive { get; set; } = false;        // Yeni veri gelince bildirim gönderilsin mi?
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Kayıt tarihi
    }
}