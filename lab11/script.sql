USE master;

CREATE TABLE Users
(
    user_id  int IDENTITY PRIMARY KEY,
    email    nvarchar(256) UNIQUE NOT NULL,
    name     nvarchar(80)         NOT NULL,
    surname  nvarchar(100)        NOT NULL DEFAULT '',
    nickname nvarchar(30) UNIQUE  NOT NULL,
);
GO


CREATE TABLE Questions
(
    question_num int IDENTITY PRIMARY KEY,
    user_id      int           NOT NULL REFERENCES Users (user_id) ON DELETE CASCADE,
    title        nvarchar(100) NOT NULL,
    description  nvarchar(max) NOT NULL,
    created_at   datetime      NOT NULL DEFAULT (GETDATE())
);
GO


CREATE TABLE Answers
(
    answer_num      int IDENTITY PRIMARY KEY,
    question_num    int           NOT NULL REFERENCES Questions (question_num),
    user_id         int           NOT NULL REFERENCES Users (user_id),
    rating          int           NOT NULL DEFAULT 0,
    attachment_code nvarchar(max)          DEFAULT NULL,
    text            nvarchar(max) NOT NULL DEFAULT '',
    created_at      datetime      NOT NULL DEFAULT (GETDATE())
);
GO


CREATE TABLE Tags
(
    tag_num int IDENTITY NOT NULL PRIMARY KEY,
    tagname nvarchar(20) NOT NULL UNIQUE,
)

CREATE TABLE Marks
(
    answer_num int NOT NULL REFERENCES Answers (answer_num),
    user_id    int NOT NULL REFERENCES Users (user_id),
    value      int NOT NULL,
    CONSTRAINT VALUE_CONSTRAINT CHECK (value = 1 OR value = -1),
    CONSTRAINT MARK_PK PRIMARY KEY (answer_num, user_id)
)

DROP TABLE TagQuestion;

CREATE TABLE TagQuestion
(
    question_num int NOT NULL REFERENCES Questions (question_num) ON DELETE CASCADE,
    tag_num      int NOT NULL REFERENCES Tags (tag_num),
    CONSTRAINT TAG_QUESTIONS_PK PRIMARY KEY (question_num, tag_num)
)


-- CREATE TRIGGER ANSWER_RATING_UPDATE_ON_INSERT_TRIGGER
--     ON Marks
--     AFTER INSERT AS
--     DECLARE @answer_num int;
--     DECLARE @user_id int;
--     DECLARE @value int;
--     DECLARE @cur CURSOR;
--     SET @cur = CURSOR FORWARD_ONLY STATIC FOR
--         SELECT answer_num, user_id, value
--         FROM inserted;
--     OPEN @cur;
--
--     FETCH NEXT FROM @cur INTO @answer_num, @user_id, @value;
--     WHILE (@@FETCH_STATUS = 0)
--         BEGIN
--             UPDATE Answers
--             SET rating = rating + @value
--             WHERE answer_num = @answer_num;
--             FETCH NEXT FROM @cur INTO @answer_num, @user_id, @value;
--         END
--     CLOSE @cur;
--     UPDATE Answers
--     SET rating = rating + inserted.value
--     FROM inserted
--     WHERE answer_num = inserted.answer_num
-- GO

DROP TRIGGER ANSWER_RATING_UPDATE_ON_INSERT_TRIGGER;

CREATE TRIGGER ANSWER_RATING_UPDATE_ON_INSERT_TRIGGER
    ON Marks
    AFTER INSERT AS
    UPDATE Answers
    SET rating = rating + (SELECT SUM(value) FROM inserted WHERE inserted.answer_num = Answers.answer_num)
    WHERE answer_num IN (SELECT answer_num FROM inserted);
GO


-- CREATE TRIGGER ANSWER_RATING_UPDATE_ON_DELETE_TRIGGER
--     ON Marks
--     AFTER DELETE AS
--     DECLARE @answer_num int;
--     DECLARE @user_id int;
--     DECLARE @value int;
--     DECLARE @cur CURSOR;
--     SET @cur = CURSOR FORWARD_ONLY STATIC FOR
--         SELECT answer_num, user_id, value
--         FROM deleted;
--     OPEN @cur;
--
--     FETCH NEXT FROM @cur INTO @answer_num, @user_id, @value;
--     WHILE (@@FETCH_STATUS = 0)
--         BEGIN
--             UPDATE Answers
--             SET rating = rating - @value
--             WHERE answer_num = @answer_num;
--             FETCH NEXT FROM @cur INTO @answer_num, @user_id, @value;
--         END
--
--     CLOSE @cur;
-- GO


DROP TRIGGER ANSWER_RATING_UPDATE_ON_DELETE_TRIGGER;
CREATE TRIGGER ANSWER_RATING_UPDATE_ON_DELETE_TRIGGER
    ON Marks
    AFTER DELETE AS
    UPDATE Answers
    SET rating = rating - (SELECT SUM(value) FROM deleted WHERE deleted.answer_num = Answers.answer_num)
    WHERE answer_num IN (SELECT answer_num FROM deleted);
GO


CREATE TRIGGER USERS_ANSWERS_DELETE_TRIGGER
    ON Users
    AFTER DELETE
    AS
BEGIN
    DELETE
    FROM Answers
    WHERE user_id IN (SELECT user_id FROM deleted);
END;
GO

CREATE TRIGGER QUESTION_ANSWERS_DELETE_TRIGGER
    ON Questions
    AFTER DELETE
    AS
BEGIN
    DELETE
    FROM Answers
    WHERE question_num IN (SELECT question_num FROM deleted);
END;
GO

DROP TRIGGER QUESTION_TAGS_DELETE_TRIGGER;

CREATE TRIGGER QUESTION_TAGS_DELETE_TRIGGER
    ON Questions
    FOR DELETE
    AS
BEGIN
    DELETE
    FROM TagQuestion
    WHERE question_num IN (SELECT question_num FROM deleted);
END;
GO

-- Запрет на изменение автора вопроса
CREATE TRIGGER QUESTIONS_AUTHOR_UPDATE_TRIGGER
    ON Questions
    FOR UPDATE AS
    IF UPDATE(user_id)
        THROW 51000, 'It is forbidden to change question author', 1;

GO

-- Запрет на изменение автора ответа и вопроса ответа
CREATE TRIGGER ANSWERS_AUTHOR_UPDATE_TRIGGER
    ON Answers
    FOR UPDATE AS
    IF UPDATE(user_id)
        THROW 51000, 'It is forbidden to change answer author', 1;

    IF UPDATE(question_num)
        THROW 51000, 'It is forbidden to change answer question', 1;
GO

-- Запрет на изменение автора оценки и ответа оценки
CREATE TRIGGER MARK_UPDATE_TRIGGER
    ON Marks
    FOR UPDATE AS
    IF UPDATE(user_id)
        THROW 51000, 'It is forbidden to change mark author', 1;

    IF UPDATE(answer_num)
        THROW 51000, 'It is forbidden to change mark answer', 1;
GO


CREATE TRIGGER TAG_QUESTION_DELETE_TRIGGER
    ON TagQuestion
    AFTER DELETE AS
BEGIN
    DELETE
    FROM Tags
    WHERE tag_num in (SELECT tag_num FROM TagQuestion GROUP BY tag_num HAVING count(*) = 0);
END
GO;


-- выборки записей (команда SELECT);
SELECT *
FROM Users;
GO

-- сортировка записей;
SELECT *
FROM Answers
WHERE rating > 2
  AND Answers.question_num = 0
ORDER BY rating DESC;
GO;

-- вложенные запросы.

-- COUNT, BETWEEN
SELECT U.user_id, U.email, U.nickname, U.name, U.surname
FROM Users U
WHERE (SELECT COUNT(*) FROM Questions Q WHERE U.user_id = Q.user_id) BETWEEN 3 AND 10

-- – условия выбора записей

-- LIKE
SELECT DISTINCT title
FROM Questions
WHERE (title LIKE '%python 3.11%')

-- EXISTS
SELECT U.user_id, U.email, U.nickname, U.name, U.surname
FROM Users U
WHERE EXISTS(SELECT answer_num FROM Answers A WHERE U.user_id = A.user_id)

-- NULL

SELECT *
FROM Answers
WHERE attachment_code IS NOT NULL

-- IN
SELECT *
FROM Answers A
WHERE question_num IN
      (SELECT question_num
       FROM Questions Q
       WHERE Q.user_id BETWEEN 1 AND 5)

-- INNER JOIN
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
         INNER JOIN Questions as Q on U.user_id = Q.user_id
GO;

-- LEFT JOIN
CREATE VIEW QuestionsAnswersView WITH SCHEMABINDING
AS
SELECT q.question_num,
       q.user_id as question_author,
       q.title,
       q.description,
       a.answer_num,
       a.user_id as answer_author,
       a.text,
       a.attachment_code,
       a.rating,
       a.created_at
FROM Questions AS q
         LEFT JOIN Answers AS a
                   ON q.question_num = a.question_num
GO;


-- RIGHT JOIN
SELECT a.answer_num, a.text, a.attachment_code, m.value, m.user_id
FROM Marks as m
         RIGHT JOIN Answers A on A.answer_num = m.answer_num
GO;


-- FULL OUTER JOIN
SELECT u.user_id, u.nickname, a.answer_num, a.text
FROM Users as u
         FULL OUTER JOIN Answers as a on u.user_id = a.user_id


-- группировка записей (GROUP BY + HAVING, использование функций агрегирования);

-- AVG
SELECT question_num, AVG(rating) as avg_answers_rating
FROM Answers
GROUP BY question_num
HAVING (AVG(rating)) > 2.5
GO;


-- COUNT
SELECT question_num, COUNT(*) as answers_count
FROM Answers
GROUP BY question_num
HAVING (COUNT(*)) >= 1
GO;

-- SUM
SELECT u.user_id, SUM(m.value) as total_mark
FROM Users as u
         INNER JOIN Marks as m on u.user_id = m.user_id
GROUP BY u.user_id
HAVING SUM(m.value) > 0
GO;

-- MIN
SELECT answer_num, SUM(value) as rating
FROM Marks
GROUP BY answer_num
HAVING SUM(value) > (SELECT MIN(rating) FROM Answers)

-- MAX
SELECT answer_num, SUM(value) as rating
FROM Marks
GROUP BY answer_num
HAVING SUM(value) = (SELECT MAX(rating) FROM Answers)


-- объединение результатов нескольких запросов;

-- INTERSECT
SELECT user_id, nickname
FROM Users
WHERE EXISTS(SELECT question_num FROM Questions WHERE Questions.user_id = Users.user_id)
INTERSECT
SELECT user_id, nickname
FROM Users
WHERE EXISTS(SELECT answer_num FROM Answers WHERE Answers.user_id = Users.user_id)

-- UNION
SELECT text, attachment_code
FROM Answers
WHERE attachment_code LIKE '%#include<iostream>%'
UNION ALL
SELECT text, attachment_code
FROM Answers
WHERE text LIKE '%cpp17%'

--UNION ALL
SELECT user_id, nickname
FROM Users
WHERE EXISTS(SELECT answer_num
             FROM Answers
             WHERE (Answers.user_id = Users.user_id)
               AND (Answers.attachment_code IS NOT NULL))
UNION ALL
SELECT user_id, nickname
FROM Users
WHERE EXISTS(SELECT answer_num FROM Marks WHERE (Marks.user_id = Users.user_id) AND (Marks.value = 1))

-- EXCEPT
SELECT user_id, nickname
FROM Users
WHERE EXISTS(SELECT answer_num
             FROM Answers
             WHERE (Answers.user_id = Users.user_id)
               AND (attachment_code IS NOT NULL)
               AND (attachment_code LIKE '%import pytest%'))
EXCEPT
SELECT user_id, nickname
FROM Users
WHERE EXISTS(SELECT question_num
             FROM Questions
             WHERE (Questions.user_id = Users.user_id)
               AND (Questions.title LIKE '%python 3.11%'))


-- Users
INSERT INTO Users(email, name, surname, nickname)
VALUES (N'kirill@vk.com', N'kirill', N'kiselev', N'kirill_vk'),
       (N'kirill@mail.ru', N'kirill', N'kiselev', N'kirill_mail');
GO

-- Questions

CREATE TYPE TagsArg AS TABLE
(
    tagname nvarchar(30)
);

DROP PROCEDURE INSERT_NEW_QUESTION;

CREATE PROCEDURE INSERT_NEW_QUESTION @user_id int,
                                     @title nvarchar(100),
                                     @description nvarchar(max),
                                     @tags TagsArg READONLY
AS
BEGIN
    IF (SELECT COUNT(tagname) FROM @tags) < 1
        THROW 51000, 'It is forbidden to insert question without tags', 1;

    DECLARE @question_num int;
    BEGIN TRANSACTION
        INSERT INTO Questions(user_id, title, description)
        VALUES (@user_id, @title, @description);

        SET @question_num = (SELECT IDENT_CURRENT('Questions'));

        INSERT INTO Tags(tagname)
        SELECT DISTINCT tagname
        FROM @tags t1
        WHERE NOT EXISTS(SELECT * FROM Tags WHERE Tags.tagname = t1.tagname);

        INSERT INTO TagQuestion(question_num, tag_num)
        SELECT DISTINCT @question_num, (SELECT tag_num FROM Tags WHERE t1.tagname = tagname)
        FROM @tags t1;

    COMMIT TRANSACTION

END;

DECLARE @tagsarg TagsArg;
INSERT INTO @tagsarg(tagname)
VALUES ('Tagname1'),
       ('Tagname2'),
       ('Tagname3');

    EXEC INSERT_NEW_QUESTION @user_id = 1, @title = 'new question123', @description = 'abcdefg22', @tags = @tagsarg
GO


SELECT *
FROM Questions;

DELETE FROM Questions WHERE question_num = 2;

SELECT *
FROM Tags;
SELECT *
FROM TagQuestion;


-- Answers

INSERT INTO Answers(question_num, user_id, text)
VALUES (1, 2, 'new answer 1');

SELECT *
FROM Answers;
-- Marks

DELETE
FROM Marks
WHERE answer_num = 1;

INSERT INTO Marks(user_id, answer_num, value)
VALUES (1, 1, 1),
       (2, 1, 1);


SELECT *
FROM Marks;
SELECT rating
FROM Answers
WHERE answer_num = 1


-- Tags

DROP PROCEDURE INSERT_NEW_TAG;

CREATE PROCEDURE INSERT_NEW_TAG @tagname nvarchar(30),
                                @question_num nvarchar(max)
AS
BEGIN
    IF EXISTS(SELECT * FROM Tags WHERE tagname = @tagname)
        THROW 51000, 'This tag already exists', 1;

    IF NOT EXISTS(SELECT * FROM Questions WHERE question_num = @question_num)
        THROW 51000, 'This question does not exists', 1;

    BEGIN TRANSACTION
        INSERT INTO Tags(tagname)
        VALUES (@tagname);

        INSERT INTO TagQuestion(question_num, tag_num)
        VALUES (@question_num, (SELECT tag_num FROM Tags WHERE tagname = @tagname));
    COMMIT TRANSACTION
END
GO;

EXEC INSERT_NEW_TAG @tagname = 'new tag 1', @question_num = 1
GO;
EXEC INSERT_NEW_TAG @tagname = 'new tag 2', @question_num = 1
GO;
EXEC INSERT_NEW_TAG @tagname = 'new tag 3', @question_num = 1
GO;

SELECT *
FROM Tags;

SELECT *
FROM TagQuestion;


-- модификации записей (команда UPDATE);
UPDATE Questions
SET title = '[DEPRECATED] ' + title
WHERE created_at < DATEADD(YEAR, -5, GETDATE());


-- удаления записей (команда DELETE);

DELETE
FROM Answers
WHERE rating < 0;

DELETE
FROM Questions
WHERE title LIKE '%Windows%'

