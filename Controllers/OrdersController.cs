using CoffeeShopApi.DTOs.Common;
using CoffeeShopApi.DTOs.Order;
using CoffeeShopApi.Extensions;
using CoffeeShopApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace CoffeeShopApi.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(IOrderService orderService, ILogger<OrdersController> logger)
    {
        _orderService = orderService;
        _logger = logger;
    }

    /// <summary>
    /// Tạo đơn hàng mới (Hỗ trợ cả khách hàng đã đăng nhập và khách vãng lai). 
    /// Nếu danh sách Items để trống, hệ thống sẽ tự động đặt hàng từ giỏ hàng hiện tại của người dùng.
    /// </summary>
    [AllowAnonymous]
    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<OrderDto>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ApiResponse<OrderDto>), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderDto request)
    {
        Console.WriteLine($"[OrdersController] >>> [POST] /api/orders CALLED! DeliveryType={request?.DeliveryType}, BranchId={request?.BranchId}, ItemsCount={request?.Items?.Count ?? 0}, Note={request?.Note}");
        _logger.LogInformation(">>> [POST] /api/orders received. DeliveryType: {DeliveryType}, BranchId: {BranchId}, ItemsCount: {ItemsCount}", 
            request?.DeliveryType, request?.BranchId, request?.Items?.Count ?? 0);

        if (request == null)
        {
            Console.WriteLine("[OrdersController] >>> CreateOrder Error: Request body is null.");
            return BadRequest(ApiResponse<OrderDto>.Fail("Dữ liệu đơn hàng không hợp lệ (null)."));
        }

        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .ToList();
            Console.WriteLine($"[OrdersController] >>> CreateOrder ModelState errors: {string.Join(", ", errors)}");
            return BadRequest(ApiResponse<OrderDto>.Fail("Dữ liệu không hợp lệ.", errors));
        }

        var userId = User.GetUserId();
        Console.WriteLine($"[OrdersController] >>> Creating order for UserId: {userId}");

        var result = await _orderService.CreateOrderAsync(userId, request);

        if (!result.Success)
        {
            Console.WriteLine($"[OrdersController] >>> CreateOrder failed: {result.Message}");
            return BadRequest(result);
        }

        Console.WriteLine($"[OrdersController] >>> Order #{result.Data!.Id} created successfully in SQL Server! Total: {result.Data!.TotalAmount:N0} VND");
        return CreatedAtAction(nameof(GetOrderById), new { id = result.Data!.Id }, result);
    }

    /// <summary>
    /// Lấy danh sách đơn hàng (Khách hàng chỉ xem đơn của mình; Admin/Staff xem được toàn bộ)
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<IReadOnlyList<OrderDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetOrders(
        [FromQuery] string? status,
        [FromQuery] int? page = null,
        [FromQuery] int? pageSize = null)
    {
        var userId = User.GetUserId();
        var userRole = User.GetUserRole();

        var result = await _orderService.GetOrdersAsync(userId, userRole, status, page, pageSize);
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
    /// Cập nhật trạng thái đơn hàng (Dành cho Admin và Nhân viên)
    /// Trạng thái hợp lệ: Pending, Confirmed, Preparing, Delivering, Completed, Cancelled
    /// </summary>
    [AllowAnonymous]
    [HttpPut("{id:int}/status")]
    [ProducesResponseType(typeof(ApiResponse<OrderDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<OrderDto>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UpdateOrderStatus(int id, [FromBody] UpdateOrderStatusDto request)
    {
        Console.WriteLine($"[OrdersController] >>> [PUT] /api/orders/{id}/status CALLED! Status={request?.Status}");
        _logger.LogInformation(">>> [PUT] /api/orders/{Id}/status received. Status: {Status}", id, request?.Status);

        if (request == null)
        {
            return BadRequest(ApiResponse<OrderDto>.Fail("Dữ liệu không hợp lệ (null)."));
        }

        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .ToList();
            Console.WriteLine($"[OrdersController] >>> UpdateOrderStatus ModelState errors: {string.Join(", ", errors)}");
            return BadRequest(ApiResponse<OrderDto>.Fail("Dữ liệu không hợp lệ.", errors));
        }

        var result = await _orderService.UpdateOrderStatusAsync(id, request.Status);
        if (!result.Success)
        {
            Console.WriteLine($"[OrdersController] >>> UpdateOrderStatus failed: {result.Message}");
            return BadRequest(result);
        }

        Console.WriteLine($"[OrdersController] >>> Order #{id} status updated to '{request.Status}' successfully in SQL Server!");
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
