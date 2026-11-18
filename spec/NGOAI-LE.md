# Các nhánh nghiệm thu theo đặc tả

## Đăng kí làm thẻ

- 4.1. Bạn đọc Mai nhập sai tên đăng nhập hoặc mật khẩu và click Đăng nhập.
- 4.2. Hệ thống thông báo "Tên đăng nhập hoặc mật khẩu không đúng". Bạn đọc click OK, nhập lại thông tin đúng và tiếp tục bước 5.
- 9.1. Bạn đọc bỏ trống một trường bắt buộc hoặc nhập dữ liệu sai định dạng (ví dụ số điện thoại hoặc email không hợp lệ) rồi click Thêm.
- 9.2. Hệ thống đánh dấu trường không hợp lệ và thông báo yêu cầu nhập đầy đủ/đúng định dạng; bạn đọc sửa dữ liệu rồi thực hiện lại bước 9.
- 10.1. Thông tin xác định bạn đọc cho thấy người này đã có thẻ còn hiệu lực trong hệ thống.
- 10.2. Hệ thống không tạo thẻ mới và thông báo "Bạn đọc đã có thẻ. Vui lòng liên hệ thư viện nếu cần cấp lại/gia hạn"; kết thúc lần đăng kí.
- 12.1. Trong lúc lưu dữ liệu xảy ra lỗi hệ thống/CSDL.
- 12.2. Hệ thống không ghi nhận bản đăng kí chưa hoàn tất, thông báo "Đăng kí chưa thành công, vui lòng thử lại" và giữ dữ liệu trên giao diện để bạn đọc thực hiện lại bước 9.

## Nhận trả tài liệu

- 4.1. Đăng nhập sai: hệ thống báo lỗi, nhân viên nhập lại; khi hợp lệ tiếp tục bước 5.
- 8.1. Không quét được thẻ: nhập mã DG009 và bấm Tìm; nếu tìm thấy thì tiếp tục bước 9.
- 9.1. Không tìm được bạn đọc: thông báo và giữ giao diện để tra lại.
- 9.2. Bạn đọc không có dòng mượn OPEN: thông báo và kết thúc lần tiếp nhận.
- 11.1. Bản sao không nằm trong danh sách đang mượn: không cho chọn; thủ thư đối chiếu lại mã bản sao và hồ sơ.
- 11.2. Chưa chọn dòng nào mà bấm Tiếp tục: báo lỗi, giữ danh sách để chọn ít nhất một dòng.
- 13.1. Không có khoản phạt: nhập 0 cho khoản tương ứng. Tổng phạt bằng 0 thì bỏ qua thu tiền ở bước 15; khi xác nhận lưu NO_FINE.
- 13.2. Thiếu tình trạng hoặc tiền phạt không phải số không âm: báo lỗi và giữ chi tiết đã nhập để sửa, chưa lập phiếu tạm.
- 15.1. Chưa thu đủ tiền phạt: thủ thư chưa bấm Xác nhận nhận trả; phiếu vẫn tạm, các dòng mượn chưa thay đổi.
- 17.1. Dòng mượn không còn OPEN, không thuộc bạn đọc hoặc đã có dòng trả: không lưu lần trả mới; tải lại danh sách và đối chiếu giao dịch đã có cùng khoản tiền đã thu.
- 18.1. Lỗi lưu: rollback toàn bộ, giữ phiếu tạm và báo Lưu phiếu trả chưa thành công. Thủ thư đối chiếu khoản đã thu rồi thử lại bước 16; không thu thêm tiền lần nữa. Nếu dừng lần nhận trả chưa lưu, thủ thư hoàn lại khoản đã thu tại quầy.
- 18.2. Gửi lại yêu cầu đã lưu thành công: trả lại phiếu đã lưu của cùng lượt xử lí, không tạo thêm phiếu hoặc chi tiết; nếu chưa xác định được kết quả, đối chiếu lần trả trước khi thử lại.
- 21.1. In lỗi hoặc hết giấy: phiếu vẫn được giữ trong CSDL; khắc phục máy in rồi in lại cùng mã phiếu.
