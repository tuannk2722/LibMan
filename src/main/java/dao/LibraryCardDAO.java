package dao;

import java.sql.*;
import java.time.LocalDate;
import java.util.UUID;
import model.*;

public class LibraryCardDAO extends DAO {
    public static final java.util.Set<String> VALID_CARD_TYPES = java.util.Set.of("Sinh viên", "Thủ thư");
    public static final int DEFAULT_CARD_MONTHS = 12;

    public LibraryCardDAO() throws SQLException { super(); }

    public static class ActiveCardException extends IllegalStateException {
        public ActiveCardException() {
            super("Bạn đọc đã có thẻ. Vui lòng liên hệ thư viện nếu cần cấp lại/gia hạn.");
        }
    }

    public LibraryCard9 getThe(int readerId) throws SQLException {
        LocalDate today = LocalDate.now();
        return one("""
            SELECT * FROM tblLibraryCard9 WHERE readerId=? AND status='ACTIVE'
            AND issueDate<=? AND expiryDate>=? LIMIT 1
            """, row -> {
                LibraryCard9 card = new LibraryCard9();
                card.setId(row.getInt("id"));
                card.setCardNumber(row.getString("cardNumber"));
                card.setCardType(row.getString("cardType"));
                card.setStatus(row.getString("status"));
                card.setIssueDate(row.getObject("issueDate", LocalDate.class));
                card.setExpiryDate(row.getObject("expiryDate", LocalDate.class));
                Reader9 reader = new Reader9();
                reader.setId(readerId);
                card.setReader(reader);
                return card;
            }, readerId, today, today);
    }

    public LibraryCard9 dangKyThe(Reader9 hoSo, String type) throws SQLException {
        if (hoSo.getFullName() == null || hoSo.getFullName().isBlank() || hoSo.getBirthDate() == null
                || hoSo.getAddress() == null || hoSo.getAddress().isBlank()
                || hoSo.getPhone() == null || !hoSo.getPhone().matches("[+]?[0-9]{8,15}")
                || hoSo.getEmail() == null || !hoSo.getEmail().matches("[^ @]+@[^ @]+[.][^ @]+")
                || type == null || !VALID_CARD_TYPES.contains(type)) {
            throw new IllegalArgumentException("Kiểm tra họ tên, ngày sinh, địa chỉ, điện thoại, email và loại thẻ.");
        }
        return transaction(() -> {
            if (one("SELECT memberId FROM tblReader9 WHERE memberId=? FOR UPDATE",
                    row -> row.getInt(1), hoSo.getId()) == null) throw new SQLException("Thiếu hồ sơ");
            if (getThe(hoSo.getId()) != null) throw new ActiveCardException();
            String configuredMonths = System.getenv("LIBMAN_STUDENT_CARD_MONTHS");
            int months;
            if (configuredMonths == null || configuredMonths.isBlank()) {
                months = DEFAULT_CARD_MONTHS;
            } else {
                try {
                    months = Integer.parseInt(configuredMonths.strip());
                } catch (NumberFormatException e) {
                    throw new SQLException("Cấu hình thời hạn thẻ không hợp lệ", e);
                }
                if (months <= 0) throw new SQLException("Thời hạn thẻ phải dương");
            }
            LibraryCard9 theMoi = new LibraryCard9();
            theMoi.setReader(hoSo);
            theMoi.setCardType(type);
            theMoi.setIssueDate(LocalDate.now());
            theMoi.setExpiryDate(theMoi.getIssueDate().plusMonths(months));
            theMoi.setStatus("ACTIVE");
            // The private reservation is visible only inside this transaction.
            String reservation = UUID.randomUUID().toString();
            new ReaderDAO(con).capNhatHoSoBanDoc(hoSo);
            theMoi.setId(insert("""
                INSERT INTO tblLibraryCard9(cardNumber,cardType,issueDate,expiryDate,status,readerId)
                VALUES (?,?,?,?,?,?)
                """, reservation, type, theMoi.getIssueDate(), theMoi.getExpiryDate(),
                theMoi.getStatus(), hoSo.getId()));
            theMoi.setCardNumber(String.format(java.util.Locale.ROOT, "T%06d", theMoi.getId()));
            update("UPDATE tblLibraryCard9 SET cardNumber=? WHERE id=?", theMoi.getCardNumber(), theMoi.getId());
            return theMoi;
        });
    }
}
