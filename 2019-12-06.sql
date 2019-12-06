-- UPDATE : 테이블 값 변경
-- UPDATE tableName SET column1 = 적용하려고 하는값1, column2 = 적용할려는값 ....
-- [WHERE row 조회 조건] - 조회조건에 해당하는 데이터만 업데이트가 된다.

INSERT INTO dept
VALUES (99, 'ddit', 'daejeon');


UPDATE dept
SET dname = '대덕', loc = '영민빌딩'
WHERE deptno = 99;

-- 업데이트 전에 업데이트 하려고하는 테이블을 WHERE절에 기술한 조건으로 SELECT를 하여 업데이트 대상 ROW를 확인해보자
SELECT *
FROM dept
WHERE deptno = 99;

-- DELETE tableName
-- [WHERE 조건]
DELETE emp
WHERE empno = 9999;


-- 매니저가 7698인 모든 사원을 삭제
-- 서브쿼리를 사용
DELETE emp
WHERE empno IN (SELECT empno
                FROM emp
                where mgr = 7698);
-- 위 쿼리는 아래와 동일
DELETE emp WHERE mgr = 7698;


--------------------------------------------------------------------------------------------------------------------------------

--          읽기 일관성 (ISOLATION LEVEL)
--      DML문이 다른 사용자에게 어떻게 영향을 미치는지 정의한 레벨( 0~3 으로 4단계)

-- LEVEL 0 : Read Uncommitted    --Oracle은 미지원
    -- 타 사용자가 커밋을 하지 않은 데이터도 볼 수 있다.
    
-- LEVEL 1 : Read committed     -- Oracle 및 대부분의 DBMS의 기본설정
    -- 커밋되지 않은 데이터는 볼 수 없다.
    
-- LEVEL 2 : Repeatable Read  -- Oralce 공식 지원X
    -- 선행 트랜잭션이 읽은 데이터를 후행 트랜젝션이 데이터를 수정,삭제하지 못함.
    -- 단, 후행 트랜잭션에서 신규입력은 가능 (즉, 타 사용자가 INSERT는 가능) --> 선행 트랜잭션에서 조회가 가능 (Phantom Read)
        -- 즉, 다른 트랜잭션에서 수정을 못하기때문에 현 트랜잭션은 해당 ROW를 항상 동일한 결과값으로 조회 할 수 있다.
    -- 단, Orale에서 For update를 이용해서 효과를 낼수 있다.    
--    SELECT * FROM EMP FOR UPDATE;
    
-- LEVEL 3 : Serializable Read
    -- 후행 트랜잭션에서 입력, 수정, 삭제된 데이터가 선행 트랜잭션에 영향을 주지 않음.
    -- 선행 트랜잭션의 데이터 조회 기준은 선행 트랜잭션의 시작된 시점. 즉, 후행 트랜잭션에서 insert를 해도 Phantom Read가 발생되지 않음.
--------------------------------------------------------------------------------------------------------------------------------


-- 트랜잭션 레벨 수정 (Serializable read)
SET TRANSACTION isolation LEVEL SERIALIZABLE;


-- DDL : TABLE 생성
-- CREATE TALBE [사용자명].테이블명 (
--     컬럼명1 컬럼타입1,
--     컬럼명2 컬럼타입2, ......
--     컬럼명N 컬럼타입N);

-- ranger_no Number         -- 레인저 번호
-- ranger_nm VARCHAR2 (50)  -- 레인저 이름
-- reg_dt DATE              -- 레인저 등록일자
-- 테이블 생성 DDL : Data Defination Language (데이터 정의어)
-- DDL rollback이 없다. (자동 커밋되므로 rollback을 할 수 없다.)
CREATE TABLE ranger(
    ranger_no NUMBER,
    renger_nm VARCHAR2 (50),
    reg_dt DATE
);

-- 오라클에서는 객체 생성시 소문자로 생성해도 내부적으로 대문자로 관리한다. 
DESC ranger;
SELECT *
FROM user_tables
WHERE table_name = 'RANGER';

INSERT INTO ranger
VALUES (1, 'brown', sysdate);

-- 데이터 조회
SELECT *
FROM ranger;

-- DML문은 DDL과 다르게 롤백이 가능하다.
ROLLBACK;

--------------------------------------------------------------------------------------------------------------------------------
-- DATE 타입에서 필드 추출하기
-- EXTRACT(필드명 FROM 컬럼/expression)
SELECT TO_CHAR(SYSDATE, 'YYYY') yyyy
       ,TO_CHAR(SYSDATE, 'MM') mm,
       EXTRACT(year FROM SYSDATE) ex_yyyy
       ,EXTRACT(month FROM SYSDATE) ex_mm
FROM dual;



-- 테이블 생성시 컬럼 레벨 제약조건 생성 : 제약조건을 추가할 컬럼에 추가. EX) PRIMARY KEY
CREATE TABLE dept_test (
    deptno NUMBER(2) PRIMARY KEY,
    danme VARCHAR2(14),
    loc VARCHAR2(13));

DROP TABLE dept_test;

-- dept_test 테이블의 deptno 컬럼에 PRIMARY KEY 제약 조건이 있기때문에 deptno에 동일한 데이터를 입력하거나 수정할 수 없다.
-- 최초 데이터 입력성공
INSERT INTO dept_test VALUES (99, 'ddit', 'daejeon');
-- dept_test 데이터에 deptno가 00번인 데이터가 있으므로 PRIMARY KEY 제약조건에 의해 입력 될 수 없다.
-- ORA-00001: unique constraint 제약 위배
-- WHWNDNJS.SYS_C007149 제약조건을 어떤 제약조건인지 판단하기 힘드므로,
-- 제약조건에 이름을 코딩 룰에 의해 붙여 주는 것이 유지보수하기 편하다
INSERT INTO dept_test VALUES (99, '대덕', '대전');



-- 테이블 삭제후 제약조건 이름을 추가하여 재생성
-- Primary Key : pk_테이블명
DROP TABLE dept_test;

CREATE TABLE dept_test (
    deptno NUMBER(2) CONSTRAINT pk_dept_test PRIMARY KEY,
    danme VARCHAR2(14),
    loc VARCHAR2(13));
    
-- insert 구문복사    
INSERT INTO dept_test VALUES (99, 'ddit', 'daejeon');
INSERT INTO dept_test VALUES (99, '대덕', '대전');
    

    
    
    
    
    