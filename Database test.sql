-- Using MS SQL SERVER as a DB Engine.

/* DATABASE design
*
*/

-- 1. create database
CREATE DATABASE MyDbTest;
GO

USE MyDbTest
GO

-- 2. create tables

-- Departments
CREATE TABLE Departments (
	ID UNIQUEIDENTIFIER,
	[Name] NVARCHAR(100) NOT NULL,
	[Description] NVARCHAR(255),
	[IsActive] BIT -- Dept. Status
)
GO
ALTER TABLE MyDbTest.Departments
	ADD CONSTRAINT PK_Departments_ID PRIMARY KEY NONCLUSTERED (ID)
GO

-- Users
CREATE TABLE Users (
	ID UNIQUEIDENTIFIER,
	[Logon] NVARCHAR(100) NOT NULL,
	[FirstName] NVARCHAR(100) NOT NULL,
	[LastName] NVARCHAR(100),
	[DepartmentId] UNIQUEIDENTIFIER,
	[StartDate] DATE,
	[EndDate] DATE
)
GO
-- add foreign keys
ALTER TABLE MyDbTest.Users
	ADD CONSTRAINT PK_USERS_ID PRIMARY KEY NONCLUSTERED (ID)
GO
ALTER TABLE MyDbTest.UserRoles
	ADD CONSTRAINT FK_Users_Departments FOREIGN KEY (DeparmentId)
		REFERENCES MyDbTest.Departments (ID)
GO

-- Roles
CREATE TABLE Roles (
	ID UNIQUEIDENTIFIER,
	[Name] NVARCHAR(100) NOT NULL,
	[StartDate] DATE,
	[EndDate] DATE
)
GO
ALTER TABLE MyDbTest.Roles
	ADD CONSTRAINT PK_Roles_ID PRIMARY KEY NONCLUSTERED (ID)
GO

-- UserRoles
CREATE TABLE UserRoles (
	ID UNIQUEIDENTIFIER,
	UserId UNIQUEIDENTIFIER,
	RoleId UNIQUEIDENTIFIER,
)
GO
-- add foreign key
ALTER TABLE MyDbTest.UserRoles
	ADD CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId)
		REFERENCES MyDbTest.Users (ID)
-- add foreign key
ALTER TABLE MyDbTest.UserRoles
	ADD CONSTRAINT FK_UserRoles_Roles FOREIGN KEY (RoleId)
		REFERENCES MyDbTest.Roles (ID)



/* HIGH LEVEL additional details
*
*/

-- tracking when record was inserted/updated
-- approach 1: 
--- adding two additional columns
--- value setting to these new columns can be achieved using two different strategies:
----- strategy 1: the DB caller, can have in-memory logic to set the fields (CreatedOn & LastUpdatedOn)
----- strategy 2: the DB takes charge by using Triggers for the Create and Update operations
ALTER TABLE Departments
	ADD CreatedOn DATE DEFAULT (GETDATE())
ALTER TABLE Departments
	ADD LastUpdatedOn DATE DEFAULT (GETDATE())
GO

ALTER TABLE Users
	ADD CreatedOn DATE DEFAULT (GETDATE())
ALTER TABLE Users
	ADD LastUpdatedOn DATE DEFAULT (GETDATE())
GO

ALTER TABLE Roles
	ADD CreatedOn DATE DEFAULT (GETDATE())
ALTER TABLE Roles
	ADD LastUpdatedOn DATE DEFAULT (GETDATE())
GO


ALTER TABLE UserRoles
	ADD CreatedOn DATE DEFAULT (GETDATE())
ALTER TABLE UserRoles
	ADD LastUpdatedOn DATE DEFAULT (GETDATE())
GO


-- approach 2: creating a registry table
--- with this approach, we create a new registry table that will hold all the record CRUD operations (except reading).
---- also, we can have two strategies:
------- strategy 1: the DB caller when inserting a new record into the other tables, 
------- at the same time requests the insertion of the Created-type record in this registry
------- strategy 2: the DB using Triggers, for the Create and/or Update operations, 
------- insert a new record into the Registry
--- this approach works best for the following acceptance criteria:
----> "Fields for tracking user details by which user was inserted/updated."

CREATE TABLE Registry (
	ID INT IDENTITY(1,1),
	[DateTime] DATETIME DEFAULT (GETDATE()),
	[Operation] VARCHAR(10), -- 'Created', 'Modified'
	[ObjectId] UNIQUEIDENTIFIER, -- User ID, Dept. Id, Role Id, UserRole Id, etc.
)


/* TECHNICAL SECTION
*
*/

/* On which approach could work best for marking a record as Inactive/Deleted*/
-- Thats known as a logical delete or soft delete. To achieve that we could
-- add into the tables another column that contains the Inactive/Delete status.
-- That way we don't need to phyisically delete the record.

ALTER TABLE Users
	ADD IsDeleted BIT DEFAULT (0) -- 0: No, it is not deleted | 1: Yes, it is deleted
GO

ALTER TABLE Roles
	ADD IsDeleted BIT DEFAULT (0) -- 0: No, it is not deleted | 1: Yes, it is deleted
GO

ALTER TABLE UserRoles
	ADD IsDeleted BIT DEFAULT (0) -- 0: No, it is not deleted | 1: Yes, it is deleted
GO
-- * i'm not adding a new column for the Departments as seems to be
--  that the Department Status (IsActive) column purpose is the same, 
--  but until it is otherwise specified, I will add it.

-- at the same time, using any of the aforementioned approaches
-- to handle the tracking of the records, we could opt by adding a new column (DeletedOn),
-- or add a new type of [Operation] ('Deleted') into the Registry table




