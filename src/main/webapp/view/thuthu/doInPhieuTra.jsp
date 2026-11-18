<%@ include file="/WEB-INF/librarian.jspf" %>
<%
String draft = param(request, "draft");
String idParam = param(request, "idPhieu");
if (!draft.isEmpty()) {
    ReturnReceipt9 inSession;
    synchronized (session) {
        inSession = (ReturnReceipt9) session.getAttribute("draft." + draft);
    }
    if (inSession != null && (inSession.getId() == 0
            || (!idParam.isEmpty() && !String.valueOf(inSession.getId()).equals(idParam)))) {
        response.sendError(409, "Chỉ in phiếu đã lưu của lượt nhận trả."); return;
    }
}
int idPhieu;
try {
    idPhieu = Integer.parseInt(idParam);
} catch (NumberFormatException e) {
    response.sendError(409, "Chỉ in phiếu đã lưu của lượt nhận trả."); return;
}
if (idPhieu <= 0) {
    response.sendError(409, "Chỉ in phiếu đã lưu của lượt nhận trả."); return;
}
try (ReturnReceiptDAO dao = new ReturnReceiptDAO()) {
    ReturnReceipt9 phieu = dao.getPhieuTra(idPhieu);
    if (phieu == null || !Set.of("PAID", "NO_FINE").contains(phieu.getPaymentStatus())) {
        request.setAttribute("message", "Chưa tìm được phiếu chính thức để in.");
    } else {
        request.setAttribute("printReceipt", phieu);
    }
} catch (SQLException e) {
    application.log("Nạp lại phiếu để in", e);
    request.setAttribute("message", "Chưa nạp được bản in. Vui lòng in lại cùng mã phiếu.");
}
request.getRequestDispatcher("gdPhieuTra.jsp").forward(request, response); return;
%>
