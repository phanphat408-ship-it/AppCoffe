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
        bool onlyAvailable = false,
        int? page = null,
        int? pageSize = null)
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

        query = query.OrderByDescending(p => p.Id);

        if (page.HasValue && page.Value > 0 && pageSize.HasValue && pageSize.Value > 0)
        {
            query = query.Skip((page.Value - 1) * pageSize.Value).Take(pageSize.Value);
        }

        return await query.ToListAsync();
    }

    public async Task<Product?> GetByIdWithCategoryAsync(int id, bool asNoTracking = false)
    {
        var query = _dbSet.Include(p => p.Category).AsQueryable();
        if (asNoTracking)
        {
            query = query.AsNoTracking();
        }
        return await query.FirstOrDefaultAsync(p => p.Id == id);
    }

    public async Task<IReadOnlyDictionary<int, int>> GetProductCountsByCategoryAsync()
    {
        return await _dbSet
            .AsNoTracking()
            .GroupBy(p => p.CategoryId)
            .Select(g => new { CategoryId = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.CategoryId, x => x.Count);
    }
}
