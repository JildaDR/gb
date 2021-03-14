DROP TABLE IF EXISTS users;
CREATE TABLE users(
id SERIAL PRIMARY KEY,
name VARCHAR(255) COMMENT 'Username',
UNIQUE unique_name(name(10))
) COMMENT = 'Users';

INSERT IGNORE INTO users VALUES
(DEFAULT, 'Ivanov'),
(DEFAULT, 'Petrov'),
(DEFAULT, 'Sidorov');

SELECT * FROM users;