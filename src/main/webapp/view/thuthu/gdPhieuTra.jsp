<%@ include file="/WEB-INF/librarian.jspf" %>
<%
String draft = param(request, "draft");
String idParam = param(request, "idPhieu");
ReturnReceipt9 phieu = (ReturnReceipt9) request.getAttribute("printReceipt");
boolean printing = phieu != null;
String activeSelection = null;

if (phieu == null && !draft.isEmpty()) {
    synchronized (session) {
        ReturnReceipt9 sessionDraft = (ReturnReceipt9) session.getAttribute("draft." + draft);
        String selection = (String) session.getAttribute("selection." + draft);
        if (sessionDraft != null && selection != null
                && draft.equals(session.getAttribute("activeDraft." + selection))
                && (sessionDraft.getId() > 0 || sessionDraft.getLibrarian().getId() == thuthu.getId())) {
            phieu = sessionDraft;
            activeSelection = selection;
        } else if (idParam.isEmpty()) {
            response.sendError(409, "Phiếu tạm không hợp lệ hoặc đã được thay thế.");
            return;
        }
    }
}

if (phieu == null && !idParam.isEmpty() && request.getAttribute("message") == null) {
    int idPhieu = 0;
    try {
        idPhieu = Integer.parseInt(idParam);
    } catch (NumberFormatException ignored) {
    }
    if (idPhieu <= 0) {
        request.setAttribute("message", "Mã phiếu trả không hợp lệ.");
    } else {
        try (ReturnReceiptDAO dao = new ReturnReceiptDAO()) {
            phieu = dao.getPhieuTra(idPhieu);
            if (phieu == null) {
                request.setAttribute("message", "Không tìm thấy phiếu trả #" + idPhieu + ".");
            }
        } catch (SQLException e) {
            application.log("Đọc phiếu trả", e);
            request.setAttribute("message", "Chưa tải được phiếu trả #" + idPhieu + ".");
        }
    }
}

if (phieu == null && request.getAttribute("message") == null) {
    response.sendError(409);
    return;
}

boolean saved = phieu != null && phieu.getId() > 0;
Integer existingReceiptId = (Integer) request.getAttribute("existingReceiptId");
%>
<!doctype html>
<html lang="vi">
<meta charset="utf-8">
<title>Phiếu trả tài liệu</title>
<style>
  @media print { nav, [role=alert], .screen { display: none; } }
  table { border-collapse: collapse; }
  th, td { border: 1px solid; padding: .3em; }
</style>
<h1>Phiếu trả tài liệu</h1>
<%@ include file="/WEB-INF/error.jspf" %>
<% if (existingReceiptId != null) { %>
  <p class="screen">
    <a id="lnkDoiChieuPhieu" href="gdPhieuTra.jsp?idPhieu=<%=existingReceiptId%>">
      Mở phiếu trả #<%=existingReceiptId%> đã lưu để đối chiếu / in lại
    </a>
  </p>
<% } %>
<% if (phieu == null) { %>
  <form method="get" action="gdPhieuTra.jsp">
    <label>Mã phiếu trả <input type="number" min="1" required name="idPhieu" value="<%=h(idParam)%>"></label>
    <button name="btnTraPhieu">Xem phiếu trả</button>
  </form>
  <nav>
    <a id="btnTrangChu" href="gdChinh.jsp">Về trang chủ</a>
  </nav>
<% } else { %>
  <% if (saved && !printing) { %>
    <p class="screen"><%=draft.isEmpty() ? "Thông tin phiếu trả đã lưu." : "Nhận trả tài liệu thành công."%></p>
  <% } %>
  <p id="outBanDoc">Bạn đọc <%=h(phieu.getReader().getReaderCode())%> – <%=h(phieu.getReader().getFullName())%></p>
  <p id="outThuThu">Thủ thư <%=h(phieu.getLibrarian().getFullName())%></p>
  <p id="outNgayTra">Ngày trả <%=date(phieu.getReturnDate())%></p>
  <p id="outMaPhieu">Mã phiếu <%=saved ? phieu.getId() : "được cấp sau khi lưu thành công"%></p>
  <table id="tblChiTietTra">
    <tr>
      <th>Mã bản sao</th>
      <th>Tên tài liệu</th>
      <th>Phạt hỏng</th>
      <th>Phạt chậm</th>
      <th>Thành tiền</th>
    </tr>
    <% for (ReturnDetail9 d : phieu.getDetails()) { %>
      <tr>
        <td><%=h(d.getLoanDetail().getCopy().getCopyCode())%></td>
        <td><%=h(d.getLoanDetail().getCopy().getDocument().getTitle())%></td>
        <td><%=money(d.getDamageFine())%></td>
        <td><%=money(d.getLateFine())%></td>
        <td><%=money(d.tinhTienPhatDong())%></td>
      </tr>
    <% } %>
  </table>
  <p>Tình trạng lúc trả</p>
  <ul>
    <% for (ReturnDetail9 d : phieu.getDetails()) { %>
      <li><%=h(d.getLoanDetail().getCopy().getCopyCode())%> – <%=h(d.getConditionAtReturn())%></li>
    <% } %>
  </ul>
  <p id="outTongPhat"><strong>Tổng tiền phạt <%=money(phieu.tinhTongPhat())%> đồng</strong></p>
  <% if (saved) { %>
    <p id="outThanhToan"><%="PAID".equals(phieu.getPaymentStatus()) ? "Đã thanh toán (PAID)" : "Không phát sinh phạt (NO_FINE)"%></p>
  <% } %>
  <nav>
    <% if (!saved) { %>
      <p>
        <%=phieu.tinhTongPhat().signum() > 0
            ? "Chỉ bấm Xác nhận nhận trả sau khi đã thu đủ " + money(phieu.tinhTongPhat()) + " đồng."
            : "Không phát sinh phạt."%>
      </p>
      <% if (Boolean.TRUE.equals(request.getAttribute("conflict"))) { %>
        <form method="post" action="gdDSDangMuon.jsp">
          <input type="hidden" name="csrf" value="<%=csrf%>">
          <input type="hidden" name="inMaBanDoc" value="<%=h(phieu.getReader().getReaderCode())%>">
          <button>Tải lại danh sách đang mượn</button>
        </form>
      <% } else { %>
        <a id="btnQuayLai" href="gdChiTietTra.jsp?selection=<%=h(activeSelection)%>&amp;draft=<%=h(draft)%>">Quay lại</a>
        <form method="post" action="doLuuPhieuTra.jsp">
          <input type="hidden" name="csrf" value="<%=csrf%>">
          <input type="hidden" name="draft" value="<%=h(draft)%>">
          <button name="btnXacNhanTra">Xác nhận nhận trả</button>
        </form>
      <% } %>
      <button name="btnInPhieu" disabled>In phiếu trả</button>
    <% } else { %>
      <form method="get" action="doInPhieuTra.jsp">
        <input type="hidden" name="idPhieu" value="<%=phieu.getId()%>">
        <% if (!draft.isEmpty()) { %>
          <input type="hidden" name="draft" value="<%=h(draft)%>">
        <% } %>
        <button name="btnInPhieu">In phiếu trả</button>
      </form>
      <a id="btnTrangChu" href="gdChinh.jsp">Về trang chủ</a>
    <% } %>
  </nav>
  <% if (printing) { %>
    <script>window.addEventListener("load", () => window.print());</script>
  <% } %>
<% } %>
</html>
