--------------------------------------------------------------------------------------------------------------------------------

--                  multiple insert

--------------------------------------------------------------------------------------------------------------------------------
DROP TABLE emp_test;

-- emp 테이블의 empno, ename 컬럼으로 emp_test, emp_test2 테이블을 생성 (CTAS, 데이터도 같이 복사)
CREATE TABLE emp_test AS
SELECT empno, ename
FROM emp;
CREATE TABLE emp_test2 AS
SELECT empno, ename
FROM emp;

--------------------------------------------------------------------------------------------------------------------------------
-- unconditional insert
-- 여러 테이블에 데이터를 동시 입력
--------------------------------------------------------------------------------------------------------------------------------
-- brown, cony를 emp_test, emp_test2에 동시에 입력
INSERT ALL
    INTO emp_test
    INTO emp_test2
SELECT 9999, 'brown' FROM  dual
UNION ALL
SELECT 9998, 'cony' FROM dual;

SELECT *
FROM emp_test
WHERE empno > 9000;
SELECT *
FROM emp_test2
WHERE empno > 9000;

ROLLBACK;

-- 테이블 별로 입력되는 데이터의 컬럼을 제어 가능
INSERT ALL
    INTO emp_test (empno, ename) VALUES (eno, enm)
    INTO emp_test2 (empno) VALUES (eno)
SELECT 9999 AS eno, 'brown' AS enm FROM  dual
UNION ALL
SELECT 9998, 'cony' FROM dual;

SELECT *
FROM emp_test
WHERE empno > 9000

UNION ALL

SELECT *
FROM emp_test2
WHERE empno > 9000;



--------------------------------------------------------------------------------------------------------------------------------
-- conditional insert
-- 조건에 따라 테이블에 데이터를 입력

-- ALL 이면 조건에 해당되면 모두 적용된다
-- FIRST가 있으면 만족하는조건 처음만 적용된다
--------------------------------------------------------------------------------------------------------------------------------

/*
    CASE
        WHEN 조건 THEN ---- IF
        WHEN 조건 THEN ---- ELSE IF 
        ELSE ----          ELSE 
*/
ROLLBACK;

INSERT FIRST  
    WHEN /*조건*/ eno > 9000 THEN
        INTO emp_test (empno, ename) VALUES (eno, enm)
    WHEN /*조건*/ eno > 9500 THEN
        INTO emp_test (empno, ename) VALUES (eno, enm)    
    ELSE
        INTO emp_test2 (empno) VALUES (eno)
SELECT 9999 AS eno, 'brown' AS enm FROM  dual
UNION ALL
SELECT 8998, 'cony' FROM dual;

SELECT *
FROM emp_test
WHERE empno > 9000
UNION ALL
SELECT *
FROM emp_test2
WHERE empno > 8000;


--------------------------------------------------------------------------------------------------------------------------------


select* from emp_test
ORDER BY empno;

-- emp 테이블에 존재하는 데이터를 emp_test 테이블로 merge
-- 만약 empno가 동일한 데이터가 존재하면
-- ename update : ename || '_merge'
-- 만약 empno에 동일한 데이터가 존재 하지 않을 경우
-- emp테이블의 empno, ename emp_test 데이터로 insert

-- emp_test 테이터에서 절반의 데이터 삭제
DELETE FROM emp_test
WHERE empno >= 7788;


-- emp 테이블에는 14건의 데이터가
-- emp_test 테이블에는 사번이 7778보다 작은 7명의 데이터가 존재
-- emp 테이블을 이용하여 emp_test 테이블을 merge 하게되면
-- emp 테이블에만 존재하는 직원 (사번이 7788보다 크거나 같은 ) 7명
-- emp_test로 새롭게 insert가 될 것이고
-- emp, emp_test에 사원번호가 동일하게 존재하는 7명의 데이터는
-- (사번이 7788보다 작은 직원)ename  컬럼의 ename || '_modify'로 업데이트 한다.


--------------------------------------------------------------------------------------------------------------------------------

/*  
    MERGE INTO 테이블명
    USING 머지대상 테이블 | VIEW | SUBQUERY
    ON (테이블명과 머지대상의 연결관계)
    WHEN MATCHED THEN
        UPDATE ....
    WHEN NOT MATCHED THEN
        INSERT ....
*/

--------------------------------------------------------------------------------------------------------------------------------


MERGE INTO emp_test
USING emp
ON (emp.empno = emp_test.empno)
WHEN MATCHED THEN
    UPDATE SET ename = ename || '_mod'
WHEN NOT MATCHED THEN
    INSERT VALUES (emp.empno, emp.ename);
    
SELECT * FROM emp_test;



-- emp_test 테이블에 사번이 9999인 데이터가 존재하면
-- ename을 'brown'으로 update
-- 존재하지 않을 경우 empno, ename VALUES (9999, 'brown')으로 insert
-- 우의 시나리오를 MERGE 구문을 활용하여 한번의 SQL로 구현

MERGE INTO emp_test
USING dual
ON (empno = :empno)
WHEN MATCHED THEN
    UPDATE SET ename = :ename || '_mod'
WHEN NOT MATCHED THEN
    INSERT VALUES (:empno, :ename);
    
SELECT * FROM emp_test
WHERE empno = 9999;


-- 만약 MERGE 문이 없다면 (** 2번의 SQL이 필요)
-- 1. empno = 9999인 데이터가 존재 하는지 확인
-- 2-1. 1번 사항에서 데이터가 존재하면 UPDATE
-- 2-2. 1번 사항에서 데이터가 존재하지 않으면 INSERT
    
    

--------------------------------------------------------------------------------------------------------------------------------
-- 실습 1. GROUP BY 기억하기
--부서별 급여합
SELECT deptno, SUM(sal) sale
FROM emp     
GROUP BY deptno

UNION All  -- 공통된 데이터가 없으므로 Union보다 Union all이 낫다.

--전체 직원의 급여합
SELECT NULL, SUM(sal) sal
FROM emp;

-- JOIN 방식으로
-- emp 테이블의 14건에 데이터를 28건으로 생성
-- 구분자(1 - 14, 2 - 14)를 기준으로 group by
-- 구분자 1 : 부서번호 기준으로 (14) row
-- 구분자 2 : 전체 (14) row
SELECT DECODE(b.rn, 1, emp.deptno, 2, null) AS gp
       ,sum(emp.sal) sal
FROM emp, (SELECT ROWNUM AS rn
          FROM dept
          WHERE ROWNUM <= 2) b
GROUP BY DECODE(b.rn, 1, emp.deptno, 2, null)
ORDER BY gp;

-- dept 테이블은 실존테이블이므로 dual사용
SELECT DECODE(b.rn, 1, emp.deptno, 2, null) AS gp
       ,sum(emp.sal) sal
FROM emp, (SELECT 1 AS rn FROM dual UNION ALL
           SELECT 2 FROM dual) b
GROUP BY DECODE(b.rn, 1, emp.deptno, 2, null)
ORDER BY gp;

-- 계층쿼리를 사용할때 방법
SELECT DECODE(b.rn, 1, emp.deptno, 2, null) AS gp
       ,sum(emp.sal) sal
FROM emp, (SELECT LEVEL rn
           FROM dual
           CONNECT BY LEVEL <= 2) b
GROUP BY DECODE(b.rn, 1, emp.deptno, 2, null)
ORDER BY gp;



    
    
--------------------------------------------------------------------------------------------------------------------------------
/*
    Report Group Function
    1. ROLLUP
     - GROUP BY ROLLUP (column.......)
     - ROLLUP절에 기술된 컬럼을 오른쪽에서 부터 지운 결과로 SUB GROUP을 생성하여 여러개의 GROUP BY절을 하나의 SQL에서 실행하도록 한다
*/
--------------------------------------------------------------------------------------------------------------------------------
-- 
 GROUP BY FOLLUP (job, deptno)
-- GROUP BY job, deptno
-- GROUP BY job
-- GROUP BY --> 전체 행을 대상으로 GROUP BY 실행

-- emp테이블을 이용하여 부서번호별, 전체직원별 급여합을 구하는 쿼리를 ROLLUP 기능을 이용하여 작성
SELECT deptno, SUM(sal) sal
FROM emp
GROUP BY ROLLUP(deptno);

-- emp 테이블을 이용하여 job, deptno 별 sal + comm 합계
--                    job 별 sal + comm 합계
--                    전체 직원의 sal + comm 합계
-- ROLLUP을 활용하여 작성
SELECT job, deptno, sum(sal + NVL(comm, 0)) AS sal_sum
FROM emp
GROUP BY ROLLUP(job, deptno);
-- GROUP BY job, deptno
-- GROUP BY job
-- GROUP BY  --> 전체 ROW 대상

-- ROLLUP은 컬럼 순서가 조회 결과에 영향을 미친다.
GROUP BY ROLLUP(deptno, job);
-- GROUP BY deptno, job
-- GROUP BY deptno
-- GROUP BY  --> 전체 ROW 대상

CASE WHEN e.salary > 2000 THEN e.salary
   ELSE 2000 END

--실습 2.
SELECT DECODE(GROUPING(job), 1, '총', job) job
        ,CASE 
            WHEN deptno IS NULL AND job IS NULL THEN '계'
            WHEN deptno IS NULL AND job IS NOT NULL THEN '소계'
            ELSE '' || deptno -- TO_CHAR(deptno)도 된다. 앞쪽은 문자열에 숫자를 더해서 문자열로만든것
        END AS deptno
        ,DECODE(GROUPING(deptno), 1, DECODE(GROUPING(job), 1, '계', '소계'), deptno) AS deptno 
        ,DECODE(GROUPING(deptno)+ GROUPING(job), 2, '계' , 1, '소계', deptno) AS deptno 
        ,GROUPING(job), GROUPING(deptno)
        ,sum(sal + NVL(comm, 0)) AS sal
FROM emp
GROUP BY ROLLUP(job, deptno);


-- 실습 3.
SELECT deptno, job, sum(sal + NVL(comm,0)) sal
FROM emp
GROUP BY ROLLUP(deptno, job)
ORDER BY deptno;

-- UNION ALL 로 치환 --  이방식대로 된다는소리
SELECT deptno, job, sum(sal + NVL(comm,0)) sal
FROM emp
GROUP BY deptno, job

UNION ALL

SELECT deptno, NULL, sum(sal + NVL(comm,0)) sal
FROM emp
GROUP BY deptno

UNION ALL

SELECT NULL, NULL, sum(sal + NVL(comm,0)) sal
FROM emp;


-- 실습 4.
SELECT d.dname, e.job, sum(e.sal + NVL(e.comm,0)) sal
FROM emp e, dept d
WHERE e.deptno = d.deptno
GROUP BY ROLLUP(d.dname, e.job)
ORDER BY d.dname, e.job DESC;

SELECT dept.dname, a.job, a.sal_sum
FROM (SELECT deptno, job, sum(sal + NVL(comm,0)) sal_sum
FROM emp
GROUP BY ROLLUP(deptno, job)
ORDER BY deptno) a, dept
WHERE dept.deptno(+) = a.deptno;


-- 실습5.
SELECT DECODE(d.dname, NULL, '총합', d.dname) AS dname
        ,e.job, sum(e.sal + NVL(e.comm,0)) sal
FROM emp e, dept d
WHERE e.deptno = d.deptno
GROUP BY ROLLUP(d.dname, e.job)
ORDER BY d.dname, e.job DESC;

