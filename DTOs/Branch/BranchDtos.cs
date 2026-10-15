using System.ComponentModel.DataAnnotations;

namespace CoffeeShopApi.DTOs.Branch;

public class BranchDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public double Lat { get; set; }
    public double Lng { get; set; }
    public string? Phone { get; set; }
    public bool IsActive { get; set; }
}

public class CreateBranchDto
{
    [Required(ErrorMessage = "Tên chi nhánh không được để trống")]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Địa chỉ chi nhánh không được để trống")]
    [MaxLength(500)]
    public string Address { get; set; } = string.Empty;

    public double Lat { get; set; }

    public double Lng { get; set; }

    [MaxLength(20)]
    public string? Phone { get; set; }

    public bool IsActive { get; set; } = true;
}
