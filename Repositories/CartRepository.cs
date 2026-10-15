using CoffeeShopApi.Data;
using CoffeeShopApi.Models;
using Microsoft.EntityFrameworkCore;

namespace CoffeeShopApi.Repositories;

public class CartRepository : Repository<CartItem>, ICartRepository
{
    public CartRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<IReadOnlyList<CartItem>> GetCartByUserIdAsync(int userId)
    {
        return await _dbSet
            .Include(ci => ci.Product)
            .ThenInclude(p => p!.Category)
            .Where(ci => ci.UserId == userId)
            .OrderByDescending(ci => ci.AddedAt)
            .ToListAsync();
    }

    public async Task<CartItem?> GetItemAsync(int userId, int productId)
    {
        return await _dbSet
            .FirstOrDefaultAsync(ci => ci.UserId == userId && ci.ProductId == productId);
    }

    public async Task<CartItem?> GetItemByIdAndUserAsync(int id, int userId)
    {
        return await _dbSet
            .Include(ci => ci.Product)
            .FirstOrDefaultAsync(ci => ci.Id == id && ci.UserId == userId);
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
