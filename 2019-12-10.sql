--------------------------------------------------------------------------------------------------------------------------------

--          제약조건 활성화 / 비활성화
--   ALTER TABLE 테이블명 ENABLE OR DISABLE CONSTRAINT 제약조건;
--  제약 조건 확인 방식 2개
-- table_name, constraints_name , column_name
-- position 정렬 (ASC)
SELECT *
FROM user_constraints
WHERE table_name = 'BUYER';
-- 제약조건이 있는 컬럼에 대한 정보
SELECT * 
FROM USER_CONS_COLUMNS
WHERE table_name = 'BUYER';

--------------------------------------------------------------------------------------------------------------------------------
-- USER_CONSTRAINTS view를 통해 dept_test 테이블에 설정된 제약조건 확인
SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME = 'DEPT_TEST';

ALTER TABLE dept_test DISABLE CONSTRAINT SYS_C007180;

-- dept_test 테이블의 deptno 컬럼에 적용된 기본키 제약조건을 비활성화 하여 동일한 부서번호를 갖는 데이터 입력을 할 수 있다.
INSERT INTO dept_test VALUES (99, 'ddit', 'daejeon');
INSERT INTO dept_test VALUES (99, 'DDIT', '대전');

SELECT *
FROM dept_test;

--dept_test 테이블의 기본키 제약조건 활성화  --> 위의 insert구문 2개가 같은 부서번호를 가지고 있어 해당 제약이 위배된 상태이므로 에러발생
-- 활성화를 위해서는 중복데이터를 삭제해야 한다.
ALTER TABLE dept_test ENABLE CONSTRAINT SYS_C007180;

--부서번호 PK
-- 부서번호가 중복되는 데이터만 조회하여 해당 데이터에 대해 수정후 기본키 제약조건을 활성화 할 수 있다.
SELECT deptno, COUNT(*)
FROM dept_test
GROUP BY deptno
HAVING COUNT(*) >= 2;

-- table_name, constraints_name , column_name
-- position 정렬 (ASC)
SELECT *
FROM user_constraints
WHERE table_name = 'BUYER';
-- 제약조건이 있는 컬럼에 대한 정보
SELECT * 
FROM USER_CONS_COLUMNS
WHERE table_name = 'BUYER';


--------------------------------------------------------------------------------------------------------------------------------

-- 테이블 주석
--   COMMENT ON TABLE 테이블명 IS '주석';

-- 테이블에 대한 주석 (코멘트)
SELECT *
FROM USER_TAB_COMMENTS;

COMMENT ON TABLE dept IS '부서';

-- 컬럼 주석
--   COMMENTS ON COLUMN 테이블명.컬럼명 IS '주석';

-- 컬럼에 대한 주석 (코멘트)
SELECT *
FROM USER_COL_COMMENTS
WHERE TABLE_NAME = 'DEPT';

COMMENT ON COLUMN dept.deptno IS '부서번호';
COMMENT ON COLUMN dept.dname IS '부서명';
COMMENT ON COLUMN dept.loc IS '부서위치 지역';
--------------------------------------------------------------------------------------------------------------------------------


-- 실습 1. user_tab_comments, user_col_comments view를 이용하여 'CUSTOMER', 'PRODUCT', 'CYCLE', 'DAILY' 테이블과 컬럼의 주석정보를 조회
SELECT tab.*, col.column_name, col.comments
FROM user_tab_comments tab, user_col_comments col
WHERE tab.table_name = col.table_name
AND tab.table_name IN ('CUSTOMER', 'PRODUCT', 'CYCLE', 'DAILY');



--------------------------------------------------------------------------------------------------------------------------------
    
--   VIEW : QUERY이다. (O)
-- 테이블 처럼 데이터가 물리적으로 존재하는 존재 하는 것이 아니다.
-- 논리적 데이터 셋 = QUERY
--   VIEW는 테이블이다.(X)

-- VIEW TODTJD
-- CREATE OR REPLACE VIEW 뷰이름 [ (컬럼별칭1, 컬럼별칭2 ....)] AS
-- SUBQUERY;

-- SYSTEM 계정에서 VIEW 생성권한 주기
--   GRANT CREATE VIEW TO 계정명;

-- ROWNUMD을 추가해서 사용하면 튜닝포인트로 처리가 되면서
-- VIEW를 이용할때 VIEW MERGING 현상이 일어나는 것을 방지할 수 있다.
-- 즉, 서브쿼리안쪽 (Inline view)에서 view merging을 방지한다는것.

--------------------------------------------------------------------------------------------------------------------------------

-- emp 테이블에서 sal, comm 컬럼을 제외한 나머지 6개의 컬럼만 조회가 되는 view.
CREATE OR REPLACE VIEW v_emp AS
SELECT empno, ename, job, mgr, hiredate, deptno
FROM emp;

SELECT *
FROM v_emp;

-- 원본 테이블이 변하면 VIEW의 결과도 바뀐다.
-- KING의 부서번혹 현재 10번. emp 테이블의 king의 부서번호데이터를 3번으로 수정. v_emp 테이블에서 king의 부서번호를 관찰
UPDATE emp
SET emp.deptno = 30
WHERE ename = 'KING';

SELECT * FROM emp;

-- JOIN된 결과를 VIEW로 생성
CREATE OR REPLACE VIEW v_emp_dept AS
SELECT emp.empno, emp.ename, dept.deptno, dept.dname
FROM emp, dept
WHERE emp.deptno = dept.deptno;

SELECT * FROM v_emp_dept;


-- emp 테이블에서 king 데이터 삭제 
SELECT *
FROM EMP
WHERE ename = 'KING';

DELETE FROM emp
WHERE ename = 'KING';

-- emp 테이블에서 KING의 데이터 삭제후 v_emp_dept view의 조회 결과 확인
SELECT *
FROM v_emp_dept;

-- emp 테이블의 empno 컬럼을 eno로 컬럼이름 변경
ALTER TABLE emp RENAME COLUMN empno TO eno;
ALTER TABLE emp RENAME COLUMN eno TO empno;


-- VIEW의 삭제
DROP VIEW v_emp;


-- 부서별 직원의 급여 합계
CREATE OR REPLACE VIEW v_emp_sal AS
SELECT deptno, SUM(sal) sum_sal
FROM emp
GROUP BY deptno;

SELECT * 
FROM v_emp_sal
WHERE deptno = 20;

-- 위의 내용을 inline - view로 표현
SELECT *
FROM (SELECT deptno, SUM(sal) sum_sal
      FROM emp
      GROUP BY deptno)
WHERE deptno = 20;


-- SEQUENCE
-- 오라클 객체로 중복되지 않는 정수 값을 리턴해주는 객체
-- CHREATE SEQUENCE 시퀀스명   
-- [옵션 ....]
-- cache_size를 정해주므로써 일정갯수의 시퀀스를 미리 메모리에 저장시켜놓는다.
CREATE SEQUENCE seq_board;
DROP SEQUENCE seq_board;

-- 시퀀스 사용방법 : 시퀀스명.nextval
SELECT SEQ_BOARD.nextval
FROM dual;

SELECT TO_CHAR(SYSDATE, 'YYYY/MM/DD') || '-' || SEQ_BOARD.nextval
FROM dual;

-- nextval 이후. 현재값을 구하는법 : 시퀀스.currval
SELECT SEQ_BOARD.currval
FROM dual;


SELECT rowid, rownum, emp.*
FROM emp
WHERE rowid = 'AAAE5uAAFAAAAEVAAC';

-- emp_test 테이블 삭제
DROP TABLE emp_test;

-- emp 테이블을 이용하여 emp_test테이블 생성
CREATE TABLE emp_test AS 
SELECT *
FROM emp;

-- emp_test 테이블에는 인덱스가 없는 상태
-- 원하는 데이터를 찾기 위해서는 테이블의 데이터를 모두 읽어봐야 한다.
EXPLAIN PLAN FOR
SELECT *
FROM emp_test
WHERE empno = 7369;

-- 실행계획을 통해 7369 사번을 갖는 직원 정보를 조회하기 위해 테이블의 모든 데이터(14건)을 읽어 본 다음에 사번이 7369인 데이터만 선택하여
-- 사용자에게 반환.  
--> ***13건의 데이터는 불필요하게 읽음.
SELECT *
FROM table(dbms_xplan.display);

-- emp 테이블을 확인
EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = 7369;

SELECT *
FROM table(dbms_xplan.display);


-- 실행계획을 통해 분석을 하면, empno가 7369인 직원을 index를 통해서 매우 빠르게 인덱스에 접근.
-- 같이 저장되어있는 rowid 값을 통해 table 에 접근을 한다.
-- table에서 읽은 데이터는 7369사번 데이터 한건만 조회.
-- 나머지 13건에 대해서는 읽지 않고 처리
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
   2 - access("EMPNO"=7369)    --> access는 접근한다는것. filter는 걸러내는것이므로 모든 데이터를 읽고서 거르는것.


-- emp 테이블 empno 컬럼으로 PRIMARY KEY 제약 생성 : pk_emp
ALTER TABLE emp ADD CONSTRAINT pk_emp PRIMARY KEY (empno);

-- dept 테이블 deptno 컬럼으로 PRIMARY KEY 제약 생성 : pk_dept
ALTER TABLE dept ADD CONSTRAINT pk_dept PRIMARY KEY (deptno);

-- emp 테이블 deptno가 dept테이블의 deptno 컬럼을 참조하도록 FOREIGN KEY 제약 추가 : fk_dept_deptno
ALTER TABLE emp ADD CONSTRAINT fk_dept_deptno FOREIGN KEY (deptno) REFERENCES dept (deptno);
