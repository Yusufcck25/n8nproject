using System.ComponentModel.DataAnnotations;

namespace backend.DTOs
{
    // Favoriye ekleme isteği için kullanılan model
    public class CreateUserFavoriteDto
    {
        [Required]
        public Guid UserId { get; set; }

        [Required]
        public long RadarDataId { get; set; }

        public string? Note { get; set; }
    }

    // Favorileri listelerken dışarı dönülen model
    public class UserFavoriteDto
    {
        public int Id { get; set; }
        public Guid UserId { get; set; }
        public long RadarDataId { get; set; }
        public string? Note { get; set; }
        public DateTime CreatedAt { get; set; }

        // İlişkili radar ilanının detayları
        public RadarDataDto? RadarData { get; set; }
    }
}
