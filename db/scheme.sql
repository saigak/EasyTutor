DROP DATABASE IF EXISTS easytutor;
CREATE DATABASE easytutor
  CHARACTER SET utf8;
USE easytutor;
DROP TABLE IF EXISTS tests_questions;
DROP TABLE IF EXISTS tests;
DROP TABLE IF EXISTS questions_answers;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS answers;
DROP TABLE IF EXISTS users_atutor;
DROP TABLE IF EXISTS proposed_answers;

CREATE TABLE users_atutor (
  name VARCHAR(100),
  PRIMARY KEY (name)
);

CREATE TABLE tests (
  test_id         BINARY(16),
  name            VARCHAR(250),
  discipline_name VARCHAR(300),
  groups          VARCHAR(10),
  course          INT,
  submission_time DATETIME,
  atutor_user_id  VARCHAR(100),
  visible         BOOL DEFAULT true,
  PRIMARY KEY (test_id),
  CONSTRAINT FK_TESTS_ATUTOR_USER_ID FOREIGN KEY (atutor_user_id) REFERENCES users_atutor (name)
);

CREATE TABLE questions (
  name   VARCHAR(250),
  header VARCHAR(250),
  PRIMARY KEY (name)
);

CREATE TABLE answers (
  id BINARY(16),
  content TEXT,
  PRIMARY KEY (id)
);

CREATE TABLE questions_answers (
  question_name  VARCHAR(250),
  answer_content BINARY(16),
  test_id        BINARY(16),
  PRIMARY KEY (question_name, answer_content, test_id),
  CONSTRAINT FK_QUESTIONS_ANSWERS_QUESTION_ID FOREIGN KEY (question_name) REFERENCES questions (name),
  CONSTRAINT FK_QUESTIONS_ANSWERS_ANSWER_ID FOREIGN KEY (answer_content) REFERENCES answers (id)
);

CREATE TABLE tests_questions (
  test_id           BINARY(16),
  question_name     VARCHAR(250),
  answer_content    BINARY(16),
  is_correct        BOOL    DEFAULT FALSE,
  exist_correct     BOOLEAN DEFAULT FALSE,
  new_correct_answer VARCHAR(250),
  PRIMARY KEY (test_id, question_name, answer_content),
  CONSTRAINT FK_TESTS_QUESTIONS_TEST_ID FOREIGN KEY (test_id) REFERENCES tests (test_id),
  CONSTRAINT FK_TESTS_QUESTIONS_ANSWER_ID FOREIGN KEY (answer_content) REFERENCES answers (id),
  CONSTRAINT FK_TESTS_QUESTIONS_QUESTION_ID FOREIGN KEY (question_name) REFERENCES questions (name)
);

CREATE TABLE tests_results (
  test_id BINARY(16),
  max     INT,
  current DOUBLE,
  PRIMARY KEY (test_id),
  CONSTRAINT FK_TESTS_RESULTS_TEST_ID FOREIGN KEY (test_id) REFERENCES tests (test_id)
);

CREATE TABLE users (
  name     VARCHAR(30) PRIMARY KEY,
  password TEXT,
  enabled  BOOL,
  email TEXT,
  first_name TEXT,
  last_name TEXT
);

CREATE TABLE users_roles (
  user_role_id INT AUTO_INCREMENT PRIMARY KEY,
  role         VARCHAR(20),
  user_name    VARCHAR(30),
  CONSTRAINT FK_USERS_ROLES_ROLE FOREIGN KEY (user_name) REFERENCES users (name)
);

CREATE TABLE proposed_answers(
  proposed_answer_id INT AUTO_INCREMENT PRIMARY KEY,
  test_id BINARY(16),
  question VARCHAR(250),
  answer BINARY(16),
  user_name VARCHAR(30),
  submission_time TIMESTAMP,
  CONSTRAINT FK_PROPOSED_ANSWER_TEST_ID FOREIGN KEY (test_id) REFERENCES tests(test_id),
  CONSTRAINT FK_PROPOSED_ANSWER_QUESTION FOREIGN KEY (question) REFERENCES questions(name),
  CONSTRAINT FK_PROPOSED_ANSWER_ANSWER FOREIGN KEY (answer) REFERENCES answers(id),
  CONSTRAINT FK_PROPOSED_ANSWER_USER_NAME FOREIGN KEY (user_name) REFERENCES users(name)
);


INSERT INTO users(name, password, enabled) VALUES ("user", "user", true);
INSERT INTO users(name, password, enabled) VALUES ("admin", "admin", true);
INSERT INTO users_roles(role, user_name)  VALUES ("ROLE_USER", "admin");
INSERT INTO users_roles(role, user_name)  VALUES ("ROLE_ADMIN", "admin");
INSERT INTO users_roles(role, user_name)  VALUES ("ROLE_USER", "user");

