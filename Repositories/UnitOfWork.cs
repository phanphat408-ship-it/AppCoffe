using CoffeeShopApi.Data;
using CoffeeShopApi.Models;
using Microsoft.EntityFrameworkCore.Storage;

namespace CoffeeShopApi.Repositories;

public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;

    public IRepository<User> Users { get; }
    public IRepository<Branch> Branches { get; }
    public IRepository<Category> Categories { get; }
    public IProductRepository Products { get; }
    public ICartRepository Cart { get; }
    public IOrderRepository Orders { get; }
    public IRepository<OrderDetail> OrderDetails { get; }

    public UnitOfWork(
        ApplicationDbContext context,
        IRepository<User> users,
        IRepository<Branch> branches,
        IRepository<Category> categories,
        IProductRepository products,
        ICartRepository cart,
        IOrderRepository orders,
        IRepository<OrderDetail> orderDetails)
    {
        _context = context;
        Users = users;
        Branches = branches;
        Categories = categories;
        Products = products;
        Cart = cart;
        Orders = orders;
        OrderDetails = orderDetails;
    }

    public async Task<int> SaveChangesAsync()
    {
        return await _context.SaveChangesAsync();
    }

    public async Task<IDbContextTransaction> BeginTransactionAsync()
    {
        return await _context.Database.BeginTransactionAsync();
    }

    public void Dispose()
    {
        _context.Dispose();
        GC.SuppressFinalize(this);
    }
}
