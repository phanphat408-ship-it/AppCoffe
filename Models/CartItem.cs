using System.ComponentModel.DataAnnotations;

namespace CoffeeShopApi.Models;

public class CartItem
{
    [Key]
    public int Id { get; set; }

    public int UserId { get; set; }

    public int ProductId { get; set; }

    public int Quantity { get; set; } = 1;

    public DateTime AddedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public User? User { get; set; }
    public Product? Product { get; set; }
}
