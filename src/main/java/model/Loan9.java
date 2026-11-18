package model;

import java.time.LocalDate;

public class Loan9 {
    private int id;
    private LocalDate borrowDate;
    private Reader9 reader;
    private Librarian9 librarian;
    private LoanDetail9[] details;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public LocalDate getBorrowDate() {
        return borrowDate;
    }

    public void setBorrowDate(LocalDate borrowDate) {
        this.borrowDate = borrowDate;
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

    public LoanDetail9[] getDetails() {
        return details;
    }

    public void setDetails(LoanDetail9[] details) {
        this.details = details;
    }

    public boolean isDetailsLoaded() {
        return details != null && details.length > 0;
    }

    /** Requires the complete collection of loan details. */
    public String getStatus() {
        if (details == null || details.length == 0) {
            throw new IllegalStateException(
                    "Chưa nạp danh sách dòng mượn (loan.details) nên không thể tính trạng thái phiếu mượn.");
        }
        for (LoanDetail9 detail : details) {
            if (detail == null || detail.getStatus() == null) {
                throw new IllegalStateException("Dòng mượn chưa có trạng thái.");
            }
            if ("OPEN".equals(detail.getStatus())) return "OPEN";
        }
        return "CLOSED";
    }
}
