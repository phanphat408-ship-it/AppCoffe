using CoffeeShopApi.DTOs.Common;
using CoffeeShopApi.DTOs.Order;
using CoffeeShopApi.Extensions;
using CoffeeShopApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoffeeShopApi.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;

    public OrdersController(IOrderService orderService)
    {
        _orderService = orderService;
    }

    /// <summary>
    /// Tạo đơn hàng mới (Bắt buộc [Authorize]). 
    /// Nếu danh sách Items để trống, hệ thống sẽ tự động đặt hàng từ giỏ hàng hiện tại của người dùng.
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<OrderDto>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ApiResponse<OrderDto>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderDto request)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .ToList();
            return BadRequest(ApiResponse<OrderDto>.Fail("Dữ liệu không hợp lệ.", errors));
        }

        var userId = User.GetUserId();
        var result = await _orderService.CreateOrderAsync(userId, request);

        if (!result.Success)
        {
            return BadRequest(result);
        }

        return CreatedAtAction(nameof(GetOrderById), new { id = result.Data!.Id }, result);
    }

    /// <summary>
    /// Lấy danh sách đơn hàng (Khách hàng chỉ xem đơn của mình; Admin/Staff xem được toàn bộ)
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<IReadOnlyList<OrderDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetOrders([FromQuery] string? status)
    {
        var userId = User.GetUserId();
        var userRole = User.GetUserRole();

        var result = await _orderService.GetOrdersAsync(userId, userRole, status);
        return Ok(result);
    }

    /// <summary>
    /// Lấy chi tiết một đơn hàng theo Id
    /// </summary>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<OrderDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<OrderDto>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetOrderById(int id)
    {
        var userId = User.GetUserId();
        var userRole = User.GetUserRole();

        var result = await _orderService.GetOrderByIdAsync(id, userId, userRole);
        if (!result.Success)
        {
            return NotFound(result);
        }

        return Ok(result);
    }

    /// <summary>
    /// Cập nhật trạng thái đơn hàng (Chỉ dành cho Admin và Nhân viên)
    /// Trạng thái hợp lệ: Pending, Confirmed, Preparing, Delivering, Completed, Cancelled
    /// </summary>
    [Authorize(Roles = "Admin,Staff")]
    [HttpPut("{id:int}/status")]
    [ProducesResponseType(typeof(ApiResponse<OrderDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<OrderDto>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UpdateOrderStatus(int id, [FromBody] UpdateOrderStatusDto request)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .ToList();
            return BadRequest(ApiResponse<OrderDto>.Fail("Dữ liệu không hợp lệ.", errors));
        }

        var result = await _orderService.UpdateOrderStatusAsync(id, request.Status);
        if (!result.Success)
        {
            return BadRequest(result);
        }

        return Ok(result);
    }

    /// <summary>
    /// Người dùng hủy đơn hàng của mình (Chỉ được hủy khi trạng thái là Pending)
    /// </summary>
    [HttpPut("{id:int}/cancel")]
    [ProducesResponseType(typeof(ApiResponse<OrderDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<OrderDto>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CancelOrder(int id)
    {
        var userId = User.GetUserId();
        var result = await _orderService.CancelOrderAsync(id, userId);
        if (!result.Success)
        {
            return BadRequest(result);
        }

        return Ok(result);
    }
}
