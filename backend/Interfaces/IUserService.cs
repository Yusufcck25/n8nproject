using backend.Common;
using backend.DTOs;

namespace backend.Interfaces
{
    // Kullanıcı işlemleri servis sözleşmesi
    public interface IUserService
    {
        // Yeni kullanıcı kaydı
        Task<ApiResponse<UserDto>> RegisterAsync(RegisterDto dto);

        // Kullanıcı girişi
        Task<ApiResponse<UserDto>> LoginAsync(LoginDto dto);

        // Kullanıcı profili getirme
        Task<ApiResponse<UserDto>> GetByIdAsync(Guid id);
    }
}