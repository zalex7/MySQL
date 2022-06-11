/*1. Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, 
 который больше всех общался с выбранным пользователем (написал ему сообщений).*/

SELECT friend_id 
  FROM (SELECT IF(to_user_id = 1, from_user_id, to_user_id) AS friend_id, COUNT(*) AS cnt
	      FROM messages 
	     WHERE to_user_id = 1 OR from_user_id = 1
	     GROUP BY friend_id
	     ORDER BY cnt DESC
	     LIMIT 1) AS friends;

/*2. Подсчитать общее количество лайков, которые получили пользователи младше 10 лет.*/

SELECT COUNT(*)
  FROM posts_likes 
 WHERE like_type = 1 AND 
 	   (SELECT TIMESTAMPDIFF(YEAR, birthday, NOW()) 
	      FROM profiles 
	     WHERE user_id = posts_likes.user_id) <= 10;

/*3. Определить кто больше поставил лайков (всего): мужчины или женщины.*/

SELECT (SELECT 
		  CASE gender 
			WHEN 'f' THEN 'female'
			WHEN 'm' THEN 'male'
			WHEN 'x' THEN 'not defined'
		  END
		  FROM profiles 
		 WHERE user_id = posts_likes.user_id) AS gender,
		COUNT(*) AS likes
  FROM posts_likes
 GROUP BY gender
HAVING gender <> 'not defined'
 ORDER BY likes DESC;
