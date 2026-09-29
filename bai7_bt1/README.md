# bai7_bt1

A new Flutter project.
# Ứng dụng Quản lý Công việc (Task Details Update)

Ứng dụng Flutter minh họa màn hình **Task Details** nhận dữ liệu công việc từ **TaskScreen**, cho phép cập nhật trạng thái `Completed` qua Checkbox và truyền dữ liệu ngược về màn hình chính.

---

## 🛠 Cấu hình môi trường & Yêu cầu
- **Flutter SDK**: `>=3.0.0`
- **Dart SDK**: `>=3.0.0`
- **Thiết bị**: Emulator (Android/iOS) hoặc thiết bị thật.

---

## 📁 Cấu trúc dự án
```text
lib/
├── models/
│   └── task.dart               # Khai báo Model cho Task
├── screens/
│   ├── task_screen.dart        # Màn hình danh sách công việc
│   └── task_detail_screen.dart # Màn hình chi tiết & Cập nhật trạng thái
└── main.dart                   # Tệp chạy chính của ứng dụng