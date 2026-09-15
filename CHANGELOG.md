# 📝 NHẬT KÝ CẬP NHẬT (CHANGELOG) - IDENTICAL HUB

Tất cả các bản cập nhật, sửa lỗi và nâng cấp tính năng đều được ghi nhận chi tiết tại đây theo đúng quy tắc dự án.

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
