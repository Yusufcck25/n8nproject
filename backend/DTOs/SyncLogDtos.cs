namespace backend.DTOs
{
    // n8n senkronizasyon log verisi için kullanılan model
    public class SyncLogDto
    {
        public int Id { get; set; }
        public string WorkflowName { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public int ProcessedCount { get; set; }
        public string? ErrorMessage { get; set; }
        public DateTime LoggedAt { get; set; }
    }
}
