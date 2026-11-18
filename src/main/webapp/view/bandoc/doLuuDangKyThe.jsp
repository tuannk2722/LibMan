<%@ include file="/WEB-INF/reader.jspf" %>
<%@ include file="/WEB-INF/post.jspf" %>
<%
Reader9 hoSo = new Reader9();
hoSo.setId(bandoc.getId());
hoSo.setReaderCode(bandoc.getReaderCode());
String next = "gdDangKyThe.jsp";
try (LibraryCardDAO dao = new LibraryCardDAO()) {
    hoSo.setFullName(param(request, "inoutHoTen"));
    hoSo.setBirthDate(LocalDate.parse(param(request, "inoutNgaySinh")));
    hoSo.setAddress(param(request, "inoutDiaChi"));
    hoSo.setEmail(param(request, "inoutEmail"));
    hoSo.setPhone(param(request, "inoutDienThoai"));
    LibraryCard9 theMoi = dao.dangKyThe(hoSo, param(request, "inoutLoaiThe"));
    bandoc.setFullName(hoSo.getFullName());
    bandoc.setBirthDate(hoSo.getBirthDate());
    bandoc.setAddress(hoSo.getAddress());
    bandoc.setEmail(hoSo.getEmail());
    bandoc.setPhone(hoSo.getPhone());
    session.setAttribute("member", bandoc);
    session.setAttribute("hoSoDangKy", bandoc);
    session.setAttribute("theMoi", theMoi);
    response.sendRedirect("gdKetQua.jsp"); return;
} catch (LibraryCardDAO.ActiveCardException e) {
    request.setAttribute("message", e.getMessage());
    next = "gdChinh.jsp";
} catch (IllegalArgumentException | java.time.DateTimeException e) {
    request.setAttribute("message", "Kiểm tra các trường hồ sơ và loại thẻ.");
} catch (SQLException e) {
    application.log("Cấp thẻ", e);
    request.setAttribute("message", "Đăng kí chưa thành công, vui lòng thử lại.");
}
request.getRequestDispatcher(next).forward(request, response); return;
%>
