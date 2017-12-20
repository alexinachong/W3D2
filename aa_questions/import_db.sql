DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  assoc_author INTEGER,


  FOREIGN KEY (assoc_author) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER,
  user_id INTEGER,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)

);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body VARCHAR(255) NOT NULL,
  subject_id INTEGER,
  user_id INTEGER,
  parent_id INTEGER,

  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (subject_id) REFERENCES questions(id)

);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  likes INTEGER,
  user_id INTEGER,
  question_id INTEGER,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ("Alexina", "Chong"),
  ("Albert", "Shin");

INSERT INTO
  questions (title, body, assoc_author)
VALUES
  ("What is SQL?", "Help me understand. Is it DDL or DML?", (SELECT id FROM users WHERE fname = 'Alexina')),
  ("Odwalla????", "Is it juice or pure sugar?", (SELECT id FROM users WHERE fname = 'Albert'));

INSERT INTO
  question_follows (question_id, user_id)
VALUES
  (1, 1),
  (2, 2);

INSERT INTO
  replies (body, subject_id, user_id, parent_id)
VALUES
  ("SQL has both Data manipulation & declaration", (SELECT id FROM questions WHERE title LIKE "What%"), 1, null),
  ("Odwalla is both!", (SELECT id FROM questions WHERE title LIKE "Odwalla%"), 2, null);

INSERT INTO
  question_likes (likes, user_id, question_id)
VALUES
  (1000, 1, 1),
  (1500, 2, 2);
