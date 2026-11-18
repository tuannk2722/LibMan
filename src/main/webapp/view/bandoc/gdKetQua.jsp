<%@ include file="/WEB-INF/reader.jspf" %>
<%
LibraryCard9 theMoi = (LibraryCard9) session.getAttribute("theMoi");
if (theMoi == null || theMoi.getReader().getId() != bandoc.getId()) {
    response.sendRedirect("gdChinh.jsp");
    return;
}
request.setAttribute("pageTitle", "Kết quả đăng kí");
%>
<%@ include file="/WEB-INF/header.jspf" %>
<section class="card card-narrow">
  <div class="card-header">
    <h1>Kết quả đăng kí</h1>
    <span class="badge badge-success">Hoàn tất</span>
  </div>
  <p id="lblThongBao" class="alert alert-success">Đăng kí làm thẻ bạn đọc thành công.</p>
  <div class="library-card-box">
    <div class="library-card-top">
      <div>
        <div class="library-card-title">Thẻ bạn đọc mới cấp</div>
        <div class="library-card-number"><output id="lblSoThe"><%=h(theMoi.getCardNumber())%></output></div>
      </div>
      <span class="badge badge-success">ACTIVE</span>
    </div>
    <div class="library-card-meta">
      <div>
        <span>Mã bạn đọc</span>
        <strong class="mono"><output id="lblMaBanDoc"><%=h(theMoi.getReader().getReaderCode())%></output></strong>
      </div>
      <div>
        <span>Loại thẻ</span>
        <strong><%=h(theMoi.getCardType())%></strong>
      </div>
      <div>
        <span>Ngày cấp</span>
        <strong class="mono"><%=date(theMoi.getIssueDate())%></strong>
      </div>
      <div>
        <span>Ngày hết hạn</span>
        <strong class="mono"><%=date(theMoi.getExpiryDate())%></strong>
      </div>
    </div>
  </div>
  <div class="form-actions" style="justify-content: center;">
    <a id="btnOkay" class="btn btn-primary" href="gdChinh.jsp">OK</a>
  </div>
</section>
<%@ include file="/WEB-INF/footer.jspf" %>
