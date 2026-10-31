using CoffeeShopApi.Models;

namespace CoffeeShopApi.Repositories;

public interface IOrderRepository : IRepository<Order>
{
    Task<IReadOnlyList<Order>> GetOrdersAsync(int? userId = null, string? status = null, int? page = null, int? pageSize = null);
    Task<Order?> GetByIdWithDetailsAsync(int orderId, bool asNoTracking = false);
    Task<Order?> GetByIdAndUserIdWithDetailsAsync(int orderId, int userId, bool asNoTracking = false);
}
