using backend.Common;
using backend.Data;
using backend.DTOs;
using backend.Entities;
using backend.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Services
{
    // Kullanıcı kayıt ve giriş mantığını yöneten servis
    public class UserService : IUserService
    {
        private readonly AppDbContext _context;

        public UserService(AppDbContext context)
        {
            _context = context;
        }

        // Yeni Kullanıcı Kaydı
        public async Task<ApiResponse<UserDto>> RegisterAsync(RegisterDto dto)
        {
            // Mükerrer E-posta Kontrolü
            var existingUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (existingUser != null)
                return ApiResponse<UserDto>.ErrorResult("Bu e-posta adresi zaten sisteme kayıtlı.");

            var user = new User
            {
                Id = Guid.NewGuid(),
                Email = dto.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                FullName = dto.FullName,
                CreatedAt = DateTime.UtcNow
            };

            await _context.Users.AddAsync(user);
            await _context.SaveChangesAsync();

            var userDto = new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FullName = user.FullName,
                CreatedAt = user.CreatedAt
            };

            return ApiResponse<UserDto>.SuccessResult(userDto, "Kullanıcı kaydı başarıyla tamamlandı.");
        }

        // Kullanıcı Giriş Kontrolü
        public async Task<ApiResponse<UserDto>> LoginAsync(LoginDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (user == null)
                return ApiResponse<UserDto>.ErrorResult("E-posta adresi veya şifre hatalı.");

            var usesBcrypt = user.PasswordHash.StartsWith("$2", StringComparison.Ordinal);
            var passwordIsValid = usesBcrypt
                ? BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash)
                : dto.Password == user.PasswordHash;

            if (!passwordIsValid)
                return ApiResponse<UserDto>.ErrorResult("E-posta adresi veya şifre hatalı.");

            if (!usesBcrypt)
            {
                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password);
                await _context.SaveChangesAsync();
            }

            var userDto = new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FullName = user.FullName,
                CreatedAt = user.CreatedAt
            };

            return ApiResponse<UserDto>.SuccessResult(userDto, "Giriş işlemi başarılı.");
        }

        // ID ile Kullanıcı Profil Getirme
        public async Task<ApiResponse<UserDto>> GetByIdAsync(Guid id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return ApiResponse<UserDto>.ErrorResult("Kullanıcı bulunamadı.");

            var userDto = new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FullName = user.FullName,
                CreatedAt = user.CreatedAt
            };

            return ApiResponse<UserDto>.SuccessResult(userDto);
        }
    }
}
