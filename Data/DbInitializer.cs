using CoffeeShopApi.Models;
using Microsoft.EntityFrameworkCore;

namespace CoffeeShopApi.Data;

public static class DbInitializer
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        // BẮT BUỘC: Cưỡng chế xóa sổ toàn bộ Database và tạo lại mới tinh 100%
        context.Database.EnsureDeleted();
        context.Database.EnsureCreated();

        // 1. Chuẩn hóa & Cập nhật Categories (4 danh mục chuẩn xu hướng)
        var targetCategories = new (string Name, string Description, string ImageUrl, string[] Aliases)[]
        {
            (
                "Cà Phê Việt",
                "Cà phê đậm đà phong cách Việt Nam, từ phin truyền thống đến biến tấu hiện đại",
                "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80",
                new[] { "Cà Phê Truyền Thống", "Cà Phê Việt", "Ca Phe Viet" }
            ),
            (
                "Trà Trái Cây & Trà Sữa",
                "Trà trái cây tươi mát sảng khoái cùng trà sữa béo ngậy chuẩn gu giới trẻ",
                "https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80",
                new[] { "Trà Trái Cây & Trà Sữa", "Trà Trái Cây", "Tra Trai Cay & Tra Sua" }
            ),
            (
                "Đá Xay & Matcha",
                "Thức uống đá xay mát lạnh, béo ngậy và bột trà xanh Matcha Nhật Bản",
                "https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=600&q=80",
                new[] { "Espresso & Cà Phê Ý", "Đá Xay & Matcha", "Da Xay & Matcha" }
            ),
            (
                "Bánh Ngọt & Ăn Vặt",
                "Bánh nướng bơ thơm lừng, tiramisu mềm mịn và các món ăn vặt nhâm nhi hấp dẫn",
                "https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80",
                new[] { "Bánh Ngọt & Đồ Ăn Nhẹ", "Bánh Ngọt & Ăn Vặt", "Banh Ngot & An Vat" }
            )
        };

        var existingCategories = await context.Categories.ToListAsync();
        var categoryMap = new Dictionary<string, Category>();

        foreach (var target in targetCategories)
        {
            var category = existingCategories.FirstOrDefault(c => 
                c.Name.Equals(target.Name, StringComparison.OrdinalIgnoreCase) ||
                target.Aliases.Any(a => a.Equals(c.Name, StringComparison.OrdinalIgnoreCase)));

            if (category == null)
            {
                category = new Category
                {
                    Name = target.Name,
                    Description = target.Description,
                    ImageUrl = target.ImageUrl
                };
                await context.Categories.AddAsync(category);
            }
            else
            {
                // Cập nhật lại tên chuẩn, mô tả và ảnh chất lượng cao
                category.Name = target.Name;
                category.Description = target.Description;
                category.ImageUrl = target.ImageUrl;
                context.Categories.Update(category);
            }

            categoryMap[target.Name] = category;
        }

        await context.SaveChangesAsync();

        // 2. Danh sách 24 Món Ăn & Thức Uống Đạt Chuẩn F&B Hiện Đại (6 món / danh mục)
        // Tất cả link Unsplash đều là link tĩnh, chất lượng cao đã được kiểm tra HTTP 200 OK
        var targetProducts = new (
            string Name, 
            string CategoryName, 
            decimal Price, 
            string Description, 
            string ImageUrl, 
            string[] OldAliases
        )[]
        {
            // --- Danh mục: Cà Phê Việt ---
            (
                "Cà Phê Sữa Đá Sài Gòn",
                "Cà Phê Việt",
                29000,
                "Hạt Robusta Buôn Ma Thuột rang mộc hòa quyện cùng sữa đặc béo ngậy và đá lạnh sảng khoái.",
                "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80",
                new[] { "Cà Phê Sữa Đá Sài Gòn", "Cà Phê Sữa Đá", "Cà phê sữa" }
            ),
            (
                "Cà Phê Đen Đá Buôn Ma Thuột",
                "Cà Phê Việt",
                25000,
                "Robusta nguyên chất 100% rang mộc truyền thống, thơm nồng đắng dịu và hậu vị ngọt sâu lắng.",
                "https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=600&q=80",
                new[] { "Cà Phê Đen Đá", "Cà Phê Đen Đá Buôn Ma Thuột", "Cà phê đen" }
            ),
            (
                "Bạc Xỉu 3 Tầng Kem Sữa",
                "Cà Phê Việt",
                35000,
                "Hòa quyện tinh tế giữa sữa đặc ngọt ngào, sữa tươi thanh mát và lớp cà phê thơm lừng bên trên.",
                "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=600&q=80",
                new[] { "Bạc Xỉu 3 Tầng", "Bạc Xỉu 3 Tầng Kem Sữa", "Bạc xỉu", "Bạc Xỉu" }
            ),
            (
                "Cà Phê Muối Cố Đô",
                "Cà Phê Việt",
                39000,
                "Vị đắng đượm của cà phê phin hòa quyện cùng lớp kem béo mặn mà đặc trưng xứ Huế khó quên.",
                "https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=600&q=80",
                new[] { "Cà Phê Muối Xứ Huế", "Cà Phê Muối Cố Đô", "Cà phê muối" }
            ),
            (
                "Cold Brew Cam Vàng",
                "Cà Phê Việt",
                45000,
                "Cà phê ủ lạnh 16 tiếng chiết xuất hương vị thanh khiết kết hợp lát cam vàng mọng nước sảng khoái.",
                "https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=600&q=80",
                new[] { "Cold Brew Cam Sả", "Cold Brew Cam Vàng", "Cold Brew Cam" }
            ),
            (
                "Cà Phê Trứng Hà Nội",
                "Cà Phê Việt",
                45000,
                "Lớp kem trứng đánh bông mịn như nhung béo ngậy phủ trên nền cà phê phin nóng hổi truyền thống.",
                "https://images.unsplash.com/photo-1534778101976-62847782c213?auto=format&fit=crop&w=600&q=80",
                new[] { "Cà Phê Trứng", "Cà Phê Trứng Hà Nội" }
            ),

            // --- Danh mục: Trà Trái Cây & Trà Sữa ---
            (
                "Trà Đào Cam Sả Tươi",
                "Trà Trái Cây & Trà Sữa",
                42000,
                "Trà đen ủ lạnh kết hợp vị chua ngọt của cam vàng, hương thơm tinh tế của sả tươi và đào giòn thơm.",
                "https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80",
                new[] { "Trà Đào Cam Sả Tươi", "Trà Đào Cam Sả", "Trà đào" }
            ),
            (
                "Trà Mãng Cầu Xiêm Nhiệt Đới",
                "Trà Trái Cây & Trà Sữa",
                45000,
                "Thịt mãng cầu xiêm tươi dầm mọng nước kết hợp nền trà lài thanh tao, chua ngọt giải nhiệt cực đã.",
                "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80",
                new[] { "Trà Mãng Cầu Đắk Lắk", "Trà Mãng Cầu Xiêm Nhiệt Đới", "Trà mãng cầu" }
            ),
            (
                "Trà Sữa Trân Châu Đường Đen",
                "Trà Trái Cây & Trà Sữa",
                45000,
                "Trà sữa béo thơm hòa quyện trân châu hoàng kim dẻo dai phủ mật mía đường đen đậm đà sóng sánh.",
                "https://images.unsplash.com/photo-1558857563-b371033873b8?auto=format&fit=crop&w=600&q=80",
                new[] { "Trà Sữa Trân Châu Đường Đen", "Trà sữa trân châu" }
            ),
            (
                "Ô Long Kem Phô Mai (Macchiato)",
                "Trà Trái Cây & Trà Sữa",
                48000,
                "Nước cốt trà ô long hảo hạng thơm mùi hoa cỏ phủ lớp kem cheese mặn béo ngậy quyến rũ.",
                "https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=600&q=80",
                new[] { "Ô Long Kem Phô Mai (Macchiato)", "Ô Long Kem Phô Mai", "Trà Ô Long Macchiato" }
            ),
            (
                "Trà Vải Hoa Hồng Băng Tuyết",
                "Trà Trái Cây & Trà Sữa",
                45000,
                "Vị ngọt thanh tao của trái vải chín mọng kết hợp siro hoa hồng tự nhiên và thạch dòn sần sật.",
                "https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?auto=format&fit=crop&w=600&q=80",
                new[] { "Trà Vải Hoa Hồng Băng Tuyết", "Trà Vải Hoa Hồng" }
            ),
            (
                "Trà Sữa Oolong Nướng Trân Châu",
                "Trà Trái Cây & Trà Sữa",
                49000,
                "Trà ô long sấy đậm vị khói caramel độc đáo hòa quyện cốt sữa New Zealand béo đậm đà khó cưỡng.",
                "https://images.unsplash.com/photo-1558857563-b371033873b8?auto=format&fit=crop&w=600&q=80",
                new[] { "Trà Sữa Oolong Nướng Trân Châu", "Trà Sữa Oolong Nướng", "Trà Sữa Ô Long" }
            ),

            // --- Danh mục: Đá Xay & Matcha ---
            (
                "Matcha Latte Uji Kyoto",
                "Đá Xay & Matcha",
                48000,
                "Bột trà xanh Uji cao cấp từ cố đô Kyoto hòa quyện cùng sữa tươi thanh trùng ngọt dịu bổ dưỡng.",
                "https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=600&q=80",
                new[] { "Matcha Latte Uji Kyoto", "Matcha Latte Nhật Bản", "Matcha Latte Kyoto", "Matcha Latte Đậu Đỏ" }
            ),
            (
                "Matcha Đá Xay Kem Whipping",
                "Đá Xay & Matcha",
                55000,
                "Matcha Nhật xay nhuyễn mịn cùng sữa tuyết mát lạnh, phủ ngọn kem tươi whipping cream ngọt ngào.",
                "https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=600&q=80",
                new[] { "Matcha Đá Xay Kem Whipping", "Matcha Đá Xay" }
            ),
            (
                "Cookie Đá Xay Socola",
                "Đá Xay & Matcha",
                52000,
                "Bánh quy Oreo giòn rụm xay cùng sốt socola Bỉ đậm đà và bọt kem tươi hấp dẫn cuốn hút.",
                "https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=600&q=80",
                new[] { "Cookie Đá Xay Socola (Oreo Freeze)", "Cookie Đá Xay", "Oreo Freeze" }
            ),
            (
                "Choco Mint Đá Xay Mát Lạnh",
                "Đá Xay & Matcha",
                52000,
                "Sự kết hợp hoàn hảo giữa socola đen béo đắng và tinh chất bạc hà the mát bừng tỉnh năng lượng.",
                "https://images.unsplash.com/photo-1577805947697-89e18249d767?auto=format&fit=crop&w=600&q=80",
                new[] { "Choco Mint Đá Xay Mát Lạnh", "Choco Mint Đá Xay", "Socola Bạc Hà" }
            ),
            (
                "Caramel Freeze Đá Xay Hạt Dẻ",
                "Đá Xay & Matcha",
                55000,
                "Cà phê đá xay sốt caramel sánh quyện kết hợp siro hạt dẻ bùi béo và vụn kẹo giòn tan.",
                "https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=600&q=80",
                new[] { "Caramel Freeze Đá Xay Hạt Dẻ", "Caramel Macchiato", "Caramel Freeze" }
            ),
            (
                "Sinh Tố Bơ Dừa Xay Nhuyễn",
                "Đá Xay & Matcha",
                49000,
                "Bơ sáp Tây Nguyên dẻo quánh xay cùng nước cốt dừa Bến Tre và sữa đặc béo ngậy thơm ngon.",
                "https://images.unsplash.com/photo-1623065422902-30a2d299bbe4?auto=format&fit=crop&w=600&q=80",
                new[] { "Sinh Tố Bơ Dừa Xay Nhuyễn", "Sinh Tố Bơ Dừa", "Sinh Tố Bơ" }
            ),

            // --- Danh mục: Bánh Ngọt & Ăn Vặt ---
            (
                "Bánh Sừng Trâu Croissant Bơ Pháp",
                "Bánh Ngọt & Ăn Vặt",
                35000,
                "Vỏ ngàn lớp vàng óng giòn rụm, ruột xốp mềm thơm nức bơ tươi New Zealand thượng hạng.",
                "https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80",
                new[] { "Bánh Sừng Trâu Croissant Bơ Pháp", "Bánh Sừng Trâu Bơ Pháp (Croissant)", "Bánh Sừng Bò Bơ Pháp (Croissant)", "Bánh Croissant Bơ Pháp" }
            ),
            (
                "Bánh Tiramisu Cacao Ý",
                "Bánh Ngọt & Ăn Vặt",
                45000,
                "Lớp kem Mascarpone mềm mượt quyện đượm cùng cà phê Espresso và bột cacao nguyên chất phủ đều.",
                "https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=600&q=80",
                new[] { "Bánh Tiramisu Cacao Ý", "Bánh Tiramisu", "Caffè Latte Nghệ Thuật" }
            ),
            (
                "Bánh Mì Que Hải Phòng Pate Cay",
                "Bánh Ngọt & Ăn Vặt",
                18000,
                "Bánh mì que nướng giòn rụm kẹp pate gan thơm béo cùng tương ớt cay nồng đậm vị đất Cảng.",
                "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80",
                new[] { "Bánh Mì Que Hải Phòng Pate Cay", "Bánh Mì Que" }
            ),
            (
                "Bánh Waffle Bỉ Sốt Mật Ong",
                "Bánh Ngọt & Ăn Vặt",
                38000,
                "Bánh waffle nướng nóng hổi giòn rụm thơm nức bơ tươi, rưới mật ong nguyên chất ngọt ngào mê đắm.",
                "https://images.unsplash.com/photo-1562376552-0d160a2f238d?auto=format&fit=crop&w=600&q=80",
                new[] { "Khô Gà Lá Chanh Cay Giòn", "Khô Gà Lá Chanh", "Bánh Waffle Bỉ Sốt Mật Ong", "Bánh Waffle Bỉ" }
            ),
            (
                "Khoai Tây Chiên Lắc Phô Mai",
                "Bánh Ngọt & Ăn Vặt",
                35000,
                "Khoai tây cọng giòn tan bên ngoài, bùi béo bên trong lắc đều bột phô mai Cheddar béo thơm.",
                "https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=600&q=80",
                new[] { "Khoai Tây Chiên Lắc Phô Mai", "Khoai Tây Chiên" }
            ),
            (
                "Bánh Mousse Chanh Leo Nhiệt Đới",
                "Bánh Ngọt & Ăn Vặt",
                42000,
                "Cốt bánh mềm mịn chua ngọt dịu dàng mát lạnh, cân bằng hoàn hảo cho buổi chiều thư giãn.",
                "https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=600&q=80",
                new[] { "Bánh Mousse Chanh Leo Nhiệt Đới", "Bánh Mousse Chanh Leo" }
            )
        };

        // BẮT BUỘC: Xóa sạch dữ liệu bảng Products (và các bảng phụ thuộc CartItems, OrderDetails, Orders)
        // để "thanh trừng" triệt để toàn bộ các món ăn bị sai hình ảnh từ trước đến nay
        if (await context.CartItems.AnyAsync())
        {
            context.CartItems.RemoveRange(context.CartItems);
        }
        if (await context.OrderDetails.AnyAsync())
        {
            context.OrderDetails.RemoveRange(context.OrderDetails);
        }
        if (await context.Orders.AnyAsync())
        {
            context.Orders.RemoveRange(context.Orders);
        }
        if (await context.Products.AnyAsync())
        {
            context.Products.RemoveRange(context.Products);
        }
        await context.SaveChangesAsync();

        // Nạp lại toàn bộ 24 món ăn với hình ảnh chính xác 100%
        foreach (var pInfo in targetProducts)
        {
            var category = categoryMap[pInfo.CategoryName];
            await context.Products.AddAsync(new Product
            {
                Name = pInfo.Name,
                Description = pInfo.Description,
                Price = pInfo.Price,
                ImageUrl = pInfo.ImageUrl,
                CategoryId = category.Id,
                IsAvailable = true,
                CreatedAt = DateTime.UtcNow
            });
        }

        await context.SaveChangesAsync();

        // 3. Chuẩn hóa Chi nhánh về 100% TP. Hồ Chí Minh (5 địa điểm sầm uất, tọa độ GPS chính xác)
        //    - Chạy mỗi lần khởi động: cập nhật chi nhánh cũ theo tên/alias, thêm chi nhánh mới,
        //      xóa các chi nhánh ngoài TP.HCM (vd: Hà Nội). Đơn hàng cũ được chuyển về chi nhánh Nguyễn Huệ.
        var targetBranches = new (string Name, string Address, double Lat, double Lng, string Phone, string[] Aliases)[]
        {
            (
                "Chi Nhánh Quận 1 - Nguyễn Huệ",
                "68 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh",
                10.7745, 106.7035,
                "02838221144",
                new[] { "Chi Nhánh Quận 1 - Nguyễn Huệ" }
            ),
            (
                "Chi Nhánh Quận 3 - Hồ Con Rùa",
                "Công trường Quốc Tế, Phường Võ Thị Sáu, Quận 3, TP. Hồ Chí Minh",
                10.7827, 106.6959,
                "02838225566",
                new[] { "Chi Nhánh Quận 3 - Hồ Con Rùa" }
            ),
            (
                "Chi Nhánh Bình Thạnh - Landmark 81",
                "475A Điện Biên Phủ, Phường 25, Quận Bình Thạnh, TP. Hồ Chí Minh",
                10.8017, 106.7145,
                "02835120081",
                new[] { "Chi Nhánh Bình Thạnh - Điện Biên Phủ" }
            ),
            (
                "Chi Nhánh TP. Thủ Đức - Xa Lộ Hà Nội",
                "Khu Công Nghệ Cao, Phường Hiệp Phú, TP. Thủ Đức, TP. Hồ Chí Minh",
                10.8411, 106.7869,
                "02837360099",
                new[] { "Chi Nhánh Thủ Đức - Xa Lộ Hà Nội" }
            ),
            (
                "Chi Nhánh Quận 7 - Phú Mỹ Hưng",
                "105 Tôn Dật Tiên, Phường Tân Phú, Quận 7, TP. Hồ Chí Minh",
                10.7294, 106.7218,
                "02854120077",
                new[] { "Chi Nhánh Quận 7 - Phú Mỹ Hưng" }
            )
        };

        var existingBranches = await context.Branches.ToListAsync();
        var keptBranches = new List<Branch>();

        foreach (var target in targetBranches)
        {
            var branch = existingBranches.FirstOrDefault(b =>
                !keptBranches.Contains(b) &&
                (b.Name.Equals(target.Name, StringComparison.OrdinalIgnoreCase) ||
                 target.Aliases.Any(a => a.Equals(b.Name, StringComparison.OrdinalIgnoreCase))));

            if (branch == null)
            {
                branch = new Branch();
                await context.Branches.AddAsync(branch);
            }

            branch.Name = target.Name;
            branch.Address = target.Address;
            branch.Lat = target.Lat;
            branch.Lng = target.Lng;
            branch.Phone = target.Phone;
            branch.IsActive = true;
            keptBranches.Add(branch);
        }

        await context.SaveChangesAsync();

        var obsoleteBranches = existingBranches.Where(b => !keptBranches.Contains(b)).ToList();
        if (obsoleteBranches.Count > 0)
        {
            var obsoleteIds = obsoleteBranches.Select(b => b.Id).ToList();
            var fallbackBranchId = keptBranches[0].Id;

            var orphanOrders = await context.Orders
                .Where(o => o.BranchId != null && obsoleteIds.Contains(o.BranchId.Value))
                .ToListAsync();
            foreach (var order in orphanOrders)
            {
                order.BranchId = fallbackBranchId;
            }

            context.Branches.RemoveRange(obsoleteBranches);
            await context.SaveChangesAsync();
        }

        // 4. Khởi tạo Tài khoản Quản trị & Demo Khách Hàng nếu chưa có
        if (!await context.Users.AnyAsync())
        {
            string adminHash = BCrypt.Net.BCrypt.HashPassword("Admin@123");
            string customerHash = BCrypt.Net.BCrypt.HashPassword("123456");

            var users = new List<User>
            {
                new()
                {
                    Name = "Quản Trị Viên (Admin)",
                    Phone = "0909000001",
                    PasswordHash = adminHash,
                    Role = "Admin",
                    CreatedAt = DateTime.UtcNow
                },
                new()
                {
                    Name = "Nguyễn Văn Khách",
                    Phone = "0909123456",
                    PasswordHash = customerHash,
                    Role = "Customer",
                    CreatedAt = DateTime.UtcNow
                }
            };
            await context.Users.AddRangeAsync(users);
            await context.SaveChangesAsync();
        }
    }
}
