package dao;

import java.sql.*;
import java.time.LocalDate;
import model.Reader9;

public class ReaderDAO extends DAO {
    private static final String PROFILE = """
        SELECT m.id, m.fullName, m.birthDate, m.address, m.email, m.phone, r.readerCode, r.status
        FROM tblMember9 m JOIN tblReader9 r ON r.memberId=m.id
        """;

    public ReaderDAO() throws SQLException { super(); }
    ReaderDAO(Connection shared) { super(shared); }

    private Reader9 read(ResultSet row) throws SQLException {
        Reader9 reader = new Reader9();
        reader.setId(row.getInt("id"));
        reader.setFullName(row.getString("fullName"));
        reader.setBirthDate(row.getObject("birthDate", LocalDate.class));
        reader.setAddress(row.getString("address"));
        reader.setEmail(row.getString("email"));
        reader.setPhone(row.getString("phone"));
        reader.setReaderCode(row.getString("readerCode"));
        reader.setStatus(row.getString("status"));
        return reader;
    }

    public Reader9 getHoSoBanDoc(int id) throws SQLException {
        return one(PROFILE + " WHERE m.id=?", this::read, id);
    }

    public Reader9 getBanDocTheoMa(String ma) throws SQLException {
        return one(PROFILE + " WHERE r.readerCode=?", this::read, ma);
    }

    public Reader9 getBanDocTheoSoThe(String soThe) throws SQLException {
        return one(PROFILE + " JOIN tblLibraryCard9 c ON c.readerId=r.memberId WHERE c.cardNumber=?",
                this::read, soThe);
    }

    public void capNhatHoSoBanDoc(Reader9 hoSo) throws SQLException {
        update("UPDATE tblMember9 SET fullName=?,birthDate=?,address=?,email=?,phone=? WHERE id=?",
                hoSo.getFullName(), hoSo.getBirthDate(), hoSo.getAddress(), hoSo.getEmail(),
                hoSo.getPhone(), hoSo.getId());
    }
}
