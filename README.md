# LibMan — Khung triển khai hai modul thư viện

## Chạy nhanh trên Windows

### Chuẩn bị một lần

1. Cài JDK 17 trở lên và tải **Core ZIP** của Tomcat 10.1. Giải nén Tomcat vào thư mục dành cho LibMan. Để giới hạn bản demo trên máy này, thêm `address="127.0.0.1"` vào connector HTTP cổng `8080` trong `conf/server.xml`. Maven Wrapper sẽ tự tải bản Maven đã ghim ở lần build đầu. [Tải Tomcat 10.1](https://tomcat.apache.org/download-10.cgi)
2. Khởi động MySQL. Nếu cài MySQL mới, dùng nhánh 8.4 LTS. Trong PowerShell tại thư mục gốc của repo, mở MySQL bằng tài khoản quản trị.

```powershell
mysql --default-character-set=utf8mb4 -u root -p
```

Chạy các lệnh sau trong `mysql>` khi tạo **database demo mới**. Thay `MAT_KHAU_RIENG` bằng mật khẩu bạn chọn cho tài khoản `libman_app`.

```sql
CREATE DATABASE LibMan CHARACTER SET utf8mb4;
USE LibMan;
SOURCE db/schema.sql
SOURCE db/scenario-test.sql
CREATE USER 'libman_app'@'localhost' IDENTIFIED BY 'MAT_KHAU_RIENG';
GRANT SELECT, INSERT, UPDATE ON LibMan.* TO 'libman_app'@'localhost';
```

Nếu đã có database và tài khoản JDBC, dùng cấu hình sẵn có. `schema.sql` chỉ chạy một lần trên database trống; `scenario-test.sql` tự làm sạch và nạp lại dữ liệu cho cả 15 bảng trong một transaction. Để nạp lại nhanh trên MySQL đã có sẵn schema `LibMan`:

```powershell
mysql --default-character-set=utf8mb4 -u root -p LibMan < db/scenario-test.sql
```

[Cách nạp file SQL trong MySQL](https://dev.mysql.com/doc/refman/8.0/en/mysql-batch-commands.html)

### Build và chạy

Mở PowerShell ở thư mục gốc của repo. Đặt hai đường dẫn theo máy của bạn, rồi chạy script. Nếu chưa đặt `LIBMAN_DB_PASSWORD` trong phiên PowerShell, script sẽ hỏi mật khẩu MySQL của tài khoản ứng dụng.

```powershell
$env:JAVA_HOME = 'C:\Program Files\Java\jdk-21'
$env:CATALINA_HOME = 'D:\tools\apache-tomcat-10.1.62'
.\run.ps1
```

Script chạy `mvnw.cmd package`, triển khai `target/LibMan.war` vào `webapps/` và chạy Tomcat ngay trong terminal. Có thể truyền đường dẫn Tomcat qua `-TomcatHome`. Nếu đã đặt `CATALINA_BASE`, script dùng thư mục `webapps/` của instance đó. Mở [LibMan](http://127.0.0.1:8080/LibMan/) khi Tomcat khởi động xong.
Nhấn `Ctrl+C` để dừng Tomcat. Sau khi sửa Java hoặc JSP, chạy lại `.\run.ps1`. Để chạy lại WAR đã build, dùng `.\run.ps1 -SkipBuild`. Nếu PowerShell chặn việc chạy script, dùng `powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\run.ps1` trong thư mục repo.

Script mặc định kết nối `jdbc:mysql://localhost:3306/LibMan` với tài khoản `libman_app`. Đặt `LIBMAN_JDBC_URL` và `LIBMAN_DB_USER` trong cùng terminal nếu dùng database hoặc tài khoản khác. `LIBMAN_STUDENT_CARD_MONTHS` mặc định là `12` cho cả hai loại thẻ. Script dùng múi giờ `Asia/Ho_Chi_Minh` nếu chưa đặt `-Duser.timezone` qua `CATALINA_OPTS`.

## Tài liệu thiết kế

Mở `spec/SPEC.md` để xem từng lớp, màn hình, nguồn thiết kế và các quyết định còn mở. `spec/TUAN-TU.md` ánh xạ đủ 23 thông điệp đăng kí thẻ và 54 thông điệp nhận trả sang mã. Toàn bộ sơ đồ UML/ERD và wireframe giao diện (mã nguồn PlantUML tại `spec/diagrams/src/`, ảnh SVG tại `spec/diagrams/svg/`) được nhúng trực tiếp trong `spec/SPEC.md` và `spec/TUAN-TU.md`.

## Phạm vi sử dụng

Khung triển khai đầy đủ luồng đăng nhập/đăng xuất và hai modul Bạn đọc, Thủ thư. Có 19 JavaBean trong `model`, 6 lớp trong `dao` kể cả DAO trừu tượng và `MemberDAO`, lược đồ MySQL 15 bảng và 16 JSP (`index.jsp`, `view/thanhvien/`, `view/bandoc/`, `view/thuthu/`). Các trang gọi JDBC qua DAO, phiếu tạm được quản lí phiên bản hiện hành và đồng bộ trong `HttpSession` của một máy Tomcat. Các chức năng ngoài hai modul được mô tả ở SPEC.

## Đóng gói và triển khai thủ công

1. Dùng JDK 17 trở lên, Tomcat 10.1 và MySQL đã khởi tạo như trên. Truyền `LIBMAN_JDBC_URL`, `LIBMAN_DB_USER` và `LIBMAN_DB_PASSWORD` vào **tiến trình Tomcat**. Đặt múi giờ JVM theo nơi vận hành, ví dụ `-Duser.timezone=Asia/Ho_Chi_Minh` trong `CATALINA_OPTS`.
2. Chạy `./mvnw package` trên Linux hoặc macOS, hoặc `.\mvnw.cmd package` trên Windows. Sao chép `target/LibMan.war` vào thư mục `webapps/` của Tomcat. WAR đã chứa MySQL Connector/J trong `WEB-INF/lib`.
3. Chạy `bin/catalina.sh run` trên Linux hoặc macOS, hoặc `bin\catalina.bat run` trên Windows. Điểm vào `/LibMan/` chuyển đến trang đăng nhập khi chưa có phiên. Trang theo vai trò trả HTTP 403 nếu phiên hiện tại thiếu quyền truy cập.

### Hợp đồng phiên của phần đăng nhập

`MemberDAO.dangNhap(username, password)` xác thực tài khoản trên `tblMember9` bằng mật khẩu băm SHA-256 (`MemberDAO.bamMatKhau`). Khi thành công, `doDangNhap.jsp` hủy phiên cũ, tạo phiên mới và đặt thuộc tính `member` bằng đối tượng từ CSDL: `Reader9` cho bạn đọc, `Librarian9` (với `position = "LIBRARIAN"`) cho thủ thư, `Manager9` (với `position = "MANAGER"`) cho quản lí; rồi chuyển tới trang chính tương ứng. `doDangXuat.jsp` hủy phiên khi người dùng đăng xuất và chuyển về `gdDangNhap.jsp`.

## Kiểm tra

- Sau `./mvnw test-compile`, chạy `java -ea -cp 'target/classes:target/test-classes' ReportExample` để kiểm tra phép tính phạt, trạng thái phiếu tạm và trạng thái phiếu mượn. Trên Windows dùng `.\mvnw.cmd` và dấu `;` trong classpath.
- Để kiểm thử JDBC, dùng **schema thử nghiệm trống riêng biệt**. Nạp `db/schema.sql` rồi `db/scenario-test.sql` đúng một lần. Đặt ba biến kết nối `LIBMAN_JDBC_URL`, `LIBMAN_DB_USER` và `LIBMAN_DB_PASSWORD` cho tiến trình Java. Sau khi build WAR bằng Maven Wrapper, chạy lệnh dưới đây ở thư mục dự án. Chương trình ghi dữ liệu cấp thẻ và nhận trả vào schema đã chọn. Mỗi lần chạy cần một schema thử nghiệm mới. Trên Windows dùng dấu `;` trong classpath.
- Để nghiệm thu qua trình duyệt sau khi tích hợp đăng nhập, dùng `spec/NGOAI-LE.md` và ca mẫu trong SPEC. Bước thu tiền và giao phiếu là thao tác thực tế của thủ thư.

```sh
java -cp 'target/classes:target/test-classes:target/LibMan/WEB-INF/lib/*' MySqlScenario
```

Bộ dữ liệu mẫu kiểm tra hai luồng độc lập trong cùng một chương trình. DAO cấp thẻ theo ngày của máy chạy. Khi gọi trực tiếp DAO trả, test đặt ngày 22/09/2026 để tái hiện số liệu báo cáo. JSP luôn dùng ngày hệ thống. Dữ liệu phụ ngoài ví dụ, gồm mã đầu tài liệu, vị trí xếp giá và thông tin phụ của thủ thư, chỉ phục vụ fixture.

## Mức xác minh khi bàn giao

Đã biên dịch toàn bộ lớp Java, chạy ReportExample với assertions, kiểm tra Java nhúng của 12 JSP bằng bộ giả lập API tối thiểu, và đối chiếu trang đích, thành phần biểu mẫu với hình gốc. Đã chạy mô phỏng các nhánh chọn thiếu dòng, giữ dữ liệu khi nhập lỗi, tổng 40.000 đồng, chặn in phiếu tạm và gửi lại lượt đã gắn id. Đã kiểm tra khóa ngoại của fixture trên bản DDL chuyển cú pháp sang SQLite trong bộ nhớ. MySqlScenario là bài kiểm thử tích hợp tái chạy được. Chưa chạy WAR trên Tomcat, MySQL thật hoặc máy in trong môi trường bàn giao.

Quy trình `run.ps1` đã được kiểm tra trên Windows với JDK 21, Tomcat 10.1.62 và MySQL 8.0.43. Các bước kiểm tra gồm build và triển khai WAR, đăng nhập hai vai trò, cấp và tra cứu thẻ, khởi động lại bằng WAR có sẵn, triển khai WAR mới và chạy `MySqlScenario` trên database thử nghiệm riêng.
