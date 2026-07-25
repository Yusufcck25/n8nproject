namespace backend.Entities
{
    // n8n otomasyonunun verileri çekerken düzgün çalışıp çalışmadığını takip eden log tablosu
    public class SyncLog
    {
        public int Id { get; set; }
        public string WorkflowName { get; set; } = string.Empty; // Çalışan n8n senaryosunun adı
        public string Status { get; set; } = "Success";          // Durum: "Success", "Failed", "Running"
        public int RecordsInserted { get; set; }                // O çalışmada veritabanına kaç yeni veri eklendi?
        public string? ErrorMessage { get; set; }               // Hata oluştuysa alınan hata mesajı
        public DateTime ExecutedAt { get; set; } = DateTime.UtcNow; // Çalışma zamanı
    }
}