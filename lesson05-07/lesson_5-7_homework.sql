/*-- Урок 6
-- Операторы, фильтрация, сортировка и ограничение

-- Разбор ДЗ урока 5
USE shop;

-- Тема Операции, задание 1
-- Пусть в таблице users поля created_at и updated_at оказались незаполненными.
-- Заполните их текущими датой и временем.
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(255),
  updated_at VARCHAR(255)
) COMMENT = 'Покупатели';

INSERT INTO
  users (name, birthday_at)
VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '2006-08-29'),
  ('Дмитрий', '1985-12-29'),
  ('Елена', '1990-12-30')
  ;

SELECT * FROM users;
DESC users;

UPDATE
  users
SET
  created_at = NOW(),
  updated_at = NOW();

-- Тема Операции, задание 2
-- Таблица users была неудачно спроектирована.
-- Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались
-- значения в формате "20.10.2017 8:10".
-- Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(255),
  updated_at VARCHAR(255)
) COMMENT = 'Покупатели';

USE shop;
INSERT INTO
  users (name, birthday_at, created_at, updated_at)
VALUES
  ('Геннадий', '1990-10-05', '07.01.2016 12:05', '07.01.2016 12:05'),
  ('Наталья', '1984-11-12', '20.05.2016 16:32', '20.05.2016 16:32'),
  ('Александр', '1985-05-20', '14.08.2016 20:10', '14.08.2016 20:10'),
  ('Сергей', '1988-02-14', '21.10.2016 9:14', '21.10.2016 9:14'),
  ('Иван', '1998-01-12', '15.12.2016 12:45', '15.12.2016 12:45'),
  ('Мария', '2006-08-29', '12.01.2017 8:56', '12.01.2017 8:56'),
  ('Дмитрий', '1985-12-29', '15.04.2018 18:46', '15.04.2018 18:46'),
  ('Елена', '1990-12-30', '17.01.2017 19:05', '17.01.2017 19:05')
  ;

SELECT * FROM users;

-- Вариант с преобразованием
-- 21.10.2016 9:14 -> 2016-10-21 09:14:00
UPDATE users
SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %k:%i'),
    updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %k:%i');


 
  


DESCRIBE users;

-- Вариант c добавлением столбцов
ALTER TABLE users
  ADD COLUMN created_at_ts DATETIME DEFAULT NOW(), 
  ADD COLUMN updated_at_ts DATETIME DEFAULT NOW();

UPDATE users
   SET created_at_ts = (SELECT str_to_date(created_at, '%d.%m.%Y %k:%i')),
       updated_at_ts = (SELECT str_to_date(updated_at, '%d.%m.%Y %k:%i'));    

ALTER TABLE users
  DROP COLUMN created_at, DROP COLUMN updated_at;	
ALTER TABLE users
  RENAME COLUMN created_at_ts to created_at, 
  RENAME COLUMN updated_at_ts to updated_at;
ALTER TABLE users
  CHANGE COLUMN updated_at updated_at DATETIME DEFAULT NOW() ON UPDATE NOW();

SELECT name, created_at, date_format(created_at, '%j %d.%m.%Y %k %H') 
FROM users;

-- https://dev.mysql.com/doc/refman/8.0/en/date-and-time-functions.html#function_date-format

-- Тема Операции, задание 3
-- В таблице складских запасов storehouses_products в поле value могут встречаться самые
-- разные цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы.
-- Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения
-- значения value. Однако, нулевые запасы должны выводиться в конце, после всех записей.
DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';

INSERT INTO
  storehouses_products (storehouse_id, product_id, value)
VALUES
  (1, 543, 0),
  (1, 789, 2500),
  (1, 3432, 0),
  (1, 826, 30),
  (1, 719, 500),
  (1, 638, 1);

SELECT * FROM storehouses_products ORDER BY value;
SELECT * FROM storehouses_products ORDER BY value desc;

SELECT * FROM storehouses_products
ORDER BY CASE WHEN value = 0 then 1 else 0 end, value;

SELECT * FROM storehouses_products
ORDER BY CASE WHEN value = 0 THEN 4294967295 ELSE value END

DESC storehouses_products

SELECT ~0 as max_bigint_unsigned, ~0 >> 32 as max_int_unsigned;

-- ORDER BY IF(value > 0, 0, 1), value;
-- ORDER BY value = 0, value;
-- ORDER BY FIELD(value, 0), value;
-- ORDER BY CASE WHEN value = 0 THEN 999999 ELSE value END
-- SELECT ~0 as max_bigint_unsigned, ~0 >> 32 as max_int_unsigned;
-- ORDER BY CASE WHEN value = 0 then 2 else 1 end, value;
-- ORDER BY CASE WHEN value > 0 THEN FALSE ELSE TRUE END, value;

-- Тема Операции, задание 4
-- (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в
-- августе и мае. Месяцы заданы в виде списка английских названий ('may', 'august')

SELECT * FROM users;

SELECT name
  FROM users
  WHERE DATE_FORMAT(birthday_at, '%M') IN ('may', 'august');

-- Тема Операции, задание 5
-- (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса.
-- SELECT * FROM catalogs WHERE id IN (5, 1, 2);
-- Отсортируйте записи в порядке, заданном в списке IN.
DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

SELECT * FROM catalogs
WHERE id IN (1, 2, 5)
ORDER BY FIELD(id, 5, 1, 2);

SELECT * FROM catalogs
WHERE id IN (5, 1, 2)
ORDER BY FIELD(id, 5, 1, 2);

-- Тема Агрегация, задание 1
-- Подсчитайте средний возраст пользователей в таблице users

SELECT * FROM users;

-- Вариант без учета полных лет 
SELECT avg(YEAR(now()) - YEAR(birthday_at)) AS age
FROM users;

-- Рекомендуемый вариант
SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) AS age
FROM users;

-- Сравнение
SELECT name, birthday_at,
  YEAR(now()) - YEAR(birthday_at) age1,
  TIMESTAMPDIFF(YEAR, birthday_at, NOW()) age2
FROM users;
	  
-- Тема Агрегация, задание 2
-- Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели.
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.
SELECT
  DATE_FORMAT(DATE(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))), '%W') AS day,
  COUNT(*) AS total
FROM users
GROUP BY day
ORDER BY total DESC;

-- Сравнение дней недели года рождения и текущего года
select name, birthday_at,
  DAYNAME(birthday_at),
  DAYNAME(DATE(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))))
from users;

-- Тема Агрегация, задание 3
-- (по желанию) Подсчитайте произведение чисел в столбце таблицы
-- Логарифм произведения равен сумме логарифмов. ln(1*2*3*4*5) = ln(1) + ln(2) + ln(3) + ln(4) + ln(5)
-- Натуральный логарифм LN() в паре с функцией возведения экспоненты в степень EXP() даст произведение
-- То есть от каждого значения в поле id берётся натуральный логарифм, затем считается сумма этих логарифмов
-- и затем экспонента возводится в степень, равную этой сумме.
SELECT ROUND(EXP(SUM(LN(id)))) FROM catalogs;
SELECT * FROM catalogs;

-- Разбор ДЗ урока 4

-- Варианты реализации таблиц для хранения лайков и постов
-- Варианты реализации лайков и постов (см. отдельный файл, применяем только финальный вариант из этого скрипта)

-- Финальный вариант
USE vk;
-- Таблица лайков
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  user_id INT UNSIGNED NOT NULL COMMENT "Идентификатор пользователя",
  target_id INT UNSIGNED NOT NULL COMMENT "Идентификатор объекта",
  target_type_id INT UNSIGNED NOT NULL COMMENT "Идентификатор типа объекта",
  like_type TINYINT UNSIGNED NOT NULL COMMENT "Идентификатор типа лайка (1 - лайк, 0 - дизлайк)",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Лайки";

-- Таблица типов объектов лайков
DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  name VARCHAR(255) NOT NULL UNIQUE COMMENT "Название типа",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Типы объектов лайков";

INSERT INTO target_types (name) VALUES 
  ('messages'),
  ('users'),
  ('media'),
  ('posts');

SELECT * FROM target_types;

-- Создадим таблицу постов
DROP TABLE IF EXISTS posts;
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  community_id INT UNSIGNED,
  head VARCHAR(255),
  body TEXT NOT NULL,
  is_public BOOLEAN DEFAULT TRUE,
  is_archived BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE messages (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "������������� ������", 
  from_user_id INT UNSIGNED NOT NULL COMMENT "������ �� ����������� ���������",
  to_user_id INT UNSIGNED NOT NULL COMMENT "������ �� ���������� ���������",
  body TEXT NOT NULL COMMENT "����� ���������",
  is_important BOOLEAN COMMENT "������� ��������",
  is_delivered BOOLEAN COMMENT "������� ��������",
  created_at DATETIME DEFAULT NOW() COMMENT "����� �������� ������",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "����� ���������� ������"
) COMMENT "���������";


-- Сгенерируем данные на основе таблицы messages
INSERT INTO posts (user_id, head, body)
  SELECT user_id, substring(body, 1, locate(' ', body) - 1), body FROM (
    SELECT
      (SELECT id FROM users ORDER BY rand() LIMIT 1) AS user_id,
      (SELECT body FROM messages ORDER BY rand() LIMIT 1) AS body
    FROM messages
  ) p;

SELECT * FROM posts;

-- Заполняем лайки
-- DELETE FROM likes;

-- Лайки сообщениям
INSERT INTO likes (user_id, target_id, target_type_id, like_type) 
  SELECT
    (SELECT id FROM users ORDER BY rand() LIMIT 1),
    (SELECT id FROM messages ORDER BY rand() LIMIT 1),
    (SELECT id FROM target_types WHERE name = 'messages'),
    IF(rand() > 0.5, 0, 1)
  FROM messages -- можно указать любую таблицу, с достаточным количеством записей
LIMIT 20;

-- Лайки пользователям
INSERT INTO likes (user_id, target_id, target_type_id, like_type) 
  SELECT
    (SELECT id FROM users ORDER BY rand() LIMIT 1),
    (SELECT id FROM users ORDER BY rand() LIMIT 1),
    (SELECT id FROM target_types WHERE name = 'users'),
    IF(rand() > 0.5, 0, 1)
  FROM messages
LIMIT 20;

-- Лайки медиафайлам
INSERT INTO likes (user_id, target_id, target_type_id, like_type) 
  SELECT
    (SELECT id FROM users ORDER BY rand() LIMIT 1),
    (SELECT id FROM media ORDER BY rand() LIMIT 1),
    (SELECT id FROM target_types WHERE name = 'media'),
    IF(rand() > 0.5, 0, 1)
  FROM messages
LIMIT 20;

-- Лайки постам
INSERT INTO likes (user_id, target_id, target_type_id, like_type) 
  SELECT
    (SELECT id FROM users ORDER BY rand() LIMIT 1),
    (SELECT id FROM posts ORDER BY rand() LIMIT 1),
    (SELECT id FROM target_types WHERE name = 'posts'),
    IF(rand() > 0.5, 0, 1)
  FROM messages
LIMIT 20;

-- Проверим
SELECT * FROM likes;

-- Добавляем внешние ключи в БД vk
-- Посмотрим ER-диаграмму в DBeaver (связей нет)
-- Для таблицы профилей

-- Смотрим структуру таблицы
DESC profiles;

-- Добавляем внешние ключи
ALTER TABLE profiles
  ADD CONSTRAINT profiles_fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  ADD CONSTRAINT profiles_fk_gender_id
    FOREIGN KEY (gender_id) REFERENCES gender(id) ON DELETE SET NULL,
  ADD CONSTRAINT profiles_fk_user_status_id
    FOREIGN KEY (user_status_id) REFERENCES user_statuses(id);

   ALTER TABLE profiles
  ADD CONSTRAINT profiles_fk_photo_id
    FOREIGN KEY (photo_id) REFERENCES media(id);
    
    
ALTER TABLE communities_users
  ADD CONSTRAINT comm_users_fk_comm_id
    FOREIGN KEY (community_id) REFERENCES communities(id),
  ADD CONSTRAINT comm_users_fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id)
 ;
*/
     
-- Для таблицы сообщений

-- Смотрим структуру таблицы
DESC messages;

-- Добавляем внешние ключи
ALTER TABLE messages
  ADD CONSTRAINT messages_fk_from_user_id 
    FOREIGN KEY (from_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_fk_to_user_id 
    FOREIGN KEY (to_user_id) REFERENCES users(id);
   
   -- Добавляем внешние ключи
  ALTER TABLE friendship
     ADD CONSTRAINT friendship_fk_user_id 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_fk_friend_id 
    FOREIGN KEY (friend_id) REFERENCES users(id);
   
    ALTER TABLE friendship
     ADD CONSTRAINT friendship_fk_status_id 
    FOREIGN KEY (status_id) REFERENCES friendship_statuses(id);
   
 ALTER TABLE likes
     ADD CONSTRAINT likes_fk_user_id 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT likes_fk_target_type_id
    FOREIGN KEY (target_type_id) REFERENCES target_types(id);
   
 ALTER TABLE media
     ADD CONSTRAINT media_fk_user_id 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT media_fk_media_type_id
    FOREIGN KEY (media_type_id) REFERENCES media_types(id);  
   
 ALTER TABLE posts
     ADD CONSTRAINT posts_fk_user_id 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT posts_fk_community_id
    FOREIGN KEY (community_id) REFERENCES communities(id);  
   
ALTER TABLE likes
    ADD CONSTRAINT likes_fk_target_id 
    FOREIGN KEY (target_id) REFERENCES users(id);  
   
   
/*
-- Посмотрим ER-диаграмму в DBeaver (появились связи)

-- Если нужно удалить
ALTER TABLE table_name DROP FOREIGN KEY constraint_name;
ALTER TABLE messages DROP FOREIGN KEY messages_from_user_id_fk;
ALTER TABLE messages DROP FOREIGN KEY messages_to_user_id_fk;

-- Примеры на основе базы данных vk
USE vk;

-- Получаем данные пользователя
SELECT * FROM users WHERE id = 3;

-- Выбираем с помощью подзапросов
SELECT * FROM profiles;

SELECT * FROM users;

SELECT
  id,
 (SELECT first_name FROM profiles WHERE user_id = 3) AS FirstName,
 (SELECT last_name FROM profiles WHERE user_id = 3) AS LastName,
 (SELECT city FROM profiles WHERE user_id = 3) AS City,
 (SELECT filename FROM media WHERE id=
   (SELECT photo_id FROM profiles WHERE user_id = 3)
 ) AS Photo
FROM users WHERE id = 3;

-- Дорабатывем условия (user_id = users.id)
SELECT
  id,
 (SELECT first_name FROM profiles WHERE user_id = users.id) AS FirstName,
 (SELECT last_name FROM profiles WHERE user_id = users.id) AS LastName,
 (SELECT city FROM profiles WHERE user_id = users.id) AS City,
 (SELECT filename FROM media WHERE id=
   (SELECT photo_id FROM profiles WHERE user_id = users.id)
 ) AS Photo
FROM users WHERE id = 3;

-- Используем алиасы (псевдонимы)
SELECT
  u.id,
 (SELECT p.first_name FROM profiles p WHERE p.user_id = u.id) AS FirstName,
 (SELECT last_name FROM profiles p WHERE p.user_id = u.id) AS LastName,
 (SELECT city FROM profiles p WHERE p.user_id = u.id) AS City,
 (SELECT m.filename FROM media m WHERE m.id=
   (SELECT photo_id FROM profiles p WHERE p.user_id = u.id)
 ) AS Photo
FROM users u WHERE id = 3;

*/
-- Определить кто больше поставил лайков (всего) - мужчины или женщины?
SELECT 
count(l.user_id), 
l.like_type, 
p.gender_id 
FROM 
likes l, 
profiles p 
WHERE 
l.user_id = p.user_id 
AND l.like_type = 1 
GROUP BY p.gender_id;


-- Найти 10 пользователей, которые проявляют 
-- наименьшую активность в использовании социальной сети
-- критерии активности - общее количество лайков и дизлайков пользователя и общее количество постов.

/*!!! 
почему лайки считаются как посты? у пользователя 86 1 лайк, но в таблице считает 3 
SELECT * FROM posts WHERE user_id = 86; 
SELECT * FROM likes WHERE user_id = 86; 
SELECT 
count(l.id) likes_per_user,
count(ps.id) posts_per_user,
l.user_id,
p.first_name, 
p.last_name 
FROM 
likes l,
profiles p,
posts ps
WHERE 
l.user_id = p.user_id
AND 
l.user_id = ps.user_id
GROUP BY l.user_id 
ORDER BY likes_per_user, posts_per_user LIMIT 100; */

SELECT 
count(l.id) likes_per_user,
count(ps.id) posts_per_user,
l.user_id,
p.first_name, 
p.last_name 
FROM 
likes l,
profiles p,
posts ps
WHERE 
l.user_id = p.user_id
AND 
l.user_id = ps.user_id
GROUP BY l.user_id 
ORDER BY likes_per_user, posts_per_user LIMIT 10;  



 
-- Подсчитать количество лайков которые получили 10 самых молодых пользователей.

SELECT SUM(likes_per_user) FROM 
(SELECT 
count(l.id) likes_per_user
FROM 
likes l,
profiles p 
WHERE 
l.target_id = p.user_id 
AND 
l.like_type = 1 
GROUP BY l.target_id 
ORDER BY p.birthday DESC LIMIT 10) AS total;

-- Список 10 самых молодых юзеров с их лайками
SELECT count(l.id) 
likes_per_user, 
l.target_id, 
p.first_name, 
p.last_name, 
p.birthday 
FROM 
likes l, 
profiles p 
WHERE 
l.target_id = p.user_id 
AND 
l.like_type = 1 
GROUP BY l.target_id 
ORDER BY p.birthday DESC LIMIT 10;


USE shop;

-- Составьте список пользователей users, которые осуществили хотя бы один заказ orders
-- в интернет магазине.

-- заполняем таблицу orders
INSERT INTO orders (user_id) SELECT u.id FROM users u ORDER BY RAND() LIMIT 50;

-- список пользователей users, которые осуществили хотя бы один заказ orders
-- в интернет магазине.

SELECT count(o.user_id) orders, p.first_name, p.last_name FROM orders o, profiles p WHERE o.user_id = p.user_id GROUP BY o.user_id ORDER BY orders;

-- Выведите список товаров products и разделов catalogs, который соответствует товару.

SELECT p.id, p.name, p.description, p.price, c.name FROM products p, catalogs c WHERE p.catalog_id = c.id;


  

/*
-- Получаем фотографии пользователя
SELECT * FROM media;
SELECT * FROM media_types;

SELECT * FROM likes
WHERE user_id = (SELECT user_id FROM profiles WHERE gender_id = 1 GROUP BY gender_id)
AND like_type = 1;


SELECT * FROM media
WHERE user_id = 3
AND media_type_id = (SELECT id FROM media_types mt WHERE mt.name = 'Image')
;

-- Выбираем историю по добавлению фотографий пользователем
SELECT CONCAT(
  'Пользователь ', 
  (SELECT CONCAT(first_name, ' ', last_name) FROM profiles WHERE user_id = media.user_id),
  ' добавил фото ', 
  filename, ' ',
  created_at) AS news
    FROM media
    WHERE user_id = 3
    AND media_type_id = ( SELECT id FROM media_types WHERE name = 'Image')
ORDER BY created_at desc
;

-- Найдём кому принадлежат 10 самых больших медиафайлов
SELECT user_id, filename, size 
  FROM media
  ORDER BY size DESC
  LIMIT 10;

-- Улучшим запрос и используем алиасы для имён таблиц
SELECT
  (SELECT CONCAT(first_name, ' ', last_name) 
    FROM profiles p WHERE p.user_id = m.user_id) AS owner,
  filename,
  size 
    FROM media m
    ORDER BY size DESC
    LIMIT 10;

DESC friendship;
-- Выбираем друзей пользователя с двух сторон отношения дружбы
SELECT * FROM friendship WHERE user_id = 3 OR friend_id = 3;

SELECT friend_id FROM friendship WHERE user_id = 3
UNION
SELECT user_id FROM friendship WHERE friend_id = 3;

-- Выбираем только друзей с активным статусом
SELECT * FROM friendship_statuses;

-- Вариант 1
(SELECT friend_id 
  FROM friendship 
  WHERE user_id = 3 AND status_id = (
      SELECT id FROM friendship_statuses WHERE name = 'Approved'
    )
)
UNION
(SELECT user_id 
  FROM friendship 
  WHERE friend_id = 3 AND status_id = (
      SELECT id FROM friendship_statuses WHERE name = 'Approved'
    )
);

-- Вариант 2
SELECT friend_id FROM (
  SELECT friend_id, status_id FROM friendship WHERE user_id = 3
  UNION
  SELECT user_id, status_id FROM friendship WHERE friend_id = 3
) AS F WHERE status_id = (
  SELECT id FROM friendship_statuses WHERE name = 'Approved'
);

SELECT
  friend_id,
  (SELECT first_name FROM profiles WHERE user_id = friend_id) AS name
FROM (
  SELECT friend_id, status_id FROM friendship WHERE user_id = 3
  UNION
  SELECT user_id, status_id FROM friendship WHERE friend_id = 3
) AS F WHERE status_id = (
  SELECT id FROM friendship_statuses WHERE name = 'Approved'
);

SELECT first_name FROM profiles WHERE user_id IN (
  SELECT
    friend_id
  FROM (
    SELECT friend_id, status_id FROM friendship WHERE user_id = 3
    UNION
    SELECT user_id, status_id FROM friendship WHERE friend_id = 3
  ) AS F WHERE status_id = (
    SELECT id FROM friendship_statuses WHERE name = 'Approved'
  )
);

-- Выбираем медиафайлы друзей
SELECT filename FROM media
WHERE user_id IN (
  (SELECT friend_id 
  FROM friendship
  WHERE user_id = 3 AND status_id = (
      SELECT id FROM friendship_statuses WHERE name = 'Approved'
    )
  )
  UNION
  (SELECT user_id 
    FROM friendship 
    WHERE friend_id = 3 AND status_id = (
      SELECT id FROM friendship_statuses WHERE name = 'Approved'
    )
  )
);

SELECT filename FROM media
WHERE user_id IN (
SELECT friend_id FROM (
  SELECT friend_id, status_id FROM friendship WHERE user_id = 3
  UNION
  SELECT user_id, status_id FROM friendship WHERE friend_id = 3
) AS F WHERE status_id = (
  SELECT id FROM friendship_statuses WHERE name = 'Approved'
)
);


-- Определяем пользователей, общее занимаемое место медиафайлов которых 
-- превышает 100МБ
SELECT user_id, SUM(size) AS total, count(*) 
  FROM media
--  WHERE user_id < 25
  GROUP BY user_id
  HAVING total > 100000000;

SELECT * FROM media;

-- При необходимости добавим тестовых данных в таблицу media, несоклько раз выполнив запрос
-- Также можно увеличить LIMIT 
INSERT INTO media (user_id, filename, SIZE, media_type_id)
SELECT user_id, filename, round(100000 + rand() * 1000000),
(SELECT id FROM media_types ORDER BY rand() LIMIT 1)
FROM media
ORDER BY rand() LIMIT 10;
 
-- С итогами  
SELECT user_id, SUM(size) AS total
  FROM media
  GROUP BY user_id WITH ROLLUP
  HAVING total > 100000000;  

 SELECT IFNULL(user_id, 'Total'), SUM(size) AS total
  FROM media
  GROUP BY user_id WITH ROLLUP
  HAVING total > 100000000;
 
-- Выбираем сообщения от пользователя и к пользователю
SELECT from_user_id, to_user_id, body, is_delivered, created_at
  FROM messages
    WHERE from_user_id = 7 OR to_user_id = 7
    ORDER BY created_at DESC;

-- Сообщения со статусом
SELECT from_user_id, 
  to_user_id, 
  body, 
  IF(is_delivered, 'delivered', 'not delivered') AS status,
  is_delivered
    FROM messages
      WHERE (from_user_id = 7 OR to_user_id = 7)
    ORDER BY created_at DESC;
    
-- Поиск пользователя по шаблонам имени  
SELECT CONCAT(first_name, ' ', last_name) AS fullname  
  FROM profiles
  WHERE first_name LIKE 'M%';

SELECT CONCAT(first_name, ' ', last_name) AS fullname  
  FROM profiles
  WHERE first_name LIKE 'M%' OR first_name LIKE 'K%';

 SELECT CONCAT(first_name, ' ', last_name) AS fullname  
  FROM profiles
  WHERE (first_name LIKE 'S%' OR first_name LIKE 'W%') AND last_name LIKE '%r';

 SELECT CONCAT(first_name, ' ', last_name) AS fullname  
  FROM profiles
  WHERE first_name LIKE 'S%' OR first_name LIKE 'W%' AND last_name LIKE '%r';

-- Используем регулярные выражения
SELECT CONCAT(first_name, ' ', last_name) AS fullname  
  FROM profiles
  WHERE last_name RLIKE '^(W|S).*r$';

-- Запрос для генерации команд удаления констрейнтов 
SELECT concat('alter table ', table_name, ' drop constraint ', constraint_name, ';') sql_text
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
WHERE constraint_schema = 'vk';

SELECT *
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
WHERE constraint_schema = 'vk';

-- Практическое задание по теме “Операторы, фильтрация, сортировка и ограничение. 
-- Агрегация данных”

-- Работаем с БД vk и тестовыми данными, которые вы сгенерировали ранее:
-- 1. Создать и заполнить таблицы лайков и постов.
-- 2. Создать все необходимые внешние ключи и диаграмму отношений.
-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?
-- 4. Подсчитать количество лайков которые получили 10 самых молодых пользователей. 
-- 5. Найти 10 пользователей, которые проявляют наименьшую активность в
-- использовании социальной сети
-- (критерии активности необходимо определить самостоятельно).

*/