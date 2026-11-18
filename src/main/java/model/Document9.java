package model;

public class Document9 {
    private int id;
    private String documentCode;
    private String title;
    private String author;
    private String publisher;
    private Integer publicationYear;
    private String standardNumber;
    private String issueNumber;
    private String catalogStatus;
    private DocumentType9 documentType;
    private DocumentCopy9[] copies = new DocumentCopy9[0];

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getDocumentCode() {
        return documentCode;
    }

    public void setDocumentCode(String documentCode) {
        this.documentCode = documentCode;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getPublisher() {
        return publisher;
    }

    public void setPublisher(String publisher) {
        this.publisher = publisher;
    }

    public Integer getPublicationYear() {
        return publicationYear;
    }

    public void setPublicationYear(Integer publicationYear) {
        this.publicationYear = publicationYear;
    }

    public String getStandardNumber() {
        return standardNumber;
    }

    public void setStandardNumber(String standardNumber) {
        this.standardNumber = standardNumber;
    }

    public String getIssueNumber() {
        return issueNumber;
    }

    public void setIssueNumber(String issueNumber) {
        this.issueNumber = issueNumber;
    }

    public String getCatalogStatus() {
        return catalogStatus;
    }

    public void setCatalogStatus(String catalogStatus) {
        this.catalogStatus = catalogStatus;
    }

    public DocumentType9 getDocumentType() {
        return documentType;
    }

    public void setDocumentType(DocumentType9 documentType) {
        this.documentType = documentType;
    }

    public DocumentCopy9[] getCopies() {
        return copies;
    }

    public void setCopies(DocumentCopy9[] copies) {
        this.copies = copies;
    }
}
