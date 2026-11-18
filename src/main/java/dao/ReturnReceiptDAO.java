package dao;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;
import java.util.regex.Pattern;
import model.*;

public class ReturnReceiptDAO extends DAO {
    public ReturnReceiptDAO() throws SQLException { super(); }

    public static class LoanConflict extends IllegalStateException {
        public LoanConflict() {
            super("Dữ liệu mượn đã thay đổi. Đối chiếu phiếu đã lưu và tiền đã thu, rồi tra lại bạn đọc.");
        }
    }

    private static final Pattern UNAVAILABLE_PATTERN = Pattern.compile(
            "(?<!\\p{L})(?:hỏng|hong|mất|mat|rách|rach|ướt|uot|bẩn|ban|thiếu|thieu|hư|ngừng|không bình thường|khong binh thuong|cần sửa|bảo trì)(?!\\p{L})",
            Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);

    public static String chuanHoaTinhTrang(String condition) {
        if (condition == null) return "";
        String normalized = condition.strip().replaceAll("\\s+", " ");
        if (normalized.isEmpty()) return "";
        if ("bình thường".equals(normalized.toLowerCase(Locale.forLanguageTag("vi")))) {
            return "Bình thường";
        }
        return normalized;
    }

    public static String xacDinhTrangThaiLuuThong(String conditionAtReturn, BigDecimal damageFine) {
        if (damageFine != null && damageFine.signum() > 0) {
            return "UNAVAILABLE";
        }
        String normalized = chuanHoaTinhTrang(conditionAtReturn).toLowerCase(Locale.forLanguageTag("vi"));
        if (normalized.isEmpty() || UNAVAILABLE_PATTERN.matcher(normalized).find()) {
            return "UNAVAILABLE";
        }
        return "AVAILABLE";
    }

    private static void checkFine(BigDecimal amount) {
        if (amount == null || amount.signum() < 0 || amount.scale() != 0 || amount.precision() > 19)
            throw new IllegalArgumentException("Tiền phạt phải là số nguyên không âm, tối đa 19 chữ số.");
    }

    private void lockOpenLine(ReturnDetail9 item, int readerId) throws SQLException {
        LoanDetail9 loanDetail = item.getLoanDetail();
        Integer copyId = one("SELECT id FROM tblDocumentCopy9 WHERE id=? FOR UPDATE",
                r -> r.getInt(1), loanDetail.getCopy().getId());
        Integer valid = one("""
            SELECT ld.id FROM tblLoanDetail9 ld JOIN tblLoan9 l ON l.id=ld.loanId
            WHERE ld.id=? AND ld.copyId=? AND l.readerId=? AND ld.status='OPEN' FOR UPDATE
            """, r -> r.getInt(1), loanDetail.getId(), copyId, readerId);
        if (valid == null || one("SELECT id FROM tblReturnDetail9 WHERE loanDetailId=? FOR UPDATE",
                r -> r.getInt(1), loanDetail.getId()) != null) throw new LoanConflict();
    }

    public ReturnReceipt9 xacNhanTra(ReturnReceipt9 phieuTam) throws SQLException {
        ReturnDetail9[] lines = phieuTam.getDetails().clone();
        if (phieuTam.getId() != 0 || lines.length == 0)
            throw new IllegalArgumentException("Cần phiếu tạm có ít nhất một dòng.");
        Arrays.sort(lines, Comparator.comparingInt(d -> d.getLoanDetail().getCopy().getId()));
        Set<Integer> selected = new HashSet<>();
        for (ReturnDetail9 line : lines) {
            if (!selected.add(line.getLoanDetail().getId())) throw new LoanConflict();
            String condition = chuanHoaTinhTrang(line.getConditionAtReturn());
            if (condition.isEmpty() || condition.length() > 255)
                throw new IllegalArgumentException("Thiếu tình trạng bản sao.");
            line.setConditionAtReturn(condition);
            checkFine(line.getDamageFine());
            checkFine(line.getLateFine());
        }
        int readerId = phieuTam.getReader().getId();
        int id = transaction(() -> {
            for (ReturnDetail9 line : lines) lockOpenLine(line, readerId);
            String status = phieuTam.tinhTongPhat().signum() > 0 ? "PAID" : "NO_FINE";
            int receiptId = insert("""
                INSERT INTO tblReturnReceipt9(returnDate,paymentStatus,readerId,librarianId)
                VALUES (?,?,?,?)
                """, phieuTam.getReturnDate(), status, readerId, phieuTam.getLibrarian().getId());
            for (ReturnDetail9 line : lines) {
                LoanDetail9 ld = line.getLoanDetail();
                update("""
                    INSERT INTO tblReturnDetail9(conditionAtReturn,damageFine,lateFine,returnReceiptId,loanDetailId)
                    VALUES (?,?,?,?,?)
                    """, line.getConditionAtReturn(), line.getDamageFine(), line.getLateFine(), receiptId, ld.getId());
                if (update("UPDATE tblLoanDetail9 SET status='RETURNED' WHERE id=? AND status='OPEN'", ld.getId()) != 1)
                    throw new LoanConflict();
                String circulation = xacDinhTrangThaiLuuThong(line.getConditionAtReturn(), line.getDamageFine());
                update("UPDATE tblDocumentCopy9 SET `condition`=?, circulationStatus=? WHERE id=?",
                        line.getConditionAtReturn(), circulation, ld.getCopy().getId());
            }
            return receiptId;
        });
        for (ReturnDetail9 line : lines) {
            line.getLoanDetail().setStatus("RETURNED");
        }
        phieuTam.setId(id);
        phieuTam.setPaymentStatus(phieuTam.tinhTongPhat().signum() > 0 ? "PAID" : "NO_FINE");
        return phieuTam;
    }

    public ReturnReceipt9 getPhieuTra(int idPhieu) throws SQLException {
        ReturnReceipt9 phieu = one("""
            SELECT p.id,p.returnDate,p.paymentStatus,r.readerCode,r.memberId AS readerId,
                   m.fullName AS readerName, p.librarianId, s.fullName AS librarianName
            FROM tblReturnReceipt9 p JOIN tblReader9 r ON r.memberId=p.readerId
            JOIN tblMember9 m ON m.id=r.memberId JOIN tblMember9 s ON s.id=p.librarianId
            WHERE p.id=?
            """, row -> {
                ReturnReceipt9 receipt = new ReturnReceipt9();
                receipt.setId(row.getInt("id"));
                receipt.setReturnDate(row.getObject("returnDate", LocalDate.class));
                receipt.setPaymentStatus(row.getString("paymentStatus"));
                Reader9 reader = new Reader9();
                reader.setId(row.getInt("readerId"));
                reader.setReaderCode(row.getString("readerCode"));
                reader.setFullName(row.getString("readerName"));
                receipt.setReader(reader);
                Librarian9 librarian = new Librarian9();
                librarian.setId(row.getInt("librarianId"));
                librarian.setFullName(row.getString("librarianName"));
                receipt.setLibrarian(librarian);
                return receipt;
            }, idPhieu);
        if (phieu == null) return null;
        List<ReturnDetail9> details = list("SELECT rd.id AS returnLine,rd.conditionAtReturn,rd.damageFine,rd.lateFine,"
                + LoanDetailDAO.COLUMNS + LoanDetailDAO.JOINS
                + " JOIN tblReturnDetail9 rd ON rd.loanDetailId=ld.id WHERE rd.returnReceiptId=? ORDER BY c.copyCode",
                row -> {
                    ReturnDetail9 line = new ReturnDetail9();
                    line.setId(row.getInt("returnLine"));
                    line.setLoanDetail(LoanDetailDAO.read(row));
                    line.setConditionAtReturn(row.getString("conditionAtReturn"));
                    line.setDamageFine(row.getBigDecimal("damageFine"));
                    line.setLateFine(row.getBigDecimal("lateFine"));
                    return line;
                }, idPhieu);
        List<LoanDetail9> loanLines = new ArrayList<>(details.size());
        for (ReturnDetail9 detail : details) {
            if (detail.getLoanDetail() != null) loanLines.add(detail.getLoanDetail());
        }
        new LoanDetailDAO(con).napChiTietPhieuMuon(loanLines);
        phieu.setDetails(details.toArray(ReturnDetail9[]::new));
        return phieu;
    }

    public ReturnReceipt9[] getDSPhieuTraTheoBanDoc(int readerId) throws SQLException {
        List<Integer> ids = list(
                "SELECT id FROM tblReturnReceipt9 WHERE readerId=? ORDER BY id DESC LIMIT 10",
                row -> row.getInt("id"), readerId);
        List<ReturnReceipt9> receipts = new ArrayList<>(ids.size());
        for (Integer id : ids) {
            ReturnReceipt9 receipt = getPhieuTra(id);
            if (receipt != null) receipts.add(receipt);
        }
        return receipts.toArray(ReturnReceipt9[]::new);
    }

    public Integer timMaPhieuTheoChiTiet(ReturnReceipt9 phieuTam) throws SQLException {
        if (phieuTam == null || phieuTam.getDetails() == null || phieuTam.getDetails().length == 0) {
            return null;
        }
        List<Integer> loanDetailIds = new ArrayList<>();
        for (ReturnDetail9 detail : phieuTam.getDetails()) {
            if (detail != null && detail.getLoanDetail() != null && detail.getLoanDetail().getId() > 0) {
                loanDetailIds.add(detail.getLoanDetail().getId());
            }
        }
        if (loanDetailIds.isEmpty()) return null;
        String placeholders = String.join(",", Collections.nCopies(loanDetailIds.size(), "?"));
        return one("SELECT returnReceiptId FROM tblReturnDetail9 WHERE loanDetailId IN ("
                + placeholders + ") ORDER BY returnReceiptId DESC LIMIT 1",
                row -> row.getInt("returnReceiptId"), loanDetailIds.toArray());
    }
}
