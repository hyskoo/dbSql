-- INDEX를 생성할때 ASC나 DESC로 인해 정렬이 되면서 인덱스가 생성이되므로
-- 인덱스를 사용할때 인덱스에 해당되는 컬럼이 정렬된 상태로 존재하므로 인덱스를 이용해 ROW정보를 찾기 편하다


-- INDEX만 조회하여 사용자의 요구사항에 만족하는 데이터를 만들어 낼 수 있는 경우

SELECT rowid, emp.*
FROM emp;

SELECT empno, rowid
FROM emp
ORDER BY empno;

-- emp  테이블의 모든 컬럼을 조회
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = 7782;

SELECT * 
FROM TABLE (SYS.DBMS_XPLAN.DISPLAY);

Plan hash value: 2949544139
 
--------------------------------------------------------------------------------------
| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |     1 |    37 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP    |     1 |    37 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | PK_EMP |     1 |       |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("EMPNO"=7782)                --> 인덱스에 접근
;   
   
-- emp  테이블의 empno 컬럼을 조회
EXPLAIN PLAN FOR
SELECT empno
FROM emp
WHERE empno = 7782;

SELECT * 
FROM TABLE (SYS.DBMS_XPLAN.DISPLAY);

Plan hash value: 56244932
 
----------------------------------------------------------------------------
| Id  | Operation         | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |        |     1 |     4 |     0   (0)| 00:00:01 |
|*  1 |  INDEX UNIQUE SCAN| PK_EMP |     1 |     4 |     0   (0)| 00:00:01 |   --> 인덱스에만 접근
----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("EMPNO"=7782)
;


-- 인덱스 제거
-- pk_emp 제약조건 삭제 --> unique 제약 삭제 --> pk_emp 삭제

-- INDEX 종류 (컬럼중복 여부)
-- UNIQUE INDEX : 인덱스 컬럼의 값이 중복될 수 없는 인덱스 (emp.empno, dept.deptno)
-- NON-UNIQUE INDEX : 인덱스 컬럼의 값이 중복될 수 있는 인덱스 (emp.job 등)  --> default 설정

ALTER TABLE emp DROP CONSTRAINT pk_emp;

-- CREATE UNIQUE INDEX idx_n_emp_01 ON emp (empno); --> empno 컬럼 중복 안됨
CREATE INDEX idx_n_emp_01 ON emp (empno);

-- 위쪽 상황이랑 달라진 것은 empno 컬럼으로 생성된 인덱스가
-- UNIQUE --> NON-UNIQUE 인덱스로 변경됨.
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = 7782;

SELECT * FROM TABLE (SYS.DBMS_XPLAN.DISPLAY);


Plan hash value: 2778386618
 
--------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              |     1 |    37 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP          |     1 |    37 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_N_EMP_01 |     1 |       |     1   (0)| 00:00:01 |   --> 값이 중복되는게 존재할수도 있으므로 index의 한칸아래까지보면서 같으면 한번더 아니면 rowid값을 통해 테이블 접속
--------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("EMPNO"=7782)



--7782
INSERT INTO emp (empno, ename) VALUES (7782, 'brown');

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = 7782;

SELECT * FROM TABLE (SYS.DBMS_XPLAN.DISPLAY);



-- emp테이블에 job 컬럼으로 non-unique index 생성
-- 인덱스명 : idx_n_emp_02

CREATE INDEX idx_n_emp_02 ON emp (job);

SELECT job, rowid
FROM emp
ORDER BY job;

-- emp 테이블에는 인덱스가 2개 존재
-- 1. empno
-- 2. job



-- IDX_02 인덱스  - 인덱스를 확인후 테이블에서 필터
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job = 'MANAGER'
AND ename LIKE 'C%';

SELECT * FROM TABLE (SYS.DBMS_XPLAN.DISPLAY);

PLAN_TABLE_OUTPUT
Plan hash value: 1112338291
 
--------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              |     1 |    37 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMP          |     1 |    37 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_N_EMP_02 |     3 |       |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("ENAME" LIKE 'C%')
   2 - access("JOB"='MANAGER')
;

-- idx_n_emp_03
-- emp 테이블의 job, ename 컬럼으로 non-unique 인덱스 생성
CREATE INDEX idx_n_emp_03 ON emp (job, ename);

SELECT * 
FROM emp
WHERE job = 'MANAGER'
AND ename LIKE '%C';  --> C로끝나는 이름  JOB을 검색하고 ENAME에 해당하는것을 찾은 인덱스를 테이블에서 찾는다

SELECT * 
FROM emp
WHERE job = 'MANAGER'
AND ename LIKE 'C%'; --> C로시작하는 이름

SELECT job, ename, rowid
FROM emp
ORDER BY job, rowid;

EXPLAIN PLAN FOR
SELECT * 
FROM emp
WHERE job = 'MANAGER' 
AND ename LIKE 'C%';

-- idx_n_emp_04
-- emp 테이블의 job, ename 컬럼으로 non-unique 인덱스 생성
CREATE INDEX idx_n_emp_04 ON emp (ename, job);

SELECT ename, job, rowid
FROM emp
ORDER BY ename, rowid;

EXPLAIN PLAN FOR
SELECT * 
FROM emp
WHERE ename LIKE 'C%'
AND job = 'MANAGER' ;

SELECT * FROM TABLE (SYS.DBMS_XPLAN.DISPLAY);


-- JOIN에서의 INDEX
-- emp 테이블은 empno컬럼으로 기본키 제약조건이 존재
-- dept 테이블은 deptno 컬럼으로 기본키 제약조건이 존재
-- emp 테이블에 기본키 제약이 삭제된 상태이므로 재생성
-- ALTER TABLE emp ADD CONSTRAINT pk_emp PRIMARY KEY (empno);

EXPLAIN PLAN FOR
SELECT ename, dname, loc
FROM emp, dept
WHERE emp.deptno = dept.deptno
AND emp.empno = 7788;

SELECT * FROM TABLE (SYS.DBMS_XPLAN.DISPLAY);

----------------------------------------------------------------------------------------------
| Id  | Operation                     | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |              |     1 |    34 |     2   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                 |              |       |       |            |          |
|   2 |   NESTED LOOPS                |              |     1 |    34 |     2   (0)| 00:00:01 |  --> NESTED LOOPS는 반복문 개념
|   3 |    TABLE ACCESS BY INDEX ROWID| EMP          |     1 |    13 |     1   (0)| 00:00:01 |
|*  4 |     INDEX RANGE SCAN          | IDX_N_EMP_01 |     1 |       |     0   (0)| 00:00:01 |
|*  5 |    INDEX UNIQUE SCAN          | PK_DEPT      |     1 |       |     0   (0)| 00:00:01 |
|   6 |   TABLE ACCESS BY INDEX ROWID | DEPT         |     5 |   105 |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access("EMP"."EMPNO"=7788)
   5 - access("EMP"."DEPTNO"="DEPT"."DEPTNO")
;


-- 실습 1.
CREATE TABLE DEPT_TEST AS
SELECT *
FROM dept
WHERE 1 = 1;

-- deptno 컬럼 기준으로 unique 인덱스 생성
CREATE UNIQUE INDEX idx_dept_test_01 ON dept_test (deptno);
-- deptno 컬럼 기준으로 non-unique 인덱스 생성
CREATE INDEX idx_dept_test_02 ON dept_test (dname);
-- deptno, dname을 기준으로 non-unique 인덱스 생성
CREATE INDEX idx_dept_test_03 ON dept_test (deptno, dname);

-- 실습 2. 실습1에서 생성한 인덱스 삭제 DDL
DROP INDEX idx_dept_test_01;
DROP INDEX idx_dept_test_02;
DROP INDEX idx_dept_test_03;


-- 실습3. 인덱스를 사용하여 효율적인 SELECT 조회하기위한 인덱스 생성
CREATE INDEX index ON emp_test (empno, sal, deptno);

-- 실습4. emp, dept 테이블에 필요하다고 생각되는 인덱스 생성




