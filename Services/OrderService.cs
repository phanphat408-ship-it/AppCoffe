using CoffeeShopApi.DTOs.Common;
using CoffeeShopApi.DTOs.Order;
using CoffeeShopApi.Models;
using CoffeeShopApi.Repositories;

namespace CoffeeShopApi.Services;

public class OrderService : IOrderService
{
    private readonly IUnitOfWork _unitOfWork;

    public OrderService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<OrderDto>> CreateOrderAsync(int userId, CreateOrderDto request)
    {
        // 1. Verify user exists
        var user = await _unitOfWork.Users.GetByIdAsync(userId);
        if (user == null)
        {
            return ApiResponse<OrderDto>.Fail("Không tìm thấy thông tin tài khoản đặt hàng.");
        }

        // 2. Collect order items: from request.Items OR user's cart
        var orderDetailsToCreate = new List<OrderDetail>();
        decimal calculatedTotal = 0;

        if (request.Items != null && request.Items.Count > 0)
        {
            // Buy directly with specified items
            foreach (var itemDto in request.Items)
            {
                var product = await _unitOfWork.Products.GetByIdAsync(itemDto.ProductId);
                if (product == null)
                {
                    return ApiResponse<OrderDto>.Fail($"Sản phẩm với ID {itemDto.ProductId} không tồn tại.");
                }

                if (!product.IsAvailable)
                {
                    return ApiResponse<OrderDto>.Fail($"Sản phẩm '{product.Name}' hiện đang tạm hết hàng.");
                }

                var subtotal = product.Price * itemDto.Quantity;
                calculatedTotal += subtotal;

                orderDetailsToCreate.Add(new OrderDetail
                {
                    ProductId = product.Id,
                    Quantity = itemDto.Quantity,
                    UnitPrice = product.Price,
                    TotalPrice = subtotal
                });
            }
        }
        else
        {
            // Checkout from user's current Cart
            var cartItems = await _unitOfWork.Cart.GetCartByUserIdAsync(userId);
            if (cartItems.Count == 0)
            {
                return ApiResponse<OrderDto>.Fail("Giỏ hàng của bạn đang trống. Vui lòng thêm sản phẩm vào giỏ hàng trước khi đặt.");
            }

            foreach (var cartItem in cartItems)
            {
                var product = cartItem.Product;
                if (product == null)
                {
                    product = await _unitOfWork.Products.GetByIdAsync(cartItem.ProductId);
                }

                if (product == null || !product.IsAvailable)
                {
                    return ApiResponse<OrderDto>.Fail($"Món '{product?.Name ?? "sản phẩm"}' hiện không còn khả dụng.");
                }

                var subtotal = product.Price * cartItem.Quantity;
                calculatedTotal += subtotal;

                orderDetailsToCreate.Add(new OrderDetail
                {
                    ProductId = product.Id,
                    Quantity = cartItem.Quantity,
                    UnitPrice = product.Price,
                    TotalPrice = subtotal
                });
            }
        }

        // 3. Verify Branch if provided
        if (request.BranchId.HasValue)
        {
            var branch = await _unitOfWork.Branches.GetByIdAsync(request.BranchId.Value);
            if (branch == null || !branch.IsActive)
            {
                return ApiResponse<OrderDto>.Fail("Chi nhánh đã chọn không khả dụng hoặc không tồn tại.");
            }
        }

        // 4. Create Order entity inside transaction
        await using var transaction = await _unitOfWork.BeginTransactionAsync();
        try
        {
            var order = new Order
            {
                UserId = userId,
                BranchId = request.BranchId,
                TotalAmount = calculatedTotal,
                Status = "Pending",
                DeliveryType = request.DeliveryType,
                ShippingAddress = request.ShippingAddress,
                ContactPhone = string.IsNullOrWhiteSpace(request.ContactPhone) ? user.Phone : request.ContactPhone,
                Note = request.Note,
                CreatedAt = DateTime.UtcNow,
                OrderDetails = orderDetailsToCreate
            };

            await _unitOfWork.Orders.AddAsync(order);
            await _unitOfWork.SaveChangesAsync();

            // If checked out from cart (request.Items was null/empty), clear the cart
            if (request.Items == null || request.Items.Count == 0)
            {
                await _unitOfWork.Cart.ClearUserCartAsync(userId);
                await _unitOfWork.SaveChangesAsync();
            }

            await transaction.CommitAsync();

            // Load complete order with includes
            var savedOrder = await _unitOfWork.Orders.GetByIdWithDetailsAsync(order.Id);
            return ApiResponse<OrderDto>.Ok(MapToOrderDto(savedOrder!), "Đặt hàng thành công!");
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync();
            return ApiResponse<OrderDto>.Fail($"Lỗi khi tạo đơn hàng: {ex.Message}");
        }
    }

    public async Task<ApiResponse<IReadOnlyList<OrderDto>>> GetOrdersAsync(int userId, string userRole, string? status = null)
    {
        // Admin or Staff can see all orders; regular Customer only sees their own
        int? filterUserId = (userRole == "Admin" || userRole == "Staff") ? null : userId;

        var orders = await _unitOfWork.Orders.GetOrdersAsync(filterUserId, status);
        var dtos = orders.Select(MapToOrderDto).ToList();

        return ApiResponse<IReadOnlyList<OrderDto>>.Ok(dtos);
    }

    public async Task<ApiResponse<OrderDto>> GetOrderByIdAsync(int orderId, int userId, string userRole)
    {
        var order = await _unitOfWork.Orders.GetByIdWithDetailsAsync(orderId);
        if (order == null)
        {
            return ApiResponse<OrderDto>.Fail("Không tìm thấy đơn hàng.");
        }

        // Check ownership unless Admin or Staff
        if (userRole != "Admin" && userRole != "Staff" && order.UserId != userId)
        {
            return ApiResponse<OrderDto>.Fail("Bạn không có quyền xem đơn hàng này.");
        }

        return ApiResponse<OrderDto>.Ok(MapToOrderDto(order));
    }

    public async Task<ApiResponse<OrderDto>> UpdateOrderStatusAsync(int orderId, string status)
    {
        var order = await _unitOfWork.Orders.GetByIdWithDetailsAsync(orderId);
        if (order == null)
        {
            return ApiResponse<OrderDto>.Fail("Không tìm thấy đơn hàng.");
        }

        var validStatuses = new[] { "Pending", "Confirmed", "Preparing", "Delivering", "Completed", "Cancelled" };
        if (!validStatuses.Contains(status, StringComparer.OrdinalIgnoreCase))
        {
            return ApiResponse<OrderDto>.Fail($"Trạng thái không hợp lệ. Các trạng thái được phép: {string.Join(", ", validStatuses)}");
        }

        order.Status = status;
        order.UpdatedAt = DateTime.UtcNow;

        _unitOfWork.Orders.Update(order);
        await _unitOfWork.SaveChangesAsync();

        return ApiResponse<OrderDto>.Ok(MapToOrderDto(order), $"Cập nhật trạng thái đơn hàng thành '{status}' thành công.");
    }

    public async Task<ApiResponse<OrderDto>> CancelOrderAsync(int orderId, int userId)
    {
        var order = await _unitOfWork.Orders.GetByIdWithDetailsAsync(orderId);
        if (order == null)
        {
            return ApiResponse<OrderDto>.Fail("Không tìm thấy đơn hàng.");
        }

        if (order.UserId != userId)
        {
            return ApiResponse<OrderDto>.Fail("Bạn chỉ có thể hủy đơn hàng của chính mình.");
        }

        if (!order.Status.Equals("Pending", StringComparison.OrdinalIgnoreCase))
        {
            return ApiResponse<OrderDto>.Fail($"Không thể hủy đơn hàng khi trạng thái đang là '{order.Status}'.");
        }

        order.Status = "Cancelled";
        order.UpdatedAt = DateTime.UtcNow;

        _unitOfWork.Orders.Update(order);
        await _unitOfWork.SaveChangesAsync();

        return ApiResponse<OrderDto>.Ok(MapToOrderDto(order), "Đã hủy đơn hàng thành công.");
    }

    private static OrderDto MapToOrderDto(Order order)
    {
        return new OrderDto
        {
            Id = order.Id,
            UserId = order.UserId,
            CustomerName = order.User?.Name ?? string.Empty,
            CustomerPhone = order.ContactPhone ?? order.User?.Phone ?? string.Empty,
            BranchId = order.BranchId,
            BranchName = order.Branch?.Name,
            TotalAmount = order.TotalAmount,
            Status = order.Status,
            DeliveryType = order.DeliveryType,
            ShippingAddress = order.ShippingAddress,
            ContactPhone = order.ContactPhone,
            Note = order.Note,
            CreatedAt = order.CreatedAt,
            OrderDetails = order.OrderDetails.Select(od => new OrderDetailDto
            {
                Id = od.Id,
                ProductId = od.ProductId,
                ProductName = od.Product?.Name ?? string.Empty,
                ProductImageUrl = od.Product?.ImageUrl ?? string.Empty,
                Quantity = od.Quantity,
                UnitPrice = od.UnitPrice,
                TotalPrice = od.TotalPrice
            }).ToList()
        };
    }
}
