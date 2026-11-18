package dao;

import java.sql.*;
import java.time.LocalDate;
import java.util.*;
import model.*;

public class LoanDetailDAO extends DAO {
    public LoanDetailDAO() throws SQLException { super(); }
    LoanDetailDAO(Connection shared) { super(shared); }

    static final String COLUMNS = """
        ld.id AS lineId, ld.dueDate, ld.status AS loanStatus, l.id AS loanKey, l.borrowDate,
        c.id AS copyKey, c.copyCode, d.id AS docKey, d.title
        """;
    static final String JOINS = """
        FROM tblLoanDetail9 ld JOIN tblLoan9 l ON l.id=ld.loanId
        JOIN tblDocumentCopy9 c ON c.id=ld.copyId JOIN tblDocument9 d ON d.id=c.documentId
        """;

    static LoanDetail9 read(ResultSet r) throws SQLException {
        Document9 doc = new Document9();
        doc.setId(r.getInt("docKey"));
        doc.setTitle(r.getString("title"));
        DocumentCopy9 copy = new DocumentCopy9();
        copy.setId(r.getInt("copyKey"));
        copy.setCopyCode(r.getString("copyCode"));
        copy.setDocument(doc);
        Loan9 loan = new Loan9();
        loan.setId(r.getInt("loanKey"));
        loan.setBorrowDate(r.getObject("borrowDate", LocalDate.class));
        LoanDetail9 detail = new LoanDetail9();
        detail.setId(r.getInt("lineId"));
        detail.setDueDate(r.getObject("dueDate", LocalDate.class));
        detail.setStatus(r.getString("loanStatus"));
        detail.setLoan(loan);
        detail.setCopy(copy);
        return detail;
    }

    void napChiTietPhieuMuon(Collection<LoanDetail9> lines) throws SQLException {
        if (lines == null || lines.isEmpty()) return;
        Map<Integer, Loan9> loansById = new LinkedHashMap<>();
        Map<Integer, LoanDetail9> knownDetails = new HashMap<>();
        for (LoanDetail9 line : lines) {
            if (line == null) continue;
            knownDetails.put(line.getId(), line);
            Loan9 loan = line.getLoan();
            if (loan != null && loan.getId() > 0) {
                Loan9 canonical = loansById.putIfAbsent(loan.getId(), loan);
                if (canonical != null) {
                    line.setLoan(canonical);
                }
            }
        }
        if (loansById.isEmpty()) return;
        String placeholders = String.join(",", Collections.nCopies(loansById.size(), "?"));
        Map<Integer, List<LoanDetail9>> detailsByLoan = new HashMap<>();
        for (Integer loanId : loansById.keySet()) {
            detailsByLoan.put(loanId, new ArrayList<>());
        }
        list("SELECT id, dueDate, status, loanId, copyId FROM tblLoanDetail9 WHERE loanId IN ("
                + placeholders + ") ORDER BY id", r -> {
            int id = r.getInt("id");
            int loanId = r.getInt("loanId");
            Loan9 loan = loansById.get(loanId);
            LoanDetail9 detail = knownDetails.get(id);
            if (detail == null) {
                detail = new LoanDetail9();
                detail.setId(id);
                detail.setDueDate(r.getObject("dueDate", LocalDate.class));
                detail.setStatus(r.getString("status"));
                DocumentCopy9 copy = new DocumentCopy9();
                copy.setId(r.getInt("copyId"));
                detail.setCopy(copy);
                detail.setLoan(loan);
            } else {
                detail.setStatus(r.getString("status"));
            }
            detailsByLoan.get(loanId).add(detail);
            return detail;
        }, loansById.keySet().toArray());
        for (Map.Entry<Integer, Loan9> entry : loansById.entrySet()) {
            List<LoanDetail9> loanLines = detailsByLoan.get(entry.getKey());
            entry.getValue().setDetails(loanLines.toArray(LoanDetail9[]::new));
        }
    }

    public LoanDetail9[] getDSDangMuon(int readerId) throws SQLException {
        List<LoanDetail9> rows = list("SELECT " + COLUMNS + JOINS
                + " WHERE l.readerId=? AND ld.status='OPEN' ORDER BY c.copyCode",
                LoanDetailDAO::read, readerId);
        napChiTietPhieuMuon(rows);
        return rows.toArray(LoanDetail9[]::new);
    }
}
