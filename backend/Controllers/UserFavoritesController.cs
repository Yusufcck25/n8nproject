using backend.DTOs;
using backend.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace backend.Controllers
{
    // Favori pazar fırsatlarının yönetildiği API uçları
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UserFavoritesController : ControllerBase
    {
        private readonly IUserFavoriteService _favoriteService;

        public UserFavoritesController(IUserFavoriteService favoriteService)
        {
            _favoriteService = favoriteService;
        }

        // Favorilere yeni fırsat ekler
        [HttpPost]
        public async Task<IActionResult> AddFavorite([FromBody] CreateUserFavoriteDto dto)
        {
            if (!TryGetCurrentUserId(out var userId)) return Unauthorized();

            var result = await _favoriteService.AddFavoriteAsync(userId, dto);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        // Kullanıcının tüm favorilerini getirir
        [HttpGet]
        public async Task<IActionResult> GetUserFavorites()
        {
            if (!TryGetCurrentUserId(out var userId)) return Unauthorized();

            var result = await _favoriteService.GetUserFavoritesAsync(userId);
            return Ok(result);
        }

        // Favori kaydını siler
        [HttpDelete("{id}")]
        public async Task<IActionResult> RemoveFavorite(int id)
        {
            if (!TryGetCurrentUserId(out var userId)) return Unauthorized();

            var result = await _favoriteService.RemoveFavoriteAsync(id, userId);
            if (!result.Success) return NotFound(result);
            return Ok(result);
        }

        private bool TryGetCurrentUserId(out Guid userId)
        {
            return Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
        }
    }
}
