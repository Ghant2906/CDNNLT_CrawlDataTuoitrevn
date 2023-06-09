CREATE DATABASE dbTinTuc;

USE dbTinTuc;

CREATE TABLE tb_news (
    news_id VARCHAR(255) NOT NULL,
    news_url VARCHAR(1000) NOT NULL,
    title VARCHAR(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
    category VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
    content VARCHAR(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
    image VARCHAR(1000) NOT NULL,
    time_stamp DATETIME,
    PRIMARY KEY (news_id)
);

CREATE TABLE tb_log (
	id INT NOT NULL AUTO_INCREMENT,
	table_name VARCHAR(255) NOT NULL,
	operation ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
	old_value JSON,
	new_value JSON,
	created_at TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP + INTERVAL 7 HOUR),
	PRIMARY KEY (`id`)
);

DELIMITER $
# create procedure
CREATE PROCEDURE psGetNews(
	IN _content varchar(255)
)
BEGIN
	IF _content IS NULL THEN
		SELECT * FROM tb_news;
	ELSE
		SELECT * FROM tb_news WHERE title LIKE CONCAT('%', _content, '%') OR content LIKE CONCAT('%', _content, '%');
	END IF;
END $

CREATE PROCEDURE psGetLog()
BEGIN
	SELECT created_at, 
		SUM(CASE WHEN operation = 'INSERT' THEN 1 ELSE 0 END) AS 'insert', 
		SUM(CASE WHEN operation = 'UPDATE' THEN 1 ELSE 0 END) AS 'update' ,
		SUM(CASE WHEN operation = 'DELETE' THEN 1 ELSE 0 END) AS 'delete'
	FROM tb_log 
	GROUP BY created_at;
END $

-- CREATE PROCEDURE psAddNews(
-- 	IN 
-- )

# create trigger
CREATE TRIGGER log_insert_trigger
AFTER INSERT ON tb_news
FOR EACH ROW
BEGIN
	INSERT INTO tb_log (table_name, operation, old_value, new_value)
	VALUES ('tb_news', 'INSERT', NULL, JSON_OBJECT('news_id', NEW.news_id, 'news_url', NEW.news_url, 'title', NEW.title, 'category', NEW.category, 'content', NEW.content, 'image', NEW.image, 'time_stamp', NEW.time_stamp));
END$

CREATE TRIGGER log_update_trigger
AFTER UPDATE ON tb_news
FOR EACH ROW
BEGIN
	IF NOT (OLDnew.s_id <=> NEW.news_id AND OLD.news_url <=> NEW.news_url AND OLD.title <=> NEW.title AND OLD.category <=> NEW.category AND OLD.content <=> NEW.content AND OLD.image <=> NEW.image AND OLD.time_stamp <=> NEW.time_stamp) THEN
		INSERT INTO tb_log (table_name, operation, old_value, new_value)
		VALUES ('tb_news', 'UPDATE', JSON_OBJECT('news_id', OLD.news_id, 'news_url', OLD.news_url, 'title', OLD.title, 'category', OLD.category, 'content', OLD.content, 'image', OLD.image, 'time_stamp', OLD.time_stamp), JSON_OBJECT('news_id', NEW.news_id, 'news_url', NEW.news_url, 'title', NEW.title, 'category', NEW.category, 'content', NEW.content, 'image', NEW.image, 'time_stamp', NEW.time_stamp));
	END IF;
END$


CREATE TRIGGER log_delete_trigger
AFTER DELETE ON tb_news
FOR EACH ROW
BEGIN
	INSERT INTO tb_log (table_name, operation, old_value, new_value)
	VALUES ('tb_news', 'DELETE', JSON_OBJECT('news_id', OLD.news_id, 'news_url', OLD.news_url, 'title', OLD.title, 'category', OLD.category, 'content', OLD.content, 'image', OLD.image, 'time_stamp', OLD.time_stamp), NULL);
END$
DELIMITER ;



INSERT INTO tb_news (news_id, news_url, title, category, content, image, time_stamp)
VALUES
	('1', 'MinhHoang', 19, 'RJG', '2023-04-16T20:20:20', '2023-04-16T20:20:20', '2023-04-16T20:20:20'),
	('2', 'ThaiThang', 19, 'ABCD', '2023-04-15T16:10:27', '2023-04-15T16:10:27', '2023-04-15T16:10:27')     
ON DUPLICATE KEY UPDATE
	news_id = VALUES(news_id),   
	news_url = VALUES(news_url),   
	title = VALUES(title),
	category = VALUES(category),   
	content = VALUES(content),   
	image = VALUES(image),
	time_stamp = VALUES(time_stamp);



