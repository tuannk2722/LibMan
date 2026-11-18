<%@ include file="/WEB-INF/librarian.jspf" %>
<%
request.setAttribute("pageTitle", "Trang chủ thủ thư");
%>
<%@ include file="/WEB-INF/header.jspf" %>
<div class="page-header">
  <div>
    <h1>Trang chủ</h1>
    <p class="page-subtitle">
      Xin chào, <strong><%=h(thuthu.getFullName())%></strong>
      (<span class="mono"><%=h(thuthu.getEmployeeCode())%></span>)
    </p>
  </div>
</div>
<div class="dashboard-grid">
  <section class="card">
    <div class="card-header">
      <h2>Tiếp nhận trả tài liệu tại quầy</h2>
    </div>
    <div class="card-body">
      <p>Tra cứu bạn đọc bằng máy quét thẻ hoặc mã bạn đọc, kiểm tra danh sách tài liệu đang mượn, ghi nhận tình trạng bản sao, lập phiếu tạm thu tiền phạt và in phiếu trả chính thức.</p>
    </div>
    <div class="form-actions">
      <a id="lnkNhanTra" class="btn btn-primary" href="gdTimBanDoc.jsp">Nhận trả tài liệu</a>
    </div>
  </section>
  <section class="card">
    <div class="card-header">
      <h2>Tra cứu / In lại phiếu trả</h2>
    </div>
    <div class="card-body">
      <p class="form-hint" style="margin-bottom: 1rem;">Nhập mã phiếu trả đã lưu trong hệ thống để xem lại chi tiết hoặc kích hoạt in lại phiếu giao cho bạn đọc.</p>
      <form class="inline-lookup-form" method="get" action="gdPhieuTra.jsp">
        <div class="form-row-stack">
          <label class="form-label" for="idPhieuHome">Mã phiếu trả</label>
          <input id="idPhieuHome" type="number" min="1" required name="idPhieu" placeholder="Ví dụ: 1">
        </div>
        <button class="btn btn-outline" name="btnTraPhieu">Tìm phiếu</button>
      </form>
    </div>
  </section>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
