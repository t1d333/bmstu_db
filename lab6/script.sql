USE AskDB;
GO

IF OBJECT_ID(N'Users') IS NOT NULL
    DROP TABLE  Users;
GO

-- Таблица с автоинкрементным ключом
CREATE TABLE Users(
    user_id int IDENTITY PRIMARY KEY,
    email nvarchar(80) UNIQUE NOT NULL ,
    name nvarchar(100) NOT NULL,
    surname nvarchar(100) NOT NULL DEFAULT '',
    nickname nvarchar(30) UNIQUE NOT NULL,
    CONSTRAINT USER_NICKNAME_LENGTH CHECK (LEN(nickname) >= 5)
);
GO



INSERT INTO  USERS(email, name, surname, nickname)
   VALUES ('test@test.ru', 'kirill', 'kiselev', 'kirill1337'),
    VALUES ('test@test12.ru', 'kirill', 'kiselev', '12kirill1337');

GO
-- Способ 1
SELECT SCOPE_IDENTITY();

GO
-- Способ 2
SELECT @@IDENTITY;

GO
-- Способ 3

SELECT IDENT_CURRENT('Users');
GO



IF OBJECT_ID(N'Questions') IS NOT NULL
    DROP TABLE  Questions;
GO
-- Таблица с глобальным
CREATE TABLE Questions (
    question_num int IDENTITY UNIQUE,
    user_id int NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE ,
    question_id uniqueidentifier ROWGUIDCOL NOT NULL DEFAULT (newid()),
    title nvarchar(100) NOT NULL,
    description nvarchar(max) NOT NULL,
    created_at datetime NOT NULL DEFAULT (GETDATE())
)

GO

INSERT INTO Questions(user_id, title, description)
VALUES (1, N'как сдать рк1 по теории формальных языков', N'мне кажется это невозможно')
GO

SELECT * FROM Questions;
GO


-- Таблица с первичным ключом на основе последовательности.

-- Создание последовательности

IF OBJECT_ID('AskSequence') IS NOT NULL
    DROP SEQUENCE AskSequence;
GO

CREATE SEQUENCE AskSequence
    START WITH 1
    INCREMENT BY 1;
GO

IF OBJECT_ID('Answers') IS NOT NULL
    DROP TABLE  Answers;
GO


CREATE TABLE Answers (
    answer_num int IDENTITY ,
    answer_id int PRIMARY KEY DEFAULT (NEXT VALUE FOR AskSequence),
    user_id int NOT NULL REFERENCES Users(user_id),
    question_num int NOT NULL REFERENCES Questions(question_num),
    rating int NOT NULL DEFAULT 0,
    created_at datetime NOT NULL DEFAULT (GETDATE()),
    text nvarchar(max) NOT NULL,
    attachment_code nvarchar(max) NULL DEFAULT NULL
)
GO

INSERT INTO Answers(user_id, question_num, text)
VALUES
       (1, 1, N'просто'),
       (2, 1, N'не просто');
GO

SELECT  * FROM Answers;



-- Cвязные таблицы

IF OBJECT_ID('Marks') IS NOT NULL
    DROP TABLE  Marks;
GO

CREATE TABLE Marks(
    user_id int REFERENCES Users(user_id),
    answer_id int REFERENCES Answers(answer_id),
    value int NOT NULL CHECK (value BETWEEN -1 AND 1),
    PRIMARY KEY (user_id, answer_id)
);

GO

INSERT INTO Marks(user_id, answer_id, value)
VALUES  (1, 1, -1),
        (1, 2, 1)
GO

DELETE FROM Answers WHERE answer_id = 2;
GO

-- DELETE CASCADE

ALTER TABLE Marks
ADD CONSTRAINT USER_ID_FK FOREIGN KEY(user_id) REFERENCES Users(user_id) ON DELETE CASCADE;

ALTER TABLE Marks
ADD CONSTRAINT ANSWER_ID_FK FOREIGN KEY(answer_id) REFERENCES Answers(answer_id) ON DELETE CASCADE;

ALTER TABLE Marks
DROP CONSTRAINT USER_ID_FK;

ALTER TABLE Marks
DROP CONSTRAINT ANSWER_ID_FK;


-- SET NULL

ALTER TABLE Marks
ADD CONSTRAINT USER_ID_FK FOREIGN KEY(user_id) REFERENCES Users(user_id) ON DELETE SET NULL;

ALTER TABLE Marks
ADD CONSTRAINT ANSWER_ID_FK FOREIGN KEY(answer_id) REFERENCES Answers(answer_id) ON DELETE SET NULL;

ALTER TABLE Marks
DROP CONSTRAINT USER_ID_FK;

ALTER TABLE Marks
DROP CONSTRAINT ANSWER_ID_FK;



-- SET DEFAULT

ALTER TABLE Marks
ADD CONSTRAINT USER_ID_FK FOREIGN KEY(user_id) REFERENCES Users(user_id) ON DELETE SET DEFAULT ;

ALTER TABLE Marks
ADD CONSTRAINT ANSWER_ID_FK FOREIGN KEY(answer_id) REFERENCES Answers(answer_id) ON DELETE SET DEFAULT ;

ALTER TABLE Marks
DROP CONSTRAINT USER_ID_FK;

ALTER TABLE Marks
DROP CONSTRAINT ANSWER_ID_FK;
