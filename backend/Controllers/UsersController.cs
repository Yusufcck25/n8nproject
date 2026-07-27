using backend.DTOs;
using backend.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers
{
    // Kullanıcı kayıt ve giriş işlemlerinin yönetildiği API uçları
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;

        public UsersController(IUserService userService)
        {
            _userService = userService;
        }

        // Yeni kullanıcı kaydı
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            var result = await _userService.RegisterAsync(dto);
            if (!result.Success) return Conflict(result);
            return Ok(result);
        }

        // Kullanıcı girişi
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            var result = await _userService.LoginAsync(dto);
            if (!result.Success) return Unauthorized(result);
            return Ok(result);
        }

        // ID ile kullanıcı profili getirme
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(Guid id)
        {
            var result = await _userService.GetByIdAsync(id);
            if (!result.Success) return NotFound(result);
            return Ok(result);
        }
    }
}
