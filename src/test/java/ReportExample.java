import dao.*;
import java.math.BigDecimal;
import model.*;

/** Run with java -ea. This check does not require a web container or database. */
public class ReportExample {
    private static ReturnDetail9 detail(String damage, String late) {
        ReturnDetail9 d = new ReturnDetail9();
        d.setDamageFine(new BigDecimal(damage));
        d.setLateFine(new BigDecimal(late));
        return d;
    }

    public static void main(String[] args) {
        ReturnDetail9 tl001 = detail("0", "10000");
        ReturnDetail9 tl102 = detail("20000", "10000");
        ReturnReceipt9 receipt = new ReturnReceipt9();
        receipt.setDetails(new ReturnDetail9[] {tl001, tl102});
        assert tl001.tinhTienPhatDong().intValueExact() == 10000;
        assert tl102.tinhTienPhatDong().intValueExact() == 30000;
        assert receipt.tinhTongPhat().intValueExact() == 40000;
        assert receipt.getId() == 0 && receipt.getPaymentStatus() == null;
        receipt.setDetails(new ReturnDetail9[] {detail("0","0")});
        assert receipt.tinhTongPhat().signum() == 0;

        Loan9 unloaded = new Loan9();
        assert !unloaded.isDetailsLoaded();
        try {
            unloaded.getStatus();
            throw new AssertionError("Loan9 chưa nạp details phải báo IllegalStateException");
        } catch (IllegalStateException expected) { }

        LoanDetail9 open = new LoanDetail9();
        open.setStatus("OPEN");
        LoanDetail9 returned = new LoanDetail9();
        returned.setStatus("RETURNED");
        Loan9 loan = new Loan9();
        loan.setDetails(new LoanDetail9[] {returned, open});
        assert loan.isDetailsLoaded();
        assert "OPEN".equals(loan.getStatus());
        open.setStatus("RETURNED");
        assert "CLOSED".equals(loan.getStatus());

        assert "Bình thường".equals(ReturnReceiptDAO.chuanHoaTinhTrang("  bình   thường "));
        assert "AVAILABLE".equals(ReturnReceiptDAO.xacDinhTrangThaiLuuThong("Bình thường", BigDecimal.ZERO));
        assert "AVAILABLE".equals(ReturnReceiptDAO.xacDinhTrangThaiLuuThong("  bình   thường ", BigDecimal.ZERO));
        assert "UNAVAILABLE".equals(ReturnReceiptDAO.xacDinhTrangThaiLuuThong("  bình   thường ", BigDecimal.valueOf(20000)));
        assert "UNAVAILABLE".equals(ReturnReceiptDAO.xacDinhTrangThaiLuuThong("Hỏng", BigDecimal.ZERO));
        assert "UNAVAILABLE".equals(ReturnReceiptDAO.xacDinhTrangThaiLuuThong("Rách bìa", BigDecimal.ZERO));
        assert "UNAVAILABLE".equals(ReturnReceiptDAO.xacDinhTrangThaiLuuThong("Mất trang", BigDecimal.ZERO));

        String hash = MemberDAO.bamMatKhau("123456");
        assert "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92".equals(hash);
        assert MemberDAO.khopMatKhau("123456", hash);
        assert !MemberDAO.khopMatKhau("123456", "!");
        assert !MemberDAO.khopMatKhau("sai", hash);

        assert LibraryCardDAO.DEFAULT_CARD_MONTHS == 12;
        assert LibraryCardDAO.VALID_CARD_TYPES.contains("Sinh viên");
        assert LibraryCardDAO.VALID_CARD_TYPES.contains("Thủ thư");

        System.out.println("OK: 10.000 + 30.000 = 40.000; zero fine; draft; loan status; condition; auth; card policy");
    }
}
