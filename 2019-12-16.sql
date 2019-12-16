-- GROUPING SETS (col1, col2)
-- 개발자가 GROUP BY 의 기준을 직접 명시한다.
-- ROLLUP과 달리 방향성을 갖지 않는다.
-- GROUPING SETS (col1, col2) == GROUPING SETS (col2, col1)
-- 다음과 결과가 동일
-- GROUP BY col 1
-- UNION ALL
-- GROUP BY col 2

-- emp테이블에서 직원의 job별 급여(sal) + 상여(comm)합,
--                    deptno(부서)별  급여(sal) + 상여(comm)합 구하기
-- 기존방식 (GROUP FUNCTION) : 2번의 SQL작성 필요(UNION/ UNION ALL)

SELECT job, null, sum(sal + NVL(comm,0)) AS sal
FROM emp
GROUP BY job

UNION ALL

SELECT null, deptno, sum(sal + NVL(comm,0)) AS sal
FROM emp
GROUP BY deptno;

-- GROUPING SETS 구문을 이용하여 위의 SQL를 집합연산을 사용하지 않고 테이블을 한번 읽어서 처리
SELECT job, deptno, sum(sal + NVL(comm,0)) AS sal
FROM emp
GROUP BY GROUPING SETS (job, deptno);


-- job, deptno를 그룹으로 한 sal+ comm합
-- mgr을 그룹으로 한 sal+ comm합
-- GROUP BY job, deptno
-- UINON ALL
-- GROUP BY mgr
-- --> GROUPING SETS((job, deptno), mgr)
SELECT job, deptno, mgr, SUM(sal+NVL(comm,0)) AS sal_comm_sum
        ,GROUPING(job), GROUPING(deptno), GROUPING(mgr)
FROM emp
GROUP BY GROUPING SETS ((job,deptno),mgr);


-- CUBE (col1, col2 .....)
-- 나열된 컬럼의 모든 가능한 조합으로 GROUP BY subset을 만든다.
-- CUBE에 나열된 컬럼이 2개인경우  : 가능한 조합 2^2 = 4
-- CUBE에 나열된 컬럼이 3개인경우  : 가능한 조합 2^3 = 8
-- CUBE에 나열된 컬럼수를 2의 제곱승한 결과가 가능한 조합 개수가 된다. (2^N)
-- 컬럼이 조금만 많아져도 가능한 조합이 기하 급수적으로 늘어나기때문에 많이 사용하지는 않는다.

-- job, deptno를 이용하여 CUBE 적용
SELECT job, deptno, SUM(sal + NVL(comm,0)) sal_comm_sum
FROM emp
GROUP BY CUBE(job, deptno);

/*
    1   1 --> GROUP BY job, deptno
    1   0 --> GROUP BY job
    0   1 --> GROUP BY deptno
    0   0 --> GROUP BY         -- emp테이블의 모든 행에 대하여 GROUP BY
*/


-- GROUP BY dmddyd
-- GROUP BY, ROLLUP, CUBE를 섞어 사용하기
-- 가능한 조합을 생각해보면 쉽게 결과를 예측할 수 ㅇㅆ다.
-- GROUP BY job, rollup(deptno), cube(mgr)
SELECT job, deptno, mgr, SUM(sal + NVL(comm,0)) sal_comm_sum, GROUPING (mgr)
FROM emp
GROUP BY job, ROLLUP(deptno), CUBE(mgr);

-- job이 group에서 같이나와도 중복되서 나오지않는다.
SELECT job, SUM(sal + NVL(comm,0)) sal_comm_sum
FROM emp
GROUP BY job, job;

SELECT job, deptno, mgr, SUM(sal + NVL(comm,0)) sal_comm_sum, GROUPING (mgr)
FROM emp
GROUP BY job, ROLLUP(job, deptno), CUBE(mgr);




-- 실습1.
CREATE TABLE dept_test AS
SELECT *
FROM dept;

ALTER TABLE dept_test ADD empcnt number;

-- 비상호 연관 서브쿼리를 상호연관 서브쿼리로 만들었다. --> 굳이 GROUP BY deptno를 할필요가 없다
UPDATE dept_test
SET empcnt = (SELECT count(*)
              FROM emp
              WHERE emp.deptno = dept_test.deptno
              );

SELECT * FROM dept_test;


-- 실습2.
DROP TABLE dept_test;
CREATE TABLE dept_test AS SELECT * FROM dept;

INSERT INTO dept_test VALUES (99, 'it1', 'daejeon');
INSERT INTO dept_test VALUES (98, 'it2', 'daejeon');

SELECT * FROM dept_test;

-- NOT IN이 안떠올랐다.
DELETE FROM dept_test
WHERE deptno NOT IN
(SELECT emp.deptno 
FROM emp 
--WHERE emp.deptno = dept_test.deptno
--GROUP BY deptno
);

-- 실습3.
DROP TABLE emp_test;
CREATE TABLE emp_test AS SELECT * FROM emp;

-- GROUP BY를 통해서 하면 다중 ROW가 되므로 WHERE를 통해서 emp_test테이블에서 가져온다
UPDATE emp_test
SET sal = sal + 200
WHERE sal < (SELECT ROUND(AVG(sal),1)
             FROM emp
             WHERE deptno = emp_test.deptno);

-- MERGE 구문을 이용한 업데이트  -> 신박하네 이거
MERGE INTO emp_test a
USING (SELECT deptno, AVG(sal) avg_sal
        FROM emp_test
        GROUP BY deptno) b
ON (a.deptno = b.deptno)
WHEN MATCHED THEN   
    UPDATE SET a.sal = a.sal+200
    WHERE a.sal < b.avg_sal;

 
-- 선생님 방식   --> 14행 모두가 update되지만 기존의 값은 그대로 유지된다.
MERGE INTO emp_test a
USING (SELECT deptno, AVG(sal) avg_sal
        FROM emp_test
        GROUP BY deptno) b
ON (a.deptno = b.deptno)
WHEN MATCHED THEN   
    UPDATE SET a.sal = CASE
                            WHEN a.sal < b.avg_sal THEN a.sal+200
                            ELSE sal
                       END;
                       
                       
                       
-- 뭐 이리 어렵냐 ㅠㅠ                       
                       
                       