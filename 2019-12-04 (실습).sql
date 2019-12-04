--1. tax 테이블을 이용 시도/시군구별 인당 연말정산 신고액 구하기
--2. 신고액이 많은 순서로 랭킹 부여하기
--랭킹(1) 시도(2) 시군구(3) 인당 연말정산 신고액(4) -- 소수점 둘째자리에서 반올림

SELECT
    *
FROM tax;

SELECT ROWNUM AS Rank, sido, sigungu, sal_year
FROM
    (SELECT id, sido, sigungu, ROUND(sal/people, 1) AS sal_year
     FROM tax
     ORDER BY sal_year DESC);


SELECT ROWNUM RANK, sido, sigungu, 도시발전지수
    FROM
        (SELECT a.sido, a.sigungu, ROUND(a.cnt/b.cnt, 1) 도시발전지수
        FROM
            (SELECT sido, sigungu, COUNT(*) cnt
            FROM fastfood
            WHERE GB IN ('버거킹', '맥도날드', 'KFC')
            GROUP BY sido, sigungu) a
            ,(SELECT sido, sigungu, COUNT(*) cnt
            FROM fastfood
            WHERE GB = '롯데리아'
            GROUP BY sido, sigungu) b
        WHERE a.sido = b.sido
        AND a.sigungu = b.sigungu
        ORDER BY 도시발전지수 DESC);
        
        
        
SELECT ROWNUM, sido, sigungu, 도시발전지수, ' ' AS 인당연말정산신고액, ysido, ysigungu, sal_year
FROM
    (SELECT ROWNUM, x.sido, x.sigungu, x.도시발전지수, y.sido AS ysido, y.sigungu AS ysigungu, y.sal_year
    FROM
        (SELECT ROWNUM AS rank1, sido, sigungu, 도시발전지수
            FROM
                (SELECT a.sido, a.sigungu, ROUND(a.cnt/b.cnt, 1) 도시발전지수
                FROM
                    (SELECT sido, sigungu, COUNT(*) cnt
                    FROM fastfood
                    WHERE GB IN ('버거킹', '맥도날드', 'KFC')
                    GROUP BY sido, sigungu) a
                    ,(SELECT sido, sigungu, COUNT(*) cnt
                    FROM fastfood
                    WHERE GB = '롯데리아'
                    GROUP BY sido, sigungu) b
                WHERE a.sido = b.sido
                AND a.sigungu = b.sigungu
                ORDER BY 도시발전지수 DESC)) x,
        (SELECT ROWNUM AS rank2, sido, sigungu, sal_year
        FROM
            (SELECT sido, sigungu, ROUND(sal/people, 1) AS sal_year
             FROM tax
             ORDER BY sal_year DESC)) y
WHERE x.rank1 = y.rank2);



-- 도시발전지수 시도, 시군구와 연말정산 납입금액의 시도, 시군구가 같은 지역끼리 조인
-- tax의 id기준으로 정렬
SELECT ROWNUM, sido, sigungu, 도시발전지수, ' ' AS 인당연말정산신고액, ysido, ysigungu, sal_year, id
FROM
    (SELECT ROWNUM, x.sido, x.sigungu, x.도시발전지수, y.sido AS ysido, y.sigungu AS ysigungu, sal_year, y.id
    FROM
        (SELECT ROWNUM AS rank1, sido, sigungu, 도시발전지수
            FROM
                (SELECT a.sido, a.sigungu, ROUND(a.cnt/b.cnt, 1) 도시발전지수
                FROM
                    (SELECT sido, sigungu, COUNT(*) cnt
                    FROM fastfood
                    WHERE GB IN ('버거킹', '맥도날드', 'KFC')
                    GROUP BY sido, sigungu) a
                    ,(SELECT sido, sigungu, COUNT(*) cnt
                    FROM fastfood
                    WHERE GB = '롯데리아'
                    GROUP BY sido, sigungu) b
                WHERE a.sido = b.sido
                AND a.sigungu = b.sigungu
                ORDER BY 도시발전지수 DESC)) x,
        (SELECT ROWNUM AS Rank, sido, sigungu, sal_year, id
         FROM
            (SELECT id, sido, sigungu, ROUND(sal/people, 1) AS sal_year
             FROM tax
             ORDER BY sal_year DESC)
         ORDER BY id) y
    WHERE x.sido(+) = y.sido
    AND x.sigungu(+) = y.sigungu
    ORDER BY y.id );        
    
    
--------------------------------- Sub 쿼리 시작 ---------------------------------------------

--SMITH가 속한 부서찾기


SELECT *
FROM emp
WHERE deptno = (SELECT deptno
                FROM emp
                WHERE ename = 'SMITH');
-----------------------------------------------------------------------------------------------------------
--             SCALAR SUBQUERY
--             SELECT 절에 표현된 서브쿼리
--             한 행, 한 COLUMN을 조회해야 한다
-----------------------------------------------------------------------------------------------------------
--             INLINE VIEW
--             FROM 절에 사용되는 서브쿼리
-----------------------------------------------------------------------------------------------------------
--             SUBQUERY
--             WHERE 절에 사용하는 서브쿼리
-----------------------------------------------------------------------------------------------------------

-- 한행에 한행만 넣음
SELECT empno, ename, deptno
        ,(SELECT dname FROM dept WHERE dept.deptno = emp.deptno) dname
FROM emp;

-- error : 한행에 2개의 행이상을 넣었다.
SELECT empno, ename, deptno
        ,(SELECT dname FROM dept) dname
FROM emp;


-- 서브쿼리 실습1 : 평균 급여보다 높은 급여를 받는 직원 수
SELECT COUNT(*)
FROM emp 
WHERE sal > (SELECT ROUND(AVG(sal),1)
             FROM emp);
 
-- 서브쿼리 실습2 : 평균 급여보다 높은 급여를 받는 직원의 정보 조회
SELECT * 
FROM emp
WHERE sal > (SELECT ROUND(AVG(sal),1)
             FROM emp);
             
-----------------------------------------------------------------------------------------------------------
--           Multi-row 연산자                  -- 잘안쓰지만 알아만두자.
--          IN  : 서브쿼리 결과중 같은 값이 있을때
--          ANY : 서브쿼리 결과중 하나라도 만족시
--          ALL : 서브쿼리 결과 모두 만족시
-----------------------------------------------------------------------------------------------------------


-- 서브쿼리 실습3 : SMITH와 WARD가 속한 부서의 모든 정보를 조회  (부서번호가 2개이므로 IN을 사용)

SELECT *
FROM emp
WHERE deptno IN (SELECT deptno
                FROM emp
                WHERE ename IN ('SMITH', 'WARD'));        
        
SELECT *
FROM emp
WHERE sal < ANY (SELECT sal   -- 800 , 1250 --> 1250 보다 작은 사람  -- ALL이면 800보다 작은사람
                FROM emp
                WHERE ename IN ('SMITH', 'WARD'));          

-- 관리자 역할을 하지 않는 사원 정보 조회
-- NULL IN : 사용시 NULL인 컬럼이 존재하지 않아야 정상동작
SELECT *
FROM emp
WHERE empno NOT IN (SELECT NVL(mgr, -1)
                    FROM emp);
SELECT *
FROM emp
WHERE empno NOT IN (SELECT mgr
                    FROM emp
                    WHERE mgr IS NOT NULL);

-----------------------------------------------------------------------------------------------------------

--          Pairwise (여러 컬럼의 값을 동시에 만족해야 하는 경우)

-----------------------------------------------------------------------------------------------------------
-- ALLEN, CLARK의 매너지와 부서번호가 동시에 같은 사원 정보 조회
-- (7499 , 30) , (7782 , 10)

SELECT *
FROM emp
WHERE (mgr, deptno) IN (SELECT mgr, deptno
                        FROM emp
                        WHERE empno IN (7499, 7782));

-- 매니저가 7698이거나  7839 이면서 소속부서가 10이거나 30번인 직원 정보 조회
-- 7698, 10
-- 7698, 30
-- 7839, 30
-- 7839, 10
SELECT *
FROM emp
WHERE mgr IN (SELECT mgr
              FROM emp
              WHERE empno IN (7499, 7782))
AND deptno IN (SELECT deptno
              FROM emp
              WHERE empno IN (7499, 7782));
        
-----------------------------------------------------------------------------------------------------------

---------------    비상호 연관 서브 쿼리    ---------------------
--           - 메인쿼리의 컬럼을 서브쿼리에서 사용하지 않는 형태의 서브쿼리
--          비상호 연관 서브 쿼리의 경ㅇ 메인쿼리에서 사용하는 테이블, 서브쿼리 조회 순서를 성능적으로 유리한쪽으로 판단하여 순서를 결정한다. 
--          (서브쿼리가 단독실행이 가능하므로)
--           - 메인쿼리의 emp 테이블을 먼저 읽을수도 있고, 서브쿠리의 emp 테이블을 먼저 읽을수도 있다.

-- 서브쿼리를 테이블보다 먼저 읽었을 경우 -> 서브쿼리가 제공자역할을 했다 라고 표현
-- 서브쿼리를 테이블보다 나중에 읽었을 경우 -> 서브쿼리가 확인자역할을 했다 라고 표현

-----------------------------------------------------------------------------------------------------------

-- 직원의 급여 평균보다 높은 급여를 받는 직원 정보 조회
-- 직원의 급여 평균
SELECT *
FROM emp
WHERE sal > (SELECT AVG(sal)
             FROM emp);
        
        
-----------------------------------------------------------------------------------------------------------

---------------    상호 연관 서브 쿼리    --------------------- 


-----------------------------------------------------------------------------------------------------------

-- 해당직원이 속한 부서의 급여평균보다 높은 급여를 받는 직원 조회
SELECT *
FROM emp m
WHERE sal > (SELECT AVG(sal)
             FROM emp
             WHERE deptno = m.deptno);
        