using backend.Common;
using backend.DTOs;

namespace backend.Interfaces
{
    // Pazar ve ihracat verilerinin servis sözleşmesi
    public interface IRadarDataService
    {
        // Filtreleme ve sayfalama ile fırsatları getirir
        Task<ApiResponse<PagedResultDto<RadarDataDto>>> GetFilteredRadarDataAsync(RadarFilterDto filter);

        // ID bazlı tekil fırsat detayını getirir
        Task<ApiResponse<RadarDataDto>> GetByIdAsync(long id);

        // n8n otomasyonundan gelen verileri toplu ekler
        Task<ApiResponse<bool>> BulkInsertAsync(List<RadarDataDto> dtos, string apiKey);
    }
}
