-- Chỉ dùng trên một schema kiểm thử mới, sau schema.sql.
-- Tài khoản mẫu đăng nhập thử nghiệm: maitn / 123456 (bạn đọc) và hatt / 123456 (thủ thư).
-- passwordHash dùng thuật toán SHA-256 hex (MemberDAO.bamMatKhau("123456")).
START TRANSACTION;
INSERT INTO tblMember9(id,username,passwordHash,fullName,birthDate,address,email,phone) VALUES
 (1,'maitn','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Nguyễn Thị Mai','2005-03-15','Hà Đông, Hà Nội','maitn@example.com','0912345678'),
 (2,'hatt','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','Trần Thu Hà','1990-01-01','Hà Nội','hatt@example.com','0900000000');
INSERT INTO tblReader9 VALUES (1,'DG009','ACTIVE');
INSERT INTO tblEmployee9 VALUES (2,'NV009','LIBRARIAN');
INSERT INTO tblLibrarian9 VALUES (2);
INSERT INTO tblDocumentType9(id,typeName) VALUES (1,'Sách'),(2,'Tạp chí');
INSERT INTO tblDocument9(id,documentCode,title,catalogStatus,documentTypeId) VALUES
 (1,'D001','Giáo trình Cơ sở dữ liệu','ACTIVE',1),
 (2,'D015','Lập trình hướng đối tượng','ACTIVE',1),
 (3,'D102','Tạp chí Công nghệ số 09/2026','ACTIVE',2);
INSERT INTO tblDocumentCopy9(id,copyCode,shelfLocation,`condition`,circulationStatus,documentId) VALUES
 (1,'TL001','A1','Bình thường','ON_LOAN',1),(2,'TL015','A2','Bình thường','ON_LOAN',2),
 (3,'TL102','B1','Bình thường','ON_LOAN',3);
INSERT INTO tblLoan9(id,borrowDate,readerId,librarianId) VALUES
 (1,'2026-09-01',1,2),(2,'2026-09-05',1,2),(3,'2026-09-10',1,2);
INSERT INTO tblLoanDetail9(id,dueDate,status,loanId,copyId) VALUES
 (1,'2026-09-20','OPEN',1,1),(2,'2026-09-26','OPEN',2,2),(3,'2026-09-20','OPEN',3,3);
COMMIT;
-- Đặt mốc ID riêng cho ca kiểm thử sinh số thẻ T009089.
ALTER TABLE tblLibraryCard9 AUTO_INCREMENT=9089;
