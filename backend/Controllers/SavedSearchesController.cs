using backend.DTOs;
using backend.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace backend.Controllers
{
    // Kullanıcının kaydettiği pazar aramalarının API uçları
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
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
            if (!TryGetCurrentUserId(out var userId)) return Unauthorized();

            var result = await _savedSearchService.SaveSearchAsync(userId, dto);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        // Kullanıcının tüm kayıtlı aramalarını getirir
        [HttpGet]
        public async Task<IActionResult> GetUserSavedSearches()
        {
            if (!TryGetCurrentUserId(out var userId)) return Unauthorized();

            var result = await _savedSearchService.GetUserSavedSearchesAsync(userId);
            return Ok(result);
        }

        // Kayıtlı aramayı siler
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSavedSearch(int id)
        {
            if (!TryGetCurrentUserId(out var userId)) return Unauthorized();

            var result = await _savedSearchService.DeleteSavedSearchAsync(id, userId);
            if (!result.Success) return NotFound(result);
            return Ok(result);
        }

        private bool TryGetCurrentUserId(out Guid userId)
        {
            return Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
        }
    }
}
