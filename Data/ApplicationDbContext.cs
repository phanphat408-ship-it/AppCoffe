using CoffeeShopApi.Models;
using Microsoft.EntityFrameworkCore;

namespace CoffeeShopApi.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Branch> Branches => Set<Branch>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderDetail> OrderDetails => Set<OrderDetail>();
    public DbSet<CartItem> CartItems => Set<CartItem>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // User Configuration
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(u => u.Phone).IsUnique();
            entity.Property(u => u.Role).HasDefaultValue("Customer");
        });

        // Category Configuration
        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasMany(c => c.Products)
                  .WithOne(p => p.Category)
                  .HasForeignKey(p => p.CategoryId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // Product Configuration
        modelBuilder.Entity<Product>(entity =>
        {
            entity.Property(p => p.Price).HasPrecision(18, 2);
        });

        // Order Configuration
        modelBuilder.Entity<Order>(entity =>
        {
            entity.Property(o => o.TotalAmount).HasPrecision(18, 2);
            entity.Property(o => o.DriverName).HasMaxLength(100);
            entity.Property(o => o.DriverPhone).HasMaxLength(20).IsUnicode(false);
            entity.Property(o => o.PaymentStatus).HasMaxLength(50).HasDefaultValue("Pending");

            entity.HasOne(o => o.User)
                  .WithMany(u => u.Orders)
                  .HasForeignKey(o => o.UserId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(o => o.Branch)
                  .WithMany(b => b.Orders)
                  .HasForeignKey(o => o.BranchId)
                  .OnDelete(DeleteBehavior.SetNull);

            entity.HasMany(o => o.OrderDetails)
                  .WithOne(od => od.Order)
                  .HasForeignKey(od => od.OrderId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // OrderDetail Configuration
        modelBuilder.Entity<OrderDetail>(entity =>
        {
            entity.Property(od => od.UnitPrice).HasPrecision(18, 2);
            entity.Property(od => od.TotalPrice).HasPrecision(18, 2);

            entity.HasOne(od => od.Product)
                  .WithMany(p => p.OrderDetails)
                  .HasForeignKey(od => od.ProductId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // CartItem Configuration
        modelBuilder.Entity<CartItem>(entity =>
        {
            entity.HasOne(ci => ci.User)
                  .WithMany(u => u.CartItems)
                  .HasForeignKey(ci => ci.UserId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(ci => ci.Product)
                  .WithMany(p => p.CartItems)
                  .HasForeignKey(ci => ci.ProductId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(ci => new { ci.UserId, ci.ProductId }).IsUnique();
        });
    }
}
