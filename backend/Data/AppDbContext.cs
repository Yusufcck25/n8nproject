using backend.Entities;
using Microsoft.EntityFrameworkCore;

namespace backend.Data
{
    // Entity Framework Core'un veritabanı ile iletişim kurmasını sağlayan ana sınıf
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        // Veritabanında tabloya dönüşecek olan DbSet tanımları
        public DbSet<User> Users => Set<User>();
        public DbSet<RadarData> RadarData => Set<RadarData>();
        public DbSet<UserFavorite> UserFavorites => Set<UserFavorite>();
        public DbSet<SavedSearch> SavedSearches => Set<SavedSearch>();
        public DbSet<SyncLog> SyncLogs => Set<SyncLog>();

        // Tablolar arası ilişkilerin, index'lerin ve kuralların konfigürasyonu
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // PERFORMANS: Ülke ve Kategoriye göre yapılan aramaların milisaniyeler sürmesi için INDEX ekliyoruz
            modelBuilder.Entity<RadarData>()
                .HasIndex(r => new { r.Country, r.Category });

            // GÜVENLİK: Aynı e-posta adresiyle ikinci kez kayıt olunamasın (Unique Index)
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            // İLİŞKİ: bir Kullanıcı silindiğinde onun Favori kayıtları da otomatik temizlensin (Cascade Delete)
            modelBuilder.Entity<UserFavorite>()
                .HasOne(uf => uf.User)
                .WithMany(u => u.Favorites)
                .HasForeignKey(uf => uf.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserFavorite>()
                .HasOne(uf => uf.RadarData)
                .WithMany(r => r.Favorites)
                .HasForeignKey(uf => uf.RadarDataId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}