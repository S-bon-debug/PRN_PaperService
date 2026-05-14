# Database Initialization Scripts

Thư mục này chứa các file SQL script để tự động khởi tạo các bảng (tables) và dữ liệu mẫu (seed data) cho 5 Microservices khi chạy Docker Compose.

## Danh sách các Database & Scripts tương ứng:

1. `01_auth_service.sql` -> Khởi tạo `auth_db` (Quản lý Users, RefreshTokens).
2. `02_document_service.sql` -> Khởi tạo `document_db` (Quản lý Subjects, Documents).
3. `03_storage_service.sql` -> Khởi tạo `storage_db` (Quản lý StorageFiles upload lên Cloud).
4. `04_aichat_service.sql` -> Khởi tạo `aichat_db` (Quản lý ChatSessions, ChatMessages RAG).
5. `05_admin_service.sql` -> Khởi tạo `admin_db` (Quản lý SystemConfigs, AuditLogs).

## Cơ chế hoạt động:
Khi chạy lệnh `docker-compose up -d`, container `jts_postgres` sẽ tự động chạy file `init-multiple-databases.sh` được mount vào `/docker-entrypoint-initdb.d/`. File bash này sẽ tạo 5 database trên và thực thi các file SQL script tương ứng vào từng DB.
