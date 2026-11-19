<%@ include file="/WEB-INF/librarian.jspf" %>
<%!
private static BigDecimal tryFine(String raw, BigDecimal fallback) {
    if (raw != null && raw.matches("[0-9]{1,19}")) {
        return new BigDecimal(raw);
    }
    return fallback != null ? fallback : BigDecimal.ZERO;
}
%>
<%
String selection = param(request, "selection");
String lookup = param(request, "lookup");
String draftParam = param(request, "draft");
LoanDetail9[] dsChon;
Reader9 bandoc;
LocalDate returnDate;
ReturnReceipt9 previous = null;

if (selection.isEmpty()) {
    LoanDetail9[] dsMuon;
    synchronized (session) {
        dsMuon = (LoanDetail9[]) session.getAttribute("loans." + lookup);
    }
    if (dsMuon == null) {
        response.sendError(409);
        return;
    }

    String[] ids = request.getParameterValues("chonTra");
    Set<String> wanted = new HashSet<>(ids == null ? List.of() : Arrays.asList(ids));
    dsChon = Arrays.stream(dsMuon)
            .filter(ld -> wanted.contains(String.valueOf(ld.getId())))
            .toArray(LoanDetail9[]::new);
    if (ids == null || ids.length == 0 || dsChon.length != ids.length) {
        request.setAttribute("message", "Hãy chọn ít nhất một dòng trong danh sách đang mượn.");
        request.getRequestDispatcher("gdDSDangMuon.jsp").forward(request, response);
        return;
    }

    selection = UUID.randomUUID().toString();
    synchronized (session) {
        String oldSelection = (String) session.getAttribute("activeSelection." + lookup);
        if (oldSelection != null && session.getAttribute("savedReceipt." + oldSelection) == null) {
            String oldDraft = (String) session.getAttribute("activeDraft." + oldSelection);
            if (oldDraft != null) {
                ReturnReceipt9 oldDraftObj = (ReturnReceipt9) session.getAttribute("draft." + oldDraft);
                if (oldDraftObj == null || oldDraftObj.getId() == 0) {
                    session.removeAttribute("draft." + oldDraft);
                    session.removeAttribute("selection." + oldDraft);
                }
                session.removeAttribute("activeDraft." + oldSelection);
            }
        }
        session.setAttribute("chosen." + selection, dsChon);
        session.setAttribute("lookup." + selection, lookup);
        session.setAttribute("date." + selection, LocalDate.now());
        session.setAttribute("activeSelection." + lookup, selection);
        bandoc = (Reader9) session.getAttribute("reader." + lookup);
        returnDate = (LocalDate) session.getAttribute("date." + selection);
    }
} else {
    synchronized (session) {
        dsChon = (LoanDetail9[]) session.getAttribute("chosen." + selection);
        lookup = (String) session.getAttribute("lookup." + selection);
        if (dsChon == null || lookup == null) {
            response.sendError(409);
            return;
        }
        if (session.getAttribute("savedReceipt." + selection) != null
                || (!draftParam.isEmpty() && !draftParam.equals(session.getAttribute("activeDraft." + selection)))) {
            response.sendError(409, "Phiếu tạm đã cũ hoặc lượt nhận trả đã được lưu.");
            return;
        }
        bandoc = (Reader9) session.getAttribute("reader." + lookup);
        returnDate = (LocalDate) session.getAttribute("date." + selection);
        if (!draftParam.isEmpty()) {
            previous = (ReturnReceipt9) session.getAttribute("draft." + draftParam);
        }
    }
}

if (bandoc == null || returnDate == null) {
    response.sendError(409);
    return;
}

boolean hasOverdue = false;
for (LoanDetail9 ld : dsChon) {
    if (overdueDays(ld.getDueDate(), returnDate) > 0) {
        hasOverdue = true;
        break;
    }
}
BigDecimal initialTotal = BigDecimal.ZERO;
request.setAttribute("pageTitle", "Nhập thông tin trả");
%>
<%@ include file="/WEB-INF/header.jspf" %>
<ol class="stepper screen" aria-label="Tiến trình nhận trả tài liệu">
  <li class="step is-done"><span class="step-num">1</span><span class="step-label">Xác định bạn đọc</span></li>
  <li class="step is-done"><span class="step-num">2</span><span class="step-label">Chọn sách trả</span></li>
  <li class="step is-active"><span class="step-num">3</span><span class="step-label">Tình trạng &amp; Tiền phạt</span></li>
  <li class="step"><span class="step-num">4</span><span class="step-label">Phiếu trả &amp; In phiếu</span></li>
</ol>
<section class="card">
  <div class="card-header">
    <div>
      <h1>Nhập thông tin trả</h1>
      <p class="page-subtitle">Ghi nhận tình trạng thực tế và hai khoản phạt cho từng bản sao trước khi lập phiếu tạm</p>
    </div>
  </div>
  <div class="meta-grid">
    <div class="meta-item">
      <span class="meta-label">Bạn đọc</span>
      <span class="meta-value"><%=h(bandoc.getReaderCode())%> – <%=h(bandoc.getFullName())%></span>
    </div>
    <div class="meta-item">
      <span class="meta-label">Ngày trả (hệ thống)</span>
      <output id="outNgayTra" class="meta-value mono"><%=date(returnDate)%></output>
    </div>
  </div>
  <%@ include file="/WEB-INF/error.jspf" %>
  <form method="post" action="doLapPhieuTam.jsp">
    <input type="hidden" name="csrf" value="<%=csrf%>">
    <input type="hidden" name="selection" value="<%=h(selection)%>">
    <% if (hasOverdue) { %>
      <div class="table-toolbar">
        <span class="form-hint">Có tài liệu quá hạn so với ngày trả hệ thống (<%=date(returnDate)%>).</span>
        <button type="button" id="btnGoiYPhatCham" class="btn btn-outline btn-sm">Gợi ý phạt chậm (5.000đ/ngày quá hạn)</button>
      </div>
    <% } %>
    <div class="table-wrapper">
      <table id="tblTaiLieuMuon" class="data-table">
        <thead>
          <tr>
            <th>Mã bản sao</th>
            <th>Tên tài liệu</th>
            <th>Tình trạng</th>
            <th class="col-money">Phạt hỏng (đồng)</th>
            <th class="col-money">Phạt chậm (đồng)</th>
          </tr>
        </thead>
        <tbody>
          <%
          for (LoanDetail9 ld : dsChon) {
              int id = ld.getId();
              long overdue = overdueDays(ld.getDueDate(), returnDate);
              ReturnDetail9 old = previous == null ? null : Arrays.stream(previous.getDetails())
                      .filter(d -> d.getLoanDetail().getId() == id)
                      .findFirst()
                      .orElse(null);
              String condFallback = old == null ? "Bình thường" : old.getConditionAtReturn();
              String currentCond = request.getParameter("inTinhTrang." + id) != null
                      ? param(request, "inTinhTrang." + id)
                      : condFallback;
              BigDecimal curDamage = tryFine(request.getParameter("inPhatHong." + id),
                      old == null ? BigDecimal.ZERO : old.getDamageFine());
              BigDecimal curLate = tryFine(request.getParameter("inPhatCham." + id),
                      old == null ? BigDecimal.ZERO : old.getLateFine());
              initialTotal = initialTotal.add(curDamage).add(curLate);
              boolean canCirculate = isCirculationAvailable(currentCond, curDamage);
          %>
            <tr data-line-id="<%=id%>" data-overdue-days="<%=overdue%>">
              <td class="mono"><strong><%=h(ld.getCopy().getCopyCode())%></strong></td>
              <td>
                <div class="doc-title"><%=h(ld.getCopy().getDocument().getTitle())%></div>
                <div class="doc-sub">
                  <span>Hạn trả: <span class="mono"><%=date(ld.getDueDate())%></span></span>
                  <% if (overdue > 0) { %>
                    <span class="badge badge-danger">Quá hạn <%=overdue%> ngày</span>
                  <% } else { %>
                    <span class="badge badge-success">Đúng hạn</span>
                  <% } %>
                </div>
              </td>
              <td>
                <%
                String selectedCond = ReturnReceiptDAO.chuanHoaTinhTrang(currentCond);
                if (!List.of("Bình thường", "Hỏng", "Rách", "Mất").contains(selectedCond)) {
                    selectedCond = "Bình thường";
                }
                %>
                <select required name="inTinhTrang.<%=id%>"
                    aria-label="Tình trạng <%=h(ld.getCopy().getCopyCode())%>">
                  <option value="Bình thường" <%="Bình thường".equals(selectedCond) ? "selected" : ""%>>Bình thường</option>
                  <option value="Hỏng" <%="Hỏng".equals(selectedCond) ? "selected" : ""%>>Hỏng</option>
                  <option value="Rách" <%="Rách".equals(selectedCond) ? "selected" : ""%>>Rách</option>
                  <option value="Mất" <%="Mất".equals(selectedCond) ? "selected" : ""%>>Mất</option>
                </select>
              </td>
              <td>
                <input class="input-money" required type="number" min="0" step="1" name="inPhatHong.<%=id%>"
                    aria-label="Phạt hỏng <%=h(ld.getCopy().getCopyCode())%>"
                    value='<%=input(request, "inPhatHong." + id, old == null ? 0 : old.getDamageFine())%>'>
              </td>
              <td>
                <input class="input-money" required type="number" min="0" step="1" name="inPhatCham.<%=id%>"
                    aria-label="Phạt chậm <%=h(ld.getCopy().getCopyCode())%>"
                    value='<%=input(request, "inPhatCham." + id, old == null ? 0 : old.getLateFine())%>'>
              </td>
            </tr>
          <% } %>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="3">Tổng tiền phạt dự kiến</td>
            <td colspan="2" class="col-money">
              <strong id="liveTotalFine" class="mono"><%=money(initialTotal)%> đồng</strong>
            </td>
          </tr>
        </tfoot>
      </table>
    </div>
    <p class="form-hint mt-1">Tình trạng và hai khoản phạt được nhập cho từng bản sao. Khi nhập phạt hỏng &gt; 0 hoặc mô tả hư hại/mất, bản sao sẽ tự chuyển sang Ngừng lưu thông.</p>
    <div class="form-actions">
      <a id="btnQuayLai" class="btn btn-secondary" href="gdDSDangMuon.jsp?lookup=<%=h(lookup)%>">Quay lại</a>
      <button class="btn btn-primary" name="btnLapPhieuTam">Lập phiếu tạm</button>
    </div>
  </form>
</section>
<%@ include file="/WEB-INF/footer.jspf" %>
