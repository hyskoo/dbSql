--------------------------------------------------------------------------------------------------------------------------------
/*
                  분석함수 / Window 함수     
                  - 해당 행의 범위를 넘어 행간 연산을 지원 
                    - 이전행의 특정 컬럼 조회
                    - 특정 범위의 행들의 컬럼 합 조회
                    - 특정 범위의 행중 특정 컬럼을 기준으로 한 순위, ROW 번호 조회
                  
*/
--------------------------------------------------------------------------------------------------------------------------------

--사원이름, 사원번호, 전체직원건수
SELECT ename, empno, COUNT(*), SUM(sal)
FROM emp
GROUP BY ename, empno;

-- 분석함수 없을때, 부서별 급여(sal) 순위 구하기
SELECT q.ename, q.sal, q.deptno, w.rn
FROM (SELECT ename, sal, deptno, ROWNUM j_rn
      FROM (SELECT ename, sal, deptno
            FROM emp
            ORDER BY deptno, sal DESC)) q,
     (SELECT rn, ROWNUM j_rn
      FROM (SELECT b.*, a.rn
            FROM (SELECT ROWNUM rn
                  FROM dual
                  CONNECT BY LEVEL <= (SELECT COUNT(*) FROM emp)) a,
                 (SELECT deptno, COUNT(*) AS cnt
                  FROM emp
                  GROUP BY deptno) b
            WHERE b.cnt >= a.rn
            ORDER BY b.deptno, a.rn)) w
WHERE q.j_rn = w.j_rn;


-- 위의 문제를 분석함수로 + 추가
-- 서브쿼리가 많은 위보다 아래가 빠르다. 다만 이것은 오라클에서만 지원하는 분석함수
SELECT ename, sal, deptno
       ,RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) rank
       ,DENSE_RANK() OVER (PARTITION BY deptno ORDER BY sal DESC) dense_rank
       ,ROW_NUMBER() OVER (PARTITION BY deptno ORDER BY sal DESC) row_rank
FROM emp;


-- 사원의 전체 급여 순위를 구하라. 단, 동일한 경우 사번이 높은순위가 되도록 작성
SELECT empno, ename, sal, deptno
        ,RANK() OVER (ORDER BY sal DESC, empno) sal_rank
        ,DENSE_RANK() OVER (ORDER BY sal DESC, empno) sal_dense_rank
        ,ROW_NUMBER() OVER (ORDER BY sal DESC, empno) sal_row_rank
FROM emp;


-- 분석함수 없이 모든 사원에 대해 사원번호, 사원이름, 해당사원이 속한 부서의 사원수를 조회
SELECT a.*, b.cnt
FROM (SELECT empno, ename, deptno
      FROM emp
      ORDER BY deptno) a,
     (SELECT deptno, COUNT(*) AS cnt
      FROM emp
      GROUP BY deptno) b
WHERE a.deptno = b.deptno;

-- 분석함수를 통해 위의 문제를 해결 
-- 분석함수에도 SUM, COUNT등 일반 집계함수를 사용할 수 있다.
SELECT empno, ename, sal, deptno
        ,COUNT(*) OVER (PARTITION BY deptno) cnt
        ,ROUND(AVG(sal) OVER (PARTITION BY deptno),2) avg_sal
        ,MAX(sal) OVER (PARTITION BY deptno) max_sal
        ,MIN(sal) OVER (PARTITION BY deptno) min_sal
FROM emp;


-- 전체사원중 급여순위가 자기보다 한단계낮은사람 조회
-- (급여가 같으면 입사일자가 빠른사람이 높은 순위)
SELECT empno, ename, hiredate, sal
        ,LEAD(sal) OVER (ORDER BY sal DESC, hiredate) AS lead_sal
FROM emp;

-- 실습5.
SELECT empno, ename, hiredate, sal
        ,LAG(sal) OVER (ORDER BY sal DESC, hiredate) AS lag_sal
FROM emp;

-- 실습 6
SELECT empno, ename, hiredate, job, sal
        ,LAG(sal) OVER (PARTITION BY job ORDER BY sal DESC, hiredate) AS sal
FROM emp;

-- 실습 no_ana 3
SELECT empno, ename, hiredate, job, sal
FROM emp 
ORDER BY sal, hiredate;

SELECT q.empno, q.ename, q.sal, w.sum_sal
FROM
(SELECT empno, ename, sal, ROWNUM AS rn
FROM (SELECT * FROM emp ORDER BY sal)) q,
(SELECT sum_sal, ROWNUM AS row_num
FROM(SELECT SUM(b.sal) sum_sal
     FROM (SELECT ROWNUM AS rn, sal FROM (SELECT sal FROM emp ORDER BY sal)) a,
          (SELECT ROWNUM AS rn, sal FROM (SELECT sal FROM emp ORDER BY sal)) b
     WHERE a.rn >= b.rn
     GROUP BY a.rn
     ORDER BY a.rn)) w
WHERE q.rn = w.row_num;


SELECT c.empno, c.ename, c.sal, sum(d.sal)
FROM
(SELECT  a.*, rownum rn
FROM
    (SELECT empno, ename, sal, hiredate
    FROM emp
    ORDER BY sal, hiredate)a)c,
(SELECT  b.*, rownum rn
FROM
    (SELECT empno, ename, sal
    FROM emp
    ORDER BY sal, hiredate) b)d
WHERE c.rn >= d.rn
GROUP BY c.empno, c.ename, c.sal, c.hiredate
ORDER BY c.sal, c.hiredate;


