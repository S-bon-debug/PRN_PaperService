# Scientific Journal Publication Trend Tracking System

## 1. Context (Bối cảnh)
Trong bối cảnh số lượng bài báo khoa học và journal học thuật ngày càng gia tăng, việc theo dõi xu hướng nghiên cứu, chủ đề nổi bật và sự phát triển của các lĩnh vực học thuật trở nên khó khăn đối với giảng viên, sinh viên và nhà nghiên cứu. Các nền tảng học thuật hiện nay chủ yếu hỗ trợ tìm kiếm bài báo nhưng chưa tập trung nhiều vào việc phân tích xu hướng công bố theo thời gian và trực quan hóa dữ liệu nghiên cứu.

## 2. Problems (Vấn đề)
- Khó theo dõi sự thay đổi và phát triển của các chủ đề nghiên cứu theo thời gian do số lượng bài báo khoa học ngày càng lớn.
- Việc tìm kiếm bài báo trên các nền tảng học thuật hiện nay chủ yếu dựa trên keyword, chưa hỗ trợ phân tích xu hướng nghiên cứu một cách trực quan.
- Giảng viên, sinh viên và nhà nghiên cứu mất nhiều thời gian để xác định các chủ đề đang nổi bật hoặc có tiềm năng nghiên cứu.

## 3. Primary Actors (Đối tượng sử dụng chính)
- **Researcher (Nhà nghiên cứu):** Phân tích xu hướng nghiên cứu, theo dõi journal và keyword chuyên sâu, khám phá các chủ đề mới nổi, và xem thống kê công bố theo thời gian.
- **Lecturer / Student (Giảng viên / Sinh viên):** Tìm kiếm bài báo tham khảo, khám phá các chủ đề phổ biến, lưu bài báo hoặc keyword quan tâm, và xem dashboard xu hướng cơ bản.
- **System Administrator (Quản trị hệ thống):** Quản lý tài khoản người dùng, cấu hình nguồn dữ liệu API, cập nhật dữ liệu bài báo và quản lý hệ thống.

## 4. Functional Requirements (Yêu cầu chức năng)
1. **Authentication (Xác thực)**
   - Đăng ký tài khoản
   - Đăng nhập, Đăng xuất
   - Quên mật khẩu
   - Cập nhật profile

2. **Document Management (Quản lý tài liệu)**
   - Upload tài liệu, Tải xuống tài liệu
   - Xem danh sách tài liệu, Xem chi tiết tài liệu
   - Xóa tài liệu, Chỉnh sửa thông tin tài liệu
   - Tìm kiếm tài liệu, Lọc tài liệu theo môn học

3. **Cloud Storage (Lưu trữ đám mây)**
   - Upload file lên cloud
   - Xem trạng thái upload
   - Preview file

4. **AI Chatbot (Hỏi đáp AI)**
   - Chat với chatbot
   - Hỏi đáp về tài liệu, Nhận câu trả lời AI
   - Xem lịch sử chat

## 5. Main Entities (Các thực thể chính)
- User
- Research Paper
- Journal
- Keyword
- Research Topic
- Publication Trend
- Author
- Bookmark
- Notification
- Dashboard Report
- API Data Source

## 6. Notes (Ghi chú hệ thống)
- Hệ thống sử dụng dữ liệu công khai từ các nguồn học thuật như Semantic Scholar, OpenAlex hoặc Crossref thông qua API miễn phí.
- Chỉ thu thập metadata của bài báo, bao gồm: tiêu đề, abstract, keywords, năm xuất bản, tác giả và journal.
- Không xử lý toàn văn (full-text) của bài báo do giới hạn bản quyền và dung lượng dữ liệu.
- Dữ liệu được giả định là hợp lệ, có cấu trúc thống nhất và luôn khả dụng từ API bên thứ ba.
- Hệ thống chỉ phân tích dữ liệu thuộc một số lĩnh vực được chọn trước (ví dụ: Computer Science hoặc AI) để giảm độ phức tạp.
- Tần suất cập nhật dữ liệu được giả định theo chu kỳ định kỳ (ví dụ: mỗi ngày hoặc mỗi tuần), không yêu cầu realtime.

## Kiến trúc Hệ thống

Dự án được xây dựng theo kiến trúc **Microservices** trên nền tảng **.NET 8.0** kết hợp với **PostgreSQL** để lưu trữ dữ liệu.

### Danh sách các Services
1. **API Gateway:** Điều hướng request từ Client đến các service tương ứng.
2. **Identity Service:** Xử lý xác thực người dùng (Login, Register, JWT, OAuth). Quản lý bởi `identity_db`.
3. **Paper Service:** Quản lý metadata bài báo, lấy từ các API bên thứ 3 (Semantic Scholar, OpenAlex). Quản lý bởi `paper_db`.
4. **Trend Service:** Phân tích dữ liệu, sinh báo cáo (dashboard, biểu đồ xu hướng theo keyword, thời gian). Quản lý bởi `trend_db`.
5. **User Service:** Quản lý thông tin hồ sơ (Profile), lịch sử và danh sách bài báo quan tâm (Bookmarks). Quản lý bởi `user_db`.
6. **Notification Service:** Hệ thống thông báo khi có bài báo mới thuộc chủ đề đang theo dõi. Quản lý bởi `notification_db`.
7. **Sync Service:** Worker chạy ngầm định kỳ (Cronjob) kéo dữ liệu từ API bên thứ 3 để cập nhật metadata. Quản lý bởi `sync_db`.
8. **Admin Service:** Quản lý người dùng, cấu hình API source. Quản lý bởi `admin_db`.

## Yêu cầu cài đặt

- [.NET 8.0 SDK](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)
- [Docker & Docker Compose](https://www.docker.com/products/docker-desktop/)
- IDE được khuyến nghị: Visual Studio 2022 hoặc Visual Studio Code.

## Hướng dẫn khởi chạy (Local)

### Bước 1: Khởi tạo Database

Tất cả 7 database được cấu hình tự động chạy thông qua Docker Compose. Các bảng (tables) sẽ được tự động tạo dựa trên file `init-multiple-databases.sh` và thư mục `db-scripts`.

1. Mở Terminal tại thư mục gốc của dự án (`JournalTrackingSystem`).
2. Chạy lệnh:
   ```bash
   docker-compose up -d
   ```
3. Sau khi Docker khởi chạy xong, bạn có thể kiểm tra database bằng cách truy cập **PgAdmin** tại:
   - **URL:** `http://localhost:5050`
   - **Email:** `admin@jts.com`
   - **Password:** `admin`

*(Connection configs: host: `postgres`, user: `postgres`, password: `yourpassword`)*

### Bước 2: Khởi chạy Microservices

Mỗi Microservice là một Web API độc lập. Bạn có thể mở file Solution `JournalTrackingSystem.sln` trên Visual Studio và setup **Multiple Startup Projects** để chạy toàn bộ các API cùng lúc, hoặc mở terminal riêng biệt tại thư mục của từng project và chạy lệnh:

```bash
dotnet run
```

*Lưu ý: Bạn cần cấu hình lại `appsettings.json` trong mỗi service với `ConnectionString` trỏ vào DB tương ứng.*

## Ghi chú

- Dự án sử dụng **Entity Framework Core 8.0** (`Npgsql.EntityFrameworkCore.PostgreSQL`).
- Do áp dụng Microservice Database-per-service, KHÔNG có ràng buộc khóa ngoại (Foreign Key) chéo giữa các database. Các liên kết bằng `UUID` sẽ do Service tự quản lý và xác thực thông qua API call nội bộ (hoặc Message Broker như RabbitMQ nếu mở rộng sau này).
