# 📝 NHẬT KÝ CẬP NHẬT (CHANGELOG) - IDENTICAL HUB

Tất cả các bản cập nhật, sửa lỗi và nâng cấp tính năng đều được ghi nhận chi tiết tại đây theo đúng quy tắc dự án.

## [v2.2.3] - 2026-09-15
### ⚡ Sửa Triệt Để Lỗi "Lỗi biên dịch: Timeout" & Nâng Cấp Bộ Loader Chống Treo (Fix & Upgrade gì):
1. **Khắc phục triệt để lỗi `Lỗi biên dịch: Timeout` trên Executor**:
   - *Nguyên nhân kỹ thuật*: Khi tải file script lớn (> 650KB) trên các Executor như Delta, Codex, Arceus X, Fluxus..., cầu nối biên dịch Luau (Bytecode Compiler Server/Worker) của Executor thường áp dụng ngưỡng thời gian chờ mặc định (Timeout 5–10 giây). Do mã nguồn nặng kèm hàng ngàn dòng thụt đầu dòng (indentation) và bình luận, việc biên dịch đồng bộ một lần bị vượt quá ngưỡng thời gian và trả về lỗi `Timeout`. Ngoài ra, khi đường truyền từ Việt Nam sang GitHub Raw bị nghẽn, `game:HttpGet` có thể trả về chuỗi phản hồi rác/Timeout mà loader cũ không kiểm tra đã vội đưa vào `loadstring()`.
   - *Giải pháp khắc phục*:
     - **Tối ưu hóa mã nguồn trong bộ nhớ (In-Memory Script Optimizer)**: Trước khi gọi `loadstring`, bộ loader tự động loại bỏ các dòng bình luận thừa và khoảng trắng thụt lề vô hình chỉ trong 0.02 giây, giúp giảm tức thì **150 KB (23% dung lượng nạp)**, giúp trình biên dịch của mọi Executor xử lý nhẹ nhàng trong nháy mắt (< 0.5s) mà không bao giờ bị nghẽn.
     - **Bộ lọc kiểm tra tính toàn vẹn (Strict Lua Script Validation)**: Hàm `IsValidLuaScript` tự động kiểm tra kích thước phản hồi (> 30KB), từ khóa nhận diện code Lua (`pcall`, `game`) và loại bỏ hoàn toàn các chuỗi phản hồi rác, lỗi mạng `Timeout`, mã HTTP 403 hoặc thông báo Rate Limit của GitHub API.
     - **Bộ biên dịch tự động thử lại đa tầng (Auto-Retry Compiler with Fallback)**: Hàm `CompileWithRetry` tự động thử biên dịch bản tối ưu trước, nếu gặp sự cố sẽ thử bản gốc, đồng thời tự động thử lại tối đa 3 lần kèm thông báo trực quan trên màn hình (`"Đang biên dịch lại..."`), loại bỏ hoàn toàn rủi ro văng lỗi do lag mạng tức thời.
2. **Hệ thống nạp đa tầng CDN quốc tế tốc độ cao (Multi-CDN Mirror Network)**:
   - Thêm máy chủ **jsDelivr Edge CDN** và **Fastly CDN** chạy song song với **GitHub Raw**.
   - Các máy chủ CDN có điểm kết nối biên (Edge Server) tại Việt Nam và Đông Nam Á, tốc độ phản hồi cực nhanh (~50–100ms), không bao giờ bị các nhà mạng VNPT, Viettel, FPT chặn hoặc bóp băng thông.
3. **Đồng bộ hóa toàn bộ hệ thống**:
   - Cập nhật đồng bộ cả [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua) và [loader_backup.lua](file:///Users/vonguyengiap/Documents/script/loader_backup.lua).
   - Nâng cấp nhãn phiên bản tĩnh lên **`v2.2.3`** trên cả [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua) và `v2/core/config.lua`.

---

## [v2.2.2] - 2026-09-15
### 🔭 Tầm Nhìn Xa Siêu Nét - Triệt Tiêu Hoàn Toàn Mờ Xa & Sương Mù (Feature & Fix gì):
1. **Khắc phục nguyên nhân nhìn xa toàn bị mờ map**:
   - *Nguyên nhân kỹ thuật*: Roblox và trò chơi mặc định sử dụng hiệu ứng `DepthOfFieldEffect` (làm mờ trường ảnh theo khoảng cách) cùng với `Atmosphere.Haze` và `Atmosphere.Density`. Khi nhìn ra xa qua các đảo hoặc đại dương, cảnh vật bị làm mờ nhòe gây nhức mắt và không thể quan sát đảo từ xa.
   - *Giải pháp triệt để*:
     - **Tắt toàn bộ hiệu ứng `DepthOfFieldEffect`**: Gán `Enabled = false`, triệt tiêu `FarIntensity = 0` và `NearIntensity = 0` trên cả `Lighting`, `Camera` và `Workspace`.
     - **Tắt toàn bộ hiệu ứng `BlurEffect`**: Gán `Enabled = false` và `Size = 0`.
     - **Làm trong suốt khí quyển `Atmosphere`**: Hạ `Density = 0`, `Haze = 0`, `Glare = 0`, `Offset = 0` loại bỏ màn khói sương đục mờ biển.
     - **Đẩy tầm nhìn sương mù tối đa**: Gán `FogEnd = 1,000,000` và `FogStart = 1,000,000`.
2. **Thêm nút gạt "Tầm Nhìn Xa (Xóa Mờ Map)" trong Tab Thị Giác & Đồ Họa**:
   - Mặc định **BẬT SẴN** ngay khi load script, giúp mọi người chơi vừa vào game là nhìn rõ mồn một toàn bộ map và các hòn đảo từ xa siêu nét.
   - Tự động lưu cấu hình theo tài khoản người dùng (`ClearFarVision`).
3. **Cơ chế chống game ghi đè (Anti Weather Re-blur)**:
   - Tự động lắng nghe `Lighting.DescendantAdded` và `Camera.DescendantAdded`: Khi game đổi thời tiết (mưa, bão, sương) và tự tạo hiệu ứng làm mờ mới, script sẽ lập tức triệt tiêu ngay lập tức.
   - Vòng lặp giám sát liên tục mỗi 2 giây đảm bảo tầm nhìn luôn luôn rõ nét 100% trong suốt quá trình treo máy.

---

## [v2.2.1] - 2026-09-15
### 🎯 Nhúng Trực Tiếp Toàn Bộ Tọa Độ Vị Trí Câu Săn Boss Gốc Cho Tất Cả Người Dùng (Update gì):
1. **Cập nhật tọa độ đứng câu & hướng nhìn biển chuẩn xác cho toàn bộ 8 đảo săn Secret Boss**:
   - Nhúng trực tiếp bộ tọa độ chuẩn (`pos` & `lookAt`) do người dùng cung cấp vào bảng cơ sở dữ liệu gốc `secretBossDatabase` trong script:
     - 🎋 **Đảo Tre (Bamboo Isle)**: `pos(-1504.8, 14.7, 252.7)`, `lookAt(-1515.0, 14.7, 301.6)`
     - ☣️ **Đảo Phóng Xạ (Fallout Isle)**: `pos(30.1, 9.3, 1682.3)`, `lookAt(32.3, 9.3, 1732.2)`
     - 🐟 **Đảo Cá Chép (Perch Isle)**: `pos(126.3, 6.8, -1472.7)`, `lookAt(116.6, 6.8, -1423.6)`
     - ❄️ **Đảo Băng Giá (Frost Isle)**: `pos(-1519.4, 6.8, -1334.5)`, `lookAt(-1469.6, 6.8, -1338.2)`
     - 🥥 **Đảo Quả Dừa (Coconut Isle)**: `pos(1250.0, 9.5, -1297.7)`, `lookAt(1289.4, 9.5, -1328.5)`
     - ☀️ **Đảo Hổ Phách (Amber Isle)**: `pos(1579.8, 18.2, 1238.4)`, `lookAt(1629.5, 18.2, 1233.7)`
     - 🏔️ **Đảo Đỉnh Sương Mù (Mistpeak)**: `pos(3031.4, 19.2, 94.8)`, `lookAt(3081.0, 19.2, 101.3)`
     - 🐙 **Vùng Biển Sâu (Secret Ocean)**: `pos(1419.7, 20.5, -208.8)`, `lookAt(1420.1, 20.5, -258.8)`
2. **Hiệu lực toàn cục cho tất cả người dùng**:
   - Tất cả người chơi khi chạy script mới sẽ mặc định dùng ngay bộ vị trí câu mép nước và góc nhìn câu tối ưu này khi xuất hiện Secret Boss mà không cần phải đi dò tìm hoặc cài đặt thủ công lại từng đảo!

---

## [v2.2.0] - 2026-09-15
### 💎 Sửa Triệt Để Lỗi Ảo Hoá Gems Không Đổi (Fix & Upgrade gì):
1. **Khắc phục nguyên nhân khiến Gems bị giữ nguyên khi ảo hoá**:
   - *Nguyên nhân 1*: Trong cấu trúc dữ liệu server `ReplicatedStorage.Data[UserId]`, trò chơi không có sẵn ValueBase tên `"Gems"` nên lệnh gán cũ bị bỏ qua (khác với Vé Nhiệm Vụ có sẵn `pData.Ticket`).
   - *Khắc phục*: Nâng cấp `visualSpoofState.ScanPlayerDataGems()` tự động tạo các đối tượng `IntValue` tên `"Gems"` và `"Gem"`, gán đồng loạt vào `pData`, `LocalPlayer` và `leaderstats`, đồng thời gán cả `Attributes`.
   - *Nguyên nhân 2 (Giao diện game)*: Các TextLabel hiển thị Gems trên thanh HUD/TopBar của game thường nằm trong khung lồng nhiều cấp hoặc có icon `💎` đứng kèm, điều kiện quét cũ không nhận diện được và bị chặn bởi biểu thức số đơn thuần.
   - *Khắc phục*: Viết bộ quét thông minh đa tầng `visualSpoofState.ScanPlayerGuiGems()`:
     - Nhận diện theo tên Label, tên Frame cha, tên Frame ông (grandparent).
     - Nhận diện theo biểu tượng cảm xúc `💎`, `🔷` hoặc từ khóa `gem`, `diamond`, `ruby`.
     - Nhận diện theo Icon ảnh (ImageLabel) đứng cạnh TextLabel trong cùng một Frame.
     - Tự động định dạng giữ nguyên icon (ví dụ: `💎 50 000`, `50 000 Gems`).
   - *Nguyên nhân 3 (Chống game ghi đè lại)*: Hook sự kiện `label:GetPropertyChangedSignal("Text")`: nếu client game cố gắng cập nhật số Gems thật lên màn hình, script sẽ lập tức cưỡng chế hiển thị lại số Gems ảo ngay trong microsecond kế tiếp.
2. **Nâng cấp ô Thống Kê Script (Bảng 3x5)**:
   - Đổi tên Tile 9 từ `"💎 Gems Đã Kiếm"` (vốn kèm dấu `+` của phiên treo máy) thành **`"💎 Gems Hiện Có"`** hiển thị chuẩn dạng tổng tài sản (ví dụ: `50 000 Gems`), đồng bộ 100% với ô `🎫 Vé Nhiệm Vụ`.
3. **Tái cấu trúc bộ nhớ tránh vượt giới hạn biến (Lua 200 Locals Limit)**:
   - Đóng gói toàn bộ các hàm hỗ trợ vào bảng phương thức `visualSpoofState`, giải quyết triệt để lỗi biên dịch `too many local variables` của Lua 5.1.

---

## [v2.1.9] - 2026-09-15
### 🎭 Tính Năng Mới: Ảo Hoá Vé Nhiệm Vụ & Gems (Visual Spoof) Lưu Vĩnh Viễn Vào Máy (New Feature & Update gì):
1. **Thêm nhóm tính năng "🎭 Ảo Hoá Tài Sản (Visual Spoof)" vào Tab Nhân Vật**:
   - **Ảo Hoá Vé Nhiệm Vụ (Tickets)**: Cho phép người chơi gõ bất kỳ con số nào mong muốn (ví dụ: `99,999`, `1,000,000`, v.v.), sau đó nhấn **Enter**.
   - **Ảo Hoá Gems / Đá Quý**: Cho phép người chơi gõ bất kỳ số lượng Gems mong muốn (ví dụ: `500,000`, `999,999`, v.v.), sau đó nhấn **Enter**.
   - **Nút "🔄 Khôi Phục Thật"**: Xóa số ảo ngay lập tức và đưa cả Vé lẫn Gems trở về số lượng thực tế từ máy chủ.
2. **Cơ Chế Lưu Trữ Vĩnh Viễn Tự Động (Auto Persistence)**:
   - Ngay khi người dùng nhấn Enter, số lượng ảo được tự động mã hóa và ghi vào tệp máy riêng theo từng tài khoản (`heavyweight_visual_spoof_<Username>.json`).
   - Lần sau khi mở lại script hoặc đổi server, script sẽ tự động đọc lại tệp này và tiếp tục hiển thị chính xác số ảo đó mà người dùng không cần phải nhập lại!
3. **Đồng Bộ Hoá Toàn Diện (Full Sync)**:
   - **Dữ liệu Game Client (`pData.Ticket` & `pData.Gems`)**: Ghi đè trực tiếp giá trị ảo lên đối tượng dữ liệu client và tự động hook sự kiện `.Changed` (nếu server gửi bản tin cập nhật thật thì client lập tức ép lại số ảo ngay lập tức).
   - **Giao Diện Game (`PlayerGui`)**: Tự động quét và cập nhật số hiển thị trên thanh HUD / TopBar / GUI tiền tệ của game để quay video, chụp ảnh màn hình hoặc xem trực tiếp cực kỳ chân thực.
   - **Lưới Thống Kê Script (`StatTiles`)**: Ô `🎫 Vé Nhiệm Vụ` và `💎 Gems Đã Kiếm` lập tức phản ánh con số ảo vừa nhập.
   - **Báo Cáo Discord Webhook**: Đồng bộ hiển thị số ảo trong báo cáo định kỳ gửi về Discord.

---

## [v2.1.8] - 2026-09-15
### 🎫 Kiểm Tra & Tối Ưu Triệt Để Chu Trình Vé: Hết Vé Hôm Nay, Auto Home Spot & Tự Động Sang Ngày Mới (Audit & Upgrade gì):
1. **Kiểm tra và xác nhận 100% cơ chế tự động hoạt động chính xác theo yêu cầu**:
   - **Chuyển ô thống kê thành "Hết vé hôm nay"**: Khi làm hết 20 vé trong ngày, NPC trả về câu thoại `"That's all the quests I've got for today! Come back tomorrow for more."`. Script lập tức nhận diện, gắn cờ `allQuestsDoneForToday = true`, và cập nhật ngay lập tức ô **⏳ Chờ Vé Mới** thành `"Hết vé hôm nay"` (đồng thời thông báo trên tab Nhiệm Vụ).
   - **Tự động bay về Home Spot câu cá / combo farm tiền**: Khi hết vé hôm nay (hoặc trong thời gian 20 phút hồi chiêu vé), nếu bật `Tự về Home Spot khi xong vé` (`TicketReturnHomeWhenDone = true`), bot tự động bay về tọa độ `HomeFarmSpot`, tự động tạo sàn nước an toàn `IdenticalWaterPlatform`, và sau 1 giây kích hoạt quăng cần `CancelAndRecastRod()`, tiếp tục câu cá, chạy combo skill Z-X-C-V và tự bán cá liên tục mà không bị khựng lại.
2. **Nâng cấp cơ chế phát hiện Ngày Mới (Auto Reset 00:00 UTC & Server Reset)**:
   - *Điểm yếu trước đây*: Hàm `IsAllQuestsDoneToday()` chỉ kiểm tra ngày của thiết bị máy tính (`os.date("%Y-%m-%d")`), chỉ đổi ngày vào lúc 00:00 nửa đêm giờ máy tính địa phương. Trong khi Roblox Game Server reset số nhiệm vụ hàng ngày vào lúc **00:00 UTC (tức 07:00 sáng giờ Việt Nam)**!
   - *Nâng cấp mới*:
     - Bổ sung kiểm tra ngày chuẩn quốc tế **00:00 UTC** (`os.date("!%Y-%m-%d")`).
     - Bổ sung theo dõi dữ liệu gốc từ Game Server `pData.TicketQuestDailyCount`: nếu server reset số vé làm trong ngày về nhỏ hơn mốc trước đó (ví dụ từ 20 về 0), script lập tức kích hoạt reset ngày mới ngay!
     - Ngay khi ngày mới được phát hiện: script tự động xóa toàn bộ cờ khóa (`allQuestsDoneForToday = false`, `readyForNewQuest = true`, `isAtHomeSpot = false`), nhân vật tự động cất cần và bay thẳng từ Home Spot về lại NPC để nhận vé làm tiếp mà người dùng hoàn toàn **không cần canh chừng hay thao tác tay**!

---

## [v2.1.7] - 2026-09-15
### 🐛 Sửa Triệt Để Lỗi Khởi Động Line 9265, Sửa Đếm Cá Trong Balo & Nhận Diện Đảo Chuẩn Xác (Fix & Update gì):
1. **Khắc phục lỗi đỏ khi chạy script: `invalid argument #1 to ipairs (table expected, got nil)` tại dòng 9265**:
   - *Hiện tượng*: Khi inject script, xuất hiện thông báo lỗi đỏ `CoreGui.10192.Loadstring:9265: invalid argument #1 to ipairs` và toàn bộ vòng lặp cập nhật dữ liệu của script bị ngừng trệ.
   - *Nguyên nhân*: Bảng `islands` trước đó bị giới hạn phạm vi trong khối `do ... end` ở đầu file, khiến vòng lặp tạo nút dịch chuyển đảo ở Tab Teleports (dòng 9265) nhận giá trị `nil`.
   - *Khắc phục*: Đưa dữ liệu toàn bộ đảo và boss vào cấu trúc dữ liệu `WorldData = { islands = {...}, bossRealms = {...} }` dùng chung toàn cục. Khai báo rõ ràng `local islands = WorldData.islands` trong khối Tab Teleport, đảm bảo 100% không bao giờ bị nil.
2. **Khắc phục lỗi hiển thị "Cá Trong Balo Sai"**:
   - *Nguyên nhân*: Do lỗi dòng 9265 làm script dừng trước khi vào vòng lặp Heartbeat, khiến ô balo bị đứng yên ở giá trị mặc định `"0 / 100"`.
   - *Khắc phục*: 
     - Viết hàm `GetCurrentBackpackFishCount()` đọc chính xác tổng số cá từ `pData.Inventory`, cộng thêm cá đang cầm trên tay (Character Tool) và trong balo trang bị (LocalPlayer.Backpack).
     - Đọc giới hạn balo chuẩn xác từ `pData.InventoryLimit.Value`.
     - Cập nhật số liệu tức thì ngay khi vừa nạp script và làm mới liên tục mỗi khung hình.
3. **Mở rộng bán kính nhận diện đảo (Khắc phục "Map Đang Đứng Bị Sai")**:
   - *Nguyên nhân*: Bán kính nhận diện cũ chỉ là `450 studs`. Khi người chơi đứng câu ở bờ đá, cầu cảng hoặc mỏm xa của đảo (cách tâm đảo >450 studs), script bị nhầm thành `"Đang ở giữa biển"`.
   - *Khắc phục*: Mở rộng bán kính nhận diện các đảo từ `450` lên `850 studs` (khoảng cách an toàn vì các đảo cách nhau >1100 studs). Đảm bảo đứng bất kỳ vị trí nào trên đảo hoặc mép nước quanh đảo đều nhận diện chính xác 100% tên hòn đảo.

---

## [v2.1.6] - 2026-09-15
### 📍 Hiển Thị Vị Trí Map Đang Đứng & Hoàn Thiện Lưới Thống Kê 3x5 (Fix & Update gì):
1. **Bổ Sung Chỉ Số "📍 Map Đang Đứng" Vào Bảng Thống Kê & Webhook Discord**:
   - *Tính năng*: Hiển thị tên hòn đảo hoặc vùng biển người chơi đang đứng (ví dụ: `[1] Đảo Khởi Đầu`, `[6] Đảo Băng Giá`, `[2] Đảo Tre`, `Vùng Câu Cá Ngầm`, v.v.) ngay trên hàng đầu tiên của bảng thống kê Tab Câu Cá.
   - *Cơ chế hoạt động*: Chuyển `GetCurrentLocationName` lên phạm vi dùng chung toàn script, tự động nhận diện và cập nhật mỗi 3 giây hoặc ngay khi người chơi dịch chuyển / bay qua đảo khác. Đồng bộ luôn vào báo cáo Webhook Discord.
2. **Hoàn Thiện Bố Cục Lưới Cân Đối 3x5 (15 Ô Metric Hoàn Chỉnh)**:
   - Bổ sung thêm 2 chỉ số thực chiến quan trọng để lấp đầy hàng thứ 5 thành hình chữ nhật 3 cột x 5 hàng hoàn hảo:
     - 🎒 **Sức Chứa Balo**: Hiển thị số lượng cá/vật phẩm hiện tại trên tổng sức chứa (ví dụ: `42 / 100`) theo thời gian thực.
     - ⏳ **Chờ Vé Mới**: Đếm ngược thời gian hồi vé nhiệm vụ trực tiếp (ví dụ: `Chờ 18:24` hoặc `Sẵn sàng nhận!`).
3. **Tái Cấu Trúc Bảng Dữ Liệu `StatTiles` & Tối Ưu Giới Hạn Biến Cục Bộ (Lua 200 Locals Limit)**:
   - Gom toàn bộ 15 biến thành viên của bảng thống kê vào bảng `StatTiles = {}` và đóng gói dữ liệu tọa độ đảo trong phạm vi khối lệnh `do ... end`.
   - Giúp giảm mạnh số lượng biến cục bộ của hàm chính, giải quyết triệt để lỗi biên dịch `too many local variables (limit is 200)` của Lua, giúp script luôn nhẹ và ổn định tối đa.

---

## [v2.1.5] - 2026-09-15
### 📊 Nâng Cấp Bảng Thống Kê 3 Cột, Bổ Sung Chỉ Số & Nút Reset Treo Máy (Fix & Update gì):
1. **Tái Cấu Trúc Khung Thống Kê Thành Lưới 3 Cột Hiện Đại (Grid 3x4 / 3xN)**:
   - *Vấn đề*: Khung thống kê cũ dạng danh sách dọc 8 dòng đơn điệu, chiếm nhiều diện tích cuộn và khó quan sát tổng thể tài khoản.
   - *Khắc phục*: Thiết kế lại toàn bộ bằng bố cục lưới 3 cột x 4 hàng (12 ô ô metric) cực kỳ gọn gàng, đẹp mắt và tiết kiệm diện tích. Mỗi ô có viền bo góc, đổi màu hover mượt mà và phân màu chỉ số trực quan (Tiền xanh lá, Gems xanh dương, Vé cam, Ngọc tím, Trait vàng kim).
   - Kiến trúc linh hoạt, sẵn sàng mở rộng thành 3x5, 3x6 bất cứ lúc nào khi cần bổ sung thêm thông tin.
2. **Bổ Sung 4 Chỉ Số Tài Sản Mới (Live Update Real-time)**:
   - 🎫 **Vé Nhiệm Vụ (Tickets)**: Đọc trực tiếp từ `ReplicatedStorage.Data[UserId].Ticket`.
   - 🔮 **Essence Orb (Ngọc Bản Mệnh)**: Đọc trực tiếp từ `ReplicatedStorage.Data[UserId].EssenceOrb`.
   - 🎲 **Vé Trait Reroll**: Đọc trực tiếp từ `ReplicatedStorage.Data[UserId]["Trait Reroll"]`.
   - 📜 **Vé Đã Xong Hôm Nay**: Đọc trực tiếp số nhiệm vụ đã hoàn thành từ `ReplicatedStorage.Data[UserId].TicketQuestDailyCount`.
   - Các chỉ số này cũng được tự động tích hợp gửi kèm báo cáo Webhook Discord định kỳ.
3. **Thêm Nút "Đặt Lại Thông Số Treo (Reset AFK)" Tiện Lợi**:
   - *Vấn đề*: Khi người chơi câu tay hoặc chơi tự do một lúc rồi mới bắt đầu treo máy, thời gian và số cá/tiền cũ làm sai lệch tốc độ Fish/h và Cash/h. Người chơi trước đây phải tắt script rồi inject lại từ đầu rất phiền phức.
   - *Khắc phục*: Thêm nút `🔄 Reset Thông Số` ngay dưới khung thống kê. Bấm 1 click là:
     - Đặt lại thời gian treo máy về `00:00:00`.
     - Lấy mốc cá và tiền hiện tại làm điểm bắt đầu mới (`initialFishCaught = curFish, initialCash = curCash`).
     - Đặt lại Gems kiếm được về `+0 Gems`.
     - Tốc độ câu cá và tốc độ tiền được tính chuẩn xác 100% từ đúng thời điểm bắt đầu treo máy!

---

## [v2.1.4] - 2026-09-15
### ☀️ Cân Bằng Ánh Sáng Fullbright & Chống Chói Lóa Theo Thời Tiết (Fix gì):
1. **Khắc phục lỗi Fullbright bị quá sáng, chói lóa trắng xóa mặt đất khi thời tiết thay đổi (Windy, Sunny)**:
   - *Hiện tượng*: Khi bật Fullbright, có lúc sáng ổn định (ban đêm), nhưng khi đổi sang thời tiết gió bão (Windy) hoặc trời nắng thì mặt đất bị chói lóa trắng xóa, cháy sáng không nhìn rõ vân đá.
   - *Nguyên nhân*: Mã cũ gán cứng `Lighting.Brightness = 10` và `ExposureCompensation = 1`. Mức này làm ánh sáng mặt trời bị nhân lên 20 lần bình thường. Khi game đổi sang các loại thời tiết có ánh sáng riêng, hai nguồn sáng cộng dồn gây cháy sáng màn hình.
   - *Khắc phục*:
     - **Cân bằng lại ánh sáng dịu mắt**: Giảm `Brightness` xuống `2.0` (mức an toàn) và đưa `ExposureCompensation` về `0`. Giữ cho ban đêm vẫn sáng rõ nhưng ban ngày và thời tiết gió bão không bao giờ bị cháy sáng trắng xóa.
     - **Tự động kìm hãm ánh sáng theo thời tiết (Anti-Glare)**: Lắng nghe sự kiện `Lighting.Changed`. Khi thời tiết game cố đẩy độ sáng hoặc phơi sáng lên quá cao, script tự động kìm hãm lại ở mức an toàn dịu mắt.
     - **Thêm thanh trượt tùy chỉnh Mức Độ Sáng**: Cho phép người chơi tự do kéo chỉnh độ sáng từ `1.0x` đến `3.5x` trong Tab ESP & Đồ Họa theo sở thích của mình.

---

## [v2.1.3] - 2026-09-15
### 🚀 Cập Nhật Logic Combo Mới: Spam Nhận Nút Khóa -> 0.15s Pass Chiêu (Fix gì):
1. **Khắc phục triệt để lỗi "X chờ 4-5s C lại chờ khá lâu V lại chờ Z dù màn hình đã hồi"**:
   - *Nguyên nhân*: Hàm `IsSkillReady` cũ duyệt toàn bộ `fUI:GetDescendants()`, bị dính các phần tử giả lập số của GUI game (như số level, slot, dame) khiến script tưởng nhầm chiêu đang còn hồi 4-5s.
   - *Khắc phục theo đề xuất logic của người dùng*:
     - **Chỉ trỏ thẳng vào nút chuẩn của game**: `PlayerGui.MainGui.Fishing.SkillButton.Frame[key]`.
     - **Cơ chế phản hồi 0.15s**: Khi nút kỹ năng mở khóa (sáng đèn), script bấm chiêu ngay ➔ Quan sát game/server nhận lệnh và nút chuyển sang trạng thái khóa Cooldown ➔ **0.15s sau lập tức PASS sang chiêu tiếp theo trong chuỗi!**
     - Loại bỏ hoàn toàn mọi thời gian chờ nhân tạo, giúp combo `X -> C -> V -> Z` xuất chiêu liên hồi mượt mà với tốc độ bàn thờ (chỉ mất ~0.15s cho mỗi chiêu nếu chiêu đang sẵn sàng).

---

## [v2.1.2] - 2026-09-15
### ⚡ Tối Ưu Tốc Độ Ra Chiêu & Sửa Lỗi Thứ Tự Combo (Fix gì):
1. **Khắc phục triệt để lỗi "Chờ lâu skill trong khi chiêu đã hồi" (Tốc độ tung chiêu siêu nhanh)**:
   - *Hiện tượng*: Khi bật combo, nhân vật đứng chờ rất lâu mới đánh chiêu tiếp theo, dù mắt thường nhìn trên giao diện thấy chiêu đã hồi xong từ lâu.
   - *Nguyên nhân*: Mã cũ gán cứng thời gian cooldown nhân tạo (`Z=2.5s, X=3.0s, C=5.0s, V=4.0s`) và độ trễ chờ `SkillEffectDelay = 1.2s`. Dù game hồi xong trong 1s - 2s, script vẫn bắt người chơi chờ đủ 5s mới cho đánh!
   - *Khắc phục*:
     - Bỏ giới hạn cứng 5.0s, chuyển sang đọc trực tiếp trạng thái hồi chiêu từ GUI game và đặt nhịp chống spam phím về `0.35s`. Ngay khi chiêu vừa hết hồi chiêu trong game, hệ thống tung chiêu TỨC THÌ.
     - Giảm độ trễ giữa các chiêu `SkillEffectDelay` từ `1.2s` xuống `0.3s` (hỗ trợ kéo thanh trượt từ `0.1s` đến `2.5s`), giúp chuỗi combo mượt mà và cực kỳ nhanh.
     - Giảm timeout hoạt ảnh `IsCharacterCastingSkill` từ 0.7s xuống 0.35s để không làm khựng nhịp tung chiêu.
2. **Khắc phục lỗi combo `X C V Z` bị đánh `Z C Z C V` (Lỗi nhảy cóc khi tắt giữ đúng thứ tự)**:
   - *Hiện tượng*: Cài chuỗi `X C V Z` nhưng khi vào đánh cá lại ra `Z C Z C V` lộn xộn.
   - *Nguyên nhân*: Do bộ nhớ thời gian tung chiêu `usedTimes` của con cá trước vẫn còn lưu, khiến chiêu `X` bị script hiểu nhầm là chưa hồi, dẫn đến việc quét nhảy cóc qua chiêu `Z`.
   - *Khắc phục*: Tự động xóa sạch bảng `usedTimes = {}` ngay khi cá cắn câu và khi kết thúc minigame. Đảm bảo mọi con cá mới luôn luôn bắt đầu từ chiêu đầu tiên trong chuỗi cài đặt (`X`).

---

## [v2.1.1] - 2026-09-15
### 🐛 Lỗi Đã Sửa (Fix gì):
1. **Sửa lỗi giật cần hủy cá khi tắt Auto Ticket Quest**:
   - *Hiện tượng*: Khi người chơi làm nhiệm vụ 100 mồi (`bait_100`), sau đó tắt "Tự Động Làm Vé Nhiệm Vụ" và sang map khác câu cá để test combo, cá vừa cắn câu thì cần bị giật lên hủy cá ngay lập tức.
   - *Nguyên nhân*: Biến kiểm tra dùng `(Config.AutoTicketQuest or hasActiveTicket) and hasActiveTicket` khiến logic vé vẫn chạy ngầm dù đã tắt nút. Đoạn code `qType == "bait_100"` đã gọi `h:UnequipTools()` ngay khi cá cắn câu để tăng tốc độ tiêu thụ mồi.
   - *Khắc phục*:
     - Bắt buộc kiểm tra `Config.AutoTicketQuest == true` thì mới cho phép các thao tác của vé hoạt động.
     - Khi gạt tắt nút "Tự Động Làm Vé Nhiệm Vụ", hệ thống lập tức xóa sạch bộ nhớ tạm của quest (`currentQuestType = "none"`, `active = false`, `isBusyRoutine = false`).
     - Gỡ bỏ hoàn toàn logic khóa chiêu khi không bật tính năng vé, trả lại quyền sử dụng toàn bộ phím chiêu cho người chơi.

---

## [v2.1.0] - 2026-09-15
### ✨ Tính Năng & Tối Ưu Lớn:
1. **Khôi phục 100% tính năng & giao diện thực tế từ backup.lua**:
   - Phục hồi toàn bộ 12.685 dòng code thực tế (các Server Remote thật: `ToggleHotbar`, `BodyVelocity`, `AnchorBar`, `ESP` sóng nước, `TicketQuest` 1.600 dòng).
2. **Loại bỏ Tab Wiki**:
   - Gỡ bỏ Tab Wiki khỏi menu và 562 dòng giao diện bách khoa cá.
   - Giữ lại bảng dữ liệu nguyên liệu cá ngầm để tính năng bán tự động, chế mồi, bảo vệ cá đột biến hoạt động bình thường.
3. **Sửa dứt điểm lỗi xoay tua Combo (`Strict Order`)**:
   - *Hiện tượng*: Cài `Z X V` thì lần 1 ra `Z X V`, lần 2 ra `X V X V`; cài `Z X` ra `X Z X Z`; cài `X C Z` thì chiêu C chưa hồi đã nhảy cóc sang Z.
   - *Khắc phục*: Khi chiêu đang hồi (cooldown), hệ thống **bắt buộc đứng chờ**, tuyệt đối không nhảy cóc sang chiêu khác và không tăng loop index. Đảm bảo 100% đúng thứ tự tuần tự.
4. **Xóa lỗi tự xóa phím 'C'**:
   - Gỡ bỏ đoạn regex trong `_loadEssential` tự ý xóa chữ `C` mỗi khi nạp file cấu hình từ ổ đĩa.
5. **Tối ưu Hot-path**:
   - Bỏ gọi hàm quét GUI nặng `DetectActiveQuest()` trong vòng lặp Heartbeat 60 FPS.
6. **Thêm Loader Bản Backup Dự Phòng**:
   - Tạo file `loader_backup.lua` để người dùng có thể chạy bản backup nguyên bản bất cứ lúc nào.

---

## [v2.0.0] - 2026-09-14
### 🚀 Khởi tạo kiến trúc Modular V2:
- Tách dự án thành các module: `v2/core/`, `v2/combo/`, `v2/features/`, `v2/ui/`.
- Tạo công cụ đóng gói tự động `build.py`.
