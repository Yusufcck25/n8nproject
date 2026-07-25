namespace backend.Entities
{
    // Kullanıcıların radar verilerini favorilerine eklemesini sağlayan köprü tablosu
    public class UserFavorite
    {
        public int Id { get; set; } // Favori kayıt ID'si

        // Hangi kullanıcı ekledi?
        public Guid UserId { get; set; }
        public User User { get; set; } = null!;

        // Hangi radar verisini ekledi?
        public long RadarDataId { get; set; }
        public RadarData RadarData { get; set; } = null!;

        public string? Note { get; set; }                          // Kullanıcının bu veriye aldığı özel not (opsiyonel)
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Favoriye eklenme tarihi
    }
}