CREATE TABLE cards (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  list_id INTEGER,

  FOREIGN KEY(list_id) REFERENCES list(id)
);

CREATE TABLE lists (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  board_id INTEGER,

  FOREIGN KEY(board_id) REFERENCES board(id)
);

CREATE TABLE boards (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL
);

INSERT INTO
  boards (id, title)
VALUES
  (1, "Programming"), (2, "Kanban Board 2");

INSERT INTO
  lists (id, title, board_id)
VALUES
  (1, "Languages", 1),
  (2, "Frameworks", 1);

INSERT INTO
  cards (id, title, list_id)
VALUES
  (1, "JavaScript", 1),
  (2, "Ruby", 1),
  (3, "Python", 1),
  (4, "jQuery", 2),
  (5, "React.js", 2),
  (6, "Ruby on Rails", 2);
