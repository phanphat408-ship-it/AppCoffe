using CoffeeShopApi.Models;

namespace CoffeeShopApi.Repositories;

public interface IProductRepository : IRepository<Product>
{
    Task<IReadOnlyList<Product>> GetFilteredAsync(int? categoryId, string? search, decimal? minPrice, decimal? maxPrice, bool onlyAvailable = false);
    Task<Product?> GetByIdWithCategoryAsync(int id);
}
