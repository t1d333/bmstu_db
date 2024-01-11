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


INSERT INTO Users(email, name, surname, nickname)
VALUES (N'kirill@vk.com', N'kirill', N'kiselev', N'kirill_vk'),
       (N'kirill@mail.ru', N'kirill', N'kiselev', N'kirill_mail'),
       (N'kirill@yandex.ru', N'kirill', N'kiselev', N'kirill_yandex13'),
       (N'slava@yandex.ru', N'slava', N'lokshin', N'slavaRusWarrior'),
       (N'abc@yandex.ru', N'abcd', N'efgdsdf', N'aaabbb13');
GO

-- Пункт 1
CREATE PROCEDURE GET_YANDEX_USERS
    @result_cursor CURSOR VARYING OUTPUT
AS
    SET @result_cursor = CURSOR
    FORWARD_ONLY STATIC FOR
    SELECT email, nickname
    FROM Users
    WHERE email LIKE '%@yandex.ru';
    OPEN @result_cursor;
GO

DECLARE @USER_CURSOR CURSOR;
DECLARE @NICKNAME nvarchar(30);
DECLARE @EMAIL    nvarchar(80);
exec GET_YANDEX_USERS @result_cursor = @USER_CURSOR OUTPUT;
FETCH NEXT FROM @USER_CURSOR INTO @NICKNAME, @EMAIL;
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @NICKNAME, @EMAIL;
    FETCH NEXT FROM @USER_CURSOR INTO @NICKNAME, @EMAIL;
END
CLOSE @USER_CURSOR
DEALLOCATE @USER_CURSOR
GO



-- Пункт 2

CREATE FUNCTION CRETATE_JSON_USER(@id int)
RETURNS nvarchar(max)
AS
BEGIN
    DECLARE @user_json nvarchar(max);
    DECLARE @user_name nvarchar(100);
    DECLARE @user_email    nvarchar(80);
    DECLARE @user_surname  nvarchar(100);
    DECLARE @user_nickname nvarchar(30);
    SELECT @user_email = u.email, @user_name = u.name, @user_surname = u.surname, @user_nickname = u.nickname
    FROM Users as u
    WHERE user_id = @id;

    SET @user_json = CONCAT('{"name": ', '"',@user_name,'"', ', ');
    SET @user_json = CONCAT(@user_json, '"surname": ', '"', @user_surname, '"', ', ');
    SET @user_json = CONCAT(@user_json, '"nickname": ', '"', @user_nickname, '"', ', ');
    SET @user_json = CONCAT(@user_json, '"email": ', '"', @user_email, '"', '}');
    RETURN @user_json;
END;


CREATE PROCEDURE GET_USERS_JSON_DATA
@result_cursor CURSOR VARYING OUTPUT
AS
    SET @result_cursor = CURSOR
    FORWARD_ONLY STATIC FOR
    SELECT user_id, dbo.CRETATE_JSON_USER(user_id) as raw_json
    FROM Users;
    OPEN @result_cursor;
GO



DECLARE @JSON_CURSOR CURSOR;
DECLARE @USER_ID nvarchar(30);
DECLARE @RAW_JSON    nvarchar(500);
exec GET_USERS_JSON_DATA @result_cursor = @JSON_CURSOR OUTPUT;
FETCH NEXT FROM @JSON_CURSOR INTO @USER_ID, @RAW_JSON;
WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @USER_ID as id, @RAW_JSON as raw_json;
        FETCH NEXT FROM @JSON_CURSOR INTO @USER_ID, @RAW_JSON;
    END
CLOSE @JSON_CURSOR;
DEALLOCATE @JSON_CURSOR;
GO


-- Пункт 3

CREATE FUNCTION IS_CONTAINS_13(@nickname nvarchar(30))
RETURNS INT
AS
BEGIN
    DECLARE @result INT;
    SET @result = 0;
    IF (@nickname LIKE  '%13%')
    SET @result = 1;
    RETURN @result;
END;

CREATE PROCEDURE PRINT_WITH_COND
AS
    DECLARE @cur CURSOR
    DECLARE @email nvarchar(80), @nickname nvarchar(30);
    EXEC GET_YANDEX_USERS @result_cursor = @cur OUTPUT;
    FETCH NEXT FROM @cur INTO @email, @nickname;
    WHILE @@FETCH_STATUS = 0
        BEGIN
            IF (dbo.IS_CONTAINS_13(@nickname) = 1)
            PRINT 'nickaeme: ' + @nickname + ', ' + 'email: ' + 'email';
            FETCH NEXT FROM @cur INTO @email, @nickname;
        END
    CLOSE @cur;
    DEALLOCATE @cur;



EXEC PRINT_WITH_COND;
GO


-- пункт 4


CREATE FUNCTION GET_USERS_TABLE_WITH_JSON()
RETURNS table
AS
RETURN (
        SELECT user_id, name, nickname, surname, email, dbo.CRETATE_JSON_USER(user_id) as raw_json
        FROM Users
    );


CREATE PROCEDURE GET_USERS_CURSOR_WITH_JSON
@result_cursor CURSOR VARYING OUTPUT
AS
    SET @result_cursor = CURSOR
    FORWARD_ONLY STATIC FOR
    SELECT * FROM dbo.GET_USERS_TABLE_WITH_JSON();
    OPEN @result_cursor;

