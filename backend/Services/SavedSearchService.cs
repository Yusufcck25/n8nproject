using backend.Common;
using backend.Data;
using backend.DTOs;
using backend.Entities;
using backend.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services
{
    // Kayıtlı pazar aramalarını yöneten servis
    public class SavedSearchService : ISavedSearchService
    {
        private readonly AppDbContext _context;

        public SavedSearchService(AppDbContext context)
        {
            _context = context;
        }

        // Yeni Pazar Araması Kaydetme
        public async Task<ApiResponse<SavedSearchDto>> SaveSearchAsync(CreateSavedSearchDto dto)
        {
            var savedSearch = new SavedSearch
            {
                UserId = dto.UserId,
                SearchQuery = dto.Name,
                Filters = dto.SearchQueryJson,
                CreatedAt = DateTime.UtcNow
            };

            await _context.SavedSearches.AddAsync(savedSearch);
            await _context.SaveChangesAsync();

            var resultDto = new SavedSearchDto
            {
                Id = savedSearch.Id,
                UserId = savedSearch.UserId,
                Name = savedSearch.SearchQuery,
                SearchQueryJson = savedSearch.Filters,
                CreatedAt = savedSearch.CreatedAt
            };

            return ApiResponse<SavedSearchDto>.SuccessResult(resultDto, "Pazar araması başarıyla kaydedildi.");
        }

        // Kullanıcının Kayıtlı Aramalarını Listeleme
        public async Task<ApiResponse<List<SavedSearchDto>>> GetUserSavedSearchesAsync(Guid userId)
        {
            var searches = await _context.SavedSearches
                .Where(s => s.UserId == userId)
                .OrderByDescending(s => s.CreatedAt)
                .Select(s => new SavedSearchDto
                {
                    Id = s.Id,
                    UserId = s.UserId,
                    Name = s.SearchQuery,
                    SearchQueryJson = s.Filters,
                    CreatedAt = s.CreatedAt
                })
                .ToListAsync();

            return ApiResponse<List<SavedSearchDto>>.SuccessResult(searches);
        }

        // Kayıtlı Aramayı Silme
        public async Task<ApiResponse<bool>> DeleteSavedSearchAsync(int searchId, Guid userId)
        {
            var search = await _context.SavedSearches.FirstOrDefaultAsync(s => s.Id == searchId && s.UserId == userId);
            if (search == null)
                return ApiResponse<bool>.ErrorResult("Silinmek istenen kayıtlı arama bulunamadı.");

            _context.SavedSearches.Remove(search);
            await _context.SaveChangesAsync();

            return ApiResponse<bool>.SuccessResult(true, "Kayıtlı arama başarıyla silindi.");
        }
    }
}
