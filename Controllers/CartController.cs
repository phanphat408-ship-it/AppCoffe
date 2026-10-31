using CoffeeShopApi.DTOs.Cart;
using CoffeeShopApi.DTOs.Common;
using CoffeeShopApi.Extensions;
using CoffeeShopApi.Models;
using CoffeeShopApi.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoffeeShopApi.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class CartController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;

    public CartController(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    /// <summary>
    /// Lấy danh sách món trong giỏ hàng của người dùng hiện tại
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<CartResponseDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetCart()
    {
        var userId = User.GetUserId();
        var cartItems = await _unitOfWork.Cart.GetCartByUserIdAsync(userId, asNoTracking: true);

        var itemDtos = cartItems.Select(ci => new CartItemDto
        {
            Id = ci.Id,
            ProductId = ci.ProductId,
            ProductName = ci.Product?.Name ?? string.Empty,
            ProductPrice = ci.Product?.Price ?? 0,
            ProductImageUrl = ci.Product?.ImageUrl ?? string.Empty,
            Quantity = ci.Quantity,
            SubTotal = (ci.Product?.Price ?? 0) * ci.Quantity
        }).ToList();

        var response = new CartResponseDto
        {
            Items = itemDtos,
            TotalItems = itemDtos.Sum(i => i.Quantity),
            TotalAmount = itemDtos.Sum(i => i.SubTotal)
        };

        return Ok(ApiResponse<CartResponseDto>.Ok(response));
    }

    /// <summary>
    /// Thêm món vào giỏ hàng (nếu đã có thì cộng dồn số lượng)
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<CartItemDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<CartItemDto>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> AddToCart([FromBody] AddToCartDto request)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .ToList();
            return BadRequest(ApiResponse<CartItemDto>.Fail("Dữ liệu không hợp lệ.", errors));
        }

        var userId = User.GetUserId();
        var product = await _unitOfWork.Products.GetByIdAsync(request.ProductId);
        if (product == null)
        {
            return BadRequest(ApiResponse<CartItemDto>.Fail($"Sản phẩm với ID {request.ProductId} không tồn tại."));
        }

        if (!product.IsAvailable)
        {
            return BadRequest(ApiResponse<CartItemDto>.Fail($"Món '{product.Name}' hiện đang tạm hết."));
        }

        var existingItem = await _unitOfWork.Cart.GetItemAsync(userId, request.ProductId);
        if (existingItem != null)
        {
            existingItem.Quantity += request.Quantity;
            _unitOfWork.Cart.Update(existingItem);
            await _unitOfWork.SaveChangesAsync();

            var updatedDto = new CartItemDto
            {
                Id = existingItem.Id,
                ProductId = product.Id,
                ProductName = product.Name,
                ProductPrice = product.Price,
                ProductImageUrl = product.ImageUrl,
                Quantity = existingItem.Quantity,
                SubTotal = product.Price * existingItem.Quantity
            };

            return Ok(ApiResponse<CartItemDto>.Ok(updatedDto, "Đã cập nhật số lượng món trong giỏ hàng."));
        }

        var newItem = new CartItem
        {
            UserId = userId,
            ProductId = request.ProductId,
            Quantity = request.Quantity,
            AddedAt = DateTime.UtcNow
        };

        await _unitOfWork.Cart.AddAsync(newItem);
        await _unitOfWork.SaveChangesAsync();

        var dto = new CartItemDto
        {
            Id = newItem.Id,
            ProductId = product.Id,
            ProductName = product.Name,
            ProductPrice = product.Price,
            ProductImageUrl = product.ImageUrl,
            Quantity = newItem.Quantity,
            SubTotal = product.Price * newItem.Quantity
        };

        return Ok(ApiResponse<CartItemDto>.Ok(dto, "Đã thêm món vào giỏ hàng."));
    }

    /// <summary>
    /// Cập nhật số lượng của một món trong giỏ hàng
    /// </summary>
    [HttpPut("{itemId:int}")]
    [ProducesResponseType(typeof(ApiResponse<CartItemDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<CartItemDto>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse<CartItemDto>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateCartItem(int itemId, [FromBody] UpdateCartItemDto request)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .ToList();
            return BadRequest(ApiResponse<CartItemDto>.Fail("Dữ liệu không hợp lệ.", errors));
        }

        var userId = User.GetUserId();
        var cartItem = await _unitOfWork.Cart.GetItemByIdAndUserAsync(itemId, userId);
        if (cartItem == null)
        {
            return NotFound(ApiResponse<CartItemDto>.Fail("Không tìm thấy món trong giỏ hàng của bạn."));
        }

        cartItem.Quantity = request.Quantity;
        _unitOfWork.Cart.Update(cartItem);
        await _unitOfWork.SaveChangesAsync();

        var dto = new CartItemDto
        {
            Id = cartItem.Id,
            ProductId = cartItem.ProductId,
            ProductName = cartItem.Product?.Name ?? string.Empty,
            ProductPrice = cartItem.Product?.Price ?? 0,
            ProductImageUrl = cartItem.Product?.ImageUrl ?? string.Empty,
            Quantity = cartItem.Quantity,
            SubTotal = (cartItem.Product?.Price ?? 0) * cartItem.Quantity
        };

        return Ok(ApiResponse<CartItemDto>.Ok(dto, "Đã cập nhật số lượng thành công."));
    }

    /// <summary>
    /// Xóa một món khỏi giỏ hàng
    /// </summary>
    [HttpDelete("{itemId:int}")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteCartItem(int itemId)
    {
        var userId = User.GetUserId();
        var cartItem = await _unitOfWork.Cart.GetItemByIdAndUserAsync(itemId, userId);
        if (cartItem == null)
        {
            return NotFound(ApiResponse<bool>.Fail("Không tìm thấy món trong giỏ hàng của bạn."));
        }

        _unitOfWork.Cart.Delete(cartItem);
        await _unitOfWork.SaveChangesAsync();

        return Ok(ApiResponse<bool>.Ok(true, "Đã xóa món khỏi giỏ hàng."));
    }

    /// <summary>
    /// Xóa toàn bộ giỏ hàng
    /// </summary>
    [HttpDelete]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ClearCart()
    {
        var userId = User.GetUserId();
        await _unitOfWork.Cart.ClearUserCartAsync(userId);
        await _unitOfWork.SaveChangesAsync();

        return Ok(ApiResponse<bool>.Ok(true, "Đã xóa toàn bộ giỏ hàng."));
    }
}
