using backend.DTOs;
using backend.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers
{
    // Favori pazar fırsatlarının yönetildiği API uçları
    [ApiController]
    [Route("api/[controller]")]
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
            var result = await _favoriteService.AddFavoriteAsync(dto);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        // Kullanıcının tüm favorilerini getirir
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserFavorites(Guid userId)
        {
            var result = await _favoriteService.GetUserFavoritesAsync(userId);
            return Ok(result);
        }

        // Favori kaydını siler
        [HttpDelete("{id}")]
        public async Task<IActionResult> RemoveFavorite(int id, [FromQuery] Guid userId)
        {
            var result = await _favoriteService.RemoveFavoriteAsync(id, userId);
            if (!result.Success) return NotFound(result);
            return Ok(result);
        }
    }
}
