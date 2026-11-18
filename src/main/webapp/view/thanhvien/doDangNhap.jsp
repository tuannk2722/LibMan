<%@ include file="/WEB-INF/common.jspf" %>
<%@ include file="/WEB-INF/post.jspf" %>
<%
String username = param(request, "inTenDangNhap");
if (username.isEmpty()) username = param(request, "username");
String password = Objects.toString(request.getParameter("inMatKhau"), "");
if (password.isEmpty()) password = Objects.toString(request.getParameter("password"), "");

Member9 member = null;
try (MemberDAO dao = new MemberDAO()) {
    member = dao.dangNhap(username, password);
} catch (SQLException e) {
    application.log("Đăng nhập hệ thống", e);
    request.setAttribute("message", "Không thể kết nối hệ thống xác thực. Vui lòng thử lại.");
    request.getRequestDispatcher("gdDangNhap.jsp").forward(request, response); return;
}
if (member == null) {
    request.setAttribute("message", "Tên đăng nhập hoặc mật khẩu không đúng");
    request.getRequestDispatcher("gdDangNhap.jsp").forward(request, response); return;
}
session.invalidate();
jakarta.servlet.http.HttpSession fresh = request.getSession(true);
fresh.setAttribute("csrf", UUID.randomUUID().toString());
fresh.setAttribute("member", member);
if (member instanceof Reader9) {
    response.sendRedirect("../bandoc/gdChinh.jsp"); return;
}
if (member instanceof Librarian9) {
    response.sendRedirect("../thuthu/gdChinh.jsp"); return;
}
request.setAttribute("message", "Tài khoản quản lí chưa có giao diện trong phạm vi hai modul.");
request.getRequestDispatcher("gdDangNhap.jsp").forward(request, response);
%>
