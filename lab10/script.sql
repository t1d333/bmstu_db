


DROP DATABASE IF EXISTS Ask
GO

CREATE DATABASE Ask;
GO

USE Ask;
GO

CREATE TABLE Users
(
    user_id  int IDENTITY PRIMARY KEY,
    email    nvarchar(80) UNIQUE NOT NULL,
    name     nvarchar(100)       NOT NULL,
    surname  nvarchar(100)       NOT NULL DEFAULT '',
    nickname nvarchar(30) UNIQUE NOT NULL,
    CONSTRAINT USER_NICKNAME_LENGTH CHECK (LEN(nickname) >= 5)
);
GO


INSERT INTO Users(email, name, surname, nickname)
VALUES (N'kirill@vk.com', N'kirill', N'kiselev', N'kirill_vk'),
       (N'kirill@mail.ru', N'kirill', N'kiselev', N'kirill_mail');
GO




SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

SELECT * FROM Users;
-- Dirty read
BEGIN TRANSACTION
    SELECT * FROM Users;
    SELECT request_session_id, request_type, request_mode, resource_database_id FROM sys.dm_tran_locks;
COMMIT TRANSACTION


BEGIN TRANSACTION
    SELECT * FROM Users;
    UPDATE Users set name = 'updated_name' WHERE user_id = 1;
    SELECT * FROM Users;
    WAITFOR DELAY '00:00:15'
    ROLLBACK


-- Nonrepeatable read
BEGIN TRANSACTION
    SELECT * FROM Users WHERE user_id = 1;
    WAITFOR DELAY '00:00:10'
    SELECT * FROM Users WHERE user_id = 1;
    SELECT request_session_id, request_type, request_mode, resource_database_id FROM sys.dm_tran_locks
COMMIT TRANSACTION


BEGIN TRANSACTION
    SELECT * FROM Users WHERE user_id = 1;
    UPDATE Users SET name = 'updated' WHERE user_id = 1;
    SELECT * FROM Users WHERE user_id = 1;
    SELECT request_session_id, request_type, request_mode, resource_database_id FROM sys.dm_tran_locks
COMMIT TRANSACTION


-- Phantom read

BEGIN TRANSACTION
    SELECT * FROM Users
    WAITFOR DELAY '00:00:10'
    SELECT * FROM Users
    SELECT request_session_id, request_type, request_mode, resource_database_id FROM sys.dm_tran_locks
COMMIT TRANSACTION


BEGIN TRANSACTION
    INSERT INTO Users(email, name, surname, nickname)
    VALUES (N'new1@vk.com', N'new_name', N'new_surname', N'new_nickname');
    SELECT * FROM Users
    SELECT request_session_id, request_type, request_mode, resource_database_id FROM sys.dm_tran_locks
COMMIT TRANSACTION