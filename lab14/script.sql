CREATE DATABASE AskDB141

CREATE DATABASE AskDB142

USE AskDB141
GO

DROP TABLE IF EXISTS Users
GO

CREATE TABLE Users
(
    user_id int PRIMARY KEY,
    email   nvarchar(256) UNIQUE NOT NULL,
    name    nvarchar(80)         NOT NULL,
    --surname  nvarchar(100)        NOT NULL DEFAULT '',
    --nickname nvarchar(30) UNIQUE  NOT NULL,
);
GO

USE AskDB142
GO

DROP TABLE IF EXISTS Users
GO

CREATE TABLE Users
(
    user_id  int                 NOT NULL PRIMARY KEY,
    -- email    nvarchar(256) UNIQUE NOT NULL,
    -- name     nvarchar(80)         NOT NULL,
    surname  nvarchar(100)       NOT NULL DEFAULT '',
    nickname nvarchar(30) UNIQUE NOT NULL,
);
GO



USE AskDB141
GO
DROP VIEW IF EXISTS UsersView
GO
CREATE VIEW UsersView AS
SELECT u1.user_id, u1.email, u1.name, u2.surname, u2.nickname
FROM AskDB141.dbo.Users as u1
         INNER JOIN AskDB142.dbo.Users as u2
                    ON u1.user_id = u2.user_id
GO


USE AskDB142
GO

DROP VIEW IF EXISTS UsersView
GO

CREATE VIEW UsersView AS
SELECT u1.user_id, u1.email, u1.name, u2.surname, u2.nickname
FROM AskDB141.dbo.Users as u1
         INNER JOIN AskDB142.dbo.Users as u2
                    ON u1.user_id = u2.user_id
GO


CREATE TRIGGER UsersViewInsertTrig ON UsersView
    INSTEAD OF INSERT
    AS
    INSERT INTO AskDB141.dbo.Users(user_id, email, name)
    SELECT user_id, email, name FROM inserted

    INSERT INTO AskDB142.dbo.Users(user_id, surname, nickname)
    SELECT user_id, surname, nickname FROM inserted
GO

CREATE TRIGGER UsersViewUpdateTrig ON UsersView
    INSTEAD OF UPDATE
    AS
    UPDATE AskDB141.dbo.Users
    SET user_id = inserted.user_id, email = inserted.email, name = inserted.name
    FROM inserted
    WHERE AskDB141.dbo.Users.user_id = inserted.user_id

    UPDATE AskDB142.dbo.Users
    SET user_id = inserted.user_id, surname = inserted.surname, nickname = inserted.nickname
    FROM inserted
    WHERE AskDB142.dbo.Users.user_id = inserted.user_id
GO

CREATE TRIGGER UsersViewDeleteTrig ON UsersView
    INSTEAD OF DELETE
    AS
    DELETE FROM AskDB141.dbo.Users WHERE user_id IN (SELECT user_id FROM deleted)
    DELETE FROM AskDB142.dbo.Users WHERE user_id IN (SELECT user_id FROM deleted)
GO


INSERT INTO UsersView(user_id, email, name, surname, nickname)
VALUES (9, N'kiri1ll@vk.com', N'kirill', N'kiselev', N'kirill_v1k'),
       (10, N'kiril1l@mail.ru', N'kirill', N'kiselev', N'kirill_mail1');



SELECT *
FROM UsersView;
SELECT *
FROM AskDB141.dbo.Users;
SELECT *
FROM AskDB142.dbo.Users;


DELETE
FROM UsersView
WHERE user_id = 9;
GO

UPDATE UsersView
SET name = 'name123'
WHERE user_id = 10;
GO