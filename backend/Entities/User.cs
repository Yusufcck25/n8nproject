namespace backend.Entities
{
    // Uygulamaya kayıt olan kullanıcıların bilgilerini tutan tablo
    public class User
    {
        public Guid Id { get; set; } = Guid.NewGuid();         // Karmaşık ve benzersiz kullanıcı ID'si
        public string Email { get; set; } = string.Empty;      // Kullanıcı e-posta adresi (Unique / Benzersiz)
        public string PasswordHash { get; set; } = string.Empty; // Güvenlik için hash'lenmiş şifre
        public string FullName { get; set; } = string.Empty;   // Kullanıcının Adı Soyadı
        public string Role { get; set; } = "User";             // Yetki rolü ("User", "Admin")
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Üyelik tarihi

        // İlişkiler: Kullanıcının kaydettiği favorileri ve aramaları
        public ICollection<UserFavorite> Favorites { get; set; } = new List<UserFavorite>();
        public ICollection<SavedSearch> SavedSearches { get; set; } = new List<SavedSearch>();
    }
}