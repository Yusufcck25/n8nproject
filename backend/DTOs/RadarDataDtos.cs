using System.ComponentModel.DataAnnotations;

namespace backend.DTOs
{
    // Mobil uygulamadan gelen arama ve sayfalama filtreleri
    public class RadarFilterDto
    {
        public string? Country { get; set; }
        public string? Category { get; set; }
        public string? SearchTerm { get; set; }
        public double? MinOpportunityScore { get; set; }
        [Range(1, 10_000)]
        public int Page { get; set; } = 1;

        [Range(1, 100)]
        public int PageSize { get; set; } = 10;
    }

    // Pazar fırsat ilanı detay modeli
    public class RadarDataDto
    {
        public long Id { get; set; }
        public string SourceName { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Country { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public double? OpportunityScore { get; set; }
        public string RawData { get; set; } = "{}";
        public DateTime CreatedAt { get; set; }
    }

    // Standart sayfalanmış liste yanıt modeli (Pagination)
    public class PagedResultDto<T>
    {
        public List<T> Items { get; set; } = new();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
    }
}
