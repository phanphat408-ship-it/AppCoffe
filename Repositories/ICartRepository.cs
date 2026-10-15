using CoffeeShopApi.Models;

namespace CoffeeShopApi.Repositories;

public interface ICartRepository : IRepository<CartItem>
{
    Task<IReadOnlyList<CartItem>> GetCartByUserIdAsync(int userId);
    Task<CartItem?> GetItemAsync(int userId, int productId);
    Task<CartItem?> GetItemByIdAndUserAsync(int id, int userId);
    Task ClearUserCartAsync(int userId);
}
