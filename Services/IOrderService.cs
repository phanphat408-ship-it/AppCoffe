using CoffeeShopApi.DTOs.Common;
using CoffeeShopApi.DTOs.Order;

namespace CoffeeShopApi.Services;

public interface IOrderService
{
    Task<ApiResponse<OrderDto>> CreateOrderAsync(int userId, CreateOrderDto request);
    Task<ApiResponse<IReadOnlyList<OrderDto>>> GetOrdersAsync(int userId, string userRole, string? status = null);
    Task<ApiResponse<OrderDto>> GetOrderByIdAsync(int orderId, int userId, string userRole);
    Task<ApiResponse<OrderDto>> UpdateOrderStatusAsync(int orderId, string status);
    Task<ApiResponse<OrderDto>> CancelOrderAsync(int orderId, int userId);
}
