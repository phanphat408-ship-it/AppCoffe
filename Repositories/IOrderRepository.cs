using CoffeeShopApi.Models;

namespace CoffeeShopApi.Repositories;

public interface IOrderRepository : IRepository<Order>
{
    Task<IReadOnlyList<Order>> GetOrdersAsync(int? userId = null, string? status = null);
    Task<Order?> GetByIdWithDetailsAsync(int orderId);
    Task<Order?> GetByIdAndUserIdWithDetailsAsync(int orderId, int userId);
}
