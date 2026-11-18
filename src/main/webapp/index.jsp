<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" trimDirectiveWhitespaces="true"
    import="model.*" %>
<%
Object currentMember = session.getAttribute("member");
if (currentMember instanceof Reader9) {
    response.sendRedirect("view/bandoc/gdChinh.jsp"); return;
}
if (currentMember instanceof Librarian9 && "LIBRARIAN".equals(((Librarian9) currentMember).getPosition())) {
    response.sendRedirect("view/thuthu/gdChinh.jsp"); return;
}
response.sendRedirect("view/thanhvien/gdDangNhap.jsp");
%>
