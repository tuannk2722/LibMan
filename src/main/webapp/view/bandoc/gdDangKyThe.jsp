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
LibraryCard9 theHienTai = null;
try (LibraryCardDAO cardDao = new LibraryCardDAO()) {
    theHienTai = cardDao.getThe(bandoc.getId());
} catch (SQLException e) {
    application.log("Kiểm tra thẻ hiện hành", e);
}
String selectedType = param(request, "inoutLoaiThe");
if (selectedType.isEmpty()) selectedType = "Sinh viên";
request.setAttribute("pageTitle", "Đăng kí làm thẻ bạn đọc");
%>
<%@ include file="/WEB-INF/header.jspf" %>
<section class="card">
  <div class="card-header">
    <div>
      <h1>Đăng kí làm thẻ bạn đọc</h1>
      <p class="page-subtitle">Rà soát thông tin cá nhân và chọn loại thẻ muốn đăng kí</p>
    </div>
  </div>
  <%@ include file="/WEB-INF/error.jspf" %>
  <% if (theHienTai != null) { %>
    <div class="alert alert-warning">
      <div>
        Bạn đọc hiện đã có thẻ hiệu lực số <strong class="mono"><%=h(theHienTai.getCardNumber())%></strong>
        (loại <strong><%=h(theHienTai.getCardType())%></strong>, hạn đến <strong class="mono"><%=date(theHienTai.getExpiryDate())%></strong>).
        Nếu cần cấp lại hoặc gia hạn, vui lòng liên hệ thư viện.
      </div>
    </div>
  <% } %>
  <form method="post" action="doLuuDangKyThe.jsp">
    <input type="hidden" name="csrf" value="<%=csrf%>">
    <fieldset>
      <legend>Thông tin bạn đọc</legend>
      <div class="form-row">
        <span class="form-label">Mã bạn đọc</span>
        <div class="form-control">
          <output id="outMaBanDoc" class="code-pill"><%=h(hoSo.getReaderCode())%></output>
        </div>
      </div>
      <div class="form-row">
        <label class="form-label" for="inoutHoTen">Họ tên</label>
        <div class="form-control">
          <input id="inoutHoTen" required maxlength="255" type="text" name="inoutHoTen"
              value='<%=input(request, "inoutHoTen", hoSo.getFullName())%>'>
        </div>
      </div>
      <div class="form-row">
        <label class="form-label" for="inoutNgaySinh">Ngày sinh</label>
        <div class="form-control">
          <input id="inoutNgaySinh" required maxlength="255" type="date"
              min="1900-01-01" max="<%=LocalDate.now()%>" name="inoutNgaySinh"
              value='<%=input(request, "inoutNgaySinh", hoSo.getBirthDate())%>'>
        </div>
      </div>
      <div class="form-row">
        <label class="form-label" for="inoutDiaChi">Địa chỉ</label>
        <div class="form-control">
          <input id="inoutDiaChi" required maxlength="255" type="text" name="inoutDiaChi"
              value='<%=input(request, "inoutDiaChi", hoSo.getAddress())%>'>
        </div>
      </div>
      <div class="form-row">
        <label class="form-label" for="inoutDienThoai">Điện thoại</label>
        <div class="form-control">
          <input id="inoutDienThoai" required maxlength="255" type="tel" pattern="[+]?[0-9]{8,15}"
              title="Nhập từ 8 đến 15 chữ số, có thể bắt đầu bằng dấu +" name="inoutDienThoai"
              value='<%=input(request, "inoutDienThoai", hoSo.getPhone())%>'>
        </div>
      </div>
      <div class="form-row">
        <label class="form-label" for="inoutEmail">Email</label>
        <div class="form-control">
          <input id="inoutEmail" required maxlength="255" type="email" name="inoutEmail"
              value='<%=input(request, "inoutEmail", hoSo.getEmail())%>'>
        </div>
      </div>
    </fieldset>
    <fieldset>
      <legend>Thông tin thẻ</legend>
      <div class="form-row">
        <label class="form-label" for="inoutLoaiThe">Loại thẻ</label>
        <div class="form-control">
          <select id="inoutLoaiThe" required name="inoutLoaiThe">
            <option value="Sinh viên" <%="Sinh viên".equals(selectedType) ? "selected" : ""%>>Sinh viên</option>
            <option value="Thủ thư" <%="Thủ thư".equals(selectedType) ? "selected" : ""%>>Thủ thư</option>
          </select>
          <p class="form-hint">Thời hạn hiệu lực mặc định của thẻ là 12 tháng kể từ ngày cấp.</p>
        </div>
      </div>
    </fieldset>
    <div class="form-actions">
      <button class="btn btn-secondary" name="btnQuayLai" formaction="gdChinh.jsp" formnovalidate>Quay lại</button>
      <button class="btn btn-primary" name="btnThem">Thêm</button>
    </div>
  </form>
</section>
<%@ include file="/WEB-INF/footer.jspf" %>
