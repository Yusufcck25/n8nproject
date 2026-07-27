using System.ComponentModel.DataAnnotations;

namespace backend.DTOs
{
    // Arama kaydetme isteği için kullanılan model
    public class CreateSavedSearchDto
    {
        [Required]
        public string Name { get; set; } = string.Empty;

        public string SearchQueryJson { get; set; } = "{}";
    }

    // Kayıtlı aramaları listelerken dönülen model
    public class SavedSearchDto
    {
        public int Id { get; set; }
        public Guid UserId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string SearchQueryJson { get; set; } = "{}";
        public DateTime CreatedAt { get; set; }
    }
}
