-- Урок 8 домашнее задание
USE vk;



-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT 
count(l.id) total, g.gender_info 
FROM likes l
JOIN 
profiles p
ON 
p.user_id = l.user_id
JOIN 
gender g 
ON 
g.id = p.gender_id
GROUP BY
g.id ORDER BY total DESC
LIMIT 1;





-- 4. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.



-- Подбиваем сумму внешним запросом

-- исходный запрос
SELECT SUM(likes_total) FROM (
  SELECT (SELECT COUNT(*) FROM likes WHERE target_id = profiles.user_id AND target_type_id = 2) 
    AS likes_total
  FROM profiles
  ORDER BY birthday 
  DESC LIMIT 10
) AS user_likes; 

-- решение не получилось :( вместо 3 получается 40, что я не так делаю?..

SELECT count(*) FROM likes l
RIGHT JOIN profiles p 
ON p.user_id = l.target_id
WHERE l.target_type_id = 2
ORDER BY p.birthday DESC LIMIT 10;




-- 5. Найти 10 пользователей, которые проявляют наименьшую активность
-- в использовании социальной сети

-- исходный запрос
SELECT 
  CONCAT(first_name, ' ', last_name) AS user, 
	(SELECT COUNT(*) FROM likes WHERE likes.user_id = profiles.user_id) +
	(SELECT COUNT(*) FROM media WHERE media.user_id = profiles.user_id) +
	(SELECT COUNT(*) FROM messages WHERE messages.from_user_id = profiles.user_id) AS overall_activity 
	  FROM profiles
	  ORDER BY overall_activity
	  LIMIT 10

-- результат	 
SELECT 	 
 CONCAT(p.first_name, ' ', p.last_name) 'user', count(l.id) + count(m.id) + count(ms.id) overall_activity FROM profiles p
LEFT JOIN
 likes l
 ON p.user_id = l.user_id
 LEFT JOIN 
 media m 
 ON m.user_id = p.user_id 
  LEFT JOIN 
 messages ms
 ON ms.from_user_id = p.user_id 
GROUP BY p.user_id
ORDER BY overall_activity LIMIT 10;
 
 -- 2. (По желанию) Доработать запрос "Список медиафайлов пользователя с количеством лайков",
-- чтобы он выводил количество лайков и дизлайков
 -- Список медиафайлов пользователя с количеством реакций(лайков и дизлайков)
 
 -- исходный запрос
SELECT
  m.filename,
  CONCAT(p.first_name, ' ', p.last_name) AS owner,
  count(l.target_id) AS total_likes
FROM media m
JOIN users u ON u.id = m.user_id
JOIN profiles p ON p.user_id = u.id
LEFT JOIN likes l ON l.target_id = m.id AND l.target_type_id = 3
WHERE u.id = 5
GROUP BY m.id;

-- что-то криво результат получается:
-- проверим лайки на медиафайл с id 110, 4 дизлайка и 1 лайк
SELECT * FROM likes l
WHERE l.target_id = 110;
-- а в этом запросе у медиафайла 110 4 дизлайка и 4 лайка
SELECT
  m.filename,
  CONCAT(p.first_name, ' ', p.last_name) AS owner,
  count(l.target_id) AS total_likes,
  count(ld.target_id) AS total_dislikes
FROM media m
JOIN users u ON u.id = m.user_id
JOIN profiles p ON p.user_id = u.id
LEFT JOIN likes l ON l.target_id = m.id AND l.target_type_id = 3 AND l.like_type = 1
LEFT JOIN likes ld ON ld.target_id = m.id AND ld.target_type_id = 3 AND ld.like_type = 0
WHERE u.id = 5
GROUP BY m.id;


