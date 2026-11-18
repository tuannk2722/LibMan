<%@ include file="/WEB-INF/reader.jspf" %>
<%
Reader9 hoSo = (Reader9) session.getAttribute("hoSoDangKy");
if (request.getAttribute("message") == null || hoSo == null || hoSo.getId() != bandoc.getId()) {
    try (ReaderDAO dao = new ReaderDAO()) {
        hoSo = dao.getHoSoBanDoc(bandoc.getId());
    } catch (SQLException e) {
        application.log("Đọc hồ sơ", e);
        response.sendError(503, "Chưa tải được hồ sơ bạn đọc");
        return;
    }
    if (hoSo == null) {
        response.sendError(404);
        return;
    }
    session.setAttribute("hoSoDangKy", hoSo);
}
String selectedType = param(request, "inoutLoaiThe");
if (selectedType.isEmpty()) selectedType = "Sinh viên";
%>
<!doctype html>
<html lang="vi">
<meta charset="utf-8">
<title>Đăng kí làm thẻ bạn đọc</title>
<h1>Đăng kí làm thẻ bạn đọc</h1>
<%@ include file="/WEB-INF/error.jspf" %>
<form method="post" action="doLuuDangKyThe.jsp">
  <input type="hidden" name="csrf" value="<%=csrf%>">
  <fieldset>
    <legend>Thông tin bạn đọc</legend>
    <p>Mã bạn đọc <output id="outMaBanDoc"><%=h(hoSo.getReaderCode())%></output></p>
    <p><label>Họ tên <input required maxlength="255" type="text" name="inoutHoTen"
        value='<%=input(request, "inoutHoTen", hoSo.getFullName())%>'></label></p>
    <p><label>Ngày sinh <input required maxlength="255" type="date" name="inoutNgaySinh"
        value='<%=input(request, "inoutNgaySinh", hoSo.getBirthDate())%>'></label></p>
    <p><label>Địa chỉ <input required maxlength="255" type="text" name="inoutDiaChi"
        value='<%=input(request, "inoutDiaChi", hoSo.getAddress())%>'></label></p>
    <p><label>Điện thoại <input required maxlength="255" type="tel" pattern="[+]?[0-9]{8,15}"
        title="Nhập từ 8 đến 15 chữ số, có thể bắt đầu bằng dấu +" name="inoutDienThoai"
        value='<%=input(request, "inoutDienThoai", hoSo.getPhone())%>'></label></p>
    <p><label>Email <input required maxlength="255" type="email" name="inoutEmail"
        value='<%=input(request, "inoutEmail", hoSo.getEmail())%>'></label></p>
  </fieldset>
  <fieldset>
    <legend>Thông tin thẻ</legend>
    <label>Loại thẻ
      <select required name="inoutLoaiThe">
        <option value="Sinh viên" <%="Sinh viên".equals(selectedType) ? "selected" : ""%>>Sinh viên</option>
        <option value="Thủ thư" <%="Thủ thư".equals(selectedType) ? "selected" : ""%>>Thủ thư</option>
      </select>
    </label>
  </fieldset>
  <button name="btnQuayLai" formaction="gdChinh.jsp" formnovalidate>Quay lại</button>
  <button name="btnThem">Thêm</button>
</form>
</html>
