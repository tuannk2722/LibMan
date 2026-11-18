<%@ include file="/WEB-INF/common.jspf" %>
<%@ include file="/WEB-INF/post.jspf" %>
<%
session.invalidate();
response.sendRedirect("gdDangNhap.jsp");
%>
