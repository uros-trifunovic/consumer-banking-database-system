-- CREATE DOMAINS
CREATE DOMAIN branchNumber AS SMALLINT
	CHECK (VALUE BETWEEN 0001 AND 9999);
	
CREATE DOMAIN zip AS INT
	CHECK (VALUE BETWEEN 00000 AND 99999);
	
CREATE DOMAIN staffIdentifier AS SMALLINT
	CHECK (VALUE BETWEEN 0001 AND 9999);
	
CREATE DOMAIN memberIdentifier AS SMALLINT
	CHECK (VALUE BETWEEN 0001 AND 9999);

CREATE DOMAIN staffPosition AS CHAR(20)
	CHECK (VALUE IN ('Customer Representative', 'Associate', 'Manager', 'Director'));
	
CREATE DOMAIN salaryLimit AS INT
	CHECK (VALUE BETWEEN 45000 AND 110000);

CREATE DOMAIN ssNumber AS INT
	CHECK (VALUE BETWEEN 000000000 AND 999999999);

CREATE DOMAIN debitCard AS BIGINT
	CHECK (VALUE BETWEEN 0000000000000000 AND 9999999999999999);

CREATE DOMAIN phoneNum AS BIGINT
	CHECK (VALUE BETWEEN 0000000000 AND 9999999999);
	
CREATE DOMAIN pwLimit AS VARCHAR(30);
	
CREATE DOMAIN accTypeID CHAR(2)
	CHECK (VALUE IN ('SC', 'SS', 'C', 'S'));
	
CREATE DOMAIN accTypeDesc CHAR(20)
	CHECK (VALUE IN ('Student Checking', 'Student Savings', 'Checking', 'Savings'));
	
CREATE DOMAIN transTypeID CHAR(2)
	CHECK (VALUE IN ('D', 'C'));

CREATE DOMAIN transTypeDesc CHAR(20)
	CHECK (VALUE IN ('Debit', 'Credit'));

-- CREATE TABLES
CREATE TABLE Branch (
	branchNo branchNumber NOT NULL,
	street VARCHAR(50) NOT NULL,
	city VARCHAR(30) NOT NULL,
	zipCode zip NOT NULL,
	PRIMARY KEY (branchNo)
);

CREATE TABLE Staff(
	staffID staffIdentifier NOT NULL,
	branchNo branchNumber NOT NULL,
	fName VARCHAR(15),
	lName VARCHAR(15),
	street VARCHAR(50) NOT NULL,
	city VARCHAR(30) NOT NULL,
	zipCode zip NOT NULL,
	staffRole staffPosition NOT NULL,
	salary salaryLimit NOT NULL,
	PRIMARY KEY (staffID),
	FOREIGN KEY (branchNo) REFERENCES Branch
		ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Member(
	memberID memberIdentifier NOT NULL,
	password pwLimit NOT NULL,
	staffID staffIdentifier NOT NULL,
	branchNo branchNumber NOT NULL,
	fName VARCHAR(15),
	lName VARCHAR(15),
	ssn SSNumber UNIQUE NOT NULL,
	street VARCHAR(50) NOT NULL,
	city VARCHAR(30) NOT NULL,
	zipCode zip NOT NULL,
	debitCardNo debitCard UNIQUE NOT NULL,
	phoneNumber phoneNum UNIQUE,
	email VARCHAR(50),
	PRIMARY KEY (memberId),
	FOREIGN KEY (staffID) REFERENCES Staff
		ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (branchNo) REFERENCES Branch
		ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE AccountTypes(
	accountTypeID accTypeID NOT NULL,
	description accTypeDesc NOT NULL,
	PRIMARY KEY (accountTypeID)
);

CREATE TABLE Account(
	accountNo BIGSERIAL NOT NULL,
	staffID staffIdentifier NOT NULL,
	memberID memberIdentifier NOT NULL,
	ssn SSNumber UNIQUE NOT NULL,
	accountTypeID accTypeID NOT NULL,
	accountName VARCHAR(30),
	balance DECIMAL(12, 2),
	PRIMARY KEY (accountNo),
	FOREIGN KEY (staffID) REFERENCES Staff
		ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (memberID) REFERENCES Member
		ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (accountTypeID) REFERENCES AccountTypes
		ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE TransactionTypes(
	transactionTypeID transTypeID NOT NULL,
	description transTypeDesc NOT NULL,
	PRIMARY KEY (transactionTypeID)
);

CREATE TABLE Transaction(
	transactionNo BIGSERIAL NOT NULL,
	accountNo BIGINT NOT NULL,
	transDate DATE NOT NULL,
	transTime TIME,
	branchNo branchNumber NOT NULL,
	transactionTypeID transTypeID NOT NULL,
	amount DECIMAL(12, 2) NOT NULL,
	note VARCHAR(50),
	PRIMARY KEY (transactionNo),
	FOREIGN KEY (accountNo) REFERENCES Account
		ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (branchNo) REFERENCES Branch
		ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (transactionTypeID) REFERENCES TransactionTypes
		ON DELETE SET NULL ON UPDATE CASCADE
);

-- Add the account types the bank offers
INSERT INTO AccountTypes
VALUES
	('SS', 'Student Savings'),
	('SC', 'Student Checking'),
	('S', 'Checking'),
	('C', 'Savings');

-- Add the transaction types the bank supports 
INSERT INTO TransactionTypes
VALUES
	('D', 'Debit'),
	('C', 'Credit');

-- Create a few branches
INSERT INTO Branch
VALUES 
	(0001, '9630 16th Avenue', 'Brooklyn', 11214),
	(0101, '966 Lexington Ave', 'New York', 10021),
	(0100, '60 Gramercy Park N #2', 'New York', 10010);

-- Assign a staff member to each branch
INSERT INTO Staff
VALUES 
	(1000, 0001, 'Mary', 'Smith', '9167 Pine St.', 'Queens', 11105, 'Manager', 90000),
	(5031, 0101, 'Peter', 'Johnson', '412 New Lane', 'New York', 10024, 'Associate', 70000),
	(5900, 0100, 'Fione', 'Valentino', '52 New Lane', 'New York', 11520, 'Associate', 65000);

-- Now when we have a few branches and staff ready to help, we add customers to each branch
INSERT INTO Member (memberId, password, staffID, branchNo, fname, lname, ssn, debitcardno, street, city, zipcode, phonenumber, email)
VALUES 
	(1011, 'password1234!', 1000, 0001, 'Melissa', 'Smith', 123456789, 1234567891011213, '1959  Hoffman Avenue', 'New York', 10013, 7181234567, 'Melissa.Smith@aol.com'),
	(2232, 'HiDO098#1!', 5900, 0100, 'Brandon', 'Jhonson ', 098765432, 1415161718192021, '4173  Scott Street', 'New York', 10011, 3472135687, 'B.Jhonson@yahoo.com'),
	(1543, 'kqoLNd097_', 5900, 0100, 'Jasmin', 'Hudson', 234986547, 2223242526272829, '893  Anmoore Road', 'Queens', 11103, 3471431234, 'JasminHud21@gmail.com');

-- The next step is to create accounts for the customers	
INSERT INTO Account
VALUES 
	(123456789011, 1000, 1011, 123456789, 'SS', 'ACN2390', 8567.34),
	(987654321001, 5031, 2232, 098765432, 'S', 'ACN1389', 26349.23),
	(456738908234, 5900, 1543, 234986547, 'C', 'ACN5478', 12234.18);

-- Now when the customers have opened accounts with the bank, they conduct transactions
INSERT INTO Transaction
VALUES
	(20200409000001, 456738908234, '04-09-2020', '12:03 PM', 0100, 'C',	134.21, 'phone bill'),
	(20191219002345, 123456789011, '12-19-2019', '8:30 AM', 0001, 'C', 577.12, 'car installment'),
	(20200921893456, 987654321001, '09-21-2020', '9:47 AM', 0101, 'D', 5000, 'gift');
	
	