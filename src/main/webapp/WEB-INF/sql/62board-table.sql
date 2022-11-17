CREATE DATABASE prj1;
USE prj1;

CREATE TABLE Board (
	id INT PRIMARY KEY AUTO_INCREMENT,
	title VARCHAR(255) NOT NULL,
    content VARCHAR(1000) NOT NULL
);
SELECT * FROM Board ORDER BY 1 DESC;

-- 작성자 컬럼 추가
ALTER TABLE Board
ADD COLUMN writer VARCHAR(255) NOT NULL;

-- 작성일시 컬럼 추가
ALTER TABLE Board
ADD COLUMN inserted DATETIME NOT NULL DEFAULT NOW();


-- 여러 게시물 추가하기
INSERT INTO Board (title, content, writer)
SELECT title, content, writer FROM Board;

SELECT COUNT(*) FROM Board;

-- page 처리 쿼리
SELECT *
FROM Board
ORDER BY id DESC
LIMIT 20, 10; -- ?1 : 어디서부터(0-base), 
              -- ?2 : 몇 개
              
-- 댓글 테이블 만들기
CREATE TABLE Reply (
	id INT PRIMARY KEY AUTO_INCREMENT,
	boardId INT NOT NULL,
    content VARCHAR(1000) NOT NULL,
    inserted DATETIME DEFAULT NOW(),
    FOREIGN KEY (boardId) REFERENCES Board(id)
); 
DESC Reply;
SELECT * FROM Reply Order BY 1 DESC;

-- 댓글 수가 결과로 같이 나오는 Board Table 조회 쿼리
SELECT 
	b.id, 
    b.title, 
    b.content, 
    b.writer, 
    b.inserted,
	count(r.id) AS countReply
FROM Board b
	LEFT OUTER JOIN Reply r ON b.id = r.boardId
GROUP BY id
ORDER BY id DESC;

-- 댓글 입력 시간 변경
SELECT * FROM Reply WHERE boardId = 3324 ORDER BY id DESC;
UPDATE Reply SET inserted = DATE(NOW()-INTERVAL 6 DAY) WHERE id = 60;
UPDATE Reply SET inserted = DATE(NOW()-INTERVAL 15 DAY) WHERE id = 59;
UPDATE Reply SET inserted = DATE(NOW()-INTERVAL 60 DAY) WHERE id = 58;
UPDATE Reply SET inserted = DATE(NOW()-INTERVAL 400 DAY) WHERE id = 57;
UPDATE Reply SET inserted = DATE(NOW()-INTERVAL 600 DAY) WHERE id < 57;

-- 파일 테이블 만들기
CREATE TABLE File (
	id INT PRIMARY KEY AUTO_INCREMENT,
	boardId INT NOT NULL,
    name VARCHAR(512) NOT NULL,
    FOREIGN KEY (boardId) REFERENCES Board(id)
);
DESC File;

SELECT * FROM File ORDER BY 1 DESC;

-- 여러 파일이 있는 게시물 조회
	SELECT
		b.id,
		b.title,
		b.content,
		b.writer,
		b.inserted,
		f.name fileName
	FROM
		Board b LEFT JOIN File f ON b.id = f.boardId
	WHERE
		b.id = 1029;

-- 댓글 수, 파일 수가 결과로 같이 나오는 Board Table 조회 쿼리 작성
	SELECT 
		b.id,
		b.title,
		b.writer,
		b.inserted,
        COUNT(DISTINCT r.id) countReply, -- id 중복되어 나오지 않도록 DISTINCT 사용
        COUNT(DISTINCT f.id) countFile
	FROM Board b LEFT JOIN Reply r ON b.id = r.boardId
                 LEFT JOIN File f ON b.id = f.boardId
    GROUP BY b.id
	ORDER BY b.id DESC;

-- Member 테이블 만들기
CREATE TABLE Member (
	id VARCHAR(255) PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    inserted DATETIME DEFAULT NOW()
);
DESC Member;
SELECT * FROM Member ORDER BY inserted DESC;

SELECT 
	id,
	'숨김' password,
	email,
	inserted
FROM Member
ORDER BY id ;

-- Member 테이블에 nickName 컬럼 추가
ALTER TABLE Member
ADD COLUMN nickName VARCHAR(255) NOT NULL UNIQUE DEFAULT id AFTER id;
DESC Member;

SELECT * FROM Member;

-- SAFE MODE
SET SQL_SAFE_UPDATES = 1;

DELETE FROM Member
WHERE id <> 'abcd';

-- 게시물 작성자를 존재하는 Member.id로 변경
UPDATE Board
SET writer = 'aaaa'
WHERE id > 0;

-- Board.writer 가 Member.id 참조하도록 변경
ALTER TABLE Board
ADD FOREIGN KEY (writer) REFERENCES Member(id);

-- 댓글 테이블에 작성자 추가
-- wirter 값이 없으면 참조키 설정 되지 않기 때문에 초기 세팅 시, 'aaaa' 기본값 설정
ALTER TABLE Reply
ADD COLUMN writer VARCHAR(255) NOT NULL DEFAULT 'aaaa' REFERENCES Member(id) AFTER content;
-- 기본값 설정 삭제
ALTER TABLE Reply
MODIFY COLUMN writer VARCHAR(255) NOT NULL;
DESC Reply;

SELECT * FROM Reply ORDER BY 1 DESC;

-- BoardLike 테이블 생성 (Like 키워드 X)
CREATE TABLE BoardLike (
	boardId INT,
    memberId VARCHAR(255),
    PRIMARY KEY (boardId, memberId),
    FOREIGN KEY (boardId) REFERENCES Board(id),
    FOREIGN KEY (memberId) REFERENCES Member(id)
);