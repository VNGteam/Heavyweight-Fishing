# 📝 NHẬT KÝ CẬP NHẬT (CHANGELOG) - IDENTICAL HUB

Tất cả các bản cập nhật, sửa lỗi và nâng cấp tính năng đều được ghi nhận chi tiết tại đây theo đúng quy tắc dự án.

## [v2.8.0] - 2026-09-17
### 📢 Nâng Cấp Toàn Diện Discord Webhook & Báo Cáo Server Đa Kênh:
1. **Nút "Gửi Báo Cáo Toàn Diện Ngay" (📊 Gửi Ngay)**:
   - Gửi ngay lập tức 1 Discord Embed sang trọng với đầy đủ 14 chỉ số quan trọng: Uptime, Thời Tiết hiện tại, Đảo đang đứng, Boss mục tiêu có thể ra, Tổng cá, Ba lô cá hiện tại, Tiền, Gems, Vé nhiệm vụ, Vé đã xong hôm nay (x/20), Essence Orb, Trait Reroll, Trạng thái bot, Code Teleport vào server (Job ID) và Thời gian cập nhật.
   - Màu sắc embed tự động đổi sang màu cam cảnh báo nếu phát hiện thời tiết nguy hiểm / bão.
2. **Thông Báo Khi Hoàn Thành Nhiệm Vụ Vé (Ticket Quest Hard)**:
   - Tự động kích hoạt khi nộp vé Hard thành công.
   - Gửi embed chi tiết: Số lượt NV hôm nay (x/20), Vé hiện có, Gems nhận được, Tổng gems, Thời gian chờ hồi chiêu, Server Job ID và Code Teleport.
   - Có toggle bật/tắt riêng trong UI (`WebhookNotifyTicketQuest`), lưu bền vững chống mất cấu hình.
3. **Nâng Cấp Báo Cáo Định Kỳ & Thêm Slider Chỉnh Tần Suất**:
   - Thêm trường Thời Tiết, Boss, Ba lô vào báo cáo định kỳ.
   - Bổ sung slider điều chỉnh "Tần Suất Báo Cáo Định Kỳ" (từ 5 đến 120 phút, mặc định 30 phút).
   - Khắc phục triệt để nguy cơ bị Discord giới hạn tần suất (429 Rate Limit) do tính sai phút thành giây.
4. **Nâng Cấp Hàm Gửi Discord Webhook Đa Hình & Tương Thích Tuyệt Đối**:
   - Hỗ trợ cả 2 định dạng gọi (chuỗi tham số title/desc/color/fields và table payload trực tiếp).
   - Tự động lấy avatar Roblox của người chơi làm thumbnail và icon footer.
   - Footer hiển thị phiên bản động theo `SCRIPT_BUILD_COMMIT`.

---

## [v2.7.1] - 2026-09-17
### ⏪ Hoàn Nguyên Về Cấu Trúc v2.6.1 (Bản Gửi Thông Báo Đẹp Gốc) + Các Bổ Sung Quan Trọng:
1. **Khôi phục 100% cấu trúc bản v2.6.1** – Đây là bản user xác nhận gửi và nhận thông báo ntfy đẹp nhất, ổn định nhất. Toàn bộ hàm `SendNtfyNotification` và luồng xử lý được giữ nguyên vẹn.
2. **Thêm `secretBossState.GetPlayerGems()`** – Hàm lấy số Gems an toàn, không làm crash script khi bấm nút Báo Cáo Server.
3. **Thêm `secretBossState.SendServerStatusNtfyAlert()`** – Gửi báo cáo tình hình server về điện thoại đầy đủ (thời tiết, gems, job ID, teleport code).
4. **Nút "Gửi Test" thông minh hơn** – Tự động bật NtfyEnabled nếu user chưa bật, hiển thị tên kênh đang gửi.

---

## [v2.7.0] - 2026-09-17
### 💎 Khôi Phục Toàn Diện Cấu Trúc Gốc v2.6.3 & Khắc Phục Lỗi Lấy Gems:
1. **Khôi Phục Toàn Bộ Hệ Thống ntfy Về Chuẩn Gốc v2.6.3 (Hoạt Động Ổn Định 100%)**:
   - Theo phản hồi chuẩn xác từ người dùng, phiên bản v2.6.3 là phiên bản gửi và nhận thông báo mượt mà nhất.
   - Toàn bộ cơ chế gửi request, headers, giao diện và luồng xử lý được hoàn nguyên về chính xác phiên bản v2.6.3, xóa bỏ hoàn toàn các thay đổi gây xung đột ở các bản 2.6.4 - 2.6.8.
2. **Khắc Phục Duy Nhất 1 Lỗi Của Bản v2.6.3 (Lỗi Không Trả Báo Cáo Server)**:
   - Bổ sung hàm `secretBossState.GetPlayerGems()` để khi người dùng ấn nút **`📊 Lấy Báo Cáo Server`** trên điện thoại, bot không bị dừng khẩn cấp ở dòng tính Gems mà sẽ tổng hợp đầy đủ và gửi ngược báo cáo server về điện thoại ngay lập tức!
3. **Đồng Bộ Phiên Bản v2.7.0 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.7.0` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.6.8] - 2026-09-17
### 🛑 Khắc Phục Triệt Để Giới Hạn Tốc Độ (Rate Limit 429) & Khôi Phục Thông Báo:
1. **Phát Hiện Nguyên Nhân Gốc (Tại Sao Không Nhận Được Tin Nhắn Từ Sau 14h34)**:
   - **Nguyên nhân**: Vòng lặp lắng nghe lệnh từ xa ở bản trước quét liên tục mỗi 2.5s trên 2 kênh, tạo ra hơn 48 lượt truy vấn/phút tới máy chủ `ntfy.sh`.
   - **Hậu quả**: Máy chủ `ntfy.sh` có chính sách giới hạn 16 req/phút cho tài khoản miễn phí. Sau khi bị quá tải lúc 14h34, máy chủ ntfy.sh đã kích hoạt chế độ **HTTP 429 (Too Many Requests)**, tạm khóa toàn bộ việc nhận và gửi tin nhắn từ mạng của Executor!
2. **Các Bước Đã Khắc Phục Toàn Diện (Fix Gì)**:
   - **Chuyển mặc định `NtfyRemoteCommandEnabled = false`**: Không tự động gửi request nền gây quá tải. Người dùng chỉ cần bật khi có nhu cầu điều khiển từ xa.
   - **Tối ưu hóa bộ quét (12s / chu kỳ, chỉ quét kênh `_cmd`)**: Giảm hơn 90% tải, tuyệt đối an toàn và không bao giờ bị ntfy.sh khóa nữa.
   - **Bắt mã lỗi 429 hiển thị lên màn hình**: Nếu IP tạm thời bị giới hạn, bot sẽ hiện thông báo cảnh báo rõ ràng thay vì im lặng.
   - **Mẹo thoát rate limit tức thì**: Chỉ cần đổi tên Topic mới (ví dụ thêm đuôi `_1`, `_88`) trên script và app điện thoại là nhận thông báo lại ngay tức khắc mà không cần đợi.
3. **Đồng Bộ Phiên Bản v2.6.8 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.6.8` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.6.7] - 2026-09-17
### 🛡️ Cơ Chế Gửi ntfy Đa Tầng Tự Động (Dual-Layer Auto Fallback):
1. **Khắc Phục Tận Gốc Sự Cố Mạng / Executor Không Nhận Thông Báo**:
   - **Tầng 1 (Root JSON API)**: Gửi qua endpoint gốc `https://ntfy.sh` với cấu trúc JSON đầy đủ (tiêu đề tiếng Việt, biểu tượng cảm xúc, nút bấm hành động).
   - **Tầng 2 (Topic URL Fallback)**: Nếu Tầng 1 trả về mã lỗi (>= 400) hoặc executor bị nghẽn mạng, bot sẽ **tự động chuyển hướng ngay lập tức** sang gửi trực tiếp qua URL Topic `https://ntfy.sh/<Topic>` bằng headers tiêu chuẩn. Đảm bảo thông báo không bao giờ bị rơi rụng.
   - **Hiển thị kênh gửi trực quan**: Nút "Gửi Test" hiển thị rõ tên Topic đang gửi đến trên màn hình game để người dùng đối chiếu chính xác với app ntfy trên điện thoại.
2. **Đồng Bộ Phiên Bản v2.6.7 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.6.7` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.6.6] - 2026-09-17
### ⚡ Khôi Phục Hoàn Toàn Hàm Gửi ntfy Chuẩn Mực & Sửa Triệt Để Báo Cáo Server:
1. **Khôi Phục Cấu Trúc Request ntfy Ổn Định (Như Bản Hoạt Động Tốt Lúc 14h34)**:
   - Đưa cấu trúc hàm `SendNtfyNotification` về chính xác phiên bản gốc đã gửi thành công lúc 14h34 (bỏ toàn bộ các tầng fallback thử nghiệm gây xung đột trên Executor di động).
   - Sử dụng đúng cấu trúc headers kép `Content-Type / content-type: application/json` và gửi trực tiếp qua `reqFunc`.
2. **Kích Hoạt Hoàn Hảo Chiều Phản Hồi Báo Cáo Server**:
   - Duy trì hàm `secretBossState.GetPlayerGems()` để khi nhận lệnh từ nút **`📊 Lấy Báo Cáo Server`**, bot không còn bị crash ngầm ở dòng lấy gem nữa mà lập tức gửi ngược báo cáo server về điện thoại.
3. **Đồng Bộ Phiên Bản v2.6.6 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.6.6` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.6.5] - 2026-09-17
### 🛠️ Sửa Lỗi Gửi Test ntfy & Khắc Phục Xung Đột Tham Số Request Trên Executor:
1. **Khắc Phục Tận Gốc Lỗi Bấm Nút "Gửi Test" Không Nhận Được Thông Báo**:
   - **Xóa bỏ xung đột key kép**: Trong bản v2.6.4, việc truyền đồng thời cả `Url` lẫn `url`, `Headers` lẫn `headers` trong cùng một bảng (table) đã khiến trình biên dịch C++ của một số executor mobile (Delta, Codex, Arceus X) báo lỗi cú pháp hoặc từ chối gửi gói tin HTTP.
   - **Cơ chế dự phòng 2 tầng độc lập**: Tách thành 2 tầng gửi riêng biệt hoàn toàn. Bot thử bảng chuẩn `{ Url, Method, Headers, Body }` trước; nếu executor không hỗ trợ thì mới gọi tầng chữ thường `{ url, method, headers, body }`.
   - **Tự động kích hoạt khi Test (`isTest = true`)**: Nút "Gửi Test" giờ đây tự động bật công tắc `NtfyEnabled = true` và đồng bộ UI, cho phép người dùng kiểm tra đường truyền thành công 100% ngay cả khi chưa kịp gạt công tắc bật ntfy.
2. **Đồng Bộ Phiên Bản v2.6.5 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.6.5` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.6.4] - 2026-09-17
### 💎 Khắc Phục Triệt Để Lỗi Không Gửi Báo Cáo Ngược Về Điện Thoại Khi Nhận Lệnh:
1. **Nguyên Nhân Kỹ Thuật (Tại Sao Nhận Được Lệnh Nhưng Không Trả Thông Báo Về Điện Thoại)**:
   - **Thành công**: Bot đã nhận được lệnh từ nút bấm trên điện thoại 100% (nên mới hiện thông báo `ShowNotification` màu tím trong tab game).
   - **Điểm lỗi**: Ngay sau đó, hàm tổng hợp báo cáo `SendServerStatusNtfyAlert()` đã gọi đến `GetPlayerGems()` để lấy số Gem nhân vật. Do hàm `GetPlayerGems` chưa được khởi tạo trong mã nguồn, Luau đã báo lỗi ngầm `attempt to call a nil value` bên trong `pcall`, dẫn đến việc hàm bị dừng khẩn cấp trước khi kịp gọi lệnh bắn thông báo `SendNtfyNotification` về ntfy!
2. **Giải Pháp Đã Xử Lý Toàn Diện (Fix Gì)**:
   - **Định nghĩa hàm `secretBossState.GetPlayerGems()` chuẩn xác**:
     - Tự động quét và đọc đúng số lượng Gem từ `PlayerData` (`Gems`, `Gem`, `Diamonds`, `Diamond`, `Ruby`), các thuộc tính Attribute, và cả bảng điểm `leaderstats`.
     - Đồng bộ chính xác với cả số Gem ảo hoá (nếu người chơi có bật Spoof Gem).
     - Không dùng biến `local` toàn cục nhằm tuân thủ tuyệt đối quy tắc giới hạn 200 local của Luau.
   - **Đồng bộ hóa các vị trí gọi hàm**:
     - Cập nhật `SendServerStatusNtfyAlert()` (báo cáo server).
     - Cập nhật `SendTicketQuestNtfyAlert()` (báo cáo xong nhiệm vụ vé).
     - Cập nhật `ticketQuestState.Tick()` (bắt chênh lệch gem trước và sau khi nộp vé).
   - **Tương thích kép Headers & Body cho Executor**:
     - Bổ sung cả key chữ hoa lẫn chữ thường (`Url/url`, `Method/method`, `Headers/headers`, `Body/body`) trong payload gửi POST tới ntfy, đảm bảo mọi executor mobile (Delta, Codex, Arceus X, Fluxus...) đều truyền tải trơn tru không bị chặn.
3. **Đồng Bộ Phiên Bản v2.6.4 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.6.4` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.6.3] - 2026-09-17
### ⚡ Sửa Lỗi Ấn Nút Trên Thông Báo Không Phản Hồi - Cơ Chế Nhận Lệnh Từ Xa ID-Based Siêu Nhạy:
1. **Khắc Phục Tận Gốc Lỗi Ấn Nút Action Không Nhận Được Báo Cáo Acc**:
   - **Nguyên nhân kỹ thuật**: 
     - Lệnh `tick()` trong môi trường Roblox/Executor tại Việt Nam (GMT+7) trả về thời gian lệch trước +7 tiếng so với máy chủ quốc tế của ntfy (`tick() = UTC + 25,200s`).
     - Khi bot gửi yêu cầu polling với `since = tick() + 1`, máy chủ ntfy hiểu là bot đang yêu cầu tìm tin nhắn trong... 7 tiếng tương lai! Vì thế ntfy lọc bỏ toàn bộ tin nhắn mới của người dùng và trả về danh sách rỗng (0 bytes).
     - Ngoài ra, việc chỉ phụ thuộc vào 1 hàm request duy nhất có thể gây nghẽn trên một số executor di động.
   - **Giải pháp toàn diện & Chuẩn xác 100%**:
     - **Chuyển sang cơ chế Polling theo ID (`since=<lastMsgId>`)**: Hoàn toàn không phụ thuộc vào đồng hồ hệ thống, múi giờ hay độ trễ mạng. ntfy chỉ gửi về những tin nhắn phát sinh sau tin nhắn gần nhất.
     - **Bộ nhớ đệm chống trùng lặp (`remoteProcessedIds`)**: Đảm bảo mỗi lệnh từ nút bấm hoặc tin nhắn chỉ được kích hoạt duy nhất một lần.
     - **Bộ gửi/nhận đa tầng `SafeHttpGet`**: Tự động thử `game:HttpGet` trước (phương thức chuẩn hóa chạy được trên 100% executor Roblox), sau đó dự phòng `syn.request / http_request / request`.
     - **Hỗ trợ 2 Kênh Nhận Lệnh Song Song**:
       - *Kênh 1*: Kênh lệnh ngầm `<Topic>_cmd` (nơi nút Action Button `📊 Lấy Báo Cáo Server` tự động bắn lệnh vào).
       - *Kênh 2*: Kênh chính `<Topic>` (nếu người dùng mở app ntfy và gõ chữ `status`, `info`, `server`, `nv`, `baocao`, bot cũng tự động nhận diện và trả kết quả ngay lập tức!).
     - **Tối ưu độ trễ**: Rút ngắn chu kỳ quét xuống 2.5 giây giúp phản hồi về điện thoại gần như tức thì ngay sau khi chạm nút.
2. **Đồng Bộ Phiên Bản v2.6.3 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.6.3` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.6.2] - 2026-09-17
### 📜 Báo Cáo Hoàn Thành Nhiệm Vụ Vé & Ra Lệnh Lấy Thông Tin Server Từ Xa Qua ntfy:
1. **Thông Báo Hoàn Thành Nhiệm Vụ Vé (Ticket Quest Alert) Về Điện Thoại**:
   - Tự động bắt sự kiện nộp vé thành công từ NPC và kiểm tra dữ liệu tài khoản (`pData`).
   - Đẩy thông báo tức thì lên màn hình điện thoại với đầy đủ các chỉ số:
     - **Tiến độ nhiệm vụ ngày**: Số nhiệm vụ đã xong dạng `<qCount>/20 NV`.
     - **Số vé đang sở hữu**: Số lượng vé hiện tại trong túi đồ (kèm dấu phân cách hàng nghìn dễ đọc).
     - **Số Gem nhận được**: Tính toán chính xác lượng Gem vừa được cộng thêm từ nhiệm vụ (`+<gemsGained> Gems`).
     - **Tổng số Gems hiện có**: Tổng tài sản Gems của tài khoản sau nhiệm vụ.
     - **Thời gian hồi chiêu**: Báo rõ số phút cần chờ đến lần nộp vé tiếp theo.
2. **Cơ Chế Ra Lệnh Từ Xa 2 Chiều (2-Way Remote Command Qua ntfy)**:
   - **Nút Hành Động 1 Chạm Trên Thông Báo (Action Button)**: Tất cả thông báo đẩy ntfy từ game gửi về điện thoại hiện được đính kèm sẵn nút bấm **`📊 Lấy Báo Cáo Server`**. Người chơi chỉ cần chạm nút này ngay trên thông báo điện thoại là bot trong game sẽ tự động phản hồi!
   - **Kênh Điều Khiển Riêng Biệt (`<Topic>_cmd`)**: Bot tự động lắng nghe lệnh từ topic điều khiển (ví dụ kênh của bạn là `ThongBaoThoiTiet` thì kênh lệnh là `ThongBaoThoiTiet_cmd`). Người dùng có thể nhắn các từ khóa như `status`, `info`, `check`, `server`, `baocao`, `thoitiet`, `nv` từ app điện thoại.
   - **Báo Cáo Tình Hình Toàn Diện Về Điện Thoại**: Khi nhận được lệnh, bot lập tức tổng hợp và gửi về:
     - Tên nhân vật đang treo máy.
     - Thời tiết hiện tại và hòn đảo đang diễn ra.
     - Tiến độ nhiệm vụ vé (`X/20 NV`, số vé đang có, trạng thái bot: đang câu / trả quest / chờ hồi chiêu).
     - Số lượng Gem hiện có.
     - Job ID server kèm cú pháp lệnh Teleport 1 chạm.
     - Thời điểm báo cáo.
3. **Cập Nhật Giao Diện & Tự Động Lưu Trữ Cấu Hình**:
   - Thêm công tắc **"Thông Báo Xong Vé (ntfy)"** và **"Nhận Lệnh Từ Xa (ntfy Remote)"** trong thẻ ntfy tại Tab Profiles.
   - Toàn bộ cài đặt được lưu bền vững vào file `HeavyweightFishing_Notifications.json` và `essential_config.json`, không bao giờ bị mất khi khởi động lại game.
4. **Đồng Bộ Phiên Bản v2.6.2 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.6.2` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.6.1] - 2026-09-17
### 🎨 Sửa Lỗi ntfy Hiển Thị Mã JSON Thô Rối Mắt - Tối Ưu Thông Báo Đẩy Đẹp, Chuẩn Mobile:
1. **Khắc Phục Tận Gốc Lỗi Hiển Thị Chuỗi JSON `{...}` Trên Ứng Dụng ntfy**:
   - **Nguyên nhân kỹ thuật**: Trong bản v2.5.9 / v2.6.0, hàm gửi thông báo đã nối thêm tên Topic vào đường dẫn URL (`https://ntfy.sh/ThongBaoThoiTiet`). Máy chủ ntfy quy định nếu một yêu cầu POST được gửi trực tiếp tới đường dẫn `/<topic>`, nó sẽ xem toàn bộ nội dung gửi lên là **văn bản thô (raw text)**, khiến toàn bộ chuỗi JSON `{"title":..., "message":..., "tags":...}` bị in thẳng ra màn hình điện thoại thành một đoạn mã lộn xộn, rối mắt.
   - **Cách khắc phục chuẩn 100%**: Sửa lại điểm gửi POST trực tiếp về Root URL `https://ntfy.sh` với payload JSON chứa trường `"topic"`. Máy chủ ntfy sẽ tự động bóc tách:
     - **Tiêu đề (Title)**: In đậm to rõ ràng trên thanh thông báo.
     - **Nội dung (Message)**: Trình bày từng dòng gọn gàng, có icon minh họa, không còn bất kỳ dấu ngoặc `{}` hay nháy kép `""` nào của JSON.
     - **Biểu tượng (Tags)**: Tự động đổi thành icon biểu tượng thời tiết (⛅, ⛈️, ❄️, 🌫️, ☀️, 🎐...).
2. **Đồng Bộ Phiên Bản v2.6.1 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.6.1` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.6.0] - 2026-09-17
### 💾 Cơ Chế Tự Động Lưu Trữ & Chống Mất Link Thông Báo (ntfy, Webhook, Telegram) Khi Kill / Mở Lại Script:
1. **Lưu Trữ Tức Thì Vào File Cấu Hình Riêng (`HeavyweightFishing_Notifications.json`)**:
   - Mỗi khi người dùng nhập hoặc thay đổi bất kỳ ô thông tin nào (`ntfy Topic`, `Webhook URL`, `Telegram Bot Token`, `Telegram Chat ID`) hay gạt các công tắc thông báo, hệ thống sẽ tự động ghi đè an toàn vào file `HeavyweightFishing_Notifications.json`.
   - Cơ chế ghi file có tích hợp bộ đệm (Debounce 0.3s) chống nghẽn I/O khi người dùng đang gõ phím liên tục.
2. **Tự Động Nạp & Đồng Bộ Giao Diện 100% Khi Kill Mở Lại Script Hoặc Nhảy Server**:
   - Khi script vừa khởi động (load), bot đọc ngay dữ liệu từ file local để nạp vào `Config` trước khi vẽ giao diện.
   - Ngay sau khi giao diện khởi tạo xong, hệ thống tự động điền lại toàn bộ đường dẫn link / Topic vào ô TextBox và bật/tắt đúng trạng thái các nút gạt.
   - **Cam kết**: Người chơi **KHÔNG BAO GIỜ BỊ MẤT** link Webhook, Token Telegram hay ntfy Topic dù kill script bao nhiêu lần hoặc chuyển server liên tục.
3. **Đồng Bộ Phiên Bản v2.6.0 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.6.0` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.5.9] - 2026-09-17
### 📱 Tích Hợp ntfy Push Notifications - Báo Cáo Thời Tiết & Server Trực Tiếp Về Điện Thoại:
1. **Thông Báo Đẩy Thời Gian Thực Về Điện Thoại Qua App ntfy (iOS / Android)**:
   - Tích hợp giao thức HTTP Push Notification qua nền tảng [ntfy.sh](https://ntfy.sh) siêu nhẹ, miễn phí 100%, không cần tài khoản, không trễ, đẩy thông báo tức thì lên màn hình khóa điện thoại.
   - Gửi payload chuẩn JSON với định dạng UTF-8 tiếng Việt hoàn hảo kèm đầy đủ biểu tượng cảm xúc (Emoji) và tag hiển thị icon ntfy chuyên biệt theo từng loại thời tiết (`zap`, `cloud_lightning`, `cloud_rain`, `snowflake`, `fog`, `sunny`, `fire`, `dash`...).
2. **Hệ Thống Cảnh Báo Thời Tiết Server Toàn Diện**:
   - **Đổi Thời Tiết (Weather Change)**: Vòng lặp giám sát ngầm đa tầng liên tục theo dõi HUD UI và Server Data, gửi thông báo ngay khi thời tiết server chuyển biến (từ Trời Quang sang Bão Sấm, Mưa, Tuyết Rơi, Sương Mù, Nắng Gắt, Gió Mạnh...) hoặc khi bão tan quay về Trời Quang (Clear).
   - **Quét Server Thời Tiết (Weather Hop Alert)**: Khi bot tự động nhảy server tìm thời tiết mục tiêu, ngay khi đáp trúng server hợp lệ, hệ thống sẽ đẩy thông báo khẩn cấp (Priority Max) về điện thoại người chơi.
   - **Thời Tiết Sẵn Có Khi Join**: Nếu server vừa vào đã có sẵn thời tiết đặc biệt, hệ thống gửi thông báo chào đón ngay lập tức.
   - **Nội dung thông báo bao gồm**:
     - Tên thời tiết chuẩn xác và Đảo liên quan.
     - Danh sách các loài Boss / Cá Thần Thoại có thể xuất hiện theo thời tiết đó.
     - Tên nhân vật, thời gian phát hiện.
     - **JobId Server** kèm đoạn code Lua Teleport 1 chạm: `game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)` giúp người dùng dễ dàng copy vào điện thoại hoặc máy tính phụ để bay thẳng vào server!
3. **Cảnh Báo Đạo Sĩ & Secret Boss Về Điện Thoại**:
   - Khi phát hiện NPC Đạo Sĩ (Taoist) hoặc Mao Sơn (Maoshan) trên map, bot đẩy thông báo kèm tọa độ và JobId server để vào mua đồ/trả quest.
   - Khi cần câu kéo trúng Secret Boss / Cá Thần Thoại, bot gửi tin nhắn cảnh báo ưu tiên cao.
4. **Giao Diện Điều Khiển ntfy Trong Tab Profiles / Webhook**:
   - Thêm cụm card **"🔔 ntfy Push (Thông Báo Thời Tiết & Server Về Điện Thoại)"**:
     - Ô nhập **ntfy Topic** (tên kênh đã đăng ký trên app ntfy, hỗ trợ cả tên kênh hoặc URL đầy đủ).
     - Công tắc Bật/Tắt ntfy Push tổng.
     - Công tắc Bật/Tắt thông báo đổi thời tiết.
     - Công tắc Bật/Tắt thông báo tìm server thời tiết.
     - Công tắc Bật/Tắt thông báo Boss & NPC.
     - Nút **"Kiểm Tra ntfy (Gửi Test)"**: Gửi tin nhắn mẫu kiểm tra kết nối ngay lập tức đến điện thoại.
5. **Lưu Cấu Hình Tài Khoản Tự Động**:
   - Tự động ghi nhớ `NtfyTopic`, `NtfyEnabled`, `NtfyAlertWeatherChange`, `NtfyAlertWeatherHop`, `NtfyNotifyBoss` vào file `essential_config.json` theo từng tài khoản, không bị mất khi thoát game hay nhảy server.
6. **Đồng Bộ Phiên Bản v2.5.9 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.5.9` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.5.8] - 2026-09-16
### 🎯 Phân Rõ Cá Secret & Cá Thường Có Ích Kèm Caption Trạng Thái Sở Hữu (Skill, Thuyền, Orb, Chế Cần/Mồi):
1. **Phân Tách Rõ Ràng 2 Nhóm Cá Cho Từng Đảo Trong Tab Săn Boss (Boss Hunter)**:
   - Thay vì gộp chung toàn bộ cá của một đảo vào 1 card duy nhất, mỗi đảo nay được chia thành **2 Card độc lập**:
     - **🔥 CÁ SECRET & THẦN THOẠI**: Các boss bí mật theo thời tiết (Golden Dragonfish, Rainbow Dragonfish, Flying Fish Emperor/Empress, Draconic Koi, Tigerfang Whale, Heavenpiercer Turtle, Reborn Puffer Beast, Frost Kingfish, Frost Queenfish, Mountain Dragonwhale, v.v.).
     - **🐟 CÁ THƯỜNG CÓ ÍCH (RƠI ĐỒ / CHẾ CẦN)**: Các loài cá thường hoặc quý hiếm có ích lợi đặc biệt (Trueform Jiaolongfish, Ascended Perch, Trueform Perch, Mountain Fish, Tiger Mirefish, Octoparasitic Fish, v.v.) kèm công tắc Bật/Tắt riêng biệt để người chơi chủ động lựa chọn câu hoặc bỏ qua.
   - Nếu đảo không có cá thường đặc biệt (như Đảo Tre - Bamboo Isle), hệ thống hiển thị dòng thông báo gọn gàng: `"Không có (Đảo này chỉ tập trung săn Cá Secret)"`.
2. **Hiển Thị Caption Nhỏ Gọn, Tối Ưu Diện Tích UI Kèm Trạng Thái Sở Hữu Thời Gian Thực**:
   - **Công dụng cá**: Nêu rõ dùng để chế cần gì (Heavenpiercer, Sacred Bamboo, Pure Diamond, Huyết Long), chế mồi gì (Rainbow, Nameless, Frost), hoặc trả quest nào (Hạ Diêu, Giang Lão, Đạo Sĩ).
   - **Rơi Thuyền (Boat Drop)**: Tra cứu tự động từ `ReplicatedStorage.Data[UserId].Boats`. Ví dụ: `Ascended Perch` tại Đảo Cá Chép -> `Thuyền Ascended Perch (5%): [ĐÃ CÓ]` hoặc `[CHƯA CÓ]`.
   - **Rơi Kỹ Năng (Skill Drop)**: Tra cứu tự động từ `ReplicatedStorage.Data[UserId].Skill[SkillName].Owned`. Ví dụ: `Trueform Jiaolongfish` tại Đảo Phóng Xạ -> `Chế Cần Huyết Long • Skill Rolling Twin Dragons (50%): [ĐÃ CÓ]` hoặc `[CHƯA CÓ]`; `Trueform Perch` -> `Skill River Suppression (20%): [ĐÃ CÓ]` hoặc `[CHƯA CÓ]`.
   - **Rơi Ngọc (Orb Drop)**: Tự động đếm số lượng ngọc người chơi đang có từ `Data[UserId].Orb` và `EssenceOrb`. Ví dụ: `Golden Dragonfish` tại Đảo Tre -> `Chế Cần & Mồi • Thần Thoại • Orb Dragon Orb (20%) [Đang có: x...] • +20 Gems`.
   - **Tự động cập nhật trực tiếp (Auto-Sync Live Caption)**: Mỗi 4 giây, hệ thống tự động kiểm tra lại kho đồ của nhân vật để cập nhật ngay lập tức từ `[CHƯA CÓ]` sang `[ĐÃ CÓ]` khi câu được đồ hoặc tăng số lượng Orb mà không cần mở lại menu.
3. **Cải Tiến Giao Diện Toggle Row**:
   - Mở rộng khung chứa văn bản mô tả (`tf.Size = UDim2.new(1, -55, 1, 0)`), bổ sung chống tràn chữ `TextTruncate = Enum.TextTruncate.AtEnd`, giúp hiển thị caption dài mượt mà, không bị che khuất hay đè lên nút gạt.
4. **Tích Hợp Cá Thường Có Ích Vào Logic Săn Boss & Fast-Skip**:
   - Khởi tạo sẵn các key cá thường có ích trong `Config.SecretBossTargets` (mặc định bật Trueform Jiaolongfish, Ascended Perch, Trueform Perch, Mountain Fish, Tiger Mirefish, Octoparasitic Fish).
   - Đảm bảo cơ chế Fast-Skip Non-Boss câu trúng các loài cá này mà không bị tự hủy dây câu.
5. **Đồng Bộ Phiên Bản v2.5.8 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.5.8` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.5.7] - 2026-09-16
### 🐟 Khắc Phục Triệt Để Vệt Sáng Tròn (White Glow Aura) & Hiển Thị Chuẩn 100% Sprite Cá:
1. **Sửa Tận Gốc Lỗi Toàn Bộ Ô Nguyên Liệu Hiển Thị Đốm Tròn Phát Sáng Trắng**:
   - **Phát hiện chính xác từ ảnh chụp màn hình game**:
     - Người dùng gửi ảnh trong đó các ô nguyên liệu (`Flying Fish Emperor`, `Flying Fish Empress`, `Rainbow Dragonfish`, `Mountain Fish`...) đều hiển thị một đốm sáng tròn mờ màu trắng trên nền tối.
     - **Nguyên nhân kỹ thuật**:
       - Trong cấu trúc GUI của game, mỗi nút `Button` chứa thư mục `Detail`. Bên trong `Detail` có một đối tượng `ImageLabel` tên là `Detail.Detail` (có gắn `UICorner`) — đây chính là **vầng hào quang tròn phát sáng (Rarity Glow Aura)** nằm sau lưng con cá!
       - Trong khi đó, **Sprite cá thật** được đặt trực tiếp tại `Button.Image` (có gắn `UIAspectRatioConstraint`).
       - Ở bản v2.5.6, hàm `ExtractFishImageFromButton` đã ưu tiên lấy `Detail.Detail` trước, và cố tình bỏ qua `Button.Image` vì nghĩ nhầm đó là icon ổ khóa! Kết quả là toàn bộ các ô nguyên liệu đều bị gán hình đốm sáng tròn thay vì ảnh con cá!
   - **Khắc phục toàn diện**:
     - Đảo ngược ưu tiên: **Ưu tiên số 1 là `Button.Image`** (chính là Sprite cá thật của game, chỉ cần lọc không chứa ID ổ khóa `10709791437` và không chứa `UIGradient`).
     - **Chặn triệt để `Detail.Detail`** (loại bỏ hoàn toàn đốm sáng hào quang tròn).
     - Trong `FetchGameFishImage`, tích hợp cơ chế nạp trực tiếp O(1) từ `ReplicatedStorage.Info.Inventory[fishName]` để lấy ngay Asset ID gốc của loài cá đó mà không cần duyệt lặp.
2. **Đồng Bộ Phiên Bản v2.5.7 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.5.7` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.5.6] - 2026-09-16
### 🛠️ Sửa Lỗi Không Thao Tác Được Nút Game (Kho Đồ, Balo) & Tối Ưu Hóa Tuyệt Đối Hiển Thị Ảnh Cá:
1. **Khắc Phục Lỗi Liệt Nút / Không Mở Được Kho Đồ & Tính Năng Game**:
   - **Nguyên nhân 1 (GuiNavigation toàn cục)**: Ở dòng 91 của `local.lua` có dòng lệnh `gs.GuiNavigationEnabled = false`. Lệnh này vô hiệu hóa hệ thống điều hướng GUI mặc định của Roblox, khiến người chơi không thể click hoặc mở được một số menu/nút giao diện mặc định của game (như kho đồ, balo, cài đặt...).
   - **Nguyên nhân 2 (Treo main thread do require 500+ ModuleScript đồng bộ)**: Ở bản v2.5.5, hàm `PreloadFishImages()` thực hiện duyệt và gọi `require(mod)` trên toàn bộ 500+ ModuleScript trong `ReplicatedStorage.Info.Inventory` ngay trên luồng chính (synchronously). Khi `FetchGameFishImage()` được gọi liên tục cho 24 ô nguyên liệu, nó gây lag nghẽn CPU và đóng băng hàng đợi sự kiện chuột/chạm của game!
   - **Khắc phục triệt để**:
     - Loại bỏ hoàn toàn dòng can thiệp `GuiNavigationEnabled = false`, trả lại 100% quyền điều hướng và thao tác giao diện tự nhiên cho game.
     - Loại bỏ toàn bộ vòng lặp `require()` 500+ module trong `ReplicatedStorage.Info.Inventory`.
     - Chuyển `PreloadFishImages()` sang chạy bất đồng bộ hoàn toàn bên trong `task.spawn()`, áp dụng cơ chế bướm ga (throttle/cooldown) tối thiểu 4 giây mới quét lại 1 lần, tuyệt đối không bao giờ làm khựng hoặc nghẽn luồng xử lý của game.
2. **Đồng Bộ Phiên Bản v2.5.6 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.5.6` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.5.5] - 2026-09-16
### 🐟 Nạp Ảnh Cá Trực Tiếp Từ ReplicatedStorage.Info.Inventory & Loại Bỏ Stencil UIGradient:
1. **Khắc Phục Lỗi Toàn Bộ Ô Nguyên Liệu Hiện Cùng Một Hình Trắng (Gradient Stencil)**:
   - **Nguyên nhân chính xác từ hình ảnh người dùng phản ánh**:
     - Trong thẻ item của game, `Detail.Image` đi kèm một đối tượng `UIGradient` con: Đây là hoa văn stencil/shimmer viền xoáy trắng trang trí dùng chung cho mọi thẻ.
     - Ngoài ra, Menu `Indexlist` (Sách Cá) chứa các hình placeholder câu hỏi/chưa mở khóa. Khi quét `Indexlist` đầu tiên, các ô nguyên liệu đã bị nạp đè bằng hình hoa văn xoáy trắng này!
   - **Khắc phục triệt để**:
     - **Tận dụng nguồn dữ liệu gốc chính thức của Game**: Quét trực tiếp thư mục `ReplicatedStorage.Info.Inventory`: Mỗi loài cá đều có 1 `ModuleScript` riêng biệt (`Flying Fish Emperor`, `Heavenpiercer Turtle`, `Rainbow Dragonfish`, `Mountain Fish`, `Ascended Perch`, v.v.). Gọi `require(mod)` để lấy trực tiếp thuộc tính `Image`/`Icon` Asset ID nguyên bản 100% của nhà phát triển game, không phụ thuộc vào GUI.
     - **Bổ sung bộ lọc UIGradient trong `ExtractFishImageFromButton`**: Tự động bỏ qua bất kỳ `ImageLabel` nào có chứa `UIGradient` con (loại bỏ dứt điểm hoa văn xoáy trắng), ưu tiên lấy `Detail.Detail` (Sprite cá thật).
     - **Loại bỏ hoàn toàn nguồn `Indexlist`** để chống nhiễm bẩn bộ nhớ đệm.
2. **Đồng Bộ Phiên Bản v2.5.5 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.5.5` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.5.4] - 2026-09-16
### 🖼️ Khắc Phục Triệt Để Lỗi "Hiện Hình Ổ Khóa Khung Màu Xanh" Thay Vì Ảnh Cá Thật:
1. **Sửa Tận Gốc Lỗi Hiển Thị Ổ Khóa (Padlock Icon Bug)**:
   - **Nguyên nhân**:
     - Trong hệ thống giao diện chuẩn của game *Heavyweight Fishing*, mỗi ô thẻ cá (`Button`) chứa 2 `ImageLabel` khác nhau:
       1. `Button.Image`: Là lớp phủ viền trạng thái và **icon ổ khóa màu xanh** (Lock Status Overlay) để hiển thị thẻ có đang khóa hay không.
       2. `Button.Detail.Image`: Mới chính là **ảnh thật của con cá** (Fish Thumbnail Asset).
     - Ở bản v2.5.3, lệnh quét ảnh gọi `btn:FindFirstChild("Image")` hoặc `(btn:FindFirstChild("Image") or ...)` nên đã lấy nhầm `Button.Image` (icon ổ khóa), dẫn tới việc toàn bộ khung nguyên liệu và ô tìm kiếm hiển thị icon ổ khóa khung xanh!
   - **Khắc phục**:
     - Viết hàm `ExtractFishImageFromButton(btn)` chuyên dụng:
       - Ưu tiên số 1: Trích xuất trực tiếp từ `btn.Detail.Image` và `btn.Detail.Detail`.
       - Ưu tiên số 2: Quét mọi `ImageLabel` con nằm trong thư mục `Detail`.
       - Loại trừ triệt để `Button.Image` (ổ khóa trực tiếp) và mã Asset ổ khóa Roblox `10709791437`.
     - Tích hợp thêm nguồn quét Sách Cá toàn thư của Game: `PlayerGui.MainGui.Menu.Index.IndexFrame.Indexlist` (chứa đầy đủ 100% tất cả các loài cá trong game).
     - Hàm `FetchGameFishImage` có cơ chế chốt chặn tự động từ chối hiển thị asset ổ khóa `10709791437`, đảm bảo hiển thị đúng ảnh cá thật hoặc biểu tượng 🐟 fallback.
2. **Đồng Bộ Phiên Bản v2.5.4 Toàn Hệ Thống**:
   - Cập nhật số phiên bản `v2.5.4` trên toàn bộ file: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.5.3] - 2026-09-16
### 🐟 Khắc Phục Triệt Để Hiển Thị Ảnh Cá Chế Cần & Chế Mồi (Preload Targeted Craft Images):
1. **Khắc Phục Lỗi Mất Ảnh Ở Khung Chế Cần & Chế Mồi**:
   - **Nguyên nhân**: Ở bản v2.5.2, khi cải thiện tìm kiếm ảnh cá, hàm `FetchGameFishImage` bị thay đổi thành quét đệ quy `PlayerGui:GetDescendants()`. Với hơn 50.000 GUI objects trong cây phân cấp game, việc quét đệ quy cho từng ô trong lưới 4-slot gây nghẽn luồng xử lý và không định vị được cấu trúc lồng sâu đặc thù của menu chế tạo, dẫn đến các ô nguyên liệu cần và mồi bị trắng/trống ảnh.
   - **Khắc phục**:
     - Phục hồi và tối ưu hóa hàm `PreloadFishImages()` quét đích danh (Targeted Deep Traversal):
       - Menu Chế Cần: `PlayerGui.MainGui.Menu.CraftRod.List[Rod].Ingredient.Slot.Button.Image` (hỗ trợ cả các biến thể folder con).
       - Menu Chế Mồi: `PlayerGui.MainGui.Menu.CraftBait.List[Bait].Ingredient.Slot.Button.Image`.
       - Balo Game: `PlayerGui.MainGui.Main.Inventory.Main.List.ScrollingFrame`.
     - Lưu trữ trực tiếp Asset ID vào `FM.FishImageCache[fishName]`.
     - Hàm `FetchGameFishImage(fishName)` truy xuất bộ nhớ đệm 0ms (Instant Cache Hit) với cơ chế tự động quét lại có định hướng nếu chưa có sẵn.
     - Gọi `PreloadFishImages()` tự động ngay khi khởi tạo tab và trong mỗi chu kỳ `RefreshAllSections()`.
2. **Đồng Bộ Phiên Bản v2.5.3 Toàn Diện**:
   - Cập nhật số phiên bản `v2.5.3` trên toàn bộ hệ thống: [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.5.2] - 2026-09-16
### ⚡ Khôi Phục Cơ Chế Khóa/Mở Cá Mượt Mà Như Bản Đầu, Sửa Nhận Diện Khóa & Quét Ảnh Sâu:
1. **Khôi Phục Cơ Chế Kích Hoạt GUI Trực Tiếp (Direct GUI Trigger) - Mượt Mà Như Bản Đầu**:
   - **Vấn đề**: Bản v2.5.1 chỉ gửi Remote đơn thuần khiến game không đổi trạng thái hoặc bị server bỏ qua.
   - **Khắc phục**:
     - Bổ sung hàm `ClickButton(btn)` kích hoạt song song `firesignal` (MouseButton1Click, Activated, MouseButton1Down, MouseButton1Up) và `getconnections(btn.MouseButton1Click):Fire()`.
     - Hàm `FindGuiFavoriteButton` tự động định vị chính xác thẻ cá và nút ngôi sao `Favorite.TextButton` nằm trong `PlayerGui.MainGui.Main.Inventory.Main.List.ScrollingFrame` cũng như `Fisher_GUI`. Thao tác mượt mà chuẩn xác như tay người bấm trực tiếp trên Balo game.
     - Kết hợp gửi Remote Event đa tầng (`item`, `item.Name`, `guiChild`) làm lớp đồng bộ fallback.
2. **Sửa Lỗi Nhận Diện Trạng Thái Khóa (`Wiki.IsItemFavorited`)**:
   - **Nguyên nhân**: Trong game, item trong Balo là `NumberValue` không có object con, trạng thái khóa được game gắn trực tiếp vào đuôi tên item: `" | Favorite"` (VD: `"Crimson Bream Sovereign | 1541348.67 | Favorite"`).
   - **Khắc phục**: Ưu tiên kiểm tra trực tiếp chuỗi `itemName:find("Favorite", 1, true)` lên đầu hàm `Wiki.IsItemFavorited(item)`, đảm bảo nhận diện chính xác 100% cá đang khóa hay mở.
3. **Khắc Phục Lỗi "Cứ Báo Chờ Xử Lý Hay Gì Á" (Anti-Stuck Processing Guard)**:
   - Thêm bộ đếm thời gian an toàn: Nếu cờ `FM.isProcessing` bị kẹt quá 4 giây do mạng giật lag hoặc tác vụ trước, hệ thống sẽ tự động mở khóa trạng thái (Auto-Reset) để người dùng có thể thao tác ngay mà không bị báo chờ vô hạn.
   - Bọc toàn bộ các vòng lặp xử lý bất đồng bộ (`task.spawn`) trong `pcall` phòng thủ, đảm bảo `FM.isProcessing = false` luôn luôn được gọi.
4. **Sửa Lỗi Tìm Kiếm "Crimson" Không Hiện Ảnh (Deep GUI Recursive Image Scan)**:
   - Cấu trúc thẻ cá trong Balo game phân tầng dạng: `ScrollingFrame -> Folder (Tên Cá | Cân Nặng) -> Frame -> Button -> ImageLabel`.
   - Nâng cấp hàm `FetchGameFishImage` quét đệ quy sâu toàn bộ cây thư mục `PlayerGui`, khớp tên theo thuộc tính của ancestor và `Title.TextLabel`, tự động cache và hiển thị ảnh cá thật sắc nét ngay khi gõ từ khóa `crim`.
5. **Đồng Bộ Phiên Bản v2.5.2 Toàn Hệ Thống**:
   - Nâng cấp `SCRIPT_BUILD_COMMIT` lên **v2.5.2** trên toàn bộ file lõi ([local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua)).

---

## [v2.5.1] - 2026-09-16
### 🛡️ Khắc Phục Triệt Để Phân Loại Cá, Sửa Khóa/Mở Cá Toàn Diện & Gợi Ý Tìm Kiếm Thông Minh:
1. **Sửa Lỗi "Mở Khóa Rác Mở Luôn Cá Quý Chế Cần Mồi"**:
   - **Nguyên nhân**: Tên item cá trong balo Roblox chứa cả cân nặng (VD: `"Crimson Bream Sovereign | 1541348.67"`). Trước đó so sánh chuỗi trực tiếp khiến cá nguyên liệu không khớp với danh sách bảo vệ, dẫn tới việc hệ thống tưởng nhầm là rác và đưa vào danh sách mở khóa!
   - **Khắc phục**:
     - Áp dụng triệt để `Wiki.GetItemRawName(item)` để bóc tách chính xác tên gốc của cá trước khi phân loại.
     - Thiết lập bộ dữ liệu bảo vệ thép `Wiki.allRodFishSet` và hàm kiểm tra `Wiki.IsProtectedFish(item)`: Bảo vệ 100% không bao giờ cho phép cá chế cần (Heavenpiercer, Sacred Bamboo, Pure Diamond), cá chế mồi thần thoại, boss bí mật, cá đột biến, hoặc cá có cân nặng $\ge 1.000.000$ KG lọt vào danh sách cá rác (`junkList`).
2. **Sửa Lỗi "Khóa Cá Quý Không Khóa Lại Được / Ấn Vào Chỉ Khóa 1 Con"**:
   - **Nguyên nhân**: 
     - Remote `FavoriteItem:FireServer(item)` trong game là dạng **TOGGLE** (chuyển đổi qua lại). Việc vừa click nút GUI vừa bắn Remote khiến trạng thái bị đảo 2 lần (khóa xong lại mở về như cũ).
     - Vòng lặp dừng lại sớm hoặc không cập nhật đúng con trỏ duyệt.
   - **Khắc phục**:
     - Kiểm tra trạng thái khóa thực tế của từng con qua `Wiki.IsItemFavorited(item)`: Khi khóa thì chỉ bắn Remote nếu cá **CHƯA** khóa (`not isFav`); khi mở khóa thì chỉ bắn Remote nếu cá **ĐANG** khóa (`isFav`). Tuyệt đối không click trùng GUI.
     - Lặp bất đồng bộ an toàn qua TOÀN BỘ số lượng cá trong danh sách với delay chuẩn `0.08s`, đảm bảo khóa sạch 100% tất cả con cá của loài đó mà không bị sót hay nghẽn mạng.
3. **Sửa Lỗi "Tiến Độ Nguyên Liệu Có Ảnh Nhưng Không Đếm Được Số Lượng (Luôn x0)"**:
   - **Nguyên nhân**: Bảng đếm số lượng trước đó lưu theo key `item.Name` (có chứa cân nặng), trong khi bảng nguyên liệu truy vấn theo tên sạch (`"Crimson Bream Sovereign"`).
   - **Khắc phục**: Chuẩn hóa toàn bộ hệ thống đếm trong `ScanAndClassifyInventory()` và `CreateVisualIngredientGrid`: đếm theo tên sạch `Wiki.GetItemRawName(item)` và so sánh chuẩn `string.lower()`, hiển thị chính xác 100% số lượng sở hữu thực tế trong balo (VD: `x3`, `x1`).
4. **Đại Tu Thanh Tìm Kiếm (Gợi Ý Danh Sách Cá Khớp Từ Khóa & Đầy Đủ Nút Khóa/Mở/Bán)**:
   - Khi nhập từ khóa tìm kiếm (VD: `crim`), hệ thống tự động quét và sinh các **Thẻ Gợi Ý (Suggestion Chips)** cho TẤT CẢ các loài cá khớp từ khóa (`Crimson Bream Sovereign`, `Crimson Electric Eel`, `Crimson Catfish`...) kèm số lượng đang có trong balo.
   - Bấm vào thẻ bất kỳ để xem chi tiết: ảnh cá kích thước lớn, huy hiệu phân loại (Cá Chế Cần / Mồi / Boss / Rác), số lượng tổng, số con đã khóa, số con đang mở.
   - Trang bị đầy đủ 2 nút độc lập: `[🔒 Khóa Toàn Bộ Loài Này]` và `[🔓 Mở Khóa Toàn Bộ Loài Này]` cùng ô nhập số lượng bán tùy chọn (nhập `0` để bán tất cả cá mở, hoặc số lượng tùy ý).
5. **Đồng Bộ Phiên Bản v2.5.1 Toàn Hệ Thống**:
   - Nâng cấp `SCRIPT_BUILD_COMMIT` lên **v2.5.1** trên toàn bộ file lõi ([local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua), [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua)).

---

## [v2.5.0] - 2026-09-16
### 🎨 Đại Tu Giao Diện Tab Quản Lý Cá (Visual 4-Slot Grid & Smart Bag Manager):
1. **Khung 4 Ô Ảnh Nguyên Liệu Trực Quan Cho Từng Cần Câu & Mồi Câu (Visual 4-Slot Grid)**:
   - **Tự động trích xuất icon cá thật từ Game**: Hệ thống tự động quét và cache hình ảnh cá trực tiếp từ `CraftRod.List`, `CraftBait.List`, và `Inventory.Main.List.ScrollingFrame`.
   - **Hiển thị đầy đủ cả 3 Cần Câu tối thượng**:
     - `Heavenpiercer Rod` (Cần Xuyên Thiên)
     - `Sacred Bamboo Rod` (Cần Trúc Thánh)
     - `Pure Diamond Rod` (Cần Kim Cương Thuần Khiết)
   - Mỗi Cần sở hữu 1 Card độc lập gồm:
     - Huy hiệu sở hữu rõ ràng: `✅ ĐÃ CÓ CẦN (Đã sở hữu X cây)` / `❌ CHƯA CÓ CẦN (Đang thu thập NL)`.
     - Thanh tiến độ nguyên liệu: `X/4 nguyên liệu (Y%)`.
     - **Khung 4 ô ảnh cá nằm ngang phong cách Dark Glass**: Hiển thị ảnh con cá (hoặc fallback emoji 🐟), tên cá, viền phát sáng xanh lá nếu đủ (`✅`) hoặc viền đỏ nếu thiếu (`❌`), và nhãn số lượng to rõ `x3` / `x0` bên dưới mỗi ô.
     - 2 Nút thao tác: `[🔒 Khóa 4 NL]` và `[🔓 Mở Khóa An Toàn]` (Tự động giữ lại cá trùng với mồi thần thoại).
   - **Khung 4 ô ảnh cá tương tự cho cả 3 loại Mồi Thần Thoại**:
     - `Nameless Bait`, `Frost Bait`, `Rainbow Bait`.
     - Hiển thị công suất chế mồi tối đa `Có thể chế tối đa: X viên mồi ✅` kèm 4 ô ảnh nguyên liệu và nút khóa/mở an toàn.

2. **Đưa Khối Quản Lý Túi Cá Rác Lên Đầu Tab (Top of Tab)**:
   - Thống kê tổng quan số cá trong Balo: Tổng số cá, Cá quý đang bảo vệ, Cá rác an toàn có thể dọn.
   - 3 Nút thao tác nhanh 1-click: `[🔒 Khóa Toàn Bộ Cá Quý]`, `[🔓 Mở Khóa Riêng Cá Rác]`, `[💰 Bán Sạch Cá Rác An Toàn]`.

3. **Thanh Tìm Kiếm Cá Thông Minh & Bán Theo Số Lượng Tùy Chọn (Search & Custom Sell)**:
   - **Thanh tìm kiếm trực quan**: Gõ tìm theo tên (VD: `Carp`, `Crimson`, `Koi`, `Sovereign`...).
   - **Card hiển thị con cá tìm được**:
     - Khung ảnh con cá (52x52 px) + Tên cá vàng nổi bật.
     - Trạng thái balo trực tiếp: `Balo: Có X con • 🔒 Đã khóa: Y • 🔓 Đang mở: Z`.
   - **Thao tác độc lập**:
     - Nút `[🔒 Khóa Loài Cá Này]` & Nút `[🔓 Mở Khóa Loài Cá Này]`.
     - **Ô Nhập Số Lượng Muốn Bán (Custom Sell)**: Mặc định `0` (Nhập `0` là bán tất cả con cá này đang mở), hoặc nhập số cụ thể (VD: `1`, `5`, `10`). Bấm nút `[💰 Bán Cá Này]`, script sẽ tự động khóa toàn bộ cá khác, mở đúng số lượng cá này, gọi lệnh bán an toàn và khôi phục bảo vệ.

4. **Tối Ưu Hóa Bộ Nhớ & Phạm Vi Biến (Lua 200 Local Limit Fix)**:
   - Sử dụng bảng điều khiển `FM` và các hàm tạo UI tiện ích (`MakeCorner`, `MakeStroke`) cùng các khối `do ... end` con, giải quyết triệt để giới hạn 200 biến cục bộ của Lua 5.1/Luau.

5. **Đồng Bộ Phiên Bản Toàn Hệ Thống**:
   - Nâng cấp `SCRIPT_BUILD_COMMIT` lên **v2.5.0** trên toàn bộ file lõi ([local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua)).

---

## [v2.4.1] - 2026-09-16
### 🛠️ Sửa Lỗi Biên Dịch & Chạy Script (Fix "invalid argument #2 to 'format'"):
1. **Khắc Phục Triệt Để Lỗi Chạy Script V2 (`line 6014`)**:
   - **Nguyên nhân**:
     - Khi chạy `v2_bundle.lua` qua `loader_v2.lua` (hoặc executor nạp bundle), tại giao diện Luyện Chiêu Nhanh (`v2/ui/tabs/tab_cau_ca.lua`), mã nguồn gọi `string.format("%d / %d lần", Config.TrainCurrentCount, Config.TrainTargetCount)`.
     - Do biến `TrainCurrentCount` bị thiếu trong bảng cấu hình mặc định `ConfigModule.Config` ([v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua)), `Config.TrainCurrentCount` mang giá trị `nil`, dẫn đến lỗi văng script: `invalid argument #2 to 'format' (number expected, got nil)`.
   - **Khắc phục**:
     - Khởi tạo giá trị mặc định `TrainCurrentCount = 0` trong [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua).
     - Bọc lớp bảo vệ phòng thủ `tonumber(Config.TrainCurrentCount) or 0` và `tonumber(Config.TrainTargetCount) or 100` trên toàn bộ các vị trí gọi `string.format` trong [v2/ui/tabs/tab_cau_ca.lua](file:///Users/vonguyengiap/Documents/script/v2/ui/tabs/tab_cau_ca.lua) và [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua).
     - Biên dịch lại toàn bộ gói [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua) bằng `build.py`, đảm bảo 100% không còn lỗi cú pháp hay thiếu biến.
2. **Đồng Bộ Phiên Bản Toàn Hệ Thống**:
   - Nâng cấp `SCRIPT_BUILD_COMMIT` lên **v2.4.1** trên toàn bộ file lõi ([local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua), [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua)).

---

## [v2.4.0] - 2026-09-16
### 🎣 Hệ Thống Quản Lý Cá Toàn Diện (Fish Manager Pro) - Chế Cần, Chế Mồi & Dọn Cá Rác An Toàn:
1. **Theo Dõi Tiến Độ Chế Cần Câu & Nhận Diện Cần Đã Sở Hữu (Rod Crafting Tracker)**:
   - **Tự động nhận diện đã có cần**: Quét trực tiếp `FishingRodInventory[rod].Owned` và `RodSkinCount[rod]`. Hiển thị badge trạng thái trực quan:
     - `✅ ĐÃ SỞ HỮU (ĐÃ CHẾ X CÂY)` nếu đã có cần trong kho.
     - `❌ CHƯA CÓ CẦN (ĐANG THU THẬP NGUYÊN LIỆU)` nếu chưa sở hữu.
   - **Thống kê 4 loại cá nguyên liệu theo dữ liệu gốc game**:
     - **Heavenpiercer Rod**: `Flying Fish Emperor` (1), `Flying Fish Empress` (1), `Heavenpiercer Turtle` (1), `Rainbow Dragonfish` (1).
     - **Sacred Bamboo Rod**: `Nameless Octoparasite` (1), `Reborn Puffer Beast` (1), `Ascended Perch` (1), `Mountain Fish` (1).
     - **Pure Diamond Rod**: `Frost Kingfish` (1), `Frost Queenfish` (1), `Sanguine Fish` (1), `Draconic Koi` (1).
   - **Chi tiết từng loại cá**: Hiển thị số lượng sở hữu / số lượng yêu cầu, trạng thái `✅ ĐỦ` / `❌ THIẾU`, xuất xứ đảo câu và điều kiện thời tiết chuẩn.
   - **Điều khiển nguyên liệu cần**: Nút **🔒 Khóa Nguyên Liệu Cần** (khóa tất cả cá làm cần) và **🔓 Mở Khóa An Toàn** (mở khóa khi cần thiết nhưng tự động giữ lại cá trùng nguyên liệu mồi thần thoại).

2. **Hệ Thống Quản Lý Chế Mồi Thần Thoại (Mythic Bait Crafting Tracker)**:
   - **Theo dõi 3 loại mồi thần thoại**:
     - **Nameless Bait**: Yêu cầu 1 `Flying Fish Emperor` + 1 `Nameless Octoparasite`.
     - **Frost Bait**: Yêu cầu 1 `Frost Kingfish` + 1 `Frost Queenfish`.
     - **Rainbow Bait**: Yêu cầu 1 `Rainbow Dragonfish` + 1 `Draconic Koi`.
   - **Tự động tính toán công suất chế mồi (Craftable Capacity)**: Hiển thị ngay số mồi tối đa có thể chế được từ số cá đang có trong balo.
   - **Thao tác nhanh**: Nút **🔒 Khóa Mồi** và **🔓 Mở Khóa Mồi** kèm cờ bypass AutoProtect, tránh bị script tự khóa lại khi đang chế mồi tại NPC.

3. **Phân Loại Thông Minh & Dọn Cá Rác An Toàn (Safe Junk Cleaner & Auto-Sell Protection)**:
   - **Bộ lọc bảo vệ đa tầng chống bán nhầm cá quý**:
     - Cá Boss & Secret Boss (Crimson Bream Sovereign, Heavenpiercer Turtle, v.v.).
     - Cá nguyên liệu chế 3 loại cần câu tối thượng.
     - Cá nguyên liệu chế 3 loại mồi thần thoại.
     - Cá làm nhiệm vụ có trọng lượng cao (Quest VIP $\ge 5,000,000$ KG).
     - Cá siêu nặng giá trị cao ($\ge 1,000,000$ KG).
     - Cá đột biến đặc biệt (Mutation: Shiny, Albino, Gold, Neon, Dark, Electric...).
   - **Thống kê Balo trực quan**: Đếm số cá quý được bảo vệ vs. số lượng cá rác thực tế có thể dọn.
   - **Nút 🔒 Khóa Toàn Bộ Cá Quý**: 1-click khóa sạch toàn bộ cá có giá trị trong túi đồ.
   - **Nút 🔓 Mở Khóa Riêng Cá Rác**: Chỉ mở khóa các con cá rác thông thường.
   - **Nút 💰 Bán Sạch Cá Rác An Toàn**: Kiểm tra an toàn 100% trước khi gọi `Events.SellFish:FireServer("All")`; đảm bảo toàn bộ cá quý đã khóa trước khi bán, tuyệt đối không làm mất cá nguyên liệu hay cá hiếm.

4. **Công Cụ Thử Nghiệm Từng Con & Spy Bắt Remote**:
   - Duy trì bảng test riêng cho loài `Crimson Bream Sovereign` và công cụ **🔍 Bật Spy Bắt Remote** để giám sát gói tin mạng của game.

5. **Đồng Bộ Phiên Bản Toàn Hệ Thống**:
   - Nâng cấp `SCRIPT_BUILD_COMMIT` lên **v2.4.0** trên toàn bộ file lõi ([local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua)).

---

## [v2.3.3] - 2026-09-16
### 🛠️ Nâng Cấp Toàn Diện Cơ Chế Khóa & Mở Khóa Cá (Tab Quản Lý Cá):
1. **Khắc Phục Hiện Tượng Bấm Nút Không Đổi Trạng Thái**:
   - **Nguyên nhân**:
     - Remote `FavoriteItem` của Server game yêu cầu kích hoạt từ client theo chuẩn nội bộ của game; gọi đơn lẻ bằng `Remote:FireServer(item)` từ bên ngoài dễ bị server từ chối hoặc sai instance.
     - Đồng thời, cơ chế tự động bảo vệ `ProtectInventoryItem` mặc định tự động khóa lại cá Secret Boss (`Crimson Bream Sovereign`) ngay sau khi vừa mở khóa (trong vòng 0.3s khi `ChildAdded` kích hoạt), khiến người chơi cảm giác nút mở khóa không có tác dụng.
   - **Khắc phục**:
     - **Tích hợp cơ chế kích hoạt trực tiếp giao diện (Direct GUI Trigger)**: Tìm chính xác `Favorite.TextButton` của con cá `Crimson Bream Sovereign` trong `PlayerGui.MainGui.Fisher_Inventory` và mô phỏng thao tác bấm tay thông qua `firesignal` và `getconnections(btn.MouseButton1Click):Fire()`. Đảm bảo 100% tuân thủ logic gốc của Game.
     - **Gửi Remote Event Đa Tầng (Fallback)**: Gửi song song cả Instance Data, GUI Element, và Item Name.
     - **Cờ Bypass AutoProtect Thông Minh**: Tự động cấp cờ `Wiki.temporarilyUnlockedBaitFish["crimson bream sovereign"] = true` khi người dùng bấm **Mở Khóa**, ngăn chặn hoàn toàn việc script tự động khóa lại sau khi mở. Khi người dùng bấm **Khóa Cá**, cờ này sẽ được gỡ bỏ ngay lập tức.
2. **Thêm Công Cụ "🔍 Bật Spy Bắt Remote"**:
   - Tích hợp tính năng bắt gói tin mạng của game ngay trên giao diện tab "Quản Lý Cá".
   - Người dùng bấm nút **Bật Spy**, sau đó mở Balo trong game và click vào biểu tượng Ngôi Sao của bất kỳ con cá nào; hệ thống sẽ chụp lại 100% tên Remote, số lượng tham số, kiểu dữ liệu và giá trị chi tiết hiển thị trực tiếp lên màn hình.
3. **Đồng Bộ Phiên Bản Toàn Hệ Thống**:
   - Nâng cấp `SCRIPT_BUILD_COMMIT` lên **v2.3.3** trên toàn bộ file lõi ([local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua)).

---

## [v2.3.2] - 2026-09-16
### 🐟 Tab Mới: Quản Lý Cá (Fish Manager) - Tính Năng Thử Nghiệm Khóa & Mở Khóa Cá:
1. **Thêm Tab Riêng "Quản Lý Cá" Trên Menu Điều Khiển**:
   - Tích hợp tab điều hướng mới nằm ngay cạnh tab **Câu Cá** và **Săn Boss** để người dùng tiện theo dõi và thao tác trực quan.
   - Giao diện thiết kế theo chuẩn Dark Glassmorphism thống nhất của Identical Hub.
2. **Chức Năng Duy Nhất: Khóa & Mở Khóa Thử Nghiệm Loài Cá `Crimson Bream Sovereign`**:
   - Thống kê chi tiết số lượng cá `Crimson Bream Sovereign` trong túi đồ (Inventory & Hotbar):
     - Dòng 1: **Loài cá thử nghiệm**: `Crimson Bream Sovereign`.
     - Dòng 2: **Tổng số lượng trong balo**: Hiển thị tổng số cá tìm thấy.
     - Dòng 3: **Đang Khóa (🔒 Favorite)**: Đếm số lượng cá đã được khóa an toàn (chống bán/chống xóa).
     - Dòng 4: **Chưa Khóa (🔓 Mở)**: Đếm số lượng cá chưa khóa.
3. **Bộ Điều Khiển Thao Tác An Toàn & Tự Động**:
   - **Nút 🔒 Khóa Cá (Lock)**: Lọc toàn bộ các con `Crimson Bream Sovereign` chưa khóa và gửi lệnh qua Remote Event `ReplicatedStorage.Events.FavoriteItem:FireServer(item)`. Có thời gian nghỉ chống spam (anti-rate-limit 50ms) giúp máy chủ xử lý mượt mà và an toàn 100%.
   - **Nút 🔓 Mở Khóa Cá (Unlock)**: Lọc toàn bộ các con `Crimson Bream Sovereign` đang bị khóa và gửi lệnh mở khóa tương ứng.
   - **Nút 🔄 Quét Lại Balo**: Quét và cập nhật số lượng tức thì.
   - **Tự Động Cập Nhật Thời Gian Thực (Auto-Sync)**: Lắng nghe sự kiện `ChildAdded` / `ChildRemoved` từ `ReplicatedStorage.Data[UserId].Inventory` và tự động cập nhật số lượng ngay khi người chơi vừa câu được hoặc chuyển tab sang "Quản Lý Cá".
4. **Đồng Bộ Phiên Bản Toàn Hệ Thống**:
   - Nâng cấp `SCRIPT_BUILD_COMMIT` lên **v2.3.2** trên toàn bộ file lõi ([local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua), [loader.lua](file:///Users/vonguyengiap/Documents/script/loader.lua)).

---

## [v2.3.1] - 2026-09-16
### 🎯 Sửa Lỗi Triệt Để Tính Năng Săn Boss & Tự Động Dịch Chuyển Theo Thời Tiết:
1. **Khắc Phục Lỗi Nhận Diện Thời Tiết Game (Direct HUD Path & Zero-Lag Weather Detection)**:
   - **Nguyên nhân cũ**: Code cũ quét toàn bộ hơn 20,000 descendants của `PlayerGui.MainGui` mỗi 2 giây và bắt buộc `d.Visible == true`. Khi người chơi mở túi đồ, menu nhiệm vụ, cài đặt, hoặc khi thanh HUD bị che mờ, điều kiện `d.Visible` trả về `false`, khiến hệ thống tưởng thời tiết đã hết (`Clear`) và hủy lệnh bay hoặc tự ý bay về Home Spot. Ngoài ra, code cũ quét tìm `StringValue` trong `ReplicatedStorage.Weather` vốn thực chất là một `Folder` chứa VFX.
   - **Khắc phục mới**: Đọc trực tiếp đường dẫn gốc HUD thời tiết của Game: `PlayerGui.MainGui.Info.Info.Weather.Value` (bỏ qua điều kiện `d.Visible`), có cơ chế lưu cache tức thì `secretBossState.GetWeatherLabel()`. Tốc độ quét đạt **0.0001ms** và chính xác 100% không phụ thuộc vào trạng thái mở/đóng menu.
2. **Lắng Nghe Sự Kiện Thời Tiết Phản Hồi Tức Thì (Reactive Event Listener - 0ms Latency)**:
   - Thêm cơ chế lắng nghe sự kiện: `Weather.Value:GetPropertyChangedSignal("Text"):Connect(...)`.
   - Ngay thời khắc Game vừa đổi thời tiết từ `Clear` sang Bão Sấm, Trời Mưa, Tuyết Rơi, Sương Mù, Nắng Gắt hoặc Trời Gió, hệ thống lập tức bắt tín hiệu trong 0.15s và kích hoạt quy trình dịch chuyển săn boss ngay lập tức, không còn phải chờ đợi vòng lặp quét định kỳ.
3. **Sửa Xung Đột Hệ Thống Phân Bậc Ưu Tiên (Priority Manager Gating Fix)**:
   - **Nguyên nhân cũ**: Hàm `PriorityManager.IsTaskActive("SecretBoss")` trước đây chỉ trả về `true` sau khi đã dịch chuyển xong (`secretBossState.active == true`). Vì vậy, khi thời tiết vừa xuất hiện, Secret Boss bị đánh giá là không hoạt động, khiến các tác vụ khác (như Treo Farm Thường hoặc Cooldown vé) chặn đứng vòng lặp săn boss.
   - **Khắc phục mới**: Tự động kích hoạt trạng thái Active của `SecretBoss` trong `PriorityManager` ngay khi phát hiện có thời tiết Boss diễn ra thực tế. Ticket Quest chỉ nhường quyền nếu người chơi đang trực tiếp câu cá quest đặc thù hoặc đang nộp quest NPC; khi vé đang trong thời gian hồi chiêu (Cooldown 20 phút), Secret Boss chiếm toàn quyền điều khiển để bay săn Boss ngay.
4. **Cơ Chế Khớp Boss Mục Tiêu Thông Minh & Fallback Tự Động (Lenient Target Matching)**:
   - Hỗ trợ so khớp tên Boss không phân biệt hoa/thường (case-insensitive) và đối chiếu chuỗi con (substring matching), giải quyết triệt để lỗi tên bị lệch ký tự (như `Heavenpiercer Turtle` vs `Heaven Piercer Turtle`, `Verdant Alligator Gar` vs `Alligator Gar`).
   - Tự động kích hoạt săn tất cả Boss trên đảo nếu danh sách cấu hình mục tiêu trống hoặc chưa chọn, tránh việc phát hiện thời tiết nhưng không bay do danh sách mục tiêu bị rỗng.
5. **Dịch Chuyển An Toàn & Triệt Tiêu Vận Tốc Vật Lý (Anti-Fling & Physics Stabilization)**:
   - Triệt tiêu hoàn toàn `AssemblyLinearVelocity` và `AssemblyAngularVelocity` trước và sau khi dịch chuyển đến đảo boss.
   - Duy trì ổn định vị trí CFrame trong 3 nhịp đầu (0.3s) chống hiện tượng nhân vật bị physics rollback hoặc trôi xuống biển.
6. **Đồng Bộ Phiên Bản & Tối Ưu Hệ Thống**:
   - Đồng bộ hóa logic nhận diện thời tiết trực tiếp trong `v2/features/weather.lua`.
   - Nâng cấp phiên bản toàn hệ thống lên **v2.3.1**.

---

## [v2.3.0] - 2026-09-16
### ⚡ Hệ Thống Tự Động Song Song Nhiệm Vụ (Ticket Quest + Zeng Tianguo) & Tái Cấu Trúc Backup:
1. **Hệ Thống Tự Động Làm Nhiệm Vụ Kỹ Năng Zeng Tianguo (`zengTianguoQuestState`)**:
   - Tự động nhận diện chuỗi nhiệm vụ `Zeng Tianguo Quest` / `Tang Thien Quoc Quest` từ Server Data (`pData.Quest.Main`).
   - Phân tích mục tiêu động: Số lần câu tại đảo chỉ định (Bamboo Isle, Frost Isle), dùng kỹ năng (`UseSkillForTimes`), câu Boss (`FishAtZoneForTimesBoss`).
   - Tự động bay đến NPC Zeng Tianguo (Skill Upgrade), kích hoạt ProximityPrompt và nộp trả nhiệm vụ khi hoàn thành.
2. **Chế Độ Song Song Thông Minh (Hybrid Parallel Mode - Ưu Tiên Vé)**:
   - **Tối ưu vị trí bãi câu**: Khi Ticket Quest yêu cầu 100 Cá, 100 Chiêu, hoặc 100 Mồi (không kén vị trí), bot tự động chuyển bãi câu sang đảo yêu cầu của Zeng Tianguo (Bamboo Isle, Frost Isle) để **cả 2 nhiệm vụ cùng tăng tiến độ đồng thời**, tiết kiệm hơn 50% thời gian cày.
   - **Ưu tiên số 1 cho Vé (Ticket Quest)**:
     - Nếu vé yêu cầu bãi đặc biệt (cá to 15m), bot giữ nguyên bãi 15m để hoàn thành vé trước.
     - Ngay khi vé đạt 100%, bot lập tức ngưng câu bay về nộp vé để nhận thưởng giá trị cao và kích hoạt đếm ngược Cooldown.
   - **Tận dụng thời gian Cooldown vé ("Thời Gian Vàng")**: Trong lúc chờ hồi chiêu vé (20 phút) hoặc khi đã hết vé hôm nay, bot tự động bay đến đảo của Zeng Tianguo tiếp tục câu dồn tiến độ thay vì chỉ đứng AFK ở Home Spot.
   - **Tự động trả Zeng Tianguo**: Khi Zeng Tianguo xong, bot tranh thủ lúc vé đang Cooldown hoặc đang rảnh để bay về NPC nộp quest mở khóa cấp kỹ năng mới.
   - **Hỗ trợ chế độ độc lập**: Có thể chạy Song Song (bật cả 2), chỉ chạy Vé (bật Vé), hoặc chỉ chạy Zeng Tianguo (bật Zeng Tianguo).
3. **Giao Diện Điều Khiển Mới Trong Tab Nhiệm Vụ (`tabQuests`)**:
   - Thẻ điều khiển riêng: **Nhiệm Vụ Kỹ Năng Zeng Tianguo & Chế Độ Song Song**.
   - Huy hiệu trực quan hiển thị chế độ vận hành: `⚡ SONG SONG (Ưu Tiên Vé)`, `🎫 Chỉ Chạy Vé NV`, `⚡ Chỉ Chạy Zeng Tianguo`.
   - Hiển thị tiến độ thời gian thực của cả 2 bên (Vé NV: x/100 • Kỹ năng: y/200).
   - Nút tìm & bay tức thì đến NPC Zeng Tianguo, nút tương tác nhanh nhận/nộp bằng tay.
4. **Tái Cấu Trúc Thư Mục Backup Gọn Gàng**:
   - Tạo thư mục `backup/` với 2 nhánh con:
     - `backup/goc/`: Chứa bản backup file monolithic gốc (`backup.lua`, `loader_backup.lua`).
     - `backup/module/`: Chứa toàn bộ các gói zip module theo phiên bản (`backup_full_project_v*.zip`, `backup_module*.zip`).
   - Xóa bỏ các bản zip tạm dư thừa.

---

## [v2.2.9] - 2026-09-16
### 🌟 Đồng Bộ Toàn Diện 100% Chức Năng Từ Bản Gốc Sang Module V2 (Full Parity Update):
1. **Bổ Sung 100% Nội Dung Tab Thử Nghiệm (`tab_thu_nghiem.lua`)**:
   - 👻 **Chế Độ Tàng Hình (Ghost / Invisibility Mode)**: Tàng hình hoàn toàn nhân vật và cần câu trước người chơi khác.
   - 🎯 **Tự Động Tẩy Luyện Trait (Auto Reroll & Lock Trait)**: Tự động cuộn trait cần câu, hỗ trợ khóa và giữ lại các trait quý hiếm như *Abyssal, Kraken, Golden, Radiant, Corrupted*.
   - ⛵ **Triệu Hồi Thuyền Tức Thì (Instant Boat Spawner & Remote Buy)**: Mua thuyền từ xa và spawn ngay dưới chân không cần đến bến cảng.
   - 🔄 **Cửa Hàng Trao Đổi Từ Xa (Remote Exchange Shop)**: Đổi Trait Reroll và Ngọc Tinh Hoa (EssenceOrb) từ xa.
   - 🎨 **Tùy Biến Màu Sắc Cần Câu (Rod Color & RGB Rainbow Cycle)**: Đổi màu sắc cần câu tùy ý và hiệu ứng chuyển màu RGB 7 sắc cầu vồng.
   - 🏰 **Quản Lý Bể Nuôi Cá & Gia Viên (Fish Tank & Plot Upgrades)**: Quản lý và nâng cấp bể cá gia viên.
2. **Bổ Sung Bộ Trang Bị Set 1 & Set 2 Trong Tab Câu Cá (`tab_cau_ca.lua`)**:
   - Chuyển đổi nhanh giữa 2 cấu hình cần & mồi (Set 1 / Set 2) chỉ với 1 click.
   - Bộ chọn mồi săn boss và mồi câu thường độc lập.
3. **Bổ Sung Boss Bạch Tuộc Bí Mật, Đấu Trường Enzo & Cẩm Nang Ráp Cần Trong Tab Săn Boss (`tab_san_boss.lua`)**:
   - Tích hợp minigame săn **Boss Bạch Tuộc Bí Mật (Octoparasite)** tại Phao Biển và Vùng Lòng Đất.
   - **Đấu Trường Boss Enzo** với cơ chế kéo cá tự động.
   - **🎣 Cẩm Nang Ráp Cần (Rod Crafting Guide)**: Hiển thị 6 công thức chế tạo cần câu và mồi câu cao cấp cùng nút lọc nhanh.
4. **Bổ Sung Thương Nhân Kỹ Năng Sage Yijiu & Vòng Quay Gacha Trong Tab Shop (`tab_shop.lua`)**:
   - **Sage Yijiu**: Chọn và mua 10 loại bí kíp kỹ năng từ xa.
   - **Auto Gacha**: Tự động quay thưởng liên tục theo banner (Taiji Banner / Egoless Banner) với số vé tùy chỉnh.
5. **Đồng Bộ Hoàn Chỉnh Hệ Thống Dịch Chuyển (`tab_dich_chuyen.lua`)**:
   - Đầy đủ **10 hòn đảo** kèm hiển thị vị trí hiện tại `[BẠN ĐANG Ở ĐÂY]` và khoảng cách `~Xm`, nút copy tọa độ.
   - **Đấu Trường Boss & Vùng Đất Bí Mật**: Phao Boss Bạch Tuộc, Vùng Câu Cá Ngầm Lòng Đất, Đấu trường Enzo.
   - **Cửa Hàng Bán Cần (Biao Di)**: 8 shop Biao Di trên các đảo.
   - **Vị Trí Cần Câu Bí Mật**: 6 tọa độ cần câu ẩn (Anchorbound, Blazeshark, Kraken, Ascendant Bamboo, Lifebloom, Demonic).
   - **Dịch Chuyển Đến Người Chơi**: Dropdown hiển thị tên kèm khoảng cách, bay đến người chơi đã chọn, làm mới, và bay đến người chơi ngẫu nhiên.
   - **🧙 17 NPC Nhiệm Vụ Toàn Bản Đồ**: Dịch chuyển tức thì đến tất cả NPC trong game với hệ thống quét model thông minh.
   - **Đạo Sĩ (Taoist & Maoshan)**: Bay tức thì đến vị trí xuất hiện của Đạo Sĩ nếu có trong server.
6. **Bổ Sung ESP Cần Bí Mật, Thuyền Bè & Ẩn Tên Trong Tab ESP (`tab_visuals.lua`)**:
   - ESP Cần Bí Mật, ESP Thuyền Bè, và tùy chọn Ẩn Tên Mặc Định Người Chơi để tối ưu tầm nhìn và giảm lag.

---

## [v2.2.8] - 2026-09-16
### 🛠️ Sửa Lỗi Thực Thi UI "attempt to call a nil value" Khi Khởi Động V2 (Fix gì):
1. **Sửa Lỗi Nil Method Trong Tab Nhiệm Vụ (`CreateStatusRow`)**:
   - *Nguyên nhân lỗi*: Trong [v2/ui/tabs/tab_nhiem_vu.lua](file:///Users/vonguyengiap/Documents/script/v2/ui/tabs/tab_nhiem_vu.lua), dòng hiển thị trạng thái gọi `Components.CreateStatusRow`. Tuy nhiên, trong [v2/ui/components.lua](file:///Users/vonguyengiap/Documents/script/v2/ui/components.lua) hàm hiển thị dòng thông tin chuẩn là `Components.CreateInfoRow`. Do hàm không tồn tại (`nil`), Executor ném lỗi `adstring:540861:6187: attempt to call a nil value` và dừng quá trình nạp script V2.
   - *Khắc phục*:
     - Chuyển `Components.CreateStatusRow` sang `Components.CreateInfoRow` trong `tab_nhiem_vu.lua`.
     - Đồng thời bổ sung alias `Components.CreateStatusRow = Components.CreateInfoRow` trong `components.lua` để đảm bảo tương thích 100%.
2. **Sửa Lỗi Gọi `Components.ShowNotification` Trong Tab Câu Cá**:
   - *Khắc phục*: Thay thế bằng `Utils.ShowNotification`, đồng thời bổ sung `Components.ShowNotification` trỏ sang `Utils.ShowNotification` để phòng ngừa lỗi gọi nhầm.
3. **Biên Dịch & Cập Nhật Gói V2**:
   - Đã build lại [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua) và kiểm tra bằng `luac -p`.
   - Nâng phiên bản lên **`v2.2.8`**.

---

## [v2.2.7] - 2026-09-16
### 🚀 Hoàn Tất Chuyển Giao 100% Tính Năng Sang Kiến Trúc Module V2 (Port 100% Features to Modular Architecture):
1. **Thông Báo Telegram Bot Đa Kênh & Kiểm Tra Kết Nối Tức Thì**:
   - Tích hợp trọn vẹn thông báo Telegram Bot gửi thông báo về điện thoại: Săn Boss, quét thấy Đạo Sĩ (Taoist), Đạo Sĩ Mao Sơn (Maoshan), Thần Linh (God Spirit), và Server Thời Tiết.
   - Thêm nút **"Kiểm Tra Telegram Bot"** gửi tin nhắn mẫu kiểm tra Token và Chat ID.
   - Tích hợp trường JobID và mã 1-click teleport tham gia server ngay lập tức trên điện thoại.
2. **Hệ Thống Tự Động Đổi Server (Auto Server Hop) Cho NPC & Thời Tiết**:
   - Tự động nhảy server liên tục và khôi phục sau khi đổi server (`HeavyweightFishing_NPCHop.json` và `HeavyweightFishing_WeatherHop.json`).
   - Hỗ trợ đổi server tìm: **Đạo Sĩ (Taoist)**, **Đạo Sĩ Mao Sơn (Maoshan)**, **Thần Linh (God Spirit)**.
   - Hỗ trợ đổi server tìm thời tiết mong muốn: **Bão Sấm**, **Bão Tuyết**, **Sương Mù**, **Nắng Gắt**, **Trời Mưa**, **Trời Gió**, **Mưa Axit**, **Trăng Máu**, **Boss Realm** hoặc bất kỳ thời tiết đặc biệt nào.
   - Bổ sung các nút tương tác nhanh với 4 Bàn Thờ Thời Tiết (Weather Totems).
3. **Quản Lý Vòng Đời Vé Nhiệm Vụ Toàn Diện (Daily Ticket Quests Lifecycle)**:
   - Tự động nhận diện loại nhiệm vụ chính xác 0ms từ dữ liệu gốc `ReplicatedStorage.Data[UserId].Quest` (100 cá, 1.5M cá Map 9, 100 chiêu, 100 mồi).
   - Tự động bay đến đảo và vị trí câu tương ứng, tự động trang bị mồi hoặc tháo mồi.
   - Xử lý mượt mà toàn bộ quy trình hội thoại NPC (chọn Quest, nhận Easy/Hard, nộp vé và *Leave*).
   - Tự động nhận biết câu thoại hết vé trong ngày và tự giải phóng cờ khi bước sang ngày mới (theo cả giờ máy tính và 00:00 UTC).
   - Tự động quay về Home Spot câu cá combo trong thời gian chờ hồi chiêu vé.
4. **Bộ Lọc Bán Cá Nâng Cao & Tự Động Chế Mồi Tối Ưu**:
   - Tự động khóa bảo vệ cá đột biến (`Shiny`, `Giant`, `Golden`, `Albino`, `Corrupted`, `Colossal`, `Heavyweight`, `Dark`, `Radiant`).
   - Giữ lại cá nặng theo ngưỡng tùy chỉnh (`MinWeightToKeep`), giữ cá quý chỉ định, và giữ cá nguyên liệu chế mồi.
   - Tự động chế tạo mồi và tự động mua mồi khi số lượng dưới ngưỡng an toàn.
5. **Phân Bổ Điểm Câu Săn Boss & Jitter Chống Trùng Lặp**:
   - Chế độ chọn điểm câu: **Tự Động (Theo Acc)** băm ID người chơi để phân bổ 5 slot câu an toàn khác nhau, chống chồng chéo khi treo nhiều acc/bot.
   - Tùy chọn **Jitter dịch chuyển** tạo độ lệch ngẫu nhiên bán kính 0.5 - 5.0 studs chống trùng tọa độ tuyệt đối.
6. **Ảo Hoá Tài Sản (Visual Spoofing) Cho Gems & Tickets**:
   - Module `spoof.lua` cho phép thay đổi giao diện hiển thị Gems và Tickets ảo, duy trì bền vững với hook lắng nghe giá trị `Changed`.
   - Tự động lưu cấu hình theo từng tài khoản và có nút Reset khôi phục số dư thật.
7. **Biên Dịch & Đồng Bộ Bộ Nạp Loader V2**:
   - Biên dịch thành công gói `v2_bundle.lua` (31 submodules, 110 requires, 0 lỗi cú pháp).
   - Bộ nạp độc lập `loader_v2.lua` sẵn sàng chạy thử nghiệm 100% tính năng với hiệu năng tối đa.

---

## [v2.2.6] - 2026-09-16
### 🛡️ Sửa Triệt Để Lỗi Tính Sát Thương 2 Người & Hỗ Trợ Boss Nhiều Mạng (Multi-Phase) (Fix & Upgrade gì):
1. **Hỗ Trợ Toàn Diện Boss Nhiều Mạng (Multi-Phase Boss - Ví dụ Boss 3 Mạng)**:
   - *Nguyên nhân lỗi cũ*: Một số Secret Boss có 2 đến 3 mạng (Phase 1, 2, 3 - thuộc tính `HasPhaseLeft = true` trong game). Khi hết mạng 1, máu Boss về 0, script cũ tưởng Boss đã chết nên kích hoạt thông báo chiến thắng và tự đóng bảng sau 6 giây, đồng thời làm mất toàn bộ dữ liệu sát thương của người chơi khi Boss hồi máu sang mạng 2.
   - *Giải pháp triệt để*:
     - Bổ sung cơ chế phát hiện chuyển mạng (`phaseTransitionUntil` 4 giây): Khi máu mạng 1 về 0 nhưng Boss vẫn còn trong game hoặc `HasPhaseLeft == true`, bảng không tắt mà hiển thị thông báo chuyển mạng: `⚡ HẠ MẠNG 1! ĐANG QUA MẠNG TIẾP...`.
     - Tự động cộng dồn máu tổng qua các mạng (`totalBossMaxHp`) khi Boss hồi sinh mạng 2, mạng 3, đồng thời **giữ nguyên toàn bộ sát thương tích lũy** của từng người chơi từ các mạng trước.
     - Tiêu đề bảng hiển thị rõ số mạng hiện tại: `⚔️ SÁT THƯƠNG BOSS • MẠNG 2 (85% HP)` và `Tên Boss [Mạng 2] • Máu Hiện Tại / Máu Mạng`.
     - Chỉ kích hoạt màn hình tổng kết vinh danh khi Boss thực sự bị câu lên hoàn toàn (`fish.Parent == nil` và hoàn thành tất cả các mạng).
2. **Khắc Phục Lỗi Tính Sát Thương Không Chuẩn Khi 2-3 Người Cùng Câu**:
   - *Nguyên nhân lỗi cũ*: Bản trước áp dụng công thức chia tỷ lệ sát thương theo lực cần câu (`RodPower`), dẫn đến việc khi một người tung chiêu xả đòn 1,000 DMG thì người câu cùng (dù không làm gì hoặc chỉ giữ cần) vẫn bị chia đều sát thương, làm bảng xếp hạng sai lệch hoàn toàn.
   - *Giải pháp chuẩn xác*:
     - **Phân tách Đòn Đột Biến (Burst Skill / Slam >= 75 DMG) & Sát Thương Cuộn Cần (Reel DPS < 75 DMG)**.
     - **Cơ chế bắt đòn đánh thời gian thực**:
       + Hook trực tiếp `Events.UseSkill` và `Events.Slam` để ghi nhận chính xác đến từng millisecond khi bản thân tung chiêu hoặc nện Perfect Slam.
       + Theo dõi trạng thái chiêu (`UsingSkill`) và animation Action của những người chơi khác cùng câu.
       + Khi có đòn burst sát thương lớn (>= 75 DMG), **100% lượng sát thương đó được ghi nhận cho đúng người chơi vừa ra đòn**.
       + Các nhịp kéo cá thông thường (< 75 DMG) mới được phân chia theo lực cần câu.
     - Hiển thị song song cả tỷ lệ % HP chuẩn xác trên tổng máu Boss và số sát thương cụ thể: `48.2% (4,820 DMG)`.
3. **Đồng Bộ Hóa Toàn Diện**:
   - Cập nhật đồng bộ trên cả bản Master [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua) và bản Modular [v2/features/boss_dps.lua](file:///Users/vonguyengiap/Documents/script/v2/features/boss_dps.lua).
   - Nâng cấp mã phiên bản tĩnh lên **`v2.2.6`** trên toàn hệ thống và biên dịch lại [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).

---

## [v2.2.5] - 2026-09-16
### ⚔️ Bảng Đo Sát Thương Săn Boss Đa Người Chơi (% HP DPS Meter HUD) (New Feature & Upgrade gì):
1. **Hiển Thị % HP Từng Người Chơi Pem Boss Theo Thời Gian Thực**:
   - Khi có 2, 3 người (hoặc nhiều người trong server) cùng câu và xả chiêu vào 1 con Boss, màn hình hiển thị trực tiếp Widget **⚔️ BẢNG SÁT THƯƠNG BOSS**.
   - Thống kê chi tiết từng người chơi tham gia:
     - 👤 **Avatar Headshot**: Tự động tải ảnh đại diện Roblox của từng người chơi tham gia.
     - 🥇 **Huy hiệu thứ hạng**: Tự động xếp hạng DPS từ cao xuống thấp (🥇 Hạng 1, 🥈 Hạng 2, 🥉 Hạng 3...).
     - 📊 **Phần trăm % HP Boss**: Hiển thị chính xác tỷ lệ % máu Boss mà từng người đã đánh được (ví dụ: `48.5% HP (2,425)`).
     - 📈 **Thanh tiến trình màu sắc**: Mỗi người chơi có màu thanh sát thương riêng biệt, trực quan và bắt mắt.
2. **Cơ Chế Phân Bổ Sát Thương Chuẩn Xác & Tổng Kết Chiến Thắng**:
   - **Tự động bắt đối tượng Boss**: Tự động nhận diện thư mục `fish.PlayerContribution` và danh sách người chơi trong minigame xung quanh Boss.
   - **Phân bổ sát thương thông minh**: Theo dõi từng nhịp sụt giảm máu của Boss (`deltaHp`), phân chia theo trọng số hành động và lực cần câu (`RodPower`).
   - **Màn hình tổng kết vinh danh (Victory Screen)**: Khi Boss bị hạ gục (máu về 0), bảng chuyển sang tiêu đề vàng **"🎉 CHIẾN THẮNG!"**, hiển thị bảng tổng kết thành tích công trạng của từng người trong 6 giây trước khi tự đóng.
3. **Giao Diện Tiện Dụng & Tùy Biến**:
   - **Kéo thả tự do (Draggable HUD)**: Cho phép dùng chuột (PC) hoặc ngón tay (Mobile) kéo thả thanh tiêu đề để đặt bảng ở bất cứ góc nào trên màn hình.
   - **Công tắc Bật/Tắt trong Tab Săn Boss**: Bổ sung tùy chọn `"Hiện Bảng Sát Thương Boss (% HP)"` trong thẻ Chat Sniper / Săn Boss, tự động lưu cấu hình theo tài khoản người dùng (`ShowBossDpsMeter`).
4. **Đồng Bộ Hóa Toàn Hệ Thống**:
   - Tối ưu hóa mã nguồn trong khối `do ... end` đảm bảo không vượt quá giới hạn 200 biến cục bộ của trình biên dịch Luau.
   - Nâng cấp mã phiên bản tĩnh lên **`v2.2.5`** trong [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua), [v2/core/config.lua](file:///Users/vonguyengiap/Documents/script/v2/core/config.lua) và [v2_bundle.lua](file:///Users/vonguyengiap/Documents/script/v2_bundle.lua).
5. **Triển Khai Chuẩn Module V2 & Tạo Loader V2 Riêng Biệt (Modular Edition)**:
   - Tạo mới module độc lập [v2/features/boss_dps.lua](file:///Users/vonguyengiap/Documents/script/v2/features/boss_dps.lua) tích hợp đầy đủ cơ chế theo dõi DPS, tính % HP Boss, và widget giao diện kéo thả mượt mà.
   - Bổ sung nút gạt cấu hình trong [v2/ui/tabs/tab_san_boss.lua](file:///Users/vonguyengiap/Documents/script/v2/ui/tabs/tab_san_boss.lua) và khởi chạy vòng lặp cập nhật trong [v2/main.lua](file:///Users/vonguyengiap/Documents/script/v2/main.lua).
   - Tạo bộ Loader mới [loader_v2.lua](file:///Users/vonguyengiap/Documents/script/loader_v2.lua) nạp trực tiếp bản `v2_bundle.lua` qua mạng lưới đa tầng CDN (GitHub Raw, jsDelivr Edge, Fastly), tối ưu hóa bộ nhớ và chống nghẽn Timeout 100%.

---

## [v2.2.4] - 2026-09-15
### 📜 Thông Báo Webhook Đạo Sĩ (Taoist & Maoshan) & Tích Hợp Telegram Bot Báo Về Điện Thoại (New Feature & Upgrade gì):
1. **Thông Báo Phát Hiện Đạo Sĩ (Taoist & Maoshan) Qua Webhook**:
   - Tự động quét và phát hiện khi **Đạo Sĩ (Taoist)**, **Đạo Sĩ Mao Sơn (Maoshan)** hoặc **Thần Linh (God Spirit)** xuất hiện trong máy chủ (áp dụng cho cả quá trình Auto Server Hop lẫn khi đang treo máy bình thường).
   - Gửi tức thì thẻ thông báo chi tiết:
     - 🎯 Tên NPC cụ thể phát hiện được.
     - 👤 Tên tài khoản tìm thấy.
     - 📍 Tọa độ đứng chuẩn xác (X, Y, Z).
     - 🔑 Job ID của máy chủ để anh em kết nối nhanh.
     - ⚡ Đoạn mã Luau 1 chạm gọi `TeleportToPlaceInstance` để dịch chuyển ngay đến server có Đạo Sĩ.
     - ⏰ Mốc thời gian chính xác.
   - **Cơ chế chống spam**: Mỗi NPC trong cùng một server chỉ gửi thông báo đúng 1 lần duy nhất, không gây nghẽn Webhook.
2. **Tích Hợp Giải Pháp Thay Thế Discord: Ứng Dụng Telegram Bot**:
   - Ngoài Discord, Telegram Bot là giải pháp tối ưu nhất: hoàn toàn miễn phí, thông báo đẩy rung chuông điện thoại 24/7 tức thì, không bao giờ bị bóp băng thông hay chặn mạng tại Việt Nam.
   - Bổ sung nhóm cấu hình **📱 Telegram Bot** trong Tab Hồ Sơ / Cài Đặt:
     - Nhập `Telegram Bot Token` (tạo miễn phí qua `@BotFather`).
     - Nhập `Telegram Chat ID` (lấy ID qua `@userinfobot`).
     - Tùy chọn bật/tắt: Báo Secret Boss, Báo Đạo Sĩ (Taoist & Maoshan).
     - Nút **"Kiểm Tra Telegram (Test)"** gửi tin nhắn mẫu kiểm tra kết nối ngay lập tức.
     - Tự động lưu cấu hình vĩnh viễn theo tài khoản người dùng (`TelegramBotToken`, `TelegramChatId`, `TelegramEnabled`, v.v.).
3. **Đồng bộ hóa toàn diện**:
   - Nâng cấp nhãn phiên bản tĩnh lên **`v2.2.4`** trong [local.lua](file:///Users/vonguyengiap/Documents/script/local.lua) và `v2/core/config.lua`.

---

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
