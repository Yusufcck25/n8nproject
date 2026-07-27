using backend.Common;
using backend.Data;
using backend.DTOs;
using backend.Entities;
using backend.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services
{
    // Pazar verilerinin veritabanı işlemlerini yürüten servis
    public class RadarDataService : IRadarDataService
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;

        public RadarDataService(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        // Ülke, Kategori, Arama Metni ve Puan bazlı filtreleme ve sayfalama (Pagination)
        public async Task<ApiResponse<PagedResultDto<RadarDataDto>>> GetFilteredRadarDataAsync(RadarFilterDto filter)
        {
            var query = _context.RadarData.AsQueryable();

            // 1. Ülke Filtresi
            if (!string.IsNullOrEmpty(filter.Country))
                query = query.Where(r => r.Country.ToLower() == filter.Country.ToLower());

            // 2. Kategori / GTİP Kodu Filtresi
            if (!string.IsNullOrEmpty(filter.Category))
                query = query.Where(r => r.Category.Contains(filter.Category));

            // 3. Başlık veya Kaynak Adında Arama Metni Filtresi
            if (!string.IsNullOrEmpty(filter.SearchTerm))
                query = query.Where(r => r.Title.Contains(filter.SearchTerm) || r.SourceName.Contains(filter.SearchTerm));

            // 4. Minimum Fırsat Puanı Filtresi
            if (filter.MinOpportunityScore.HasValue)
                query = query.Where(r => r.OpportunityScore >= filter.MinOpportunityScore.Value);

            // Filtrelenmiş toplam kayıt sayısı
            int totalCount = await query.CountAsync();

            // Sayfalama (Skip & Take) ve DTO Dönüşümü
            var items = await query
                .OrderByDescending(r => r.CreatedAt)
                .Skip((filter.Page - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .Select(r => new RadarDataDto
                {
                    Id = r.Id,
                    SourceName = r.SourceName,
                    Title = r.Title,
                    Country = r.Country,
                    Category = r.Category,
                    OpportunityScore = r.OpportunityScore,
                    RawData = r.RawData,
                    CreatedAt = r.CreatedAt
                })
                .ToListAsync();

            var pagedResult = new PagedResultDto<RadarDataDto>
            {
                Items = items,
                TotalCount = totalCount,
                Page = filter.Page,
                PageSize = filter.PageSize
            };

            return ApiResponse<PagedResultDto<RadarDataDto>>.SuccessResult(pagedResult, "Pazar fırsatları başarıyla listelendi.");
        }

        // ID ile tekil fırsat arama
        public async Task<ApiResponse<RadarDataDto>> GetByIdAsync(long id)
        {
            var entity = await _context.RadarData.FindAsync(id);
            if (entity == null)
                return ApiResponse<RadarDataDto>.ErrorResult("Aranan pazar verisi bulunamadı.");

            var dto = new RadarDataDto
            {
                Id = entity.Id,
                SourceName = entity.SourceName,
                Title = entity.Title,
                Country = entity.Country,
                Category = entity.Category,
                OpportunityScore = entity.OpportunityScore,
                RawData = entity.RawData,
                CreatedAt = entity.CreatedAt
            };

            return ApiResponse<RadarDataDto>.SuccessResult(dto);
        }

        // n8n otomasyonundan gelen verilerin toplu basılması
        public async Task<ApiResponse<bool>> BulkInsertAsync(List<RadarDataDto> dtos, string apiKey)
        {
            // API Key Güvenlik Kontrolü
            var validApiKey = _configuration["N8nSettings:ApiKey"];
            if (string.IsNullOrWhiteSpace(validApiKey) || apiKey != validApiKey)
                return ApiResponse<bool>.ErrorResult("Yetkisiz n8n erişimi! Geçersiz API Key.");

            // DTO -> Entity dönüşümü ve veritabanına ekleme
            var entities = dtos.Select(dto => new RadarData
            {
                SourceName = dto.SourceName,
                Title = dto.Title,
                Country = dto.Country,
                Category = dto.Category,
                OpportunityScore = dto.OpportunityScore,
                RawData = dto.RawData,
                CreatedAt = DateTime.UtcNow
            }).ToList();

            await _context.RadarData.AddRangeAsync(entities);
            await _context.SaveChangesAsync();

            return ApiResponse<bool>.SuccessResult(true, $"{entities.Count} adet yeni veri n8n ile veritabanına aktarıldı.");
        }
    }
}
