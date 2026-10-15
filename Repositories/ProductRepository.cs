using CoffeeShopApi.Data;
using CoffeeShopApi.Models;
using Microsoft.EntityFrameworkCore;

namespace CoffeeShopApi.Repositories;

public class ProductRepository : Repository<Product>, IProductRepository
{
    public ProductRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<IReadOnlyList<Product>> GetFilteredAsync(
        int? categoryId, 
        string? search, 
        decimal? minPrice, 
        decimal? maxPrice, 
        bool onlyAvailable = false)
    {
        var query = _dbSet.Include(p => p.Category).AsNoTracking().AsQueryable();

        if (categoryId.HasValue && categoryId.Value > 0)
        {
            query = query.Where(p => p.CategoryId == categoryId.Value);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var searchLower = search.Trim().ToLower();
            query = query.Where(p => p.Name.ToLower().Contains(searchLower) || 
                                     (p.Description != null && p.Description.ToLower().Contains(searchLower)));
        }

        if (minPrice.HasValue)
        {
            query = query.Where(p => p.Price >= minPrice.Value);
        }

        if (maxPrice.HasValue)
        {
            query = query.Where(p => p.Price <= maxPrice.Value);
        }

        if (onlyAvailable)
        {
            query = query.Where(p => p.IsAvailable);
        }

        return await query.OrderByDescending(p => p.Id).ToListAsync();
    }

    public async Task<Product?> GetByIdWithCategoryAsync(int id)
    {
        return await _dbSet.Include(p => p.Category)
                           .FirstOrDefaultAsync(p => p.Id == id);
    }
}
