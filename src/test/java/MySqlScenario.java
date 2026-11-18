import dao.*;
import model.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;

/** Integration test on a freshly initialized, disposable scenario database. */
public class MySqlScenario {
    private static void check(boolean value, String message) {
        if (!value) throw new AssertionError(message);
    }
    private static ReturnDetail9 detail(LoanDetail9 ld, String condition, int damage, int late) {
        ReturnDetail9 item = new ReturnDetail9();
        item.setLoanDetail(ld);
        item.setConditionAtReturn(condition);
        item.setDamageFine(BigDecimal.valueOf(damage));
        item.setLateFine(BigDecimal.valueOf(late));
        return item;
    }
    private static ReturnReceipt9 draft(Reader9 reader, ReturnDetail9... details) {
        Librarian9 librarian = new Librarian9();
        librarian.setId(2);
        ReturnReceipt9 receipt = new ReturnReceipt9();
        receipt.setLibrarian(librarian);
        receipt.setReader(reader);
        receipt.setReturnDate(LocalDate.of(2026,9,22));
        receipt.setDetails(details);
        return receipt;
    }
    public static void main(String[] args) throws Exception {
        try (MemberDAO members = new MemberDAO()) {
            Member9 mReader = members.dangNhap("maitn", "123456");
            check(mReader instanceof Reader9 && "DG009".equals(((Reader9) mReader).getReaderCode()),
                    "Đăng nhập bạn đọc thất bại");
            Member9 mLibrarian = members.dangNhap("hatt", "123456");
            check(mLibrarian instanceof Librarian9 && "LIBRARIAN".equals(((Librarian9) mLibrarian).getPosition()),
                    "Đăng nhập thủ thư thất bại");
            check(members.dangNhap("maitn", "sai-mat-khau") == null, "Mật khẩu sai phải bị từ chối");
        }
        Reader9 reader;
        try (ReaderDAO readers = new ReaderDAO(); LibraryCardDAO cards = new LibraryCardDAO()) {
            reader = readers.getHoSoBanDoc(1);
            check("DG009".equals(reader.getReaderCode()), "Sai dữ liệu mẫu");
            LibraryCard9 card = cards.dangKyThe(reader,"Sinh viên");
            check("T009089".equals(card.getCardNumber()), "Sai số thẻ của fixture");
            check(readers.getBanDocTheoMa("DG009").getId()==readers.getBanDocTheoSoThe("T009089").getId(), "Sai chủ thẻ");
        }
        try (LibraryCardDAO cards = new LibraryCardDAO()) {
            cards.dangKyThe(reader,"Sinh viên");
            throw new AssertionError("Đã cấp trùng thẻ");
        } catch (LibraryCardDAO.ActiveCardException expected) { }
        LoanDetail9[] open;
        try (LoanDetailDAO loans = new LoanDetailDAO()) { open = loans.getDSDangMuon(1); }
        check(Arrays.stream(open).map(d -> d.getCopy().getCopyCode()).toList()
                .equals(java.util.List.of("TL001","TL015","TL102")), "Sai danh sách mượn");
        check("OPEN".equals(open[0].getLoan().getStatus()), "Phiếu mượn OPEN không được trả CLOSED");
        ReturnDetail9 first = detail(open[0],"Bình thường",0,10000);
        ReturnDetail9 third = detail(open[2],"Hỏng",20000,10000);
        ReturnReceipt9 paid;
        try (ReturnReceiptDAO receipts = new ReturnReceiptDAO()) {
            paid = receipts.xacNhanTra(draft(reader,first,third));
        }
        try (ReturnReceiptDAO receipts = new ReturnReceiptDAO()) {
            ReturnReceipt9 print = receipts.getPhieuTra(paid.getId());
            check(print.getDetails().length==2 && print.getTotalFine().intValueExact()==40000, "Sai bản in");
            check("PAID".equals(print.getPaymentStatus()), "Sai thanh toán");
            check("CLOSED".equals(print.getDetails()[0].getLoanDetail().getLoan().getStatus()),
                    "Phiếu mượn đã trả hết phải ở trạng thái CLOSED");
            check(receipts.getDSPhieuTraTheoBanDoc(1).length >= 1, "Thiếu danh sách phiếu trả theo bạn đọc");
            check(Integer.valueOf(paid.getId()).equals(receipts.timMaPhieuTheoChiTiet(draft(reader, first))),
                    "Không tìm thấy mã phiếu đã lưu theo chi tiết");
        }
        try (ReturnReceiptDAO receipts = new ReturnReceiptDAO()) {
            receipts.xacNhanTra(draft(reader,first,third));
            throw new AssertionError("Đã lưu trùng dòng trả");
        } catch (ReturnReceiptDAO.LoanConflict expected) { }
        try (LoanDetailDAO loans = new LoanDetailDAO(); ReturnReceiptDAO receipts = new ReturnReceiptDAO()) {
            open = loans.getDSDangMuon(1);
            check(open.length==1 && "TL015".equals(open[0].getCopy().getCopyCode()), "Đóng nhầm dòng");
            ReturnReceipt9 noFine = receipts.xacNhanTra(draft(reader,detail(open[0],"Bình thường",0,0)));
            check("NO_FINE".equals(noFine.getPaymentStatus()), "Sai phiếu không phạt");
        }
        System.out.println("OK: cấp thẻ, hai cách tra cứu, PAID, in, chống trả trùng, NO_FINE");
    }
}
