-- Q&A platform database (PostgreSQL, 3NF)
-- Entities: Users, Question, Answer, Tag
-- Multivalued attribute (Skills) -> table Skill
-- M:N relationship Question-Tag -> table QuestionTag
-- Derived attribute Reputation is not stored; it can be calculated from answers.

DROP TABLE IF EXISTS QuestionTag, Tag, Answer, Question, Skill, Users CASCADE;

CREATE TABLE Users (
    UserID    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FirstName VARCHAR(50)  NOT NULL,
    LastName  VARCHAR(50)  NOT NULL,
    Email     VARCHAR(100) NOT NULL UNIQUE,
    Country   VARCHAR(50)
);

CREATE TABLE Skill (
    UserID INT         NOT NULL REFERENCES Users(UserID) ON DELETE CASCADE,
    Skill  VARCHAR(50) NOT NULL,
    PRIMARY KEY (UserID, Skill)
);

CREATE TABLE Question (
    QuestionID   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserID       INT          NOT NULL REFERENCES Users(UserID),
    Title        VARCHAR(255) NOT NULL,
    Body         TEXT         NOT NULL,
    CreationDate TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ViewCount    INT          NOT NULL DEFAULT 0 CHECK (ViewCount >= 0),
    -- Stored on purpose for fast display; kept correct by the trigger below.
    AnswerCount  INT          NOT NULL DEFAULT 0 CHECK (AnswerCount >= 0)
);

CREATE TABLE Answer (
    AnswerID     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    QuestionID   INT       NOT NULL REFERENCES Question(QuestionID) ON DELETE CASCADE,
    UserID       INT       NOT NULL REFERENCES Users(UserID),
    Body         TEXT      NOT NULL,
    CreationDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsAccepted   BOOLEAN   NOT NULL DEFAULT FALSE
);

CREATE TABLE Tag (
    TagID   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TagName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE QuestionTag (
    QuestionID INT NOT NULL REFERENCES Question(QuestionID) ON DELETE CASCADE,
    TagID      INT NOT NULL REFERENCES Tag(TagID)           ON DELETE CASCADE,
    PRIMARY KEY (QuestionID, TagID)
);

-- Trigger: keep Question.AnswerCount in sync with the Answer table.
-- Fires after an answer is inserted (+1) or deleted (-1).
CREATE OR REPLACE FUNCTION update_answer_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE Question
        SET AnswerCount = AnswerCount + 1
        WHERE QuestionID = NEW.QuestionID;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE Question
        SET AnswerCount = AnswerCount - 1
        WHERE QuestionID = OLD.QuestionID;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER UpdateAnswerCount
AFTER INSERT OR DELETE ON Answer
FOR EACH ROW
EXECUTE FUNCTION update_answer_count();