# Đối chiếu thông điệp với mã nguồn

Mỗi hàng dùng diễn giải của kịch bản phiên bản 3 trong báo cáo. Cột cuối chỉ ra nơi thực hiện hoặc nơi nhận kết quả. Hành động tại quầy do thủ thư thực hiện.

## Hình 3.6 — Đăng kí làm thẻ

| Bước | Kịch bản trong báo cáo | Vị trí trong khung |
|---:|---|---|
| 1 | Tại trang gdChinh.jsp, bạn đọc chọn chức năng Đăng kí làm thẻ bạn đọc. | bandoc/gdChinh.jsp → gdDangKyThe.jsp |
| 2 | Trang gdChinh.jsp gọi trang gdDangKyThe.jsp. | bandoc/gdChinh.jsp → gdDangKyThe.jsp |
| 3 | Trang gdDangKyThe.jsp gọi lớp ReaderDAO, yêu cầu lấy hồ sơ của bạn đọc đang đăng nhập. | gdDangKyThe.jsp |
| 4 | Lớp ReaderDAO thực hiện phương thức getHoSoBanDoc(id), với id được lấy từ phiên đăng nhập, để truy xuất hồ sơ bạn đọc. | ReaderDAO.getHoSoBanDoc → read → Reader9 |
| 5 | Phương thức getHoSoBanDoc(id) gọi lớp Reader9 để đóng gói thông tin hồ sơ vừa truy xuất. | ReaderDAO.getHoSoBanDoc → read → Reader9 |
| 6 | Lớp Reader9 khởi tạo đối tượng và đóng gói thông tin bạn đọc, gồm mã bạn đọc và các thông tin cá nhân kế thừa từ Member9. | ReaderDAO.getHoSoBanDoc → read → Reader9 |
| 7 | Lớp Reader9 trả đối tượng hồ sơ bạn đọc về cho phương thức getHoSoBanDoc(id) của lớp ReaderDAO. | ReaderDAO.getHoSoBanDoc → read → Reader9 |
| 8 | Lớp ReaderDAO trả hồ sơ bạn đọc về trang gdDangKyThe.jsp. | ReaderDAO.getHoSoBanDoc → read → Reader9 |
| 9 | Trang gdDangKyThe.jsp hiển thị biểu mẫu đăng kí, gồm mã bạn đọc, họ tên, ngày sinh, địa chỉ, điện thoại, email, trường chọn loại thẻ và các nút Thêm, Quay lại. Mã bạn đọc chỉ được hiển thị, không cho phép chỉnh sửa. | gdDangKyThe.jsp → doLuuDangKyThe.jsp |
| 10 | Bạn đọc rà soát hoặc cập nhật thông tin: họ tên Nguyễn Thị Mai, ngày sinh 15/03/2005, địa chỉ Hà Đông, Hà Nội, điện thoại 0912345678, email maitn@example.com; chọn loại thẻ Sinh viên và bấm Thêm. | gdDangKyThe.jsp → doLuuDangKyThe.jsp |
| 11 | Trang gdDangKyThe.jsp gọi trang doLuuDangKyThe.jsp, chuyển thông tin hồ sơ và loại thẻ đã chọn để xử lí đăng kí. Định danh bạn đọc được xác định theo phiên đăng nhập. | gdDangKyThe.jsp → doLuuDangKyThe.jsp |
| 12 | Trang doLuuDangKyThe.jsp gọi lớp LibraryCardDAO, yêu cầu đăng kí thẻ cho hồ sơ hoSo với loại thẻ type. | doLuuDangKyThe.jsp |
| 13 | Lớp LibraryCardDAO thực hiện phương thức dangKyThe(hoSo, type). Phương thức kiểm tra dữ liệu đầu vào, mở giao dịch và khóa hồ sơ bạn đọc trước khi kiểm tra điều kiện cấp thẻ. | LibraryCardDAO.dangKyThe |
| 14 | Trong quá trình thực hiện dangKyThe(hoSo, type), lớp LibraryCardDAO gọi nội bộ phương thức getThe(readerId) để kiểm tra thẻ còn hiệu lực của bạn đọc trên cùng kết nối và giao dịch. Trong luồng thành công, không tìm thấy thẻ còn hiệu lực nên quá trình cấp thẻ được tiếp tục. | LibraryCardDAO.getThe |
| 15 | Phương thức dangKyThe(hoSo, type) xác lập thông tin thẻ mới và gọi lớp LibraryCard9 để đóng gói thông tin thẻ. | LibraryCardDAO.dangKyThe → LibraryCard9 |
| 16 | Lớp LibraryCard9 khởi tạo và đóng gói thẻ mới: số thẻ T009089, loại Sinh viên, ngày cấp 22/08/2026, ngày hết hạn theo loại thẻ, trạng thái ban đầu và hồ sơ DG009. Ngày cấp minh họa đứng trước các lần mượn tháng 09/2026 trong kịch bản nhận trả. | LibraryCardDAO.dangKyThe → LibraryCard9 |
| 17 | Lớp LibraryCard9 trả đối tượng thẻ mới theMoi về cho lớp LibraryCardDAO. | LibraryCardDAO.dangKyThe → LibraryCard9 |
| 18 | Phương thức dangKyThe(hoSo, type) lưu thay đổi hồ sơ và thẻ mới trong cùng một giao dịch. Sau khi lưu và commit thành công, lớp LibraryCardDAO trả đối tượng thẻ đã lưu về trang doLuuDangKyThe.jsp. | LibraryCardDAO.dangKyThe → ReaderDAO(shared) → commit |
| 19 | Trang doLuuDangKyThe.jsp gọi trang gdKetQua.jsp, chuyển kết quả đăng kí gồm mã bạn đọc và số thẻ vừa cấp. | doLuuDangKyThe.jsp → gdKetQua.jsp |
| 20 | Trang gdKetQua.jsp hiển thị thông báo: “Đăng kí làm thẻ bạn đọc thành công. Mã bạn đọc: DG009. Số thẻ: T009089”. | gdKetQua.jsp |
| 21 | Bạn đọc bấm nút OK trên trang gdKetQua.jsp. | gdKetQua.jsp |
| 22 | Trang gdKetQua.jsp gọi trang gdChinh.jsp. | gdKetQua.jsp → bandoc/gdChinh.jsp |
| 23 | Trang gdChinh.jsp hiển thị lại giao diện chính của bạn đọc; lượt đăng kí làm thẻ kết thúc. | gdKetQua.jsp → bandoc/gdChinh.jsp |

## Hình 3.10 — Nhận trả tài liệu

| Bước | Kịch bản trong báo cáo | Vị trí trong khung |
|---:|---|---|
| 1 | Thủ thư Trần Thu Hà đã đăng nhập, chọn Nhận trả tài liệu tại gdChinh.jsp. | thuthu/gdChinh.jsp → gdTimBanDoc.jsp |
| 2 | gdChinh.jsp gọi gdTimBanDoc.jsp và giữ thông tin thủ thư từ phiên đăng nhập. | thuthu/gdChinh.jsp → gdTimBanDoc.jsp |
| 3 | gdTimBanDoc.jsp hiển thị ô số thẻ, ô mã bạn đọc và nút Tìm. | gdTimBanDoc.jsp → gdDSDangMuon.jsp |
| 4 | Thủ thư quét thẻ T009089 của Nguyễn Thị Mai và bấm Tìm; chỉ sử dụng một loại mã tra cứu. | gdTimBanDoc.jsp → gdDSDangMuon.jsp |
| 5 | gdTimBanDoc.jsp gọi gdDSDangMuon.jsp, chuyển số thẻ đã đọc. | gdTimBanDoc.jsp → gdDSDangMuon.jsp |
| 6 | gdDSDangMuon.jsp gọi ReaderDAO để xác định hồ sơ từ số thẻ. | gdDSDangMuon.jsp → ReaderDAO.getBanDocTheoSoThe |
| 7 | ReaderDAO thực hiện getBanDocTheoSoThe(soThe), tra thẻ và hồ sơ chủ thẻ trong CSDL. | gdDSDangMuon.jsp → ReaderDAO.getBanDocTheoSoThe |
| 8 | ReaderDAO gọi Reader9 để đóng gói hồ sơ truy xuất được. | ReaderDAO.read → Reader9 → gdDSDangMuon.jsp |
| 9 | Reader9 được khởi tạo và đóng gói readerCode cùng thông tin cá nhân kế thừa từ Member9; hồ sơ là DG009, Nguyễn Thị Mai. | ReaderDAO.read → Reader9 → gdDSDangMuon.jsp |
| 10 | Reader9 trả đối tượng banDoc về ReaderDAO. | ReaderDAO.read → Reader9 → gdDSDangMuon.jsp |
| 11 | ReaderDAO trả banDoc về gdDSDangMuon.jsp. | ReaderDAO.read → Reader9 → gdDSDangMuon.jsp |
| 12 | gdDSDangMuon.jsp gọi LoanDetailDAO để lấy các dòng mượn của bạn đọc vừa xác định. | gdDSDangMuon.jsp → LoanDetailDAO.getDSDangMuon |
| 13 | LoanDetailDAO thực hiện getDSDangMuon(readerId), chỉ truy vấn các dòng OPEN thuộc bạn đọc đó. | gdDSDangMuon.jsp → LoanDetailDAO.getDSDangMuon |
| 14 | LoanDetailDAO gọi LoanDetail9 để đóng gói kết quả truy vấn. Các tham chiếu loan, copy và copy.document được nạp đủ dữ liệu hiển thị. | LoanDetailDAO.read → LoanDetail9[] → gdDSDangMuon.jsp |
| 15 | LoanDetail9 được khởi tạo cho từng dòng kết quả, gồm id, dueDate, status và các tham chiếu liên quan; thu được danh sách TL001, TL015, TL102. | LoanDetailDAO.read → LoanDetail9[] → gdDSDangMuon.jsp |
| 16 | Các đối tượng LoanDetail9 được tập hợp thành dsMuon và trả về LoanDetailDAO. | LoanDetailDAO.read → LoanDetail9[] → gdDSDangMuon.jsp |
| 17 | LoanDetailDAO trả mảng dsMuon về gdDSDangMuon.jsp. | LoanDetailDAO.read → LoanDetail9[] → gdDSDangMuon.jsp |
| 18 | gdDSDangMuon.jsp hiển thị mã và họ tên bạn đọc; mỗi dòng gồm mã bản sao, tên tài liệu, ngày mượn và hạn trả. | gdDSDangMuon.jsp |
| 19 | Thủ thư đối chiếu tài liệu thực nhận, chọn TL001 và TL102 rồi bấm Tiếp tục; TL015 không được chọn. | gdDSDangMuon.jsp |
| 20 | gdDSDangMuon.jsp gọi gdChiTietTra.jsp, chuyển các dòng mượn đã chọn, bạn đọc và thông tin thủ thư trong phiên. | gdDSDangMuon.jsp → gdChiTietTra.jsp |
| 21 | gdChiTietTra.jsp hiển thị hai bản sao đã chọn, ngày trả của hệ thống và các ô tình trạng, phạt hỏng, phạt chậm. | gdDSDangMuon.jsp → gdChiTietTra.jsp |
| 22 | Thủ thư nhập TL001: Bình thường, phạt hỏng 0, phạt chậm 10.000 đồng; TL102: Hỏng, phạt hỏng 20.000, phạt chậm 10.000 đồng; bấm Lập phiếu tạm. Ngày trả minh họa là 22/09/2026, lấy từ hệ thống. | gdChiTietTra.jsp → doLapPhieuTam.jsp |
| 23 | gdChiTietTra.jsp gọi doLapPhieuTam.jsp, chuyển tình trạng và hai khoản phạt của từng dòng được chọn. | gdChiTietTra.jsp → doLapPhieuTam.jsp |
| 24 | doLapPhieuTam.jsp kiểm tra danh sách không rỗng, tình trạng được nhập và tiền phạt là số không âm; định danh dòng mượn được đối chiếu với danh sách của bạn đọc trong phiên. | doLapPhieuTam.jsp |
| 25 | doLapPhieuTam.jsp gọi ReturnDetail9 cho mỗi dòng trả cần tạo trong bộ nhớ. | doLapPhieuTam.jsp → ReturnDetail9.tinhTienPhatDong |
| 26 | ReturnDetail9 được khởi tạo và nhận loanDetail, conditionAtReturn, damageFine, lateFine của dòng tương ứng. | doLapPhieuTam.jsp → ReturnDetail9.tinhTienPhatDong |
| 27 | ReturnDetail9 thực hiện tinhTienPhatDong(), cộng damageFine và lateFine; kết quả lần lượt là 10.000 và 30.000 đồng. | doLapPhieuTam.jsp → ReturnDetail9.tinhTienPhatDong |
| 28 | ReturnDetail9 trả dòng trả đã tính tiền cho doLapPhieuTam.jsp; lặp các bước 25–28 đến khi có đủ dsTra. | doLapPhieuTam.jsp → ReturnDetail9.tinhTienPhatDong |
| 29 | doLapPhieuTam.jsp gọi ReturnReceipt9 để tạo phiếu tạm từ bạn đọc, thủ thư, ngày trả của hệ thống và dsTra. | doLapPhieuTam.jsp → ReturnReceipt9.tinhTongPhat |
| 30 | ReturnReceipt9 được khởi tạo và nhận reader, librarian, returnDate, details; phiếu chưa có id do CSDL cấp và chưa được lưu. | doLapPhieuTam.jsp → ReturnReceipt9.tinhTongPhat |
| 31 | ReturnReceipt9 thực hiện tinhTongPhat(), cộng tiền phạt các dòng để được 40.000 đồng. | doLapPhieuTam.jsp → ReturnReceipt9.tinhTongPhat |
| 32 | ReturnReceipt9 trả phieuTam về doLapPhieuTam.jsp; trang giữ phiếu tạm trong phiên, chưa ghi CSDL. | doLapPhieuTam.jsp → ReturnReceipt9.tinhTongPhat |
| 33 | doLapPhieuTam.jsp gọi gdPhieuTra.jsp để hiển thị phiếu tạm. | doLapPhieuTam.jsp → gdPhieuTra.jsp |
| 34 | gdPhieuTra.jsp hiển thị bạn đọc, thủ thư, hai dòng trả và tổng phạt 40.000 đồng để đối chiếu. Phiếu chưa có id chính thức; nút In phiếu trả chưa được phép dùng. | gdPhieuTra.jsp và thủ thư tại quầy |
| 35 | Thủ thư đối chiếu phiếu tạm, thu đủ 40.000 đồng từ bạn đọc tại quầy rồi bấm Xác nhận nhận trả. Đây đồng thời là xác nhận đã thu đủ tiền phạt. | gdPhieuTra.jsp và thủ thư tại quầy |
| 36 | gdPhieuTra.jsp gọi doLuuPhieuTra.jsp; trang xử lí lấy phieuTam từ phiên, không dùng dữ liệu tổng tiền do trình duyệt gửi làm căn cứ. | gdPhieuTra.jsp → doLuuPhieuTra.jsp → ReturnReceiptDAO |
| 37 | doLuuPhieuTra.jsp gọi ReturnReceiptDAO để lưu lần nhận trả. | gdPhieuTra.jsp → doLuuPhieuTra.jsp → ReturnReceiptDAO |
| 38 | ReturnReceiptDAO thực hiện xacNhanTra(phieuTam) trên cùng kết nối và giao dịch: khóa bản sao và dòng mượn; kiểm tra OPEN, đúng bạn đọc, chưa có dòng trả; kiểm tra và tính lại phạt; lưu phiếu PAID cùng chi tiết, đóng đúng dòng mượn và cập nhật bản sao; commit khi tất cả thành công. | ReturnReceiptDAO.xacNhanTra |
| 39 | ReturnReceiptDAO trả phieuDaLuu có id và paymentStatus = PAID về doLuuPhieuTra.jsp. TL015 vẫn OPEN. | ReturnReceiptDAO.xacNhanTra |
| 40 | doLuuPhieuTra.jsp trả kết quả cho gdPhieuTra.jsp, đánh dấu phiếu tạm đã xử lí để không xác nhận lại thành một lần trả mới. | doLuuPhieuTra.jsp → gdPhieuTra.jsp |
| 41 | gdPhieuTra.jsp thông báo Nhận trả tài liệu thành công, hiển thị mã phiếu, tổng phạt 40.000 đồng và trạng thái Đã thanh toán; cho phép in. | gdPhieuTra.jsp → doInPhieuTra.jsp |
| 42 | Thủ thư bấm In phiếu trả. | gdPhieuTra.jsp → doInPhieuTra.jsp |
| 43 | gdPhieuTra.jsp gọi doInPhieuTra.jsp, truyền idPhieu của phiếu đã lưu. | gdPhieuTra.jsp → doInPhieuTra.jsp |
| 44 | doInPhieuTra.jsp gọi ReturnReceiptDAO để nạp phiếu chính thức. | doInPhieuTra.jsp → ReturnReceiptDAO.getPhieuTra |
| 45 | ReturnReceiptDAO thực hiện getPhieuTra(idPhieu), truy xuất phiếu, chi tiết và các dữ liệu liên quan. | doInPhieuTra.jsp → ReturnReceiptDAO.getPhieuTra |
| 46 | ReturnReceiptDAO gọi ReturnReceipt9 để đóng gói kết quả truy xuất. | ReturnReceiptDAO.getPhieuTra → ReturnReceipt9 → doInPhieuTra.jsp |
| 47 | ReturnReceipt9 khởi tạo đối tượng phieu gồm id, returnDate, paymentStatus, bạn đọc, thủ thư và các chi tiết. /totalFine được tính từ các khoản phạt đã lưu trên dòng, vẫn là 40.000 đồng; hình không tách phép tính này thành một thông điệp riêng. | ReturnReceiptDAO.getPhieuTra → ReturnReceipt9 → doInPhieuTra.jsp |
| 48 | ReturnReceipt9 trả đối tượng phieu về ReturnReceiptDAO. | ReturnReceiptDAO.getPhieuTra → ReturnReceipt9 → doInPhieuTra.jsp |
| 49 | ReturnReceiptDAO trả phieu về doInPhieuTra.jsp. | ReturnReceiptDAO.getPhieuTra → ReturnReceipt9 → doInPhieuTra.jsp |
| 50 | doInPhieuTra.jsp kiểm tra phiếu tồn tại, có trạng thái PAID hoặc NO_FINE và trả nội dung in về gdPhieuTra.jsp. | doInPhieuTra.jsp → gdPhieuTra.jsp |
| 51 | gdPhieuTra.jsp hiển thị bản in cho thủ thư và kích hoạt hộp thoại in. Thủ thư xác nhận in, nhận phiếu từ máy in và giao bạn đọc; các thao tác tại quầy không tạo lời gọi ghi CSDL. | gdPhieuTra.jsp và hộp thoại in |
| 52 | Thủ thư chọn Về trang chủ trên gdPhieuTra.jsp. | gdPhieuTra.jsp và hộp thoại in |
| 53 | gdPhieuTra.jsp gọi gdChinh.jsp. | gdPhieuTra.jsp → thuthu/gdChinh.jsp |
| 54 | gdChinh.jsp hiển thị lại giao diện chính của thủ thư; lượt nhận trả kết thúc. | gdPhieuTra.jsp → thuthu/gdChinh.jsp |
