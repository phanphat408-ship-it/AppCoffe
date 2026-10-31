using CoffeeShopApi.Data;
using CoffeeShopApi.Models;
using Microsoft.EntityFrameworkCore;

namespace CoffeeShopApi.Repositories;

public class OrderRepository : Repository<Order>, IOrderRepository
{
    public OrderRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<IReadOnlyList<Order>> GetOrdersAsync(int? userId = null, string? status = null, int? page = null, int? pageSize = null)
    {
        var query = _dbSet
            .Include(o => o.User)
            .Include(o => o.Branch)
            .Include(o => o.OrderDetails)
                .ThenInclude(od => od.Product)
            .AsNoTracking()
            .AsQueryable();

        if (userId.HasValue)
        {
            query = query.Where(o => o.UserId == userId.Value);
        }

        if (!string.IsNullOrWhiteSpace(status))
        {
            query = query.Where(o => o.Status.ToLower() == status.Trim().ToLower());
        }

        query = query.OrderByDescending(o => o.CreatedAt);

        if (page.HasValue && page.Value > 0 && pageSize.HasValue && pageSize.Value > 0)
        {
            query = query.Skip((page.Value - 1) * pageSize.Value).Take(pageSize.Value);
        }

        return await query.ToListAsync();
    }

    public async Task<Order?> GetByIdWithDetailsAsync(int orderId, bool asNoTracking = false)
    {
        var query = _dbSet
            .Include(o => o.User)
            .Include(o => o.Branch)
            .Include(o => o.OrderDetails)
                .ThenInclude(od => od.Product)
            .AsQueryable();

        if (asNoTracking)
        {
            query = query.AsNoTracking();
        }

        return await query.FirstOrDefaultAsync(o => o.Id == orderId);
    }

    public async Task<Order?> GetByIdAndUserIdWithDetailsAsync(int orderId, int userId, bool asNoTracking = false)
    {
        var query = _dbSet
            .Include(o => o.User)
            .Include(o => o.Branch)
            .Include(o => o.OrderDetails)
                .ThenInclude(od => od.Product)
            .AsQueryable();

        if (asNoTracking)
        {
            query = query.AsNoTracking();
        }

        return await query.FirstOrDefaultAsync(o => o.Id == orderId && o.UserId == userId);
    }
}
