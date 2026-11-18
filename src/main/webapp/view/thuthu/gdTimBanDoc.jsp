<%@ include file="/WEB-INF/librarian.jspf" %>
<%
request.setAttribute("pageTitle", "Xác định bạn đọc");
%>
<%@ include file="/WEB-INF/header.jspf" %>
<ol class="stepper screen" aria-label="Tiến trình nhận trả tài liệu">
  <li class="step is-active"><span class="step-num">1</span><span class="step-label">Xác định bạn đọc</span></li>
  <li class="step"><span class="step-num">2</span><span class="step-label">Chọn sách trả</span></li>
  <li class="step"><span class="step-num">3</span><span class="step-label">Tình trạng &amp; Tiền phạt</span></li>
  <li class="step"><span class="step-num">4</span><span class="step-label">Phiếu trả &amp; In phiếu</span></li>
</ol>
<section class="card">
  <div class="card-header">
    <div>
      <h1>Xác định bạn đọc</h1>
      <p class="page-subtitle">Quét số thẻ thư viện hoặc nhập mã bạn đọc</p>
    </div>
  </div>
  <%@ include file="/WEB-INF/error.jspf" %>
  <form action="gdDSDangMuon.jsp" method="post">
    <input type="hidden" name="csrf" value="<%=csrf%>">
    <div class="form-row">
      <label class="form-label" for="inSothe">Số thẻ</label>
      <div class="form-control">
        <input id="inSothe" autofocus name="inSothe" placeholder="Quét thẻ hoặc nhập số thẻ (VD: T009089)"
            value='<%=input(request, "inSothe", "")%>'>
      </div>
    </div>
    <div class="form-row">
      <label class="form-label" for="inMaBanDoc">Hoặc mã bạn đọc</label>
      <div class="form-control">
        <input id="inMaBanDoc" name="inMaBanDoc" placeholder="Nhập mã bạn đọc nếu không quét được thẻ (VD: DG009)"
            value='<%=input(request, "inMaBanDoc", "")%>'>
      </div>
    </div>
    <div class="form-actions">
      <a class="btn btn-secondary" href="gdChinh.jsp">Trở về</a>
      <button class="btn btn-primary" name="btnTim">Tìm</button>
    </div>
  </form>
</section>
<%@ include file="/WEB-INF/footer.jspf" %>
