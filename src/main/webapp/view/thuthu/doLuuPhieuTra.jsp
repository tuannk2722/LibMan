<%@ include file="/WEB-INF/librarian.jspf" %>
<%@ include file="/WEB-INF/post.jspf" %>
<%
String draft = param(request, "draft");
Integer existingReceiptId = null;
int savedId = 0;
synchronized (session) {
    ReturnReceipt9 phieuTam = (ReturnReceipt9) session.getAttribute("draft." + draft);
    String selection = (String) session.getAttribute("selection." + draft);
    if (phieuTam == null || selection == null || phieuTam.getLibrarian().getId() != thuthu.getId()) {
        response.sendError(409, "Phiếu tạm không hợp lệ hoặc đã hết hạn."); return;
    }
    int readerId = phieuTam.getReader().getId();
    if (!draft.equals(session.getAttribute("activeDraft." + selection))
            || !draft.equals(session.getAttribute("activeReaderDraft." + readerId))) {
        response.sendError(409, "Phiếu tạm đã cũ hoặc đã được thay thế bởi bản mới."); return;
    }
    if (phieuTam.getId() == 0) {
        ReturnReceipt9 alreadySaved = (ReturnReceipt9) session.getAttribute("savedReceipt." + selection);
        if (alreadySaved != null && alreadySaved.getId() > 0) {
            session.setAttribute("draft." + draft, alreadySaved);
            phieuTam = alreadySaved;
        } else {
            try (ReturnReceiptDAO dao = new ReturnReceiptDAO()) {
                ReturnReceipt9 phieuDaLuu = dao.xacNhanTra(phieuTam);
                session.setAttribute("draft." + draft, phieuDaLuu);
                session.setAttribute("savedReceipt." + selection, phieuDaLuu);
                phieuTam = phieuDaLuu;
            } catch (ReturnReceiptDAO.LoanConflict e) {
                request.setAttribute("conflict", true);
                request.setAttribute("message", e.getMessage());
                try (ReturnReceiptDAO lookupDao = new ReturnReceiptDAO()) {
                    existingReceiptId = lookupDao.timMaPhieuTheoChiTiet(phieuTam);
                } catch (SQLException ignored) { }
            } catch (SQLException | IllegalArgumentException e) {
                application.log("Nhận trả tài liệu", e);
                request.setAttribute("message", "Lưu phiếu trả chưa thành công hoặc chưa rõ kết quả. Đối chiếu tiền đã thu và giao dịch trước khi thử lại. Nếu dừng khi chưa lưu, hoàn lại tiền.");
                try (ReturnReceiptDAO lookupDao = new ReturnReceiptDAO()) {
                    existingReceiptId = lookupDao.timMaPhieuTheoChiTiet(phieuTam);
                } catch (SQLException ignored) { }
            }
        }
    }
    savedId = phieuTam.getId();
}
if (existingReceiptId != null) {
    request.setAttribute("existingReceiptId", existingReceiptId);
}
if (request.getAttribute("message") != null) {
    request.getRequestDispatcher("gdPhieuTra.jsp").forward(request, response); return;
}
response.sendRedirect("gdPhieuTra.jsp?draft=" + draft + "&idPhieu=" + savedId);
%>
