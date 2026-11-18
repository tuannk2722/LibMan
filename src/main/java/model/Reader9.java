package model;

public class Reader9 extends Member9 {
    private String readerCode;
    private String status;
    private LibraryCard9[] cards = new LibraryCard9[0];

    public String getReaderCode() {
        return readerCode;
    }

    public void setReaderCode(String readerCode) {
        this.readerCode = readerCode;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LibraryCard9[] getCards() {
        return cards;
    }

    public void setCards(LibraryCard9[] cards) {
        this.cards = cards;
    }
}
