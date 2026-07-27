using backend.DTOs;
using backend.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers
{
    // Kullanıcının kaydettiği pazar aramalarının API uçları
    [ApiController]
    [Route("api/[controller]")]
    public class SavedSearchesController : ControllerBase
    {
        private readonly ISavedSearchService _savedSearchService;

        public SavedSearchesController(ISavedSearchService savedSearchService)
        {
            _savedSearchService = savedSearchService;
        }

        // Aramayı kaydeder
        [HttpPost]
        public async Task<IActionResult> SaveSearch([FromBody] CreateSavedSearchDto dto)
        {
            var result = await _savedSearchService.SaveSearchAsync(dto);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        // Kullanıcının tüm kayıtlı aramalarını getirir
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserSavedSearches(Guid userId)
        {
            var result = await _savedSearchService.GetUserSavedSearchesAsync(userId);
            return Ok(result);
        }

        // Kayıtlı aramayı siler
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSavedSearch(int id, [FromQuery] Guid userId)
        {
            var result = await _savedSearchService.DeleteSavedSearchAsync(id, userId);
            if (!result.Success) return NotFound(result);
            return Ok(result);
        }
    }
}
