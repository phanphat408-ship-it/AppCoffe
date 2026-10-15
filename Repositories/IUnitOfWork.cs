using CoffeeShopApi.Models;
using Microsoft.EntityFrameworkCore.Storage;

namespace CoffeeShopApi.Repositories;

public interface IUnitOfWork : IDisposable
{
    IRepository<User> Users { get; }
    IRepository<Branch> Branches { get; }
    IRepository<Category> Categories { get; }
    IProductRepository Products { get; }
    ICartRepository Cart { get; }
    IOrderRepository Orders { get; }
    IRepository<OrderDetail> OrderDetails { get; }

    Task<int> SaveChangesAsync();
    Task<IDbContextTransaction> BeginTransactionAsync();
}
