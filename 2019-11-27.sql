-- Group Function
-- 특정 컬럼이나, 표현을 기준으로 여러행의 값을 한행의 결과로 생성
-- 그룹함수에서 null컬럼은 계산에서 제외된다.
-- group by절에 작성된 컬럼 이외의 컬럼이 select절에 올수 없다.
-- where절에 그룹함수를 조건으로 사용할 수 없다.
-- COUNT-건수, SUM-합계, AVG-평균, MAX-최대값, MIN-최소값

-- [ 1 ] 전체 직원을 대상으로 (14건을 -> 1건)
SELECT MAX(sal) AS max_sal       --가장 높은 급여
        ,MIN(sal) AS min_sal     --가장 낮은 급여
        ,ROUND(AVG(sal), 2) AS avg_sal    --전 직원의 급여 평균
        ,SUM(sal) AS sum_sal     --전 직원의 급여 합
        ,COUNT(sal) AS count_sal --급여 건수(null이 아닌 값이면 1건)
        ,COUNT(mgr) AS count_mgr --직원의 관리자 건수 (king은 mgr이 null)
        ,COUNT(*) AS count_row   --특정 컬럼의 건수가 아니라 행의 갯수를 알고 싶을때 사용
FROM emp;

-- [ 2 ] 부서 번호를 기준으로 (14건을 -> 3건)
SELECT deptno
        ,MAX(sal) AS max_sal       --부서에서 가장 높은 급여
        ,MIN(sal) AS min_sal     --부서에서 가장 낮은 급여
        ,ROUND(AVG(sal), 2) AS avg_sal    --부서 직원의 급여 평균
        ,SUM(sal) AS sum_sal     --부서 직원의 급여 합
        ,COUNT(sal) AS count_sal --부서의 급여 건수(null이 아닌 값이면 1건)
        ,COUNT(mgr) AS count_mgr --부서 직원의 관리자 건수(king은 mgr이 null)
        ,COUNT(*) AS count_row   --부서의 조직원수
FROM emp
GROUP BY deptno;

-- [ 3 ] 부서 번호와 사원이름을 기준으로 (사원이름이 유니크값이므로 14건 전부출력)
SELECT deptno, ename
        ,MAX(sal) AS max_sal       --부서에서 가장 높은 급여
        ,MIN(sal) AS min_sal     --부서에서 가장 낮은 급여
        ,ROUND(AVG(sal), 2) AS avg_sal    --부서 직원의 급여 평균
        ,SUM(sal) AS sum_sal     --부서 직원의 급여 합
        ,COUNT(sal) AS count_sal --부서의 급여 건수(null이 아닌 값이면 1건)
        ,COUNT(mgr) AS count_mgr --부서 직원의 관리자 건수(king은 mgr이 null)
        ,COUNT(*) AS count_row   --부서의 조직원수
FROM emp
GROUP BY deptno, ename;

-- [ 4 ] SELECT절에는 GROUP BY 절에 표현한 컬럼 이외의 컬럼이 올수없다.
--       논리적으로 성립이 되지 않음(여러명의 직원 정보를 한건의 데이터로 그루핑)
--  단, 예외적으로 상수값들은 SELECT절에 표현이 가능하다
SELECT deptno, SYSDATE, 1, '문자열'
        ,MAX(sal) AS max_sal    
        ,MIN(sal) AS min_sal     
        ,ROUND(AVG(sal), 2) AS avg_sal   
        ,SUM(sal) AS sum_sal  
        ,COUNT(sal) AS count_sal 
        ,COUNT(mgr) AS count_mgr 
        ,COUNT(*) AS count_row  
FROM emp
GROUP BY deptno;

-- [ 5 ] 그룹함수에서는 NULL 컬럼은 계산에서 제외된다.
-- emp테이블에서 comm컬럼이 null이 아닌 데이터 4건이 존재. 9건은 null
SELECT COUNT(comm) AS count_comm            -- null이 아닌 데이터의 갯수 4건
        ,SUM(comm) AS sum_comm              -- null이 아닌 데이터의 합
        ,SUM(sal) AS sum_sal
        ,SUM(sal + comm) AS total_sal_sum   -- sal + comm이 먼저 계산되어 null과의 연산에 의해 null이 되는 컬럼이 생성된다.
        ,SUM(sal + NVL(comm, 0)) AS total_sal_sum
FROM emp;

-- [ 6 ] WHERE절에는 GROUP 합수를 포현할수 없다. (HAVING절에서 사용)

-- 1. 부서별 최대 급여 구하기
SELECT deptno, MAX(sal) m_sal
FROM emp
GROUP BY deptno;
-- 2. 부서별 최대 급여 값이 3000이 넘는 행만 구하기
SELECT deptno, MAX(sal) m_sal
FROM emp
WHERE MAX(sal) > 3000 -- ORA-00934 WHERE절에는 GROUP함수를 사용할 수 없다 (에러 출력)
GROUP BY deptno; 

SELECT deptno, MAX(sal) m_sal
FROM emp
GROUP BY deptno
HAVING MAX(sal) > 3000;

--실습 3. 
SELECT deptno
        ,DECODE(deptno, 10, 'ACCOUNTING', 20, 'RESEARCH', 30, 'SALES', 'OPERATIONS') AS dname_deptno
        ,CASE
                WHEN deptno = 10 THEN 'ACCOUNTING'
                WHEN deptno = 20 THEN 'RESEARCH'
                WHEN deptno = 30 THEN 'SALES'
                ELSE 'OPERATIONS'
        END dname_case
        ,MAX(sal)
        ,MIN(sal)
        ,ROUND(AVG(sal), 2)
        ,SUM(sal)
        ,COUNT(sal)
        ,COUNT(mgr)
        ,COUNT(*)
FROM emp
GROUP BY deptno
        ,DECODE(deptno, 10, 'ACCOUNTING', 20, 'RESEARCH', 30, 'SALES', 'OPERATIONS')
        ,CASE
            WHEN deptno = 10 THEN 'ACCOUNTING' 
            WHEN deptno = 20 THEN 'RESEARCH' 
            WHEN deptno = 30 THEN 'SALES' 
            ELSE 'OPERATIONS'
        END
ORDER BY deptno;

-- 실습 4.
SELECT TO_CHAR(hiredate, 'YYYYMM') AS hire_YYYYMM
        , COUNT(*) AS cnt
FROM emp
GROUP BY TO_CHAR(hiredate, 'YYYYMM');

SELECT hire_yyyymm, COUNT(*) AS cnt
FROM 
    (
    SELECT TO_CHAR(hiredate, 'YYYYMM') AS hire_yyyymm
    FROM emp
    ) hire_yyyymm
GROUP BY hire_yyyymm;

--실습 5.
SELECT TO_CHAR(hiredate, 'YYYY') AS hire_YYYY
        , COUNT(*) AS cnt
FROM emp
GROUP BY TO_CHAR(hiredate, 'YYYY');

SELECT hire_yyyy, COUNT(*) AS cnt
FROM
    (
    SELECT TO_CHAR(hiredate, 'YYYY') AS hire_YYYY
    FROM emp
    ) hire_yyyy 
GROUP BY hire_yyyy;

--실습 6.
SELECT COUNT(*), COUNT(deptno), COUNT(dname), COUNT(loc)
FROM dept;

--실습 7
SELECT COUNT(deptno)
FROM
    (
    SELECT deptno
    FROM emp
    GROUP BY deptno
    );

SELECT COUNT(COUNT(deptno)) AS cnt
FROM emp
GROUP BY deptno;

SELECT COUNT(DISTINCT deptno)
FROM emp;

