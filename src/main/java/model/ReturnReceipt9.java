package model;

import java.time.LocalDate;
import java.math.BigDecimal;

public class ReturnReceipt9 {
    private int id;
    private LocalDate returnDate;
    private String paymentStatus;
    private Reader9 reader;
    private Librarian9 librarian;
    private ReturnDetail9[] details = new ReturnDetail9[0];

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public LocalDate getReturnDate() {
        return returnDate;
    }

    public void setReturnDate(LocalDate returnDate) {
        this.returnDate = returnDate;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public Reader9 getReader() {
        return reader;
    }

    public void setReader(Reader9 reader) {
        this.reader = reader;
    }

    public Librarian9 getLibrarian() {
        return librarian;
    }

    public void setLibrarian(Librarian9 librarian) {
        this.librarian = librarian;
    }

    public ReturnDetail9[] getDetails() {
        return details;
    }

    public void setDetails(ReturnDetail9[] details) {
        this.details = details;
    }

    public BigDecimal tinhTongPhat() {
        BigDecimal total = BigDecimal.ZERO;
        for (ReturnDetail9 detail : details) {
            total = total.add(detail.tinhTienPhatDong());
        }
        return total;
    }

    public BigDecimal getTotalFine() {
        return tinhTongPhat();
    }
}
