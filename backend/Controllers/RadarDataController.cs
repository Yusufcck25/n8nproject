using backend.DTOs;
using backend.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers
{
    // Pazar ve ihracat fırsat verilerinin dışarı açıldığı API uçları
    [ApiController]
    [Route("api/[controller]")]
    public class RadarDataController : ControllerBase
    {
        private readonly IRadarDataService _radarService;

        public RadarDataController(IRadarDataService radarService)
        {
            _radarService = radarService;
        }

        // Filtreleme ve sayfalama ile fırsat verilerini getirir
        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] RadarFilterDto filter)
        {
            var result = await _radarService.GetFilteredRadarDataAsync(filter);
            return Ok(result);
        }

        // ID ile tekil kayıt detayını getirir
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(long id)
        {
            var result = await _radarService.GetByIdAsync(id);
            if (!result.Success) return NotFound(result);
            return Ok(result);
        }

        // n8n otomasyonunun veritabanına toplu veri aktardığı güvenli uç
        [HttpPost("bulk-import")]
        public async Task<IActionResult> BulkImport([FromBody] List<RadarDataDto> dtos, [FromHeader(Name = "X-N8N-API-KEY")] string apiKey)
        {
            var result = await _radarService.BulkInsertAsync(dtos, apiKey);
            if (!result.Success) return Unauthorized(result);
            return Ok(result);
        }
    }
}