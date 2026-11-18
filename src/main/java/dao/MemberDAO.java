package dao;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.time.LocalDate;
import java.util.Locale;
import model.*;

public class MemberDAO extends DAO {
    public MemberDAO() throws SQLException { super(); }

    public static String bamMatKhau(String rawPassword) {
        if (rawPassword == null) {
            throw new IllegalArgumentException("Mật khẩu không được để trống.");
        }
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(rawPassword.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                hex.append(Character.forDigit((b >>> 4) & 0xF, 16));
                hex.append(Character.forDigit(b & 0xF, 16));
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("Thiếu thuật toán SHA-256", e);
        }
    }

    public static boolean khopMatKhau(String rawPassword, String storedHash) {
        if (rawPassword == null || storedHash == null || storedHash.isBlank() || "!".equals(storedHash)) {
            return false;
        }
        String expected = storedHash.strip();
        if (expected.regionMatches(true, 0, "sha256:", 0, 7)) {
            expected = expected.substring(7).strip();
        }
        expected = expected.toLowerCase(Locale.ROOT);
        if (!expected.matches("[0-9a-f]{64}")) {
            return false;
        }
        String actual = bamMatKhau(rawPassword);
        return MessageDigest.isEqual(
                actual.getBytes(StandardCharsets.US_ASCII),
                expected.getBytes(StandardCharsets.US_ASCII));
    }

    private static void copyBaseFields(ResultSet row, Member9 member) throws SQLException {
        member.setId(row.getInt("id"));
        member.setUsername(row.getString("username"));
        member.setFullName(row.getString("fullName"));
        member.setBirthDate(row.getObject("birthDate", LocalDate.class));
        member.setAddress(row.getString("address"));
        member.setEmail(row.getString("email"));
        member.setPhone(row.getString("phone"));
    }

    public Member9 dangNhap(String username, String password) throws SQLException {
        if (username == null || username.isBlank() || password == null || password.isEmpty()) {
            return null;
        }
        return one("""
            SELECT m.id, m.username, m.passwordHash, m.fullName, m.birthDate, m.address, m.email, m.phone,
                   r.readerCode, r.status AS readerStatus,
                   e.employeeCode, e.position,
                   l.employeeId AS librarianId
            FROM tblMember9 m
            LEFT JOIN tblReader9 r ON r.memberId = m.id
            LEFT JOIN tblEmployee9 e ON e.memberId = m.id
            LEFT JOIN tblLibrarian9 l ON l.employeeId = e.memberId
            WHERE m.username = ?
            """, row -> {
                if (!khopMatKhau(password, row.getString("passwordHash"))) {
                    return null;
                }
                String position = row.getString("position");
                String employeeCode = row.getString("employeeCode");
                Object librarianId = row.getObject("librarianId");
                if (librarianId != null && "LIBRARIAN".equals(position)) {
                    Librarian9 librarian = new Librarian9();
                    copyBaseFields(row, librarian);
                    librarian.setEmployeeCode(employeeCode);
                    librarian.setPosition("LIBRARIAN");
                    return librarian;
                }
                if (employeeCode != null && "MANAGER".equals(position)) {
                    Manager9 manager = new Manager9();
                    copyBaseFields(row, manager);
                    manager.setEmployeeCode(employeeCode);
                    manager.setPosition("MANAGER");
                    return manager;
                }
                String readerCode = row.getString("readerCode");
                String readerStatus = row.getString("readerStatus");
                if (readerCode != null && "ACTIVE".equals(readerStatus)) {
                    Reader9 reader = new Reader9();
                    copyBaseFields(row, reader);
                    reader.setReaderCode(readerCode);
                    reader.setStatus(readerStatus);
                    return reader;
                }
                return null;
            }, username.strip());
    }
}
