<%@ include file="/WEB-INF/reader.jspf" %>
<%
LibraryCard9 theMoi = (LibraryCard9) session.getAttribute("theMoi");
if (theMoi == null || theMoi.getReader().getId() != bandoc.getId()) {
    response.sendRedirect("gdChinh.jsp");
    return;
}
%>
<!doctype html>
<html lang="vi">
<meta charset="utf-8">
<title>Kết quả đăng kí</title>
<h1>Kết quả đăng kí</h1>
<p id="lblThongBao">Đăng kí làm thẻ bạn đọc thành công.</p>
<p>Mã bạn đọc <output id="lblMaBanDoc"><%=h(theMoi.getReader().getReaderCode())%></output></p>
<p>Số thẻ <output id="lblSoThe"><%=h(theMoi.getCardNumber())%></output></p>
<a id="btnOkay" href="gdChinh.jsp">OK</a>
</html>
