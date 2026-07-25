using backend.Common;
using backend.DTOs;

namespace backend.Interfaces
{
    // n8n senkronizasyon logları servis sözleşmesi
    public interface ISyncLogService
    {
        // Son logları getirir
        Task<ApiResponse<List<SyncLogDto>>> GetLogsAsync(int count = 20);

        // Yeni log kaydı ekler
        Task<ApiResponse<bool>> CreateLogAsync(SyncLogDto dto);
    }
}