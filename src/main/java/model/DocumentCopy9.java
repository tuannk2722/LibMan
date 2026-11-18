package model;

public class DocumentCopy9 {
    private int id;
    private String copyCode;
    private String shelfLocation;
    private String condition;
    private String circulationStatus;
    private Document9 document;
    private ImportDetail9 importDetail;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCopyCode() {
        return copyCode;
    }

    public void setCopyCode(String copyCode) {
        this.copyCode = copyCode;
    }

    public String getShelfLocation() {
        return shelfLocation;
    }

    public void setShelfLocation(String shelfLocation) {
        this.shelfLocation = shelfLocation;
    }

    public String getCondition() {
        return condition;
    }

    public void setCondition(String condition) {
        this.condition = condition;
    }

    public String getCirculationStatus() {
        return circulationStatus;
    }

    public void setCirculationStatus(String circulationStatus) {
        this.circulationStatus = circulationStatus;
    }

    public Document9 getDocument() {
        return document;
    }

    public void setDocument(Document9 document) {
        this.document = document;
    }

    public ImportDetail9 getImportDetail() {
        return importDetail;
    }

    public void setImportDetail(ImportDetail9 importDetail) {
        this.importDetail = importDetail;
    }
}
