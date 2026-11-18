<%@ include file="/WEB-INF/reader.jspf" %>
<%
LibraryCard9 theHienHanh = null;
boolean cardLookupError = false;
try (LibraryCardDAO cardDao = new LibraryCardDAO()) {
    theHienHanh = cardDao.getThe(bandoc.getId());
} catch (SQLException e) {
    application.log("Tải thẻ bạn đọc", e);
    cardLookupError = true;
}
request.setAttribute("pageTitle", "Trang chủ bạn đọc");
%>
<%@ include file="/WEB-INF/header.jspf" %>
<div class="page-header">
  <div>
    <h1>Trang chủ</h1>
    <p class="page-subtitle">Xin chào, <strong><%=h(bandoc.getFullName())%></strong></p>
  </div>
</div>
<%@ include file="/WEB-INF/error.jspf" %>
<div class="dashboard-grid">
  <section class="card">
    <div class="card-header">
      <h2>Hồ sơ bạn đọc</h2>
    </div>
    <div class="card-body">
      <div class="meta-grid" style="margin-bottom: 1rem;">
        <div class="meta-item">
          <span class="meta-label">Mã bạn đọc</span>
          <span class="meta-value mono"><%=h(bandoc.getReaderCode())%></span>
        </div>
        <div class="meta-item">
          <span class="meta-label">Họ tên</span>
          <span class="meta-value"><%=h(bandoc.getFullName())%></span>
        </div>
        <div class="meta-item">
          <span class="meta-label">Email</span>
          <span class="meta-value"><%=h(bandoc.getEmail())%></span>
        </div>
        <div class="meta-item">
          <span class="meta-label">Điện thoại</span>
          <span class="meta-value mono"><%=h(bandoc.getPhone())%></span>
        </div>
      </div>
      <p class="form-hint">Kiểm tra thông tin hồ sơ hoặc đăng kí thẻ thư viện trực tuyến tại mục bên dưới.</p>
    </div>
    <div class="form-actions">
      <a id="dangkythe" class="btn btn-primary" href="gdDangKyThe.jsp">Đăng kí làm thẻ bạn đọc</a>
    </div>
  </section>
  <section class="card">
    <div class="card-header">
      <h2>Thẻ thư viện hiện hành</h2>
      <% if (theHienHanh != null) { %>
        <span class="badge badge-success">Đang hiệu lực</span>
      <% } else if (cardLookupError) { %>
        <span class="badge badge-neutral">Chưa kiểm tra được</span>
      <% } else { %>
        <span class="badge badge-warning">Chưa có thẻ hiệu lực</span>
      <% } %>
    </div>
    <div class="card-body">
      <% if (theHienHanh != null) { %>
        <div class="library-card-box">
          <div class="library-card-top">
            <div>
              <div class="library-card-title">Thẻ bạn đọc LibMan</div>
              <div class="library-card-number"><%=h(theHienHanh.getCardNumber())%></div>
            </div>
            <span class="badge badge-success">ACTIVE</span>
          </div>
          <div class="library-card-meta">
            <div>
              <span>Loại thẻ</span>
              <strong><%=h(theHienHanh.getCardType())%></strong>
            </div>
            <div>
              <span>Ngày cấp</span>
              <strong class="mono"><%=date(theHienHanh.getIssueDate())%></strong>
            </div>
            <div>
              <span>Ngày hết hạn</span>
              <strong class="mono"><%=date(theHienHanh.getExpiryDate())%></strong>
            </div>
          </div>
        </div>
      <% } else if (cardLookupError) { %>
        <div class="library-card-empty">
          <p class="mb-0">Hiện chưa thể kiểm tra trạng thái thẻ từ cơ sở dữ liệu.</p>
        </div>
      <% } else { %>
        <div class="library-card-empty">
          <p><strong>Chưa có thẻ thư viện còn hiệu lực.</strong></p>
          <p class="form-hint mb-0">Bạn đọc có thể bấm nút <em>Đăng kí làm thẻ bạn đọc</em> để cập nhật hồ sơ và nhận số thẻ mới ngay.</p>
        </div>
      <% } %>
    </div>
  </section>
</div>
<%@ include file="/WEB-INF/footer.jspf" %>
