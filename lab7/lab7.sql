IF OBJECT_ID('AskDB') IS NOT NULL
    DROP DATABASE AskDB;
GO

CREATE DATABASE AskDB;

GO

USE AskDB;
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


CREATE TABLE Questions
(
    question_num int IDENTITY UNIQUE,
    user_id      int                         NOT NULL REFERENCES Users (user_id) ON DELETE CASCADE,
    title        nvarchar(100)               NOT NULL,
    description  nvarchar(max)               NOT NULL,
    created_at   datetime                    NOT NULL DEFAULT (GETDATE())
);
GO


INSERT INTO Users(email, name, surname, nickname)
VALUES (N'kirill@vk.com', N'kirill', N'kiselev', N'kirill_vk'),
       (N'kirill@mail.ru', N'kirill', N'kiselev', N'kirill_mail'),
       (N'kirill@yandex.ru', N'kirill', N'kiselev', N'kirill_yandex');


INSERT INTO Questions(user_id, title, description)
VALUES (1, 'first question', 'first question description'),
       (2, 'second question', 'second question description'),
       (1, 'third question', 'third question description');

SELECT *
FROM Users;
GO

SELECT *
FROM Questions;
GO


CREATE VIEW UsersNicknameEmailView
AS
SELECT nickname, email
FROM Users;
GO

CREATE VIEW UsersQuestionsView WITH SCHEMABINDING
AS
SELECT U.nickname, U.user_id, Q.question_num, Q.title, Q.description
FROM dbo.Users as U JOIN dbo.Questions as Q on U.user_id = Q.user_id
WITH CHECK OPTION;

CREATE UNIQUE CLUSTERED INDEX USERS_QUESTIONS_VIEW_IDX ON UsersQuestionsView(nickname, title);

SELECT *
FROM UsersNicknameEmailView;

SELECT *
FROM UsersQuestionsView;

-- INDEX
CREATE INDEX USERS_EMAIL_IDX
    ON Users (email)
    INCLUDE (nickname);
GO

-- CHECK INDEX
SELECT *
FROM sys.indexes
WHERE object_id = (SELECT object_id FROM sys.objects WHERE name = 'UsersQuestionsView');

-- SELECT *
-- FROM sys.dm_db_index_usage_stats;


