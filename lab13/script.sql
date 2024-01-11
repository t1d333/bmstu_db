CREATE DATABASE AskDB1

CREATE DATABASE AskDB2

USE AskDB1
GO

DROP TABLE IF EXISTS Users
GO

CREATE TABLE Users
(
    user_id  int PRIMARY KEY CHECK (user_id <= 4),
    email    nvarchar(256) UNIQUE NOT NULL,
    name     nvarchar(80)         NOT NULL,
    surname  nvarchar(100)        NOT NULL DEFAULT '',
);
GO

DROP TRIGGER IF EXISTS UsersInsert

CREATE TRIGGER UsersInsert ON Users
    AFTER INSERT AS
BEGIN
    IF (EXISTS (SELECT * FROM inserted as i JOIN AskDB2.dbo.Users as u ON i.user_id = u.user_id))
        BEGIN
            THROW 50001, 'such user already exists',1
        END

    IF (EXISTS (SELECT * FROM inserted as i JOIN AskDB2.dbo.Users as u ON i.email = u.email))
        BEGIN
            THROW 50001, 'such user already exists',1
        END
END
GO


CREATE TRIGGER UsersUpdateTrigger ON Users
    AFTER UPDATE AS
BEGIN
    IF UPDATE(user_id)
        THROW 50002, 'cant update user_id',1

    IF (EXISTS (SELECT * FROM inserted as i JOIN AskDB2.dbo.Users as u ON i.email = u.email))
        BEGIN
            THROW 50001, 'user with this email already exists',1
        END
END
GO


USE AskDB2
GO

DROP TABLE IF EXISTS Users
GO

CREATE TABLE Users
(
    user_id  int NOT NULL PRIMARY KEY CHECK (user_id > 4),
    email    nvarchar(256) UNIQUE NOT NULL,
    name     nvarchar(80)         NOT NULL,
    surname  nvarchar(100)        NOT NULL DEFAULT '',
    nickname nvarchar(30) UNIQUE  NOT NULL,
);
GO

DROP TRIGGER IF EXISTS UsersInsert
CREATE TRIGGER UsersInsert ON Users
    AFTER INSERT AS
BEGIN
    IF (EXISTS (SELECT * FROM inserted as i JOIN AskDB1.dbo.Users as u ON i.user_id = u.user_id))
        BEGIN
            THROW 50001, 'such user already exists',1
        END

    IF (EXISTS (SELECT * FROM inserted as i JOIN AskDB1.dbo.Users as u ON i.email = u.email))
        BEGIN
            THROW 50001, 'such user already exists',1
        END
END
GO



DROP TRIGGER IF EXISTS UsersUpdateTrigger

CREATE TRIGGER UsersUpdateTrigger ON Users
    AFTER UPDATE AS
BEGIN
    IF UPDATE(user_id)
        THROW 50002, 'cant update user_id',1

    IF (EXISTS (SELECT * FROM inserted as i JOIN AskDB1.dbo.Users as u ON i.email = u.email))
        BEGIN
            THROW 50001, 'user with this email already exists',1
        END
END
GO

DROP TRIGGER IF EXISTS UsersInsert

CREATE TRIGGER UsersInsert ON Users
FOR INSERT AS
BEGIN
    (SELECT * FROM AskDB2.dbo.Users)
END
GO

USE AskDB1
GO

DROP VIEW IF EXISTS UsersView
GO

CREATE VIEW UsersView AS
SELECT user_id, email, name, surname, nickname
FROM AskDB1.dbo.Users
UNION ALL
SELECT user_id, email, name, surname, nickname
FROM AskDB2.dbo.Users
GO


USE AskDB2
GO

DROP VIEW IF EXISTS UsersView
GO

CREATE VIEW UsersView AS
SELECT user_id, email, name, surname, nickname
FROM AskDB1.dbo.Users
UNION ALL
SELECT user_id, email, name, surname, nickname
FROM AskDB2.dbo.Users
GO


INSERT INTO UsersView(user_id, email, name, surname, nickname)
VALUES (9, N'kiri1ll@vk.com', N'kirill', N'kiselev', N'kirill_v1k'),
       (10, N'kiril1l@mail.ru', N'kirill', N'kiselev', N'kirill_mail1');


INSERT INTO UsersView(user_id, email, name, surname, nickname)
VALUES (13, N'kiri1ll@vk111.com', N'kirill', N'kiselev', N'kirill_v1111k');

SELECT * FROM UsersView;
SELECT * FROM AskDB1.dbo.Users;
SELECT * FROM AskDB2.dbo.Users;


DELETE FROM UsersView WHERE user_id = 9;
GO

UPDATE UsersView SET name = 'name123' WHERE user_id = 0;
GO
