<%@ include file="/WEB-INF/reader.jspf" %>
<!doctype html>
<html lang="vi">
<meta charset="utf-8">
<title>Trang chủ bạn đọc</title>
<h1>Trang chủ bạn đọc</h1>
<p>Xin chào, <%=h(bandoc.getFullName())%></p>
<%@ include file="/WEB-INF/error.jspf" %>
<p><a id="dangkythe" href="gdDangKyThe.jsp">Đăng kí làm thẻ bạn đọc</a></p>
<form method="post" action="../thanhvien/doDangXuat.jsp">
  <input type="hidden" name="csrf" value="<%=csrf%>">
  <button name="btnDangXuat">Đăng xuất</button>
</form>
</html>
