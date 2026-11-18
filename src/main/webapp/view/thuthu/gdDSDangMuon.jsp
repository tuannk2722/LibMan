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
LocalDate todayRef = LocalDate.now();
request.setAttribute("pageTitle", "Danh sách tài liệu đang mượn");
%>
<%@ include file="/WEB-INF/header.jspf" %>
<ol class="stepper screen" aria-label="Tiến trình nhận trả tài liệu">
  <li class="step is-done"><span class="step-num">1</span><span class="step-label">Xác định bạn đọc</span></li>
  <li class="step is-active"><span class="step-num">2</span><span class="step-label">Chọn sách trả</span></li>
  <li class="step"><span class="step-num">3</span><span class="step-label">Tình trạng &amp; Tiền phạt</span></li>
  <li class="step"><span class="step-num">4</span><span class="step-label">Phiếu trả &amp; In phiếu</span></li>
</ol>
<section class="card">
  <div class="card-header">
    <div>
      <h1>Danh sách tài liệu đang mượn</h1>
      <p class="page-subtitle">Đối chiếu tài liệu thực nhận tại quầy và chọn các bản sao bạn đọc trả lần này</p>
    </div>
    <span class="badge badge-info">Đang mượn: <%=dsMuon.length%> bản sao</span>
  </div>
  <div id="outBanDoc" class="meta-grid">
    <div class="meta-item">
      <span class="meta-label">Mã bạn đọc</span>
      <span class="meta-value mono"><%=h(banDoc.getReaderCode())%></span>
    </div>
    <div class="meta-item">
      <span class="meta-label">Họ tên</span>
      <span class="meta-value"><%=h(banDoc.getFullName())%></span>
    </div>
  </div>
  <%@ include file="/WEB-INF/error.jspf" %>
  <% if (dsMuon.length == 0) { %>
    <div class="alert alert-info">
      <div>Bạn đọc không có dòng mượn đang mở.</div>
    </div>
    <div class="form-actions">
      <a id="btnTimLai" class="btn btn-secondary" href="gdTimBanDoc.jsp">Tìm bạn đọc khác</a>
      <a class="btn btn-primary" href="gdChinh.jsp">Về trang chủ</a>
    </div>
  <% } else { %>
    <form method="post" action="gdChiTietTra.jsp">
      <input type="hidden" name="csrf" value="<%=csrf%>">
      <input type="hidden" name="lookup" value="<%=h(lookup)%>">
      <div class="table-toolbar">
        <label class="checkbox-label" for="chonTatCa">
          <input type="checkbox" id="chonTatCa">
          <span>Chọn tất cả tài liệu</span>
        </label>
        <span id="selectedCount" class="badge badge-neutral">Đã chọn: 0 / <%=dsMuon.length%> tài liệu</span>
      </div>
      <div class="table-wrapper">
        <table id="tblDangMuon" class="data-table">
          <thead>
            <tr>
              <th class="col-check">Chọn</th>
              <th>Mã bản sao</th>
              <th>Tên tài liệu</th>
              <th>Ngày mượn</th>
              <th>Hạn trả</th>
            </tr>
          </thead>
          <tbody>
            <% for (LoanDetail9 ld : dsMuon) {
                 long overdue = overdueDays(ld.getDueDate(), todayRef); %>
              <tr>
                <td class="col-check">
                  <label class="checkbox-hit">
                    <input type="checkbox" name="chonTra"
                        aria-label="Chọn <%=h(ld.getCopy().getCopyCode())%>"
                        value="<%=ld.getId()%>">
                  </label>
                </td>
                <td class="mono"><strong><%=h(ld.getCopy().getCopyCode())%></strong></td>
                <td class="doc-title"><%=h(ld.getCopy().getDocument().getTitle())%></td>
                <td class="mono"><%=date(ld.getLoan().getBorrowDate())%></td>
                <td>
                  <span class="mono"><%=date(ld.getDueDate())%></span>
                  <% if (overdue > 0) { %>
                    <span class="badge badge-danger">Quá hạn <%=overdue%> ngày</span>
                  <% } else { %>
                    <span class="badge badge-success">Còn hạn</span>
                  <% } %>
                </td>
              </tr>
            <% } %>
          </tbody>
        </table>
      </div>
      <div class="form-actions">
        <a id="btnTimLai" class="btn btn-secondary" href="gdTimBanDoc.jsp">Tìm bạn đọc khác</a>
        <button class="btn btn-primary" name="btnTiepTuc">Tiếp tục</button>
      </div>
    </form>
  <% } %>
</section>
<% if (dsPhieuTra != null && dsPhieuTra.length > 0) { %>
  <section class="card">
    <div class="card-header">
      <h2>Phiếu trả đã lưu gần đây</h2>
      <span class="badge badge-neutral"><%=dsPhieuTra.length%> phiếu</span>
    </div>
    <div class="table-wrapper">
      <table id="tblPhieuTraGanDay" class="data-table">
        <thead>
          <tr>
            <th>Mã phiếu</th>
            <th>Ngày trả</th>
            <th class="col-money">Tổng phạt</th>
            <th>Trạng thái</th>
            <th>Thao tác</th>
          </tr>
        </thead>
        <tbody>
          <% for (ReturnReceipt9 pt : dsPhieuTra) { %>
            <tr>
              <td class="mono"><strong>#<%=pt.getId()%></strong></td>
              <td class="mono"><%=date(pt.getReturnDate())%></td>
              <td class="col-money"><%=money(pt.tinhTongPhat())%> đồng</td>
              <td>
                <span class="badge <%="PAID".equals(pt.getPaymentStatus()) ? "badge-info" : "badge-success"%>">
                  <%=h(pt.getPaymentStatus())%>
                </span>
              </td>
              <td><a class="btn btn-outline btn-sm" href="gdPhieuTra.jsp?idPhieu=<%=pt.getId()%>">Xem / In lại</a></td>
            </tr>
          <% } %>
        </tbody>
      </table>
    </div>
  </section>
<% } %>
<%@ include file="/WEB-INF/footer.jspf" %>
