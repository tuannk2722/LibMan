package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public abstract class DAO implements AutoCloseable {
    protected final Connection con;
    private final boolean owner;

    protected DAO() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Thiếu MySQL Connector/J", e);
        }
        con = DriverManager.getConnection(System.getenv("LIBMAN_JDBC_URL"),
                System.getenv("LIBMAN_DB_USER"), System.getenv("LIBMAN_DB_PASSWORD"));
        owner = true;
    }

    protected DAO(Connection shared) {
        con = shared;
        owner = false;
    }

    @FunctionalInterface
    interface Row<T> { T read(ResultSet result) throws SQLException; }

    @FunctionalInterface
    interface Work<T> { T run() throws SQLException; }

    protected <T> T transaction(Work<T> work) throws SQLException {
        con.setAutoCommit(false);
        try {
            T result = work.run();
            con.commit();
            return result;
        } catch (SQLException | RuntimeException e) {
            con.rollback();
            throw e;
        }
        // One request owns this connection and closes it after this transaction.
    }

    private void bind(PreparedStatement statement, Object[] values) throws SQLException {
        for (int i = 0; i < values.length; i++) statement.setObject(i + 1, values[i]);
    }

    protected <T> List<T> list(String sql, Row<T> mapper, Object... values) throws SQLException {
        try (PreparedStatement s = con.prepareStatement(sql)) {
            bind(s, values);
            try (ResultSet rows = s.executeQuery()) {
                List<T> result = new ArrayList<>();
                while (rows.next()) result.add(mapper.read(rows));
                return result;
            }
        }
    }

    protected <T> T one(String sql, Row<T> mapper, Object... values) throws SQLException {
        List<T> rows = list(sql, mapper, values);
        return rows.isEmpty() ? null : rows.get(0);
    }

    protected int update(String sql, Object... values) throws SQLException {
        try (PreparedStatement s = con.prepareStatement(sql)) {
            bind(s, values);
            return s.executeUpdate();
        }
    }

    protected int insert(String sql, Object... values) throws SQLException {
        try (PreparedStatement s = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bind(s, values);
            s.executeUpdate();
            try (ResultSet keys = s.getGeneratedKeys()) {
                if (!keys.next()) throw new SQLException("Thiếu khóa vừa cấp");
                return keys.getInt(1);
            }
        }
    }

    @Override public void close() throws SQLException {
        if (owner) con.close();
    }
}
