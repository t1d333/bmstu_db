
IF OBJECT_ID('Users') IS NOT NULL
    DROP TABLE Users
GO

USE master;

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
    question_num int IDENTITY PRIMARY KEY ,
    user_id      int                         NOT NULL REFERENCES Users (user_id) ON DELETE CASCADE,
    title        nvarchar(100)               NOT NULL,
    description  nvarchar(max)               NOT NULL,
    created_at   datetime                    NOT NULL DEFAULT (GETDATE())
);
GO


INSERT INTO Users(email, name, surname, nickname)
VALUES (N'kirill@vk.com', N'kirill', N'kiselev', N'kirill_vk'),
       (N'kirill@mail.ru', N'kirill', N'kiselev', N'kirill_mail'),
       (N'kirill@yandex.ru', N'kirill', N'kiselev', N'kirill_yandex'),
       (N'abc@mail.ru', N'abc', N'bbbbbb', N'bbbbbbbb'),
       (N'abc@yandex.ru', N'abc', N'cccccc', N'ccccccc');


INSERT INTO Questions(user_id, title, description)
VALUES (1, 'first question', 'first question description'),
       (2, 'second question', 'second question description'),
       (1, 'third question', 'third question description');

SELECT * FROM Users;


IF OBJECT_ID('NewUsers') IS NOT NULL
    DROP TABLE Users
GO

CREATE TABLE NewUsers
(
    user_id int PRIMARY KEY ,
    register_time datetime,
)

SELECT * FROM NewUsers;

-- триггер на вставку
CREATE TRIGGER UPDATE_NEW_USERS_ON_INSERT
ON Users
AFTER INSERT
AS
    INSERT INTO NewUsers (user_id, register_time)
    SELECT user_id, GETDATE()
    FROM inserted;



CREATE TRIGGER LIMIT_NEW_USERS
ON NewUsers
AFTER INSERT
AS
WHILE (SELECT count(*) FROM NewUsers) > 5
    BEGIN
        DELETE FROM NewUsers
        WHERE user_id IN (
            SELECT TOP 1 user_id
            FROM NewUsers
            ORDER BY register_time
        );
    END


INSERT INTO Users(email, name, surname, nickname)
VALUES (N'abcd3113@vk.com', N'abc', N'aaaaa', N'abcdefgу1132111'),
    (N'abcd2211@vk.com', N'abc', N'aaaaa', N'ab1cdefg1у12'),
    (N'abc1d111@vk.com', N'abc', N'aaaaa', N'abcd1efgу113');


-- триггер на обновление
CREATE TRIGGER UPDATE_NEW_USERS_ON_UPDATE
ON Users
AFTER UPDATE
AS
    IF UPDATE(email)
        THROW 51000, 'It is forbidden to change email', 1;


-- триггер на удаление
CREATE TRIGGER UPDATE_NEW_USERS_ON_DELETE
ON Users
AFTER DELETE
AS
    DELETE FROM NewUsers
    WHERE NewUsers.user_id IN (SELECT user_id FROM deleted);


    CREATE VIEW UsersQuestionsView WITH SCHEMABINDING
    AS
    SELECT U.user_id as author_id,
           U.nickname,
           U.name,
           U.surname,
           U.email,
           Q.question_num,
           Q.title,
           Q.description
    FROM dbo.Users as U
             JOIN dbo.Questions as Q on U.user_id = Q.user_id
GO;

-- INSERT TRIGGER

CREATE TRIGGER  USER_QUESTIONS_VIEW_INSERT_TRIGGER ON UsersQuestionsView
INSTEAD OF INSERT
AS
    BEGIN
            INSERT INTO Users(email, name, surname, nickname)
            SELECT DISTINCT i.email, i.name, i.surname, i.nickname FROM inserted as i
            WHERE NOT EXISTS(SELECT * FROM Users AS u WHERE u.nickname = i.nickname OR u.email = i.email);

            INSERT INTO Questions(user_id, title, description)
            SELECT (SELECT user_id FROM Users WHERE nickname = inserted.nickname), title, description FROM inserted;
    END
GO;

INSERT INTO UsersQuestionsView(author_id, nickname, name, surname, email, question_num, title, description)
VALUES (0, N'kirill_vk123', 'name', 'surname', 'email@vk123.com', 0, N'title1', N'description1'),
       (1, N'kirill_vk1', 'name', 'surname', 'email1@vk.com', 0, N'title2', N'description2'),
       (2, N'kirill_vk2', 'name', 'surname', 'email2@vk.com', 0, N'title3', N'description3');

SELECT * FROM Questions;

SELECT * FROM Users;

SELECT * FROM UsersQuestionsView;


-- Update trigger
CREATE TRIGGER  USER_QUESTIONS_VIEW_UPDATE_TRIGGER ON UsersQuestionsView
INSTEAD OF UPDATE
AS
BEGIN
    
    IF UPDATE(author_id)
        THROW 51000, 'It is forbidden to question author', 1;

  
    UPDATE Questions
    SET title = inserted.title, description = inserted.description
    FROM inserted
    WHERE Questions.question_num = inserted.question_num

    UPDATE Users
    SET nickname = inserted.nickname, name = inserted.name, surname = inserted.surname, email = inserted.email
    FROM inserted
    WHERE inserted.author_id = Users.user_id

END
GO;

SELECT * FROM Questions;

UPDATE UsersQuestionsView
SET title = 'new title1123'
WHERE author_id = 9;

UPDATE UsersQuestionsView
SET name = 'new name123'
WHERE author_id = 9;

SELECT * FROM UsersQuestionsView;

-- Delete trigger
CREATE TRIGGER  USER_QUESTIONS_VIEW_DELETE_TRIGGER ON UsersQuestionsView
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM Questions
    WHERE question_num IN (SELECT question_num FROM deleted);
END
GO;

DELETE FROM UsersQuestionsView
WHERE author_id = 9;

SELECT * FROM Questions;


