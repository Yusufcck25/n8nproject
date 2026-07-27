using backend.Common;
using backend.DTOs;

namespace backend.Interfaces
{
    // Favori ilan yönetimi servis sözleşmesi
    public interface IUserFavoriteService
    {
        // Favoriye ekler
        Task<ApiResponse<UserFavoriteDto>> AddFavoriteAsync(Guid userId, CreateUserFavoriteDto dto);

        // Favoriden çıkarır
        Task<ApiResponse<bool>> RemoveFavoriteAsync(int favoriteId, Guid userId);

        // Kullanıcının tüm favorilerini getirir
        Task<ApiResponse<List<UserFavoriteDto>>> GetUserFavoritesAsync(Guid userId);
    }
}
