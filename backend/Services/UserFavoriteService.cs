using backend.Common;
using backend.Data;
using backend.DTOs;
using backend.Entities;
using backend.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services
{
    // Kullanıcının favori fırsatlarını yöneten servis
    public class UserFavoriteService : IUserFavoriteService
    {
        private readonly AppDbContext _context;

        public UserFavoriteService(AppDbContext context)
        {
            _context = context;
        }

        // Favorilere Yeni Fırsat Ekleme
        public async Task<ApiResponse<UserFavoriteDto>> AddFavoriteAsync(Guid userId, CreateUserFavoriteDto dto)
        {
            var favorite = new UserFavorite
            {
                UserId = userId,
                RadarDataId = dto.RadarDataId,
                Note = dto.Note,
                CreatedAt = DateTime.UtcNow
            };

            await _context.UserFavorites.AddAsync(favorite);
            await _context.SaveChangesAsync();

            var resultDto = new UserFavoriteDto
            {
                Id = favorite.Id,
                UserId = favorite.UserId,
                RadarDataId = favorite.RadarDataId,
                Note = favorite.Note,
                CreatedAt = favorite.CreatedAt
            };

            return ApiResponse<UserFavoriteDto>.SuccessResult(resultDto, "Fırsat favorilerinize eklendi.");
        }

        // Favoriden Çıkarma
        public async Task<ApiResponse<bool>> RemoveFavoriteAsync(int favoriteId, Guid userId)
        {
            var favorite = await _context.UserFavorites.FirstOrDefaultAsync(f => f.Id == favoriteId && f.UserId == userId);
            if (favorite == null)
                return ApiResponse<bool>.ErrorResult("Silinmek istenen favori kaydı bulunamadı.");

            _context.UserFavorites.Remove(favorite);
            await _context.SaveChangesAsync();

            return ApiResponse<bool>.SuccessResult(true, "Favori kaydı başarıyla silindi.");
        }

        // Kullanıcının Tüm Favorilerini Getirme (İlan Detaylarıyla Birlikte)
        public async Task<ApiResponse<List<UserFavoriteDto>>> GetUserFavoritesAsync(Guid userId)
        {
            var favorites = await _context.UserFavorites
                .Include(f => f.RadarData) // İlişkili ilan verisini de bağlama (Join)
                .Where(f => f.UserId == userId)
                .OrderByDescending(f => f.CreatedAt)
                .Select(f => new UserFavoriteDto
                {
                    Id = f.Id,
                    UserId = f.UserId,
                    RadarDataId = f.RadarDataId,
                    Note = f.Note,
                    CreatedAt = f.CreatedAt,
                    RadarData = f.RadarData != null ? new RadarDataDto
                    {
                        Id = f.RadarData.Id,
                        SourceName = f.RadarData.SourceName,
                        Title = f.RadarData.Title,
                        Country = f.RadarData.Country,
                        Category = f.RadarData.Category,
                        OpportunityScore = f.RadarData.OpportunityScore,
                        RawData = f.RadarData.RawData,
                        CreatedAt = f.RadarData.CreatedAt
                    } : null
                })
                .ToListAsync();

            return ApiResponse<List<UserFavoriteDto>>.SuccessResult(favorites);
        }
    }
}
