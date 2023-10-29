USE master;
GO
IF DB_ID (N'AskDB') IS NOT NULL
DROP DATABASE AskDB;
GO

-- 1. Создание базы данных
CREATE DATABASE AskDB
ON PRIMARY
  ( NAME='Ask_dat',
    FILENAME = '/data/data.mdf',
    SIZE=10MB,
    MAXSIZE=UNLIMITED, FILEGROWTH=5%)

  LOG ON (
      NAME =  'Ask_log',
      FILENAME = '/data/ask_log.ldf',
      SIZE=10MB,
      MAXSIZE=25MB,
      FILEGROWTH=5MB
      );


USE AskDB;
-- 2. Создание таблицы

IF OBJECT_ID(N'USERS') IS NOT NULL
    DROP TABLE  USERS;

CREATE TABLE USERS(
    user_id int PRIMARY KEY,
    email nvarchar(80) UNIQUE NOT NULL ,
    name nvarchar(100) NOT NULL,
    surname nvarchar(100) NOT NULL,
    nickname nvarchar(30) UNIQUE NOT NULL,
);


-- 3. Создание файловой группы и файла данных

ALTER DATABASE AskDB
ADD FILEGROUP AskFilegroup;
GO

ALTER  DATABASE AskDB
ADD FILE (
    NAME='ask_user_dat',
    FILENAME = '/data/ask_user_dat.ndf',
    SIZE=10MB,
    MAXSIZE=UNLIMITED, FILEGROWTH=5%
    )
TO FILEGROUP AskFilegroup;
GO

-- 4. Установка новой файловой группы группой по-умолчанию

ALTER DATABASE AskDB
MODIFY FILEGROUP AskFilegroup DEFAULT;

-- 5. Создание еще одной таблицы


if OBJECT_ID(N'TAGS') is NOT NULL
	DROP Table TAGS;

CREATE TABLE TAGS(
    tag_id int PRIMARY KEY,
    tagname nvarchar(30) UNIQUE NOT NULL,
);

-- 6. Удаление группы

ALTER DATABASE AskDB
    MODIFY FILEGROUP [primary] default;

DROP TABLE  Tags;

ALTER  DATABASE  AskDB
    REMOVE FILE Ask_user_dat;

ALTER DATABASE AskDB
    REMOVE FILEGROUP AskFilegroup;

-- 7. Создание схемы

CREATE SCHEMA ASK_SCHEMA;

-- перемещение таблицы

ALTER SCHEMA ASK_SCHEMA TRANSFER dbo.USERS;

-- Удаление таблицы
DROP TABLE  ASK_SCHEMA.USERS;

-- Удаление схемы
DROP SCHEMA ASK_SCHEMA;
