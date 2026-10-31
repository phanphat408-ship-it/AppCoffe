using CoffeeShopApi.DTOs.Common;
using CoffeeShopApi.DTOs.Product;
using CoffeeShopApi.Models;
using CoffeeShopApi.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoffeeShopApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CategoriesController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;

    public CategoriesController(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    /// <summary>
    /// Lấy danh sách danh mục sản phẩm
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<IReadOnlyList<CategoryDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetCategories()
    {
        var categories = await _unitOfWork.Categories.GetAllAsync();
        var countsMap = await _unitOfWork.Products.GetProductCountsByCategoryAsync();

        var dtos = categories.Select(c => new CategoryDto
        {
            Id = c.Id,
            Name = c.Name,
            Description = c.Description,
            ImageUrl = c.ImageUrl,
            ProductCount = countsMap.TryGetValue(c.Id, out var count) ? count : 0
        }).ToList();

        return Ok(ApiResponse<IReadOnlyList<CategoryDto>>.Ok(dtos));
    }

    /// <summary>
    /// Lấy chi tiết danh mục theo Id
    /// </summary>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<CategoryDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<CategoryDto>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetCategoryById(int id)
    {
        var category = await _unitOfWork.Categories.GetByIdAsync(id, asNoTracking: true);
        if (category == null)
        {
            return NotFound(ApiResponse<CategoryDto>.Fail($"Không tìm thấy danh mục với ID {id}."));
        }

        var productCount = await _unitOfWork.Products.CountAsync(p => p.CategoryId == category.Id);
        var dto = new CategoryDto
        {
            Id = category.Id,
            Name = category.Name,
            Description = category.Description,
            ImageUrl = category.ImageUrl,
            ProductCount = productCount
        };

        return Ok(ApiResponse<CategoryDto>.Ok(dto));
    }

    /// <summary>
    /// Tạo mới danh mục (Yêu cầu quyền Admin)
    /// </summary>
    [Authorize(Roles = "Admin")]
    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<CategoryDto>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ApiResponse<CategoryDto>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreateCategory([FromBody] CreateCategoryDto request)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .ToList();
            return BadRequest(ApiResponse<CategoryDto>.Fail("Dữ liệu không hợp lệ.", errors));
        }

        var category = new Category
        {
            Name = request.Name.Trim(),
            Description = request.Description?.Trim(),
            ImageUrl = request.ImageUrl?.Trim()
        };

        await _unitOfWork.Categories.AddAsync(category);
        await _unitOfWork.SaveChangesAsync();

        var dto = new CategoryDto
        {
            Id = category.Id,
            Name = category.Name,
            Description = category.Description,
            ImageUrl = category.ImageUrl,
            ProductCount = 0
        };

        return CreatedAtAction(nameof(GetCategoryById), new { id = category.Id }, ApiResponse<CategoryDto>.Ok(dto, "Tạo danh mục thành công."));
    }

    /// <summary>
    /// Cập nhật danh mục (Yêu cầu quyền Admin)
    /// </summary>
    [Authorize(Roles = "Admin")]
    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<CategoryDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<CategoryDto>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateCategory(int id, [FromBody] CreateCategoryDto request)
    {
        var category = await _unitOfWork.Categories.GetByIdAsync(id);
        if (category == null)
        {
            return NotFound(ApiResponse<CategoryDto>.Fail($"Không tìm thấy danh mục với ID {id}."));
        }

        category.Name = request.Name.Trim();
        category.Description = request.Description?.Trim();
        category.ImageUrl = request.ImageUrl?.Trim();

        _unitOfWork.Categories.Update(category);
        await _unitOfWork.SaveChangesAsync();

        var productCount = await _unitOfWork.Products.CountAsync(p => p.CategoryId == category.Id);
        var dto = new CategoryDto
        {
            Id = category.Id,
            Name = category.Name,
            Description = category.Description,
            ImageUrl = category.ImageUrl,
            ProductCount = productCount
        };

        return Ok(ApiResponse<CategoryDto>.Ok(dto, "Cập nhật danh mục thành công."));
    }

    /// <summary>
    /// Xóa danh mục (Yêu cầu quyền Admin)
    /// </summary>
    [Authorize(Roles = "Admin")]
    [HttpDelete("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteCategory(int id)
    {
        var category = await _unitOfWork.Categories.GetByIdAsync(id);
        if (category == null)
        {
            return NotFound(ApiResponse<bool>.Fail($"Không tìm thấy danh mục với ID {id}."));
        }

        var hasProducts = await _unitOfWork.Products.ExistsAsync(p => p.CategoryId == id);
        if (hasProducts)
        {
            return BadRequest(ApiResponse<bool>.Fail("Không thể xóa danh mục đang chứa sản phẩm. Hãy xóa hoặc chuyển sản phẩm sang danh mục khác trước."));
        }

        _unitOfWork.Categories.Delete(category);
        await _unitOfWork.SaveChangesAsync();

        return Ok(ApiResponse<bool>.Ok(true, "Xóa danh mục thành công."));
    }
}
