<%@ include file="/WEB-INF/common.jspf" %>
<%
Object currentMember = session.getAttribute("member");
%>
<!doctype html>
<html lang="vi">
<meta charset="utf-8">
<title>Đăng nhập hệ thống</title>
<h1>Đăng nhập hệ thống LibMan</h1>
<%@ include file="/WEB-INF/error.jspf" %>
<% if (currentMember instanceof Reader9) {
     Reader9 r = (Reader9) currentMember; %>
  <p>Đang đăng nhập: Bạn đọc <%=h(r.getReaderCode())%> – <%=h(r.getFullName())%>.
    <a href="../bandoc/gdChinh.jsp">Vào trang chủ bạn đọc</a></p>
  <form method="post" action="doDangXuat.jsp">
    <input type="hidden" name="csrf" value="<%=csrf%>">
    <button name="btnDangXuat">Đăng xuất</button>
  </form>
<% } else if (currentMember instanceof Librarian9) {
     Librarian9 l = (Librarian9) currentMember; %>
  <p>Đang đăng nhập: Thủ thư <%=h(l.getEmployeeCode())%> – <%=h(l.getFullName())%>.
    <a href="../thuthu/gdChinh.jsp">Vào trang chủ thủ thư</a></p>
  <form method="post" action="doDangXuat.jsp">
    <input type="hidden" name="csrf" value="<%=csrf%>">
    <button name="btnDangXuat">Đăng xuất</button>
  </form>
<% } %>
<form method="post" action="doDangNhap.jsp">
  <input type="hidden" name="csrf" value="<%=csrf%>">
  <p><label>Tên đăng nhập <input required autofocus maxlength="255" name="inTenDangNhap"
      value='<%=input(request, "inTenDangNhap", "")%>'></label></p>
  <p><label>Mật khẩu <input required maxlength="255" type="password" name="inMatKhau"></label></p>
  <button name="btnDangNhap">Đăng nhập</button>
</form>
</html>
