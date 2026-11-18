CREATE TABLE tblMember9 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(255) NOT NULL UNIQUE,
    `passwordHash` VARCHAR(255) NOT NULL,
    `fullName` VARCHAR(255) NOT NULL,
    `birthDate` DATE NOT NULL,
    `address` VARCHAR(255) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `phone` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblReader9 (
    `memberId` INT NOT NULL PRIMARY KEY,
    `readerCode` VARCHAR(255) NOT NULL UNIQUE,
    `status` VARCHAR(255) NOT NULL,
    FOREIGN KEY (memberId) REFERENCES tblMember9(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblEmployee9 (
    `memberId` INT NOT NULL PRIMARY KEY,
    `employeeCode` VARCHAR(255) NOT NULL UNIQUE,
    `position` VARCHAR(255) NOT NULL,
    FOREIGN KEY (memberId) REFERENCES tblMember9(id) ON DELETE RESTRICT,
    CHECK (position IN ('LIBRARIAN','MANAGER'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblLibrarian9 (
    `employeeId` INT NOT NULL PRIMARY KEY,
    FOREIGN KEY (employeeId) REFERENCES tblEmployee9(memberId) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblLibraryCard9 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `cardNumber` VARCHAR(255) NOT NULL UNIQUE,
    `cardType` VARCHAR(255) NOT NULL,
    `issueDate` DATE NOT NULL,
    `expiryDate` DATE NOT NULL,
    `status` VARCHAR(255) NOT NULL,
    `readerId` INT NOT NULL,
    FOREIGN KEY (readerId) REFERENCES tblReader9(memberId) ON DELETE RESTRICT,
    CHECK (expiryDate >= issueDate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblDocumentType9 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `typeName` VARCHAR(255) NOT NULL,
    `description` VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblDocument9 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `documentCode` VARCHAR(255) NOT NULL UNIQUE,
    `title` VARCHAR(255) NOT NULL,
    `author` VARCHAR(255) NULL,
    `publisher` VARCHAR(255) NULL,
    `publicationYear` INT NULL,
    `standardNumber` VARCHAR(255) NULL,
    `issueNumber` VARCHAR(255) NULL,
    `catalogStatus` VARCHAR(255) NOT NULL,
    `documentTypeId` INT NOT NULL,
    FOREIGN KEY (documentTypeId) REFERENCES tblDocumentType9(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblSupplier9 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `supplierCode` VARCHAR(255) NOT NULL UNIQUE,
    `name` VARCHAR(255) NOT NULL,
    `address` VARCHAR(255) NOT NULL,
    `phone` VARCHAR(255) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `status` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblImportReceipt9 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `importDate` DATE NOT NULL,
    `note` VARCHAR(255) NULL,
    `supplierId` INT NOT NULL,
    `librarianId` INT NOT NULL,
    FOREIGN KEY (supplierId) REFERENCES tblSupplier9(id) ON DELETE RESTRICT,
    FOREIGN KEY (librarianId) REFERENCES tblLibrarian9(employeeId) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblImportDetail9 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `quantity` INT NOT NULL,
    `importReceiptId` INT NOT NULL,
    `documentId` INT NOT NULL,
    FOREIGN KEY (importReceiptId) REFERENCES tblImportReceipt9(id) ON DELETE RESTRICT,
    FOREIGN KEY (documentId) REFERENCES tblDocument9(id) ON DELETE RESTRICT,
    CHECK (quantity > 0),
    UNIQUE (importReceiptId, documentId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblDocumentCopy9 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `copyCode` VARCHAR(255) NOT NULL UNIQUE,
    `shelfLocation` VARCHAR(255) NOT NULL,
    `condition` VARCHAR(255) NOT NULL,
    `circulationStatus` VARCHAR(255) NOT NULL,
    `documentId` INT NOT NULL,
    `importDetailId` INT NULL,
    FOREIGN KEY (documentId) REFERENCES tblDocument9(id) ON DELETE RESTRICT,
    FOREIGN KEY (importDetailId) REFERENCES tblImportDetail9(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblLoan9 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `borrowDate` DATE NOT NULL,
    `readerId` INT NOT NULL,
    `librarianId` INT NOT NULL,
    FOREIGN KEY (readerId) REFERENCES tblReader9(memberId) ON DELETE RESTRICT,
    FOREIGN KEY (librarianId) REFERENCES tblLibrarian9(employeeId) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblLoanDetail9 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `dueDate` DATE NOT NULL,
    `status` VARCHAR(255) NOT NULL,
    `loanId` INT NOT NULL,
    `copyId` INT NOT NULL,
    FOREIGN KEY (loanId) REFERENCES tblLoan9(id) ON DELETE RESTRICT,
    FOREIGN KEY (copyId) REFERENCES tblDocumentCopy9(id) ON DELETE RESTRICT,
    CHECK (status IN ('OPEN','RETURNED')),
    UNIQUE (loanId, copyId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblReturnReceipt9 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `returnDate` DATE NOT NULL,
    `paymentStatus` VARCHAR(255) NOT NULL,
    `readerId` INT NOT NULL,
    `librarianId` INT NOT NULL,
    FOREIGN KEY (readerId) REFERENCES tblReader9(memberId) ON DELETE RESTRICT,
    FOREIGN KEY (librarianId) REFERENCES tblLibrarian9(employeeId) ON DELETE RESTRICT,
    CHECK (paymentStatus IN ('PAID','NO_FINE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tblReturnDetail9 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `conditionAtReturn` VARCHAR(255) NOT NULL,
    `damageFine` DECIMAL(19,0) NOT NULL DEFAULT 0,
    `lateFine` DECIMAL(19,0) NOT NULL DEFAULT 0,
    `returnReceiptId` INT NOT NULL,
    `loanDetailId` INT NOT NULL UNIQUE,
    FOREIGN KEY (returnReceiptId) REFERENCES tblReturnReceipt9(id) ON DELETE RESTRICT,
    FOREIGN KEY (loanDetailId) REFERENCES tblLoanDetail9(id) ON DELETE RESTRICT,
    CHECK (damageFine >= 0 AND lateFine >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
