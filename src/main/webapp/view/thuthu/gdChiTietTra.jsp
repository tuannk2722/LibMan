<%@ include file="/WEB-INF/librarian.jspf" %>
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
%>
<!doctype html>
<html lang="vi">
<meta charset="utf-8">
<title>Nhập thông tin trả</title>
<h1>Nhập thông tin trả</h1>
<p>Bạn đọc <%=h(bandoc.getReaderCode())%> – <%=h(bandoc.getFullName())%></p>
<p>Ngày trả <output id="outNgayTra"><%=date(returnDate)%></output></p>
<%@ include file="/WEB-INF/error.jspf" %>
<form method="post" action="doLapPhieuTam.jsp">
  <input type="hidden" name="csrf" value="<%=csrf%>">
  <input type="hidden" name="selection" value="<%=h(selection)%>">
  <datalist id="dsTinhTrang">
    <option value="Bình thường">
    <option value="Hỏng">
    <option value="Rách">
    <option value="Mất">
  </datalist>
  <table id="tblTaiLieuMuon">
    <tr>
      <th>Mã bản sao</th>
      <th>Tên tài liệu</th>
      <th>Tình trạng</th>
      <th>Phạt hỏng (đồng)</th>
      <th>Phạt chậm (đồng)</th>
    </tr>
    <%
    for (LoanDetail9 ld : dsChon) {
        int id = ld.getId();
        ReturnDetail9 old = previous == null ? null : Arrays.stream(previous.getDetails())
                .filter(d -> d.getLoanDetail().getId() == id)
                .findFirst()
                .orElse(null);
    %>
      <tr>
        <td><%=h(ld.getCopy().getCopyCode())%></td>
        <td><%=h(ld.getCopy().getDocument().getTitle())%></td>
        <td>
          <input required maxlength="255" list="dsTinhTrang" name="inTinhTrang.<%=id%>"
              value='<%=input(request, "inTinhTrang." + id, old == null ? "Bình thường" : old.getConditionAtReturn())%>'>
        </td>
        <td>
          <input required type="number" min="0" step="1" name="inPhatHong.<%=id%>"
              value='<%=input(request, "inPhatHong." + id, old == null ? 0 : old.getDamageFine())%>'>
        </td>
        <td>
          <input required type="number" min="0" step="1" name="inPhatCham.<%=id%>"
              value='<%=input(request, "inPhatCham." + id, old == null ? 0 : old.getLateFine())%>'>
        </td>
      </tr>
    <% } %>
  </table>
  <a id="btnQuayLai" href="gdDSDangMuon.jsp?lookup=<%=h(lookup)%>">Quay lại</a>
  <button name="btnLapPhieuTam">Lập phiếu tạm</button>
</form>
</html>
