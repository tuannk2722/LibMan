package model;

import java.time.LocalDate;

public class LoanDetail9 {
    private int id;
    private LocalDate dueDate;
    private String status;
    private Loan9 loan;
    private DocumentCopy9 copy;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public LocalDate getDueDate() {
        return dueDate;
    }

    public void setDueDate(LocalDate dueDate) {
        this.dueDate = dueDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Loan9 getLoan() {
        return loan;
    }

    public void setLoan(Loan9 loan) {
        this.loan = loan;
    }

    public DocumentCopy9 getCopy() {
        return copy;
    }

    public void setCopy(DocumentCopy9 copy) {
        this.copy = copy;
    }
}
