using backend.Common;
using backend.DTOs;
using backend.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace backend.Controllers
{
    // Kullanıcı kayıt ve giriş işlemlerinin yönetildiği API uçları
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IConfiguration _configuration;

        public UsersController(IUserService userService, IConfiguration configuration)
        {
            _userService = userService;
            _configuration = configuration;
        }

        // Yeni kullanıcı kaydı
        [AllowAnonymous]
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            var result = await _userService.RegisterAsync(dto);
            if (!result.Success) return Conflict(result);
            return Ok(result);
        }

        // Kullanıcı girişi
        [AllowAnonymous]
        [EnableRateLimiting("login")]
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            var result = await _userService.LoginAsync(dto);
            if (!result.Success) return Unauthorized(result);

            var (accessToken, expiresAt) = CreateAccessToken(result.Data!);
            var response = ApiResponse<LoginResponseDto>.SuccessResult(
                new LoginResponseDto
                {
                    User = result.Data!,
                    AccessToken = accessToken,
                    ExpiresAt = expiresAt
                },
                result.Message);

            return Ok(response);
        }

        // ID ile kullanıcı profili getirme
        [HttpGet("me")]
        public async Task<IActionResult> GetCurrentUser()
        {
            if (!TryGetCurrentUserId(out var currentUserId)) return Unauthorized();

            var result = await _userService.GetByIdAsync(currentUserId);
            if (!result.Success) return NotFound(result);
            return Ok(result);
        }

        private bool TryGetCurrentUserId(out Guid userId)
        {
            return Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);
        }

        private (string AccessToken, DateTime ExpiresAt) CreateAccessToken(UserDto user)
        {
            var expiresAt = DateTime.UtcNow.AddHours(8);
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims:
                [
                    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                    new Claim(ClaimTypes.Email, user.Email),
                    new Claim(ClaimTypes.Role, user.Role)
                ],
                expires: expiresAt,
                signingCredentials: credentials);

            return (new JwtSecurityTokenHandler().WriteToken(token), expiresAt);
        }
    }
}
