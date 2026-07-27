using backend.DTOs;
using backend.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers
{
    // n8n senkronizasyon loglarının izlendiği ve kaydedildiği API uçları
    [ApiController]
    [Route("api/[controller]")]
    public class SyncLogsController : ControllerBase
    {
        private readonly ISyncLogService _syncLogService;

        public SyncLogsController(ISyncLogService syncLogService)
        {
            _syncLogService = syncLogService;
        }

        // Son logları getirir
        [HttpGet]
        public async Task<IActionResult> GetLogs([FromQuery] int count = 20)
        {
            var result = await _syncLogService.GetLogsAsync(count);
            return Ok(result);
        }

        // Yeni log ekler
        [HttpPost]
        public async Task<IActionResult> CreateLog([FromBody] SyncLogDto dto)
        {
            var result = await _syncLogService.CreateLogAsync(dto);
            if (!result.Success) return BadRequest(result);
            return Ok(result);
        }
    }
}