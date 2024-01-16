CREATE DATABASE lab12;
GO

USE lab12;
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
    question_num int IDENTITY PRIMARY KEY,
    user_id      int           NOT NULL REFERENCES Users (user_id) ON DELETE CASCADE,
    title        nvarchar(100) NOT NULL,
    description  nvarchar(max) NOT NULL,
    created_at   datetime      NOT NULL DEFAULT (GETDATE())
);
GO