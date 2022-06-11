/*1. Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, который больше всех общался 
 * с выбранным пользователем (написал ему сообщений).*/

SELECT u.id, u.firstname, u.lastname, COUNT(*) cnt  
  FROM users u
  JOIN messages m ON u.id = m.from_user_id OR u.id = m.to_user_id
 WHERE (m.from_user_id = 1 OR m.to_user_id = 1) AND u.id != 1
 GROUP BY u.id, u.firstname, u.lastname
 ORDER BY cnt DESC
 LIMIT 1;

/*2. Подсчитать общее количество лайков, которые получили пользователи младше 10 лет.*/

 SELECT COUNT(*) likes_cnt
   FROM posts_likes pl  
   JOIN posts p ON pl.post_id = p.id 
   JOIN profiles pf ON p.user_id = pf.user_id
  WHERE pl.like_type = 1 AND TIMESTAMPDIFF(YEAR, pf.birthday, NOW()) <=10;

/*3. Определить кто больше поставил лайков (всего): мужчины или женщины.*/ 

SELECT CASE pf.gender 
			WHEN 'f' THEN 'female'
			WHEN 'm' THEN 'male'
			WHEN 'x' THEN 'not defined'
		  END AS pol,
       COUNT(*) likes_cnt
  FROM posts_likes pl
  JOIN profiles pf ON pl.user_id = pf.user_id  
 GROUP BY pol
HAVING pol <> 'not defined'
 ORDER BY likes_cnt DESC; 

 
