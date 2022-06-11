USE vk;

DROP TABLE IF EXISTS posts, comments, likes;

CREATE TABLE IF NOT EXISTS posts (
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(150) NOT NULL,
	txt TEXT NOT NULL,
    attached_image_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME NOT NULL DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
    INDEX (title),
	FOREIGN KEY (user_id) REFERENCES users (id),
	FOREIGN KEY (attached_image_id) REFERENCES media (id)
);

CREATE TABLE IF NOT EXISTS comments (
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
    post_id BIGINT UNSIGNED NOT NULL,
	txt TEXT NOT NULL,
	created_at DATETIME NOT NULL DEFAULT NOW(),
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	
	FOREIGN KEY (user_id) REFERENCES users (id),
	FOREIGN KEY (post_id) REFERENCES posts (id)
);

CREATE TABLE IF NOT EXISTS likes (
	user_id BIGINT UNSIGNED NOT NULL,
    post_id BIGINT UNSIGNED NOT NULL,
    type_of ENUM('like', 'dislike') NOT NULL,
    PRIMARY KEY (user_id, post_id),
    
	FOREIGN KEY (user_id) REFERENCES users (id),
	FOREIGN KEY (post_id) REFERENCES posts (id)
);

-- Пост Пети
INSERT posts VALUES (DEFAULT, 1, 'Мой первый пост', 'Съешь [же] ещё этих мягких французских булок да выпей чаю.', 1, DEFAULT, DEFAULT);

-- Комментарий от Васи
INSERT comments VALUES (DEFAULT, 2, 1, 'Шаришь!', DEFAULT, DEFAULT);

-- Лайк от Васи
INSERT likes VALUES (2, 1, 'like');

SELECT * FROM posts;
SELECT * FROM comments;
SELECT * FROM likes;

 
