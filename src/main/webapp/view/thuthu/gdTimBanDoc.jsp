<%@ include file="/WEB-INF/librarian.jspf" %>
<!doctype html>
<html lang="vi">
<meta charset="utf-8">
<title>Xác định bạn đọc</title>
<h1>Xác định bạn đọc</h1>
<%@ include file="/WEB-INF/error.jspf" %>
<form action="gdDSDangMuon.jsp" method="post">
  <input type="hidden" name="csrf" value="<%=csrf%>">
  <p><label>Số thẻ <input autofocus name="inSothe" value='<%=input(request, "inSothe", "")%>'></label></p>
  <p><label>Hoặc mã bạn đọc <input name="inMaBanDoc" value='<%=input(request, "inMaBanDoc", "")%>'></label></p>
  <p>Quét thẻ hoặc nhập một loại mã.</p>
  <a href="gdChinh.jsp">Về trang chủ</a>
  <button name="btnTim">Tìm</button>
</form>
<form action="gdPhieuTra.jsp" method="get">
  <p>
    <label>Hoặc mở / in lại phiếu trả theo mã phiếu <input type="number" min="1" required name="idPhieu"></label>
    <button name="btnTraPhieu">Xem / In lại phiếu trả</button>
  </p>
</form>
</html>
