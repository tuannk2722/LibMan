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
request.setAttribute("pageTitle", "Phiếu trả tài liệu");
%>
<%@ include file="/WEB-INF/header.jspf" %>
<ol class="stepper screen" aria-label="Tiến trình nhận trả tài liệu">
  <li class="step is-done"><span class="step-num">1</span><span class="step-label">Xác định bạn đọc</span></li>
  <li class="step is-done"><span class="step-num">2</span><span class="step-label">Chọn sách trả</span></li>
  <li class="step is-done"><span class="step-num">3</span><span class="step-label">Tình trạng &amp; Tiền phạt</span></li>
  <li class="step <%=saved ? "is-done" : "is-active"%>"><span class="step-num">4</span><span class="step-label">Phiếu trả &amp; In phiếu</span></li>
</ol>
<section class="card">
  <div class="print-only print-header">
    <div class="print-org">THƯ VIỆN LIBMAN</div>
    <h1>PHIẾU XÁC NHẬN TRẢ TÀI LIỆU</h1>
  </div>
  <div class="card-header screen">
    <div>
      <h1>Phiếu trả tài liệu</h1>
      <p class="page-subtitle"><%=saved ? "Chứng từ nhận trả chính thức đã lưu trong hệ thống" : "Phiếu tạm để đối chiếu tài liệu và tiền phạt trước khi xác nhận"%></p>
    </div>
    <% if (phieu != null) { %>
      <% if (saved) { %>
        <span class="badge badge-success">Đã lưu (#<%=phieu.getId()%>)</span>
      <% } else { %>
        <span class="badge badge-warning">Phiếu tạm (Chưa lưu)</span>
      <% } %>
    <% } %>
  </div>
  <%@ include file="/WEB-INF/error.jspf" %>
  <% if (existingReceiptId != null) { %>
    <p class="screen alert alert-info">
      <a id="lnkDoiChieuPhieu" class="btn btn-outline btn-sm" href="gdPhieuTra.jsp?idPhieu=<%=existingReceiptId%>">
        Mở phiếu trả #<%=existingReceiptId%> đã lưu để đối chiếu / in lại
      </a>
    </p>
  <% } %>
  <% if (phieu == null) { %>
    <form class="inline-lookup-form" method="get" action="gdPhieuTra.jsp">
      <div class="form-row-stack">
        <label class="form-label" for="idPhieuRetry">Mã phiếu trả</label>
        <input id="idPhieuRetry" type="number" min="1" required name="idPhieu" value="<%=h(idParam)%>">
      </div>
      <button class="btn btn-primary" name="btnTraPhieu">Xem phiếu trả</button>
    </form>
    <nav class="action-bar screen">
      <a id="btnTrangChu" class="btn btn-secondary" href="gdChinh.jsp">Về trang chủ</a>
    </nav>
  <% } else { %>
    <% if (saved && !printing) { %>
      <p class="screen alert alert-success"><%=draft.isEmpty() ? "Thông tin phiếu trả đã lưu." : "Nhận trả tài liệu thành công."%></p>
    <% } %>
    <div class="meta-grid">
      <div id="outBanDoc" class="meta-item">
        <span class="meta-label">Bạn đọc</span>
        <span class="meta-value"><%=h(phieu.getReader().getReaderCode())%> – <%=h(phieu.getReader().getFullName())%></span>
      </div>
      <div id="outThuThu" class="meta-item">
        <span class="meta-label">Thủ thư</span>
        <span class="meta-value"><%=h(phieu.getLibrarian().getFullName())%></span>
      </div>
      <div id="outNgayTra" class="meta-item">
        <span class="meta-label">Ngày trả</span>
        <span class="meta-value mono"><%=date(phieu.getReturnDate())%></span>
      </div>
      <div id="outMaPhieu" class="meta-item">
        <span class="meta-label">Mã phiếu</span>
        <span class="meta-value <%=saved ? "mono" : ""%>"><%=saved ? String.valueOf(phieu.getId()) : "được cấp sau khi lưu thành công"%></span>
      </div>
    </div>
    <div class="table-wrapper">
      <table id="tblChiTietTra" class="data-table">
        <thead>
          <tr>
            <th>Mã bản sao</th>
            <th>Tên tài liệu</th>
            <th class="col-money">Phạt hỏng</th>
            <th class="col-money">Phạt chậm</th>
            <th class="col-money">Thành tiền</th>
          </tr>
        </thead>
        <tbody>
          <% for (ReturnDetail9 d : phieu.getDetails()) { %>
            <tr>
              <td class="mono"><strong><%=h(d.getLoanDetail().getCopy().getCopyCode())%></strong></td>
              <td class="doc-title"><%=h(d.getLoanDetail().getCopy().getDocument().getTitle())%></td>
              <td class="col-money"><%=money(d.getDamageFine())%></td>
              <td class="col-money"><%=money(d.getLateFine())%></td>
              <td class="col-money"><strong><%=money(d.tinhTienPhatDong())%></strong></td>
            </tr>
          <% } %>
        </tbody>
      </table>
    </div>
    <div class="condition-section">
      <strong>Tình trạng lúc trả</strong>
      <ul class="condition-list">
        <% for (ReturnDetail9 d : phieu.getDetails()) {
             boolean canCirculate = isCirculationAvailable(d.getConditionAtReturn(), d.getDamageFine()); %>
          <li>
            <span>
              <strong class="mono"><%=h(d.getLoanDetail().getCopy().getCopyCode())%></strong>
              – <%=h(d.getConditionAtReturn())%>
            </span>
            <span class="badge <%=canCirculate ? "badge-success" : "badge-warning"%>">
              <%=circulationLabel(d.getConditionAtReturn(), d.getDamageFine())%>
            </span>
          </li>
        <% } %>
      </ul>
    </div>
    <div class="receipt-summary">
      <p id="outTongPhat" class="receipt-total"><strong>Tổng tiền phạt <%=money(phieu.tinhTongPhat())%> đồng</strong></p>
      <% if (saved) { %>
        <p id="outThanhToan" class="mb-0">
          <span class="badge <%="PAID".equals(phieu.getPaymentStatus()) ? "badge-info" : "badge-success"%>">
            <%="PAID".equals(phieu.getPaymentStatus()) ? "Đã thanh toán (PAID)" : "Không phát sinh phạt (NO_FINE)"%>
          </span>
        </p>
      <% } %>
    </div>
    <% if (!saved) { %>
      <p class="cash-notice screen <%=phieu.tinhTongPhat().signum() > 0 ? "" : "is-zero"%>">
        <%=phieu.tinhTongPhat().signum() > 0
            ? "Chỉ bấm Xác nhận nhận trả sau khi đã thu đủ " + money(phieu.tinhTongPhat()) + " đồng."
            : "Không phát sinh phạt."%>
      </p>
    <% } %>
    <nav class="action-bar screen">
      <% if (!saved) { %>
        <div class="action-group">
          <% if (Boolean.TRUE.equals(request.getAttribute("conflict"))) { %>
            <form method="post" action="gdDSDangMuon.jsp">
              <input type="hidden" name="csrf" value="<%=csrf%>">
              <input type="hidden" name="inMaBanDoc" value="<%=h(phieu.getReader().getReaderCode())%>">
              <button class="btn btn-secondary">Tải lại danh sách đang mượn</button>
            </form>
          <% } else { %>
            <a id="btnQuayLai" class="btn btn-secondary" href="gdChiTietTra.jsp?selection=<%=h(activeSelection)%>&amp;draft=<%=h(draft)%>">Quay lại</a>
          <% } %>
        </div>
        <div class="action-group">
          <% if (!Boolean.TRUE.equals(request.getAttribute("conflict"))) { %>
            <form method="post" action="doLuuPhieuTra.jsp">
              <input type="hidden" name="csrf" value="<%=csrf%>">
              <input type="hidden" name="draft" value="<%=h(draft)%>">
              <button class="btn btn-primary" name="btnXacNhanTra">Xác nhận nhận trả</button>
            </form>
          <% } %>
          <button class="btn btn-outline" name="btnInPhieu" disabled>In phiếu trả</button>
        </div>
      <% } else { %>
        <a id="btnTrangChu" class="btn btn-secondary" href="gdChinh.jsp">Về trang chủ</a>
        <form method="get" action="doInPhieuTra.jsp">
          <input type="hidden" name="idPhieu" value="<%=phieu.getId()%>">
          <% if (!draft.isEmpty()) { %>
            <input type="hidden" name="draft" value="<%=h(draft)%>">
          <% } %>
          <button class="btn btn-primary" name="btnInPhieu">In phiếu trả</button>
        </form>
      <% } %>
    </nav>
    <div class="print-only print-signatures">
      <div>
        <strong>Bạn đọc</strong>
        <div class="print-sign-note">(Ký, ghi rõ họ tên)</div>
        <div><%=h(phieu.getReader().getFullName())%></div>
      </div>
      <div>
        <strong>Thủ thư tiếp nhận</strong>
        <div class="print-sign-note">(Ký, ghi rõ họ tên)</div>
        <div><%=h(phieu.getLibrarian().getFullName())%></div>
      </div>
    </div>
    <% if (printing) { %>
      <script>window.addEventListener("load", () => window.print());</script>
    <% } %>
  <% } %>
</section>
<%@ include file="/WEB-INF/footer.jspf" %>
