-- 별칭 : 테이블, 컬럼을 다른 이름으로 지칭
-- [AS] 별칭명
-- SELECT empno [AS] eno FROM emp e

-- SYNONYM (동의어) -- 다른 사용자가 가지고있는 테이블이나 뷰에 대한 조회 권한을 줄때 사용. hr.employee FROM절을 해야되므로 (사용자명.테이블명)
-- 오라클 객체를 다른이름으로 부를 수 있도록 하는것
-- 만약에 emp 테이블을 e 라고 하는 SYNONYM(동의어)로 생성을 하면
-- 다음과 같이 SQL을 작성 할 수 있다.
-- SELECT * 
-- FROM e;

-- CREATE [PUBLIC] SYNONYM synoym_name for object;

-- system에서 SYNONYM 생성 권한 부여
--GRANT CREATE SYNONYM TO whwndnjs;

-- emp 테이블을 사용하여 synonym e를 생성
-- CREATE SYNONYM 시노님 이름 FOR 오라클 객체;
CREATE SYNONYM e FOR emp;


-- emp 라는 테이블 명 대신에 e라고 하는 시노님을 사용하여 쿼리를 작성할 수 있다.
SELECT * FROM e;

-- SEM 계정의 FASTFOOD 테이블을 HR 계정에서도 볼 수 있도록 테이블 조회 권한을 부여
GRANT SELECT ON fastfood TO HR;



-- DML  :  SELECT / INSERT / UPDATE / DELETE / INSERT ALL  / MERGE

-- TCL : COMMIT  / ROLLBACK / [SAVEPOINT]

-- DDL : CREATE  / ALTER / DROP

-- DCL : GRANT / REVOKE

SELECT * FROM dictionary
ORDER BY TABLE_NAME;



-- 동일한 SQL의 개념에 따르면 아래 SQL은 다르다
SELECT /* 201911_205 */ * FROM emp;
SELECT /* 201911_205 */ * FROM EMP;
SELEct /* 201911_205 */ * FROM EMP;


-- system 계정에서 실행  ---> 실행결과는 같지만 SQL이 다른것 3개가 나온다.
SELECT *
FROM V$SQL
WHERE SQL_TEXT LIKE '%201911_205%';


-- 그래서 WHERE 절의 조건이 상수면 BIND 변수를 사용하는것이 좋다. (운영 DB에서)

SELECT /* 201911_205 */ * FROM emp WHERE empno = :7369;
SELECT /* 201911_205 */ * FROM emp WHERE empno = :7788;
SELECT /* 201911_205 */ * FROM emp WHERE empno = :empno;


















