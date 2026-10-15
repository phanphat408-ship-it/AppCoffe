using System.ComponentModel.DataAnnotations;

namespace CoffeeShopApi.DTOs.Cart;

public class AddToCartDto
{
    [Required(ErrorMessage = "ProductId không được để trống")]
    public int ProductId { get; set; }

    [Range(1, 100, ErrorMessage = "Số lượng phải từ 1 đến 100")]
    public int Quantity { get; set; } = 1;
}

public class UpdateCartItemDto
{
    [Range(1, 100, ErrorMessage = "Số lượng phải từ 1 đến 100")]
    public int Quantity { get; set; }
}

public class CartItemDto
{
    public int Id { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public decimal ProductPrice { get; set; }
    public string ProductImageUrl { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal SubTotal { get; set; }
}

public class CartResponseDto
{
    public List<CartItemDto> Items { get; set; } = new();
    public int TotalItems { get; set; }
    public decimal TotalAmount { get; set; }
}
