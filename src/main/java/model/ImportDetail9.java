package model;

public class ImportDetail9 {
    private int id;
    private int quantity;
    private Document9 document;
    private DocumentCopy9[] copies = new DocumentCopy9[0];

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Document9 getDocument() {
        return document;
    }

    public void setDocument(Document9 document) {
        this.document = document;
    }

    public DocumentCopy9[] getCopies() {
        return copies;
    }

    public void setCopies(DocumentCopy9[] copies) {
        this.copies = copies;
    }
}
