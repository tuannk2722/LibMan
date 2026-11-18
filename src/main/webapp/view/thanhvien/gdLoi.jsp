<%@ page isErrorPage="true" %>
<%@ include file="/WEB-INF/common.jspf" %>
<%
Integer _errCodeAttr = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
int _errCode = _errCodeAttr != null ? _errCodeAttr : (response.getStatus() >= 400 ? response.getStatus() : 500);
String _errRawMsg = Objects.toString(request.getAttribute("jakarta.servlet.error.message"), "").strip();

String _errTitle;
String _errDesc;
switch (_errCode) {
    case 403:
        _errTitle = "Không có quyền truy cập (HTTP 403)";
        _errDesc = "Phiên đăng nhập không có quyền truy cập trang này hoặc mã xác thực biểu mẫu (CSRF) đã hết hạn. Vui lòng đăng nhập đúng vai trò hoặc tải lại trang trước khi thao tác.";
        break;
    case 404:
        _errTitle = "Không tìm thấy trang yêu cầu (HTTP 404)";
        _errDesc = "Đường dẫn bạn truy cập không tồn tại hoặc tài nguyên đã được di chuyển.";
        break;
    case 405:
        _errTitle = "Phương thức truy cập không được hỗ trợ (HTTP 405)";
        _errDesc = "Trang xử lý này chỉ tiếp nhận yêu cầu gửi từ biểu mẫu hợp lệ (POST), không hỗ trợ mở trực tiếp qua thanh địa chỉ.";
        break;
    case 409:
        _errTitle = "Phiên thao tác đã thay đổi hoặc hết hiệu lực (HTTP 409)";
        _errDesc = "Phiếu tạm, danh sách đang chọn hoặc lượt nhận trả đã được lưu/thay thế ở bước mới hơn. Vui lòng quay lại trang chủ để bắt đầu thao tác mới.";
        break;
    case 503:
        _errTitle = "Dịch vụ tạm thời gián đoạn (HTTP 503)";
        _errDesc = "Chưa thể kết nối tới cơ sở dữ liệu hoặc hệ thống đang bận. Vui lòng kiểm tra kết nối và thử lại sau ít phút.";
        break;
    default:
        _errTitle = "Đã xảy ra lỗi hệ thống (HTTP " + _errCode + ")";
        _errDesc = "Quá trình xử lý yêu cầu gặp sự cố ngoài dự kiến. Vui lòng quay lại trang chủ và thử lại.";
        break;
}

request.setAttribute("pageTitle", _errTitle);
%>
<%@ include file="/WEB-INF/header.jspf" %>
<section class="card card-narrow">
  <div class="card-header">
    <h1><%=h(_errTitle)%></h1>
    <span class="badge badge-danger">HTTP <%=_errCode%></span>
  </div>
  <p><%=h(_errDesc)%></p>
  <% if (!_errRawMsg.isEmpty() && _errCode != 500) { %>
    <p class="alert alert-warning">Chi tiết: <%=h(_errRawMsg)%></p>
  <% } %>
  <div class="form-actions">
    <a class="btn btn-secondary" href="<%=ctx(request)%>/view/thanhvien/gdDangNhap.jsp">Trang đăng nhập</a>
    <a class="btn btn-primary" href="<%=ctx(request)%>/index.jsp">Về trang chủ</a>
  </div>
</section>
<%@ include file="/WEB-INF/footer.jspf" %>
