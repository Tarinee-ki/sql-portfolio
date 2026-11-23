-- Demo data and examples for the Q&A platform database.
-- Run schema.sql first on a fresh database (IDs start at 1).
-- All people and email addresses below are fictional.

-- 1. Insert users, skills, tags, a question and tags for it
INSERT INTO Users (FirstName, LastName, Email, Country) VALUES
    ('Anna', 'Becker',    'anna.becker@example.com',    'Germany'),
    ('Ravi', 'Kumar',     'ravi.kumar@example.com',     'India'),
    ('Mia',  'Lindqvist', 'mia.lindqvist@example.com',  'Sweden');

INSERT INTO Skill (UserID, Skill) VALUES
    (1, 'SQL'), (1, 'Python'), (2, 'PostgreSQL'), (3, 'Java');

INSERT INTO Tag (TagName) VALUES ('sql'), ('postgresql'), ('window-functions');

INSERT INTO Question (UserID, Title, Body) VALUES
    (1, 'How do I find missing rows with a CROSS JOIN?',
        'I want every combination of area, year and series that has no row.');

INSERT INTO QuestionTag (QuestionID, TagID) VALUES (1, 1), (1, 2);

-- 2. Trigger demo: AnswerCount starts at 0
SELECT QuestionID, Title, AnswerCount FROM Question;

-- Insert two answers: the trigger raises AnswerCount to 2
INSERT INTO Answer (QuestionID, UserID, Body) VALUES
    (1, 2, 'Generate all combinations with CROSS JOIN and filter with NOT EXISTS.'),
    (1, 3, 'You can also use EXCEPT on the combinations.');

SELECT QuestionID, Title, AnswerCount FROM Question;

-- Delete one answer: the trigger lowers AnswerCount to 1
DELETE FROM Answer WHERE AnswerID = 2;

SELECT QuestionID, Title, AnswerCount FROM Question;

-- 3. Delete a user.
--    Mia has no questions or answers left, so this works;
--    her Skill rows are removed automatically (ON DELETE CASCADE).
DELETE FROM Users WHERE UserID = 3;

-- Deleting user 1 would fail: she still owns a question
-- (no ON DELETE CASCADE on Question.UserID, so the data is protected).
-- DELETE FROM Users WHERE UserID = 1;