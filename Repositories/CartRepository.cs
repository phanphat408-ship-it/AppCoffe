using CoffeeShopApi.Data;
using CoffeeShopApi.Models;
using Microsoft.EntityFrameworkCore;

namespace CoffeeShopApi.Repositories;

public class CartRepository : Repository<CartItem>, ICartRepository
{
    public CartRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<IReadOnlyList<CartItem>> GetCartByUserIdAsync(int userId, bool asNoTracking = false)
    {
        var query = _dbSet
            .Include(ci => ci.Product)
            .ThenInclude(p => p!.Category)
            .Where(ci => ci.UserId == userId)
            .OrderByDescending(ci => ci.AddedAt);

        return asNoTracking
            ? await query.AsNoTracking().ToListAsync()
            : await query.ToListAsync();
    }

    public async Task<CartItem?> GetItemAsync(int userId, int productId)
    {
        return await _dbSet
            .FirstOrDefaultAsync(ci => ci.UserId == userId && ci.ProductId == productId);
    }

    public async Task<CartItem?> GetItemByIdAndUserAsync(int id, int userId, bool asNoTracking = false)
    {
        var query = _dbSet.Include(ci => ci.Product).AsQueryable();
        if (asNoTracking)
        {
            query = query.AsNoTracking();
        }
        return await query.FirstOrDefaultAsync(ci => ci.Id == id && ci.UserId == userId);
    }

    public async Task ClearUserCartAsync(int userId)
    {
        var items = await _dbSet.Where(ci => ci.UserId == userId).ToListAsync();
        if (items.Count > 0)
        {
            _dbSet.RemoveRange(items);
        }
    }
}
