using backend.DTOs;
using backend.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Cryptography;
using System.Text;
using System.ComponentModel.DataAnnotations;

namespace backend.Controllers
{
    // n8n senkronizasyon loglarının izlendiği ve kaydedildiği API uçları
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class SyncLogsController : ControllerBase
    {
        private readonly ISyncLogService _syncLogService;
        private readonly IConfiguration _configuration;

        public SyncLogsController(ISyncLogService syncLogService, IConfiguration configuration)
        {
            _syncLogService = syncLogService;
            _configuration = configuration;
        }

        // Son logları getirir
        [HttpGet]
        public async Task<IActionResult> GetLogs([FromQuery, Range(1, 100)] int count = 20)
        {
            var result = await _syncLogService.GetLogsAsync(count);
            return Ok(result);
        }

        // Yeni log ekler
        [AllowAnonymous]
        [HttpPost]
        public async Task<IActionResult> CreateLog(
            [FromBody] SyncLogDto dto,
            [FromHeader(Name = "X-N8N-API-KEY")] string? apiKey)
        {
            if (!IsValidN8nApiKey(apiKey)) return Unauthorized();

            var result = await _syncLogService.CreateLogAsync(dto);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }

        private bool IsValidN8nApiKey(string? apiKey)
        {
            var configuredApiKey = _configuration["N8nSettings:ApiKey"];
            if (string.IsNullOrWhiteSpace(configuredApiKey) || string.IsNullOrWhiteSpace(apiKey))
                return false;

            return CryptographicOperations.FixedTimeEquals(
                Encoding.UTF8.GetBytes(apiKey),
                Encoding.UTF8.GetBytes(configuredApiKey));
        }
    }
}
