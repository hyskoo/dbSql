SELECT *
FROM sem.users;

SELECT *
FROM jobs;

SELECT *
FROM USER_TABLES;

-- 78     --> grant를 받아서 fastfood 테이블 조회가능
SELECT *
FROM ALL_TABLES
WHERE OWNER = 'whwndnjs';

SELECT *
FROM whwndnjs.fastfood;

-- whwndnjs.fastfood --> fastfood로 시노님 생성
CREATE SYNONYM fastfood FOR whwndnjs.fastfood;
SELECT * FROM fastfood;
DROP SYNONYM fastfood;


