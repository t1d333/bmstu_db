CREATE DATABASE AskDB151

CREATE DATABASE AskDB152

USE AskDB151
GO

DROP TABLE IF EXISTS Users
GO

CREATE TABLE Users
(
    user_id int IDENTITY PRIMARY KEY,
    email   nvarchar(256) UNIQUE NOT NULL,
    name    nvarchar(80)         NOT NULL,
    surname nvarchar(100)        NOT NULL DEFAULT '',
);
GO


CREATE TRIGGER UsersDeleteTrigger
    ON Users
    AFTER DELETE AS
BEGIN
    DELETE FROM AskDB152.dbo.Questions WHERE user_id IN (SELECT user_id FROM deleted)
END
GO



CREATE TRIGGER UsersUpdateTrigger ON Users
    AFTER UPDATE AS
BEGIN
    IF UPDATE(user_id)
        THROW 50002, 'cant update user_id',1
END
GO


USE AskDB152
GO

DROP TABLE IF EXISTS Questions
GO

CREATE TABLE Questions
(
    question_num int IDENTITY PRIMARY KEY,
    user_id      int           NOT NULL,
    title        nvarchar(100) NOT NULL,
    description  nvarchar(max) NOT NULL,
    created_at   datetime      NOT NULL DEFAULT (GETDATE())
);
GO

CREATE TRIGGER QuestionsInsertTrig
    ON Questions
    AFTER INSERT AS
BEGIN
    IF EXISTS(SELECT i.user_id FROM inserted AS i WHERE i.user_id NOT IN (SELECT user_id FROM AskDB151.dbo.Users))
        BEGIN
            THROW 51000, N'User with this id does not exists', 1
        END
END
GO

CREATE TRIGGER QUESTIONS_AUTHOR_UPDATE
    ON Questions
    FOR UPDATE AS
BEGIN
    IF UPDATE(user_id)
        THROW 51000, 'It is forbidden to change question author', 1;
END
GO

CREATE VIEW UsersQuestionsView
AS
  SELECT  U.user_id, U.name, U.surname, U.email, Q.question_num, Q.title,Q.description, Q.created_at
  FROM AskDB151.dbo.Users As U INNER JOIN AskDB152.dbo.Questions Q on U.user_id = Q.user_id


INSERT INTO AskDB151.dbo.Users(email, name, surname)
VALUES (N'kirill@vk.com', N'kirill', N'kiselev'),
       (N'kirill@mail.ru', N'kirill', N'kiselev');
GO


INSERT INTO AskDB152.dbo.Questions(user_id, title, description)
VALUES (3, 'test', 'test123');

DELETE FROM AskDB152.dbo.Questions WHERE title = 'test'

UPDATE AskDB152.dbo.Questions SET user_id = 10 WHERE title = 'test'

DELETE FROM AskDB151.dbo.Users WHERE user_id = 2;
SELECT * FROM AskDB152.dbo.Questions;

SELECT * FROM AskDB151.dbo.Users;

