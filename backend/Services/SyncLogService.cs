using backend.Common;
using backend.Data;
using backend.DTOs;
using backend.Entities;
using backend.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services
{
    // n8n veri senkronizasyon loglarını yöneten servis
    public class SyncLogService : ISyncLogService
    {
        private readonly AppDbContext _context;

        public SyncLogService(AppDbContext context)
        {
            _context = context;
        }

        // Son Senkronizasyon Loglarını Listeleme
        public async Task<ApiResponse<List<SyncLogDto>>> GetLogsAsync(int count = 20)
        {
            var logs = await _context.SyncLogs
                .OrderByDescending(l => l.ExecutedAt)
                .Take(count)
                .Select(l => new SyncLogDto
                {
                    Id = l.Id,
                    WorkflowName = l.WorkflowName,
                    Status = l.Status,
                    ProcessedCount = l.RecordsInserted,
                    ErrorMessage = l.ErrorMessage,
                    LoggedAt = l.ExecutedAt
                })
                .ToListAsync();

            return ApiResponse<List<SyncLogDto>>.SuccessResult(logs);
        }

        // Yeni Log Kaydı Ekleme
        public async Task<ApiResponse<bool>> CreateLogAsync(SyncLogDto dto)
        {
            var log = new SyncLog
            {
                WorkflowName = dto.WorkflowName,
                Status = dto.Status,
                RecordsInserted = dto.ProcessedCount,
                ErrorMessage = dto.ErrorMessage,
                ExecutedAt = DateTime.UtcNow
            };

            await _context.SyncLogs.AddAsync(log);
            await _context.SaveChangesAsync();

            return ApiResponse<bool>.SuccessResult(true, "Senkronizasyon log kaydı oluşturuldu.");
        }
    }
}
