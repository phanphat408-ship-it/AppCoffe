using CoffeeShopApi.DTOs.Common;
using CoffeeShopApi.DTOs.Product;
using CoffeeShopApi.Models;
using CoffeeShopApi.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoffeeShopApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;

    public ProductsController(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    /// <summary>
    /// Lấy danh sách sản phẩm (có hỗ trợ lọc theo danh mục, tìm kiếm tên, khoảng giá)
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<IReadOnlyList<ProductDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetProducts(
        [FromQuery] int? categoryId,
        [FromQuery] string? search,
        [FromQuery] decimal? minPrice,
        [FromQuery] decimal? maxPrice,
        [FromQuery] bool onlyAvailable = false)
    {
        var products = await _unitOfWork.Products.GetFilteredAsync(categoryId, search, minPrice, maxPrice, onlyAvailable);

        var productDtos = products.Select(p => new ProductDto
        {
            Id = p.Id,
            Name = p.Name,
            Description = p.Description,
            Price = p.Price,
            ImageUrl = p.ImageUrl,
            CategoryId = p.CategoryId,
            CategoryName = p.Category?.Name,
            IsAvailable = p.IsAvailable,
            CreatedAt = p.CreatedAt
        }).ToList();

        return Ok(ApiResponse<IReadOnlyList<ProductDto>>.Ok(productDtos));
    }

    /// <summary>
    /// Lấy chi tiết sản phẩm theo Id
    /// </summary>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<ProductDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<ProductDto>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetProductById(int id)
    {
        var product = await _unitOfWork.Products.GetByIdWithCategoryAsync(id);
        if (product == null)
        {
            return NotFound(ApiResponse<ProductDto>.Fail($"Không tìm thấy sản phẩm với ID {id}."));
        }

        var dto = new ProductDto
        {
            Id = product.Id,
            Name = product.Name,
            Description = product.Description,
            Price = product.Price,
            ImageUrl = product.ImageUrl,
            CategoryId = product.CategoryId,
            CategoryName = product.Category?.Name,
            IsAvailable = product.IsAvailable,
            CreatedAt = product.CreatedAt
        };

        return Ok(ApiResponse<ProductDto>.Ok(dto));
    }

    /// <summary>
    /// Tạo mới một món ăn / đồ uống (Yêu cầu quyền Admin hoặc Staff)
    /// </summary>
    [Authorize(Roles = "Admin,Staff")]
    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<ProductDto>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ApiResponse<ProductDto>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreateProduct([FromBody] CreateProductDto request)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .ToList();
            return BadRequest(ApiResponse<ProductDto>.Fail("Dữ liệu không hợp lệ.", errors));
        }

        var category = await _unitOfWork.Categories.GetByIdAsync(request.CategoryId);
        if (category == null)
        {
            return BadRequest(ApiResponse<ProductDto>.Fail($"Danh mục với ID {request.CategoryId} không tồn tại."));
        }

        var product = new Product
        {
            Name = request.Name.Trim(),
            Description = request.Description?.Trim(),
            Price = request.Price,
            ImageUrl = request.ImageUrl.Trim(),
            CategoryId = request.CategoryId,
            IsAvailable = request.IsAvailable,
            CreatedAt = DateTime.UtcNow
        };

        await _unitOfWork.Products.AddAsync(product);
        await _unitOfWork.SaveChangesAsync();

        var dto = new ProductDto
        {
            Id = product.Id,
            Name = product.Name,
            Description = product.Description,
            Price = product.Price,
            ImageUrl = product.ImageUrl,
            CategoryId = product.CategoryId,
            CategoryName = category.Name,
            IsAvailable = product.IsAvailable,
            CreatedAt = product.CreatedAt
        };

        return CreatedAtAction(nameof(GetProductById), new { id = product.Id }, ApiResponse<ProductDto>.Ok(dto, "Thêm món mới thành công."));
    }

    /// <summary>
    /// Cập nhật thông tin món ăn / đồ uống (Yêu cầu quyền Admin hoặc Staff)
    /// </summary>
    [Authorize(Roles = "Admin,Staff")]
    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<ProductDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<ProductDto>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<ProductDto>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateProduct(int id, [FromBody] UpdateProductDto request)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .ToList();
            return BadRequest(ApiResponse<ProductDto>.Fail("Dữ liệu không hợp lệ.", errors));
        }

        var product = await _unitOfWork.Products.GetByIdWithCategoryAsync(id);
        if (product == null)
        {
            return NotFound(ApiResponse<ProductDto>.Fail($"Không tìm thấy sản phẩm với ID {id}."));
        }

        var category = await _unitOfWork.Categories.GetByIdAsync(request.CategoryId);
        if (category == null)
        {
            return BadRequest(ApiResponse<ProductDto>.Fail($"Danh mục với ID {request.CategoryId} không tồn tại."));
        }

        product.Name = request.Name.Trim();
        product.Description = request.Description?.Trim();
        product.Price = request.Price;
        product.ImageUrl = request.ImageUrl.Trim();
        product.CategoryId = request.CategoryId;
        product.IsAvailable = request.IsAvailable;

        _unitOfWork.Products.Update(product);
        await _unitOfWork.SaveChangesAsync();

        var dto = new ProductDto
        {
            Id = product.Id,
            Name = product.Name,
            Description = product.Description,
            Price = product.Price,
            ImageUrl = product.ImageUrl,
            CategoryId = product.CategoryId,
            CategoryName = category.Name,
            IsAvailable = product.IsAvailable,
            CreatedAt = product.CreatedAt
        };

        return Ok(ApiResponse<ProductDto>.Ok(dto, "Cập nhật sản phẩm thành công."));
    }

    /// <summary>
    /// Xóa món ăn / đồ uống (Yêu cầu quyền Admin)
    /// </summary>
    [Authorize(Roles = "Admin")]
    [HttpDelete("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteProduct(int id)
    {
        var product = await _unitOfWork.Products.GetByIdAsync(id);
        if (product == null)
        {
            return NotFound(ApiResponse<bool>.Fail($"Không tìm thấy sản phẩm với ID {id}."));
        }

        _unitOfWork.Products.Delete(product);
        await _unitOfWork.SaveChangesAsync();

        return Ok(ApiResponse<bool>.Ok(true, "Xóa sản phẩm thành công."));
    }
}
