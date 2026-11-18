package model;

import java.time.LocalDate;

public class ImportReceipt9 {
    private int id;
    private LocalDate importDate;
    private String note;
    private Supplier9 supplier;
    private Librarian9 librarian;
    private ImportDetail9[] details = new ImportDetail9[0];

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public LocalDate getImportDate() {
        return importDate;
    }

    public void setImportDate(LocalDate importDate) {
        this.importDate = importDate;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Supplier9 getSupplier() {
        return supplier;
    }

    public void setSupplier(Supplier9 supplier) {
        this.supplier = supplier;
    }

    public Librarian9 getLibrarian() {
        return librarian;
    }

    public void setLibrarian(Librarian9 librarian) {
        this.librarian = librarian;
    }

    public ImportDetail9[] getDetails() {
        return details;
    }

    public void setDetails(ImportDetail9[] details) {
        this.details = details;
    }
}
