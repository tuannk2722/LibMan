<%@ include file="/WEB-INF/librarian.jspf" %>
<%
String lookup = param(request, "lookup");
Reader9 banDoc;
LoanDetail9[] dsMuon;
ReturnReceipt9[] dsPhieuTra = null;

if (lookup.isEmpty()) {
    String soThe = param(request, "inSothe");
    String ma = param(request, "inMaBanDoc");
    String failure = null;
    banDoc = null;
    dsMuon = null;

    if (soThe.isEmpty() == ma.isEmpty()) {
        failure = "Vui lòng nhập đúng một loại mã.";
    } else {
        try (ReaderDAO readers = new ReaderDAO()) {
            banDoc = soThe.isEmpty() ? readers.getBanDocTheoMa(ma) : readers.getBanDocTheoSoThe(soThe);
            if (banDoc == null) {
                failure = "Không tìm được bạn đọc.";
            } else {
                try (LoanDetailDAO loans = new LoanDetailDAO();
                     ReturnReceiptDAO receipts = new ReturnReceiptDAO()) {
                    dsMuon = loans.getDSDangMuon(banDoc.getId());
                    dsPhieuTra = receipts.getDSPhieuTraTheoBanDoc(banDoc.getId());
                }
            }
        } catch (SQLException e) {
            application.log("Tra bạn đọc và dòng mượn", e);
            failure = "Chưa tải được dữ liệu. Vui lòng tra lại.";
        }
    }

    if (failure != null) {
        request.setAttribute("message", failure);
        request.getRequestDispatcher("gdTimBanDoc.jsp").forward(request, response);
        return;
    }

    lookup = UUID.randomUUID().toString();
    synchronized (session) {
        session.setAttribute("reader." + lookup, banDoc);
        session.setAttribute("loans." + lookup, dsMuon);
    }
} else {
    synchronized (session) {
        banDoc = (Reader9) session.getAttribute("reader." + lookup);
        dsMuon = (LoanDetail9[]) session.getAttribute("loans." + lookup);
    }
    if (banDoc == null || dsMuon == null) {
        response.sendError(409);
        return;
    }
    try (ReturnReceiptDAO receipts = new ReturnReceiptDAO()) {
        dsPhieuTra = receipts.getDSPhieuTraTheoBanDoc(banDoc.getId());
    } catch (SQLException e) {
        application.log("Lịch sử phiếu trả", e);
        dsPhieuTra = new ReturnReceipt9[0];
    }
}
%>
<!doctype html>
<html lang="vi">
<meta charset="utf-8">
<title>Danh sách tài liệu đang mượn</title>
<h1>Danh sách tài liệu đang mượn</h1>
<p id="outBanDoc">Mã bạn đọc <%=h(banDoc.getReaderCode())%> · Họ tên <%=h(banDoc.getFullName())%></p>
<%@ include file="/WEB-INF/error.jspf" %>
<% if (dsMuon.length == 0) { %>
  <p>Bạn đọc không có dòng mượn đang mở.</p>
  <a href="gdChinh.jsp">Về trang chủ</a>
<% } else { %>
  <form method="post" action="gdChiTietTra.jsp">
    <input type="hidden" name="csrf" value="<%=csrf%>">
    <input type="hidden" name="lookup" value="<%=h(lookup)%>">
    <table id="tblDangMuon">
      <tr>
        <th>Chọn</th>
        <th>Mã bản sao</th>
        <th>Tên tài liệu</th>
        <th>Ngày mượn</th>
        <th>Hạn trả</th>
      </tr>
      <% for (LoanDetail9 ld : dsMuon) { %>
        <tr>
          <td>
            <input type="checkbox" name="chonTra"
                aria-label="Chọn <%=h(ld.getCopy().getCopyCode())%>"
                value="<%=ld.getId()%>">
          </td>
          <td><%=h(ld.getCopy().getCopyCode())%></td>
          <td><%=h(ld.getCopy().getDocument().getTitle())%></td>
          <td><%=date(ld.getLoan().getBorrowDate())%></td>
          <td><%=date(ld.getDueDate())%></td>
        </tr>
      <% } %>
    </table>
    <button name="btnTiepTuc">Tiếp tục</button>
  </form>
<% } %>
<% if (dsPhieuTra != null && dsPhieuTra.length > 0) { %>
  <h2>Phiếu trả đã lưu gần đây</h2>
  <table id="tblPhieuTraGanDay">
    <tr>
      <th>Mã phiếu</th>
      <th>Ngày trả</th>
      <th>Tổng phạt</th>
      <th>Trạng thái</th>
      <th>Thao tác</th>
    </tr>
    <% for (ReturnReceipt9 pt : dsPhieuTra) { %>
      <tr>
        <td>#<%=pt.getId()%></td>
        <td><%=date(pt.getReturnDate())%></td>
        <td><%=money(pt.tinhTongPhat())%> đồng</td>
        <td><%=h(pt.getPaymentStatus())%></td>
        <td><a href="gdPhieuTra.jsp?idPhieu=<%=pt.getId()%>">Xem / In lại</a></td>
      </tr>
    <% } %>
  </table>
<% } %>
<a id="btnTimLai" href="gdTimBanDoc.jsp">Tìm bạn đọc khác</a>
</html>
