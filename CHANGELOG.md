# 📝 NHẬT KÝ CẬP NHẬT (CHANGELOG) - IDENTICAL HUB

Tất cả các bản cập nhật, sửa lỗi và nâng cấp tính năng đều được ghi nhận chi tiết tại đây theo đúng quy tắc dự án.

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
