using System.ComponentModel.DataAnnotations;

namespace CoffeeShopApi.DTOs.Product;

public class ProductDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Price { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
    public int CategoryId { get; set; }
    public string? CategoryName { get; set; }
    public bool IsAvailable { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateProductDto
{
    [Required(ErrorMessage = "Tên món không được để trống")]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string? Description { get; set; }

    [Required(ErrorMessage = "Giá món không được để trống")]
    [Range(1000, 10000000, ErrorMessage = "Giá sản phẩm phải từ 1,000 VND đến 10,000,000 VND")]
    public decimal Price { get; set; }

    [Required(ErrorMessage = "Đường dẫn hình ảnh không được để trống")]
    [MaxLength(500)]
    public string ImageUrl { get; set; } = string.Empty;

    [Required(ErrorMessage = "Danh mục không được để trống")]
    public int CategoryId { get; set; }

    public bool IsAvailable { get; set; } = true;
}

public class UpdateProductDto
{
    [Required(ErrorMessage = "Tên món không được để trống")]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string? Description { get; set; }

    [Required(ErrorMessage = "Giá món không được để trống")]
    [Range(1000, 10000000, ErrorMessage = "Giá sản phẩm phải từ 1,000 VND đến 10,000,000 VND")]
    public decimal Price { get; set; }

    [Required(ErrorMessage = "Đường dẫn hình ảnh không được để trống")]
    [MaxLength(500)]
    public string ImageUrl { get; set; } = string.Empty;

    [Required(ErrorMessage = "Danh mục không được để trống")]
    public int CategoryId { get; set; }

    public bool IsAvailable { get; set; } = true;
}

public class CategoryDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public int ProductCount { get; set; }
}

public class CreateCategoryDto
{
    [Required(ErrorMessage = "Tên danh mục không được để trống")]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(250)]
    public string? Description { get; set; }

    [MaxLength(500)]
    public string? ImageUrl { get; set; }
}
