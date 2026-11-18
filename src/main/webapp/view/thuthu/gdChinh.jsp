<%@ include file="/WEB-INF/librarian.jspf" %>
<!doctype html>
<html lang="vi">
<meta charset="utf-8">
<title>Trang chủ thủ thư</title>
<h1>Trang chủ thủ thư</h1>
<p>Xin chào, <%=h(thuthu.getFullName())%></p>
<p><a id="lnkNhanTra" href="gdTimBanDoc.jsp">Nhận trả tài liệu</a></p>
<form method="get" action="gdPhieuTra.jsp">
  <label>Tra cứu / In lại phiếu trả theo mã phiếu <input type="number" min="1" required name="idPhieu"></label>
  <button name="btnTraPhieu">Xem / In lại phiếu trả</button>
</form>
<form method="post" action="../thanhvien/doDangXuat.jsp">
  <input type="hidden" name="csrf" value="<%=csrf%>">
  <button name="btnDangXuat">Đăng xuất</button>
</form>
</html>
