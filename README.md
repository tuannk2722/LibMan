# LibMan — Khung triển khai hai modul thư viện

Mở `spec/SPEC.md` để xem từng lớp, màn hình, nguồn thiết kế và các quyết định còn mở. `spec/TUAN-TU.md` ánh xạ đủ 23 thông điệp đăng kí thẻ và 54 thông điệp nhận trả sang mã. Các hình trong `spec/hinh/` được trích trực tiếp từ báo cáo Word.

## Phạm vi sử dụng

Khung triển khai đầy đủ luồng đăng nhập/đăng xuất và hai modul Bạn đọc, Thủ thư. Có 19 JavaBean trong `model`, 6 lớp trong `dao` kể cả DAO trừu tượng và `MemberDAO`, lược đồ MySQL 15 bảng và 16 JSP (`index.jsp`, `view/thanhvien/`, `view/bandoc/`, `view/thuthu/`). Các trang gọi JDBC qua DAO, phiếu tạm được quản lí phiên bản hiện hành và đồng bộ trong `HttpSession` của một máy Tomcat. Các chức năng ngoài hai modul được mô tả ở SPEC.

## Đóng gói và triển khai

1. Dùng JDK 17, Maven 3.8 trở lên, Tomcat 10.1 và MySQL 8.0.16 trở lên để thực thi CHECK. Tạo schema LibMan trống, chọn schema rồi chạy `db/schema.sql`. Cấp tài khoản JDBC quyền đọc, thêm và cập nhật những bảng của hai modul.
2. Truyền biến môi trường vào **tiến trình Tomcat**. `LIBMAN_JDBC_URL` là URL JDBC đến schema, ví dụ `jdbc:mysql://localhost:3306/LibMan`. `LIBMAN_DB_USER` và `LIBMAN_DB_PASSWORD` là tài khoản CSDL. `LIBMAN_STUDENT_CARD_MONTHS` là biến tùy chọn để ghi đè số tháng hiệu lực thẻ (mặc định cố định là `12` tháng cho cả hai loại thẻ `Sinh viên` và `Thủ thư`). Đặt múi giờ JVM theo nơi vận hành, ví dụ `-Duser.timezone=Asia/Ho_Chi_Minh`.
3. Từ thư mục có pom.xml, chạy `mvn package`. Sao chép `target/LibMan.war` vào `webapps/` của Tomcat. Maven đóng gói Connector/J vào WEB-INF/lib.
4. Điểm vào ứng dụng là `/LibMan/` (`index.jsp`), tự động chuyển hướng tới `/LibMan/view/thanhvien/gdDangNhap.jsp` nếu chưa đăng nhập. Điểm vào bạn đọc là `/LibMan/view/bandoc/gdChinh.jsp`; điểm vào thủ thư là `/LibMan/view/thuthu/gdChinh.jsp`. Nếu chưa có phiên đúng vai trò, trang trả HTTP 403. Tài khoản mẫu trong `db/scenario-test.sql` gồm `maitn` (bạn đọc) và `hatt` (thủ thư), đều dùng mật khẩu `123456`.

### Hợp đồng phiên của phần đăng nhập

`MemberDAO.dangNhap(username, password)` xác thực tài khoản trên `tblMember9` bằng mật khẩu băm SHA-256 (`MemberDAO.bamMatKhau`). Khi thành công, `doDangNhap.jsp` hủy phiên cũ, tạo phiên mới và đặt thuộc tính `member` bằng đối tượng từ CSDL: `Reader9` cho bạn đọc, `Librarian9` (với `position = "LIBRARIAN"`) cho thủ thư, `Manager9` (với `position = "MANAGER"`) cho quản lí; rồi chuyển tới trang chính tương ứng. `doDangXuat.jsp` hủy phiên khi người dùng đăng xuất và chuyển về `gdDangNhap.jsp`.

## Kiểm tra

- Sau `mvn test-compile`, chạy `java -ea -cp target/classes:target/test-classes ReportExample` để kiểm tra phép tính phạt, trạng thái phiếu tạm và trạng thái phiếu mượn. Trên Windows thay dấu phân cách đường dẫn classpath bằng dấu chấm phẩy.
- Để kiểm thử JDBC, dùng **schema thử nghiệm trống riêng biệt**. Nạp schema.sql rồi nạp `db/scenario-test.sql` đúng một lần. Đặt cùng bốn biến môi trường cho tiến trình Java. Sau `mvn package`, chạy hai lệnh dưới đây ở thư mục dự án. Chương trình ghi dữ liệu cấp thẻ và nhận trả vào schema đã chọn. Mỗi lần chạy cần một schema thử nghiệm mới.
- Để nghiệm thu qua trình duyệt sau khi tích hợp đăng nhập, dùng `spec/NGOAI-LE.md` và ca mẫu trong SPEC. Bước thu tiền và giao phiếu là thao tác thực tế của thủ thư.

```sh
mvn dependency:copy-dependencies -DincludeScope=runtime
java -cp 'target/classes:target/test-classes:target/dependency/*' MySqlScenario
```

Bộ dữ liệu mẫu kiểm tra hai luồng độc lập trong cùng một chương trình. DAO cấp thẻ theo ngày của máy chạy. Khi gọi trực tiếp DAO trả, test đặt ngày 22/09/2026 để tái hiện số liệu báo cáo. JSP luôn dùng ngày hệ thống. Dữ liệu phụ ngoài ví dụ, gồm mã đầu tài liệu, vị trí xếp giá và thông tin phụ của thủ thư, chỉ phục vụ fixture.

## Mức xác minh khi bàn giao

Đã biên dịch toàn bộ lớp Java, chạy ReportExample với assertions, kiểm tra Java nhúng của 12 JSP bằng bộ giả lập API tối thiểu, và đối chiếu trang đích, thành phần biểu mẫu với hình gốc. Đã chạy mô phỏng các nhánh chọn thiếu dòng, giữ dữ liệu khi nhập lỗi, tổng 40.000 đồng, chặn in phiếu tạm và gửi lại lượt đã gắn id. Đã kiểm tra khóa ngoại của fixture trên bản DDL chuyển cú pháp sang SQLite trong bộ nhớ. MySqlScenario là bài kiểm thử tích hợp tái chạy được. Chưa chạy WAR trên Tomcat, MySQL thật hoặc máy in trong môi trường bàn giao.
