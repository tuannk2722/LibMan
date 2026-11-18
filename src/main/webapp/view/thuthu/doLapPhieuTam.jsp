<%@ include file="/WEB-INF/librarian.jspf" %>
<%@ include file="/WEB-INF/post.jspf" %>
<%!
private static BigDecimal fine(String value) {
    if (!value.matches("[0-9]{1,19}")) throw new IllegalArgumentException("Tiền phạt phải là số nguyên không âm.");
    return new BigDecimal(value);
}
%>
<%
String selection = param(request, "selection");
LoanDetail9[] dsChon;
String lookup;
Reader9 bandoc;
LocalDate returnDate;
synchronized (session) {
    dsChon = (LoanDetail9[]) session.getAttribute("chosen." + selection);
    lookup = (String) session.getAttribute("lookup." + selection);
    bandoc = lookup == null ? null : (Reader9) session.getAttribute("reader." + lookup);
    returnDate = (LocalDate) session.getAttribute("date." + selection);
    if (dsChon == null || dsChon.length == 0 || lookup == null || bandoc == null || returnDate == null) {
        response.sendError(409); return;
    }
    if (!selection.equals(session.getAttribute("activeSelection." + lookup))) {
        response.sendError(409, "Lượt chọn tài liệu đã cũ hoặc đã được thay thế."); return;
    }
    if (session.getAttribute("savedReceipt." + selection) != null) {
        response.sendError(409, "Lượt nhận trả đã được lưu, không thể lập lại phiếu tạm."); return;
    }
    String currentDraft = (String) session.getAttribute("activeDraft." + selection);
    if (currentDraft != null) {
        ReturnReceipt9 currentObj = (ReturnReceipt9) session.getAttribute("draft." + currentDraft);
        if (currentObj != null && currentObj.getId() > 0) {
            response.sendError(409, "Lượt nhận trả đã được lưu, không thể lập lại phiếu tạm."); return;
        }
    }
}
ReturnDetail9[] dsTra = new ReturnDetail9[dsChon.length];
try {
    for (int i = 0; i < dsChon.length; i++) {
        int id = dsChon[i].getId();
        String condition = ReturnReceiptDAO.chuanHoaTinhTrang(param(request, "inTinhTrang." + id));
        if (condition.isEmpty() || condition.length() > 255)
            throw new IllegalArgumentException("Kiểm tra tình trạng từng bản sao.");
        ReturnDetail9 line = new ReturnDetail9();
        line.setLoanDetail(dsChon[i]);
        line.setConditionAtReturn(condition);
        line.setDamageFine(fine(param(request, "inPhatHong." + id)));
        line.setLateFine(fine(param(request, "inPhatCham." + id)));
        line.tinhTienPhatDong();
        dsTra[i] = line;
    }
} catch (IllegalArgumentException e) {
    request.setAttribute("message", e.getMessage());
    request.getRequestDispatcher("gdChiTietTra.jsp").forward(request, response); return;
}
ReturnReceipt9 phieuTam = new ReturnReceipt9();
phieuTam.setReader(bandoc);
phieuTam.setLibrarian(thuthu);
phieuTam.setReturnDate(returnDate);
phieuTam.setDetails(dsTra);
phieuTam.tinhTongPhat();
String draft = UUID.randomUUID().toString();
synchronized (session) {
    if (!selection.equals(session.getAttribute("activeSelection." + lookup))
            || session.getAttribute("savedReceipt." + selection) != null) {
        response.sendError(409, "Lượt nhận trả đã thay đổi hoặc đã được lưu."); return;
    }
    String oldDraft = (String) session.getAttribute("activeDraft." + selection);
    if (oldDraft != null) {
        ReturnReceipt9 oldObj = (ReturnReceipt9) session.getAttribute("draft." + oldDraft);
        if (oldObj != null && oldObj.getId() > 0) {
            response.sendError(409, "Lượt nhận trả đã được lưu, không thể lập lại phiếu tạm."); return;
        }
        session.removeAttribute("draft." + oldDraft);
        session.removeAttribute("selection." + oldDraft);
    }
    String oldReaderDraft = (String) session.getAttribute("activeReaderDraft." + bandoc.getId());
    if (oldReaderDraft != null && !oldReaderDraft.equals(oldDraft)) {
        ReturnReceipt9 oldReaderObj = (ReturnReceipt9) session.getAttribute("draft." + oldReaderDraft);
        if (oldReaderObj != null && oldReaderObj.getId() == 0) {
            session.removeAttribute("draft." + oldReaderDraft);
            session.removeAttribute("selection." + oldReaderDraft);
        }
    }
    session.setAttribute("draft." + draft, phieuTam);
    session.setAttribute("selection." + draft, selection);
    session.setAttribute("activeDraft." + selection, draft);
    session.setAttribute("activeReaderDraft." + bandoc.getId(), draft);
}
response.sendRedirect("gdPhieuTra.jsp?draft=" + draft);
%>
