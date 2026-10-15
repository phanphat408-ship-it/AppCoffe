using CoffeeShopApi.DTOs.Branch;
using CoffeeShopApi.DTOs.Common;
using CoffeeShopApi.Models;
using CoffeeShopApi.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoffeeShopApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BranchesController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;

    public BranchesController(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    /// <summary>
    /// Lấy danh sách tất cả các chi nhánh quán cà phê
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<IReadOnlyList<BranchDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetBranches()
    {
        var branches = await _unitOfWork.Branches.GetAllAsync();
        var dtos = branches.Select(b => new BranchDto
        {
            Id = b.Id,
            Name = b.Name,
            Address = b.Address,
            Lat = b.Lat,
            Lng = b.Lng,
            Phone = b.Phone,
            IsActive = b.IsActive
        }).ToList();

        return Ok(ApiResponse<IReadOnlyList<BranchDto>>.Ok(dtos));
    }

    /// <summary>
    /// Lấy chi tiết chi nhánh theo Id
    /// </summary>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<BranchDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<BranchDto>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetBranchById(int id)
    {
        var branch = await _unitOfWork.Branches.GetByIdAsync(id);
        if (branch == null)
        {
            return NotFound(ApiResponse<BranchDto>.Fail($"Không tìm thấy chi nhánh với ID {id}."));
        }

        var dto = new BranchDto
        {
            Id = branch.Id,
            Name = branch.Name,
            Address = branch.Address,
            Lat = branch.Lat,
            Lng = branch.Lng,
            Phone = branch.Phone,
            IsActive = branch.IsActive
        };

        return Ok(ApiResponse<BranchDto>.Ok(dto));
    }

    /// <summary>
    /// Tạo mới một chi nhánh (Yêu cầu quyền Admin)
    /// </summary>
    [Authorize(Roles = "Admin")]
    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<BranchDto>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ApiResponse<BranchDto>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreateBranch([FromBody] CreateBranchDto request)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .ToList();
            return BadRequest(ApiResponse<BranchDto>.Fail("Dữ liệu không hợp lệ.", errors));
        }

        var branch = new Branch
        {
            Name = request.Name.Trim(),
            Address = request.Address.Trim(),
            Lat = request.Lat,
            Lng = request.Lng,
            Phone = request.Phone?.Trim(),
            IsActive = request.IsActive
        };

        await _unitOfWork.Branches.AddAsync(branch);
        await _unitOfWork.SaveChangesAsync();

        var dto = new BranchDto
        {
            Id = branch.Id,
            Name = branch.Name,
            Address = branch.Address,
            Lat = branch.Lat,
            Lng = branch.Lng,
            Phone = branch.Phone,
            IsActive = branch.IsActive
        };

        return CreatedAtAction(nameof(GetBranchById), new { id = branch.Id }, ApiResponse<BranchDto>.Ok(dto, "Thêm chi nhánh thành công."));
    }

    /// <summary>
    /// Cập nhật chi nhánh (Yêu cầu quyền Admin)
    /// </summary>
    [Authorize(Roles = "Admin")]
    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<BranchDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<BranchDto>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateBranch(int id, [FromBody] CreateBranchDto request)
    {
        var branch = await _unitOfWork.Branches.GetByIdAsync(id);
        if (branch == null)
        {
            return NotFound(ApiResponse<BranchDto>.Fail($"Không tìm thấy chi nhánh với ID {id}."));
        }

        branch.Name = request.Name.Trim();
        branch.Address = request.Address.Trim();
        branch.Lat = request.Lat;
        branch.Lng = request.Lng;
        branch.Phone = request.Phone?.Trim();
        branch.IsActive = request.IsActive;

        _unitOfWork.Branches.Update(branch);
        await _unitOfWork.SaveChangesAsync();

        var dto = new BranchDto
        {
            Id = branch.Id,
            Name = branch.Name,
            Address = branch.Address,
            Lat = branch.Lat,
            Lng = branch.Lng,
            Phone = branch.Phone,
            IsActive = branch.IsActive
        };

        return Ok(ApiResponse<BranchDto>.Ok(dto, "Cập nhật chi nhánh thành công."));
    }

    /// <summary>
    /// Xóa chi nhánh (Yêu cầu quyền Admin)
    /// </summary>
    [Authorize(Roles = "Admin")]
    [HttpDelete("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteBranch(int id)
    {
        var branch = await _unitOfWork.Branches.GetByIdAsync(id);
        if (branch == null)
        {
            return NotFound(ApiResponse<bool>.Fail($"Không tìm thấy chi nhánh với ID {id}."));
        }

        _unitOfWork.Branches.Delete(branch);
        await _unitOfWork.SaveChangesAsync();

        return Ok(ApiResponse<bool>.Ok(true, "Xóa chi nhánh thành công."));
    }
}
