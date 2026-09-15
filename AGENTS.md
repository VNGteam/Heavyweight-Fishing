# QUY TẮC PHÁT TRIỂN & CẬP NHẬT DỰ ÁN (PROJECT RULES)

## 📌 QUY TẮC BẮT BUỘC SAU MỖI LẦN CẬP NHẬT (UPDATE RULE)
Mỗi khi có bất kỳ thay đổi, sửa lỗi (bug fix) hay cập nhật tính năng mới trong code:
1. **Cập nhật mã phiên bản (Version / Build Name)**:
   - Thay đổi biến `SCRIPT_BUILD_COMMIT` trong [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua) (và `ConfigModule.SCRIPT_BUILD_COMMIT` trong `v2/core/config.lua`).
   - Định dạng phiên bản rõ ràng, ví dụ: `v2.1.0`, `v2.1.1`, `v2.1.2`, ...
   - Mã này sẽ hiển thị trực tiếp trên huy hiệu (badge) cạnh tiêu đề **CÂU CÁ PRO** trong menu game.
2. **Ghi lại nhật ký thay đổi vào [CHANGELOG.md](file:///Users/vonguyengiap/Documents/script/CHANGELOG.md)**:
   - Ghi rõ ngày giờ cập nhật.
   - Ghi số phiên bản mới.
   - Ghi chi tiết các lỗi đã sửa (**Fix gì**), tính năng mới thêm, và lý do kỹ thuật.
3. **Báo cáo rõ ràng trong câu trả lời người dùng**:
   - Luôn nêu rõ: **Phiên bản mới nhất là gì (Build Name)**.
   - Luôn liệt kê chi tiết: **Đã sửa / cập nhật những gì (Fix gì)**.
   - Cung cấp link chạy loader để người dùng test ngay.
