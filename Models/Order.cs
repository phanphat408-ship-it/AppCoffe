using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CoffeeShopApi.Models;

public class Order
{
    [Key]
    public int Id { get; set; } // OrderId

    public int UserId { get; set; }

    public int? BranchId { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal TotalAmount { get; set; }

    [Required]
    [MaxLength(50)]
    public string Status { get; set; } = "Pending"; // Pending, Confirmed, Preparing, Delivering, Completed, Cancelled

    [Required]
    [MaxLength(50)]
    public string DeliveryType { get; set; } = "Delivery"; // DineIn, Takeaway, Delivery

    [MaxLength(500)]
    public string? ShippingAddress { get; set; }

    [MaxLength(20)]
    public string? ContactPhone { get; set; }

    [MaxLength(500)]
    public string? Note { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    // Navigation properties
    public User? User { get; set; }
    public Branch? Branch { get; set; }
    public ICollection<OrderDetail> OrderDetails { get; set; } = new List<OrderDetail>();
}
