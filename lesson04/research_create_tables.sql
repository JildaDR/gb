/* Приложение для составления и ведения опросов и вывода статистики из данных опросов.
 * Задачи:
 * Регистрация пользователя
 * Создание профиля пользователя
 * Создание опросов с вариантами ответов 'да/нет/не знаю',  либо числовое значение -??? Не знаю как добавить числа из формы инпут в приложении.???
 * Настройка интервалов прохождения опросов, длительность ведения опросов
 * Вывод статистики по разным критериям запроса из собранных данных опросов*/


DROP DATABASE IF EXISTS research;
CREATE DATABASE research;
USE research;

-- Справочник статусов пользователей
DROP TABLE IF EXISTS user_statuses;
CREATE TABLE user_statuses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
  name VARCHAR(100) NOT NULL COMMENT "Название статуса",
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Справочник статусов пользователя"; 

-- Заполняем справочник статусов пользователей
INSERT INTO user_statuses (name) VALUES ('Single'), ('Married'), ('Divorced'), ('Widowed');


-- Справочник полов
DROP TABLE IF EXISTS gender;
CREATE TABLE gender (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
  gender VARCHAR(25) COMMENT "Название пола",
  gender_info VARCHAR(150) COMMENT "Информация о поле",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Варианты полов";

-- Заполняем справочник полов
INSERT INTO gender (gender, gender_info) VALUES ('M', 'Male'), ('F', 'Female');

-- Справочник цветов
DROP TABLE IF EXISTS colors;
CREATE TABLE colors (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
  name VARCHAR(50) UNIQUE COMMENT "Название цвета",
  color_info CHAR(7) NOT NULL COMMENT "HEX Код цвета",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Цвета";

-- Заполняем справочник цветов
INSERT INTO colors (name, color_info) VALUES ('red', '#f73208'), ('green', '#08F716');

-- Таблица списка категорий
DROP TABLE IF EXISTS category_list;
CREATE TABLE category_list (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор категории",
  name VARCHAR(150) NOT NULL UNIQUE COMMENT "Название категории",
  color_id INT NOT NULL UNIQUE COMMENT "Ссылка на цвет",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"  
) COMMENT "Категории";

-- Таблица статусов опросов
DROP TABLE IF EXISTS poll_statuses;
CREATE TABLE poll_statuses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор статуса",
  name VARCHAR(150) NOT NULL UNIQUE COMMENT "Название статуса",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"  
) COMMENT "Статусы опросов";

-- Заполняем таблицу статусов опросов
INSERT INTO poll_statuses (name) VALUES ('active'), ('inactive'), ('paused');

-- Создаём таблицу пользователей
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
  email VARCHAR(100) NOT NULL UNIQUE COMMENT "Почта",
  phone VARCHAR(100) NOT NULL UNIQUE COMMENT "Телефон",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Пользователи";  

-- Таблица профилей
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
  user_id INT UNSIGNED NOT NULL PRIMARY KEY COMMENT "Ссылка на пользователя", 
  first_name VARCHAR(100) NOT NULL COMMENT "Имя пользователя",
  last_name VARCHAR(100) NOT NULL COMMENT "Фамилия пользователя",
  patronymic_name VARCHAR(100) COMMENT "Отчество пользователя",
  gender_id CHAR(1) NOT NULL COMMENT "Ссылка на пол",
  birthday DATE COMMENT "Дата рождения",
  photo_id INT UNSIGNED COMMENT "Ссылка на основную фотографию пользователя",
  status_id VARCHAR(30) COMMENT "Ссылка на статус",
  city VARCHAR(130) COMMENT "Город проживания",
  country VARCHAR(130) COMMENT "Страна проживания",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Профили"; 

-- Каталог наград
DROP TABLE IF EXISTS rewards;
CREATE TABLE rewards (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор награды", 
  name VARCHAR(50) UNIQUE COMMENT "Название награды",
  category_id INT UNSIGNED NOT NULL COMMENT "Ссылка на категорию", 
  color_id CHAR(7) NOT NULL COMMENT "ссылка на HEX Код цвета",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Цвета";


-- Таблица списка опросов
DROP TABLE IF EXISTS polls;
CREATE TABLE polls (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор опроса",
  name VARCHAR(150) NOT NULL UNIQUE COMMENT "Название опроса",
  statuse_id INT UNSIGNED NOT NULL COMMENT "Ссылка на статус опроса",
  category_id INT UNSIGNED NOT NULL COMMENT "Ссылка на категорию опроса",
  is_analyzed BOOLEAN COMMENT "Учет в статистике",
  is_rewarded BOOLEAN COMMENT "Имеется ли награда",
  night_mode BOOLEAN COMMENT "Ночной режим",
  reward_id INT UNSIGNED COMMENT "Ссылка на награду",
  reward_amount INT UNSIGNED COMMENT "Количество наград",  
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"  
) COMMENT "Список опросов";



-- Таблица вопросов
DROP TABLE IF EXISTS questions;
CREATE TABLE questions (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор вопроса",
  name TEXT NOT NULL COMMENT "Вопрос",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"  
) COMMENT "Список опросов";

-- Каталог ответов
DROP TABLE IF EXISTS answer_form;
CREATE TABLE answer_form (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор ответа",
  name VARCHAR(150) NOT NULL UNIQUE COMMENT "Ответ",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"  
) COMMENT "Список ответов";



-- Заполняем формы ответов
INSERT INTO answer_form (name) VALUES ('yes'), ('no'), ('not sure');

