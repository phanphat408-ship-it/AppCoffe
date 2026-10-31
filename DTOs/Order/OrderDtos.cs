using System.ComponentModel.DataAnnotations;

namespace CoffeeShopApi.DTOs.Order;

public class CreateOrderItemDto
{
    [Required]
    public int ProductId { get; set; }

    [Range(1, 100, ErrorMessage = "Số lượng phải từ 1 đến 100")]
    public int Quantity { get; set; }
}

public class CreateOrderDto
{
    public int? BranchId { get; set; }

    [Required(ErrorMessage = "Hình thức nhận hàng không được để trống (DineIn, Takeaway, Delivery)")]
    public string DeliveryType { get; set; } = "Delivery"; // DineIn, Takeaway, Delivery

    [MaxLength(500)]
    public string? ShippingAddress { get; set; }

    [MaxLength(20)]
    public string? ContactPhone { get; set; }

    [MaxLength(500)]
    public string? Note { get; set; }

    // If Items is empty or null, the system can auto-create the order from the user's current Cart!
    public List<CreateOrderItemDto>? Items { get; set; }
}

public class OrderDetailDto
{
    public int Id { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string ProductImageUrl { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal TotalPrice { get; set; }
}

public class OrderDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public string CustomerPhone { get; set; } = string.Empty;
    public int? BranchId { get; set; }
    public string? BranchName { get; set; }
    public decimal TotalAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public string DeliveryType { get; set; } = string.Empty;
    public string? ShippingAddress { get; set; }
    public string? ContactPhone { get; set; }
    public string? Note { get; set; }
    public string? DriverName { get; set; }
    public string? DriverPhone { get; set; }
    public string PaymentStatus { get; set; } = "Pending";
    public DateTime CreatedAt { get; set; }
    public List<OrderDetailDto> OrderDetails { get; set; } = new();
}

public class UpdateOrderStatusDto
{
    [Required(ErrorMessage = "Trạng thái đơn hàng không được để trống")]
    public string Status { get; set; } = string.Empty; // Pending, Confirmed, Preparing, Delivering, Completed, Cancelled
}
