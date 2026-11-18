<%@ include file="/WEB-INF/common.jspf" %>
<%
Object currentMember = session.getAttribute("member");
request.setAttribute("pageTitle", "Đăng nhập hệ thống");
%>
<%@ include file="/WEB-INF/header.jspf" %>
<section class="card card-narrow">
  <div class="card-header">
    <div>
      <h1>Đăng nhập hệ thống LibMan</h1>
      <p class="page-subtitle">Cổng đăng nhập dành cho Bạn đọc và Thủ thư</p>
    </div>
  </div>
  <%@ include file="/WEB-INF/error.jspf" %>
  <% if (currentMember instanceof Reader9) {
       Reader9 r = (Reader9) currentMember; %>
    <div class="alert alert-info">
      <div>
        Đang đăng nhập: Bạn đọc <strong class="mono"><%=h(r.getReaderCode())%></strong> – <strong><%=h(r.getFullName())%></strong>.
      </div>
    </div>
    <div class="action-group" style="margin-bottom: 1.25rem;">
      <a class="btn btn-primary" href="../bandoc/gdChinh.jsp">Vào trang chủ bạn đọc</a>
      <form class="inline-form" method="post" action="doDangXuat.jsp">
        <input type="hidden" name="csrf" value="<%=csrf%>">
        <button class="btn btn-secondary" name="btnDangXuat">Đăng xuất</button>
      </form>
    </div>
  <% } else if (currentMember instanceof Librarian9) {
       Librarian9 l = (Librarian9) currentMember; %>
    <div class="alert alert-info">
      <div>
        Đang đăng nhập: Thủ thư <strong class="mono"><%=h(l.getEmployeeCode())%></strong> – <strong><%=h(l.getFullName())%></strong>.
      </div>
    </div>
    <div class="action-group" style="margin-bottom: 1.25rem;">
      <a class="btn btn-primary" href="../thuthu/gdChinh.jsp">Vào trang chủ thủ thư</a>
      <form class="inline-form" method="post" action="doDangXuat.jsp">
        <input type="hidden" name="csrf" value="<%=csrf%>">
        <button class="btn btn-secondary" name="btnDangXuat">Đăng xuất</button>
      </form>
    </div>
  <% } %>
  <form method="post" action="doDangNhap.jsp">
    <input type="hidden" name="csrf" value="<%=csrf%>">
    <div class="form-row-stack">
      <label class="form-label" for="inTenDangNhap">Tên đăng nhập</label>
      <input id="inTenDangNhap" required autofocus maxlength="255" name="inTenDangNhap"
          autocomplete="username" placeholder="Nhập tên đăng nhập"
          value='<%=input(request, "inTenDangNhap", "")%>'>
    </div>
    <div class="form-row-stack">
      <label class="form-label" for="inMatKhau">Mật khẩu</label>
      <input id="inMatKhau" required maxlength="255" type="password" name="inMatKhau"
          autocomplete="current-password" placeholder="Nhập mật khẩu">
    </div>
    <button class="btn btn-primary btn-block" name="btnDangNhap">Đăng nhập</button>
  </form>
</section>
<%@ include file="/WEB-INF/footer.jspf" %>
