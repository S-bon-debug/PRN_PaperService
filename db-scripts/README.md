# Database Scripts — Scientific Journal Tracking System

## Danh sách file

| File | Database | Service |
|------|----------|---------|
| 01_identity_service.sql | identity_db | Identity Service |
| 02_paper_service.sql | paper_db | Paper Service |
| 03_trend_service.sql | trend_db | Trend Service |
| 04_user_service.sql | user_db | User Service |
| 05_notification_service.sql | notification_db | Notification Service |
| 06_sync_service.sql | sync_db | Sync Service |
| 07_admin_service.sql | admin_db | Admin Service |

## Cách chạy

### Tạo toàn bộ databases
```bash
psql -U postgres -c "CREATE DATABASE identity_db;"
psql -U postgres -c "CREATE DATABASE paper_db;"
psql -U postgres -c "CREATE DATABASE trend_db;"
psql -U postgres -c "CREATE DATABASE user_db;"
psql -U postgres -c "CREATE DATABASE notification_db;"
psql -U postgres -c "CREATE DATABASE sync_db;"
psql -U postgres -c "CREATE DATABASE admin_db;"
```

### Chạy từng script
```bash
psql -U postgres -d identity_db     -f 01_identity_service.sql
psql -U postgres -d paper_db        -f 02_paper_service.sql
psql -U postgres -d trend_db        -f 03_trend_service.sql
psql -U postgres -d user_db         -f 04_user_service.sql
psql -U postgres -d notification_db -f 05_notification_service.sql
psql -U postgres -d sync_db         -f 06_sync_service.sql
psql -U postgres -d admin_db        -f 07_admin_service.sql
```

### Hoặc chạy 1 lệnh duy nhất
```bash
for f in 0*.sql; do
  db=$(basename $f .sql | sed 's/0[0-9]_//' | sed 's/_service//')_db
  psql -U postgres -d $db -f $f
done
```

## Lưu ý quan trọng — Microservice DB

Vì mỗi service dùng DB riêng, **không có FK xuyên service**.
Các UUID tham chiếu qua service khác được comment rõ trong schema.

Ví dụ: `user_db.bookmarks.user_id` → tham chiếu `identity_db.users.id`
nhưng KHÔNG có FOREIGN KEY constraint — service tự validate qua API call.

## Connection strings (appsettings.json mẫu)

```json
{
  "ConnectionStrings": {
    "IdentityDb":     "Host=localhost;Database=identity_db;Username=postgres;Password=yourpassword",
    "PaperDb":        "Host=localhost;Database=paper_db;Username=postgres;Password=yourpassword",
    "TrendDb":        "Host=localhost;Database=trend_db;Username=postgres;Password=yourpassword",
    "UserDb":         "Host=localhost;Database=user_db;Username=postgres;Password=yourpassword",
    "NotificationDb": "Host=localhost;Database=notification_db;Username=postgres;Password=yourpassword",
    "SyncDb":         "Host=localhost;Database=sync_db;Username=postgres;Password=yourpassword",
    "AdminDb":        "Host=localhost;Database=admin_db;Username=postgres;Password=yourpassword"
  }
}
```
