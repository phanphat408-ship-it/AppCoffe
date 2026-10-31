using CoffeeShopApi.Models;

namespace CoffeeShopApi.Repositories;

public interface IProductRepository : IRepository<Product>
{
    Task<IReadOnlyList<Product>> GetFilteredAsync(
        int? categoryId, 
        string? search, 
        decimal? minPrice, 
        decimal? maxPrice, 
        bool onlyAvailable = false,
        int? page = null,
        int? pageSize = null);
    Task<Product?> GetByIdWithCategoryAsync(int id, bool asNoTracking = false);
    Task<IReadOnlyDictionary<int, int>> GetProductCountsByCategoryAsync();
}
