using CoffeeShopApi.DTOs.Auth;
using CoffeeShopApi.DTOs.Common;
using CoffeeShopApi.Models;
using CoffeeShopApi.Repositories;

namespace CoffeeShopApi.Services;

public interface IAuthService
{
    Task<ApiResponse<AuthResponseDto>> RegisterAsync(RegisterRequestDto request);
    Task<ApiResponse<AuthResponseDto>> LoginAsync(LoginRequestDto request);
    Task<ApiResponse<UserDto>> GetCurrentUserAsync(int userId);
}

public class AuthService : IAuthService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtService _jwtService;

    public AuthService(
        IUnitOfWork unitOfWork,
        IPasswordHasher passwordHasher,
        IJwtService jwtService)
    {
        _unitOfWork = unitOfWork;
        _passwordHasher = passwordHasher;
        _jwtService = jwtService;
    }

    public async Task<ApiResponse<AuthResponseDto>> RegisterAsync(RegisterRequestDto request)
    {
        // 1. Check if phone already registered
        var existingUsers = await _unitOfWork.Users.FindAsync(u => u.Phone == request.Phone.Trim());
        if (existingUsers.Any())
        {
            return ApiResponse<AuthResponseDto>.Fail("Số điện thoại này đã được đăng ký trong hệ thống.");
        }

        // 2. Hash password
        var passwordHash = _passwordHasher.HashPassword(request.Password);

        // 3. Create user entity
        var role = !string.IsNullOrWhiteSpace(request.Role) && 
                   (request.Role.Equals("Admin", StringComparison.OrdinalIgnoreCase) || 
                    request.Role.Equals("Staff", StringComparison.OrdinalIgnoreCase)) 
                   ? request.Role 
                   : "Customer";

        var user = new User
        {
            Name = request.Name.Trim(),
            Phone = request.Phone.Trim(),
            PasswordHash = passwordHash,
            Role = role,
            CreatedAt = DateTime.UtcNow
        };

        await _unitOfWork.Users.AddAsync(user);
        await _unitOfWork.SaveChangesAsync();

        // 4. Generate token
        var (token, expiresAt) = _jwtService.GenerateToken(user);

        var responseDto = new AuthResponseDto
        {
            Token = token,
            ExpiresAt = expiresAt,
            User = new UserDto
            {
                Id = user.Id,
                Name = user.Name,
                Phone = user.Phone,
                Role = user.Role,
                CreatedAt = user.CreatedAt
            }
        };

        return ApiResponse<AuthResponseDto>.Ok(responseDto, "Đăng ký tài khoản thành công.");
    }

    public async Task<ApiResponse<AuthResponseDto>> LoginAsync(LoginRequestDto request)
    {
        // 1. Find user by phone
        var users = await _unitOfWork.Users.FindAsync(u => u.Phone == request.Phone.Trim());
        var user = users.FirstOrDefault();

        if (user == null)
        {
            return ApiResponse<AuthResponseDto>.Fail("Số điện thoại hoặc mật khẩu không chính xác.");
        }

        // 2. Verify password
        var isValidPassword = _passwordHasher.VerifyPassword(request.Password, user.PasswordHash);
        if (!isValidPassword)
        {
            return ApiResponse<AuthResponseDto>.Fail("Số điện thoại hoặc mật khẩu không chính xác.");
        }

        // 3. Generate token
        var (token, expiresAt) = _jwtService.GenerateToken(user);

        var responseDto = new AuthResponseDto
        {
            Token = token,
            ExpiresAt = expiresAt,
            User = new UserDto
            {
                Id = user.Id,
                Name = user.Name,
                Phone = user.Phone,
                Role = user.Role,
                CreatedAt = user.CreatedAt
            }
        };

        return ApiResponse<AuthResponseDto>.Ok(responseDto, "Đăng nhập thành công.");
    }

    public async Task<ApiResponse<UserDto>> GetCurrentUserAsync(int userId)
    {
        var user = await _unitOfWork.Users.GetByIdAsync(userId);
        if (user == null)
        {
            return ApiResponse<UserDto>.Fail("Không tìm thấy thông tin người dùng.");
        }

        var userDto = new UserDto
        {
            Id = user.Id,
            Name = user.Name,
            Phone = user.Phone,
            Role = user.Role,
            CreatedAt = user.CreatedAt
        };

        return ApiResponse<UserDto>.Ok(userDto);
    }
}
