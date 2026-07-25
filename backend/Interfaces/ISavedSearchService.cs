using backend.Common;
using backend.DTOs;

namespace backend.Interfaces
{
    // Kayıtlı pazar aramaları servis sözleşmesi
    public interface ISavedSearchService
    {
        // Aramayı kaydeder
        Task<ApiResponse<SavedSearchDto>> SaveSearchAsync(CreateSavedSearchDto dto);

        // Kullanıcının kayıtlı aramalarını listeler
        Task<ApiResponse<List<SavedSearchDto>>> GetUserSavedSearchesAsync(Guid userId);

        // Kayıtlı aramayı siler
        Task<ApiResponse<bool>> DeleteSavedSearchAsync(int searchId, Guid userId);
    }
}
