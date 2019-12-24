-- WITH
/* 
    WITH 블록이름 AS (
    서브쿼리
    )
    
    SELECT * 
    FROM 블록이름
*/
-- 해당 부서의 급여평균이 전체 직원의 급여평균보다 높은 부서를 조회
SELECT deptno, AVG(sal)
FROM emp
GROUP BY deptno
HAVING AVG(sal) > (SELECT AVG(sal) FROM emp);  --전체직원 급여 평균

-- WITH 절을 사용하여 위의 쿼리를 작성
WITH dept_sal_avg AS(
    SELECT deptno, AVG(sal) AS avg_sal
    FROM emp
    GROUP BY deptno
    ),
    emp_sal_avg AS (
    SELECT AVG(sal) AS avg_sal FROM emp
    )
SELECT *
FROM dept_sal_avg
WHERE dept_sal_avg.avg_sal > (SELECT avg_sal FROM emp_sal_avg);



-- 계층쿼리

-- 0. 달력만들기
-- CONNECT BY LEVEL <= N
-- 테이블의 ORW 건수를 N만큼 반복한다
-- CONNECT BY LEVEL 절을 사용한 쿼리에서는 SELECT 절에서 LEVEL이라는 특수컬럼을 사용 할 수 있다.
-- 계층을 표현하는 특수 컬럼으로 1부터 증가하며 ROWNUM과 유사하나 추후 배우게될 START WITH, CONNECT BY 절에서 다른 점을 배운다.



-- 2019년 11월은 30일까지 존재
-- 201911
-- 일자 + 정수 = 정수만큼 미래의 일자 증가
-- 20191 --> 해당 년월의 날짜가 몇일까지 존재하는가?
-- 1-일, 2-월 ........? 7-토

-- 마지막주를 53주로 만들기 위해서 일요일을 기준으로 주차 구하기
SELECT /*일요일이면 날짜, 화요일이면 날짜, 수요일이면 날짜....... 토요일이면 날짜*/
        /*dt, d,*/ /*iw,*/
        MAX(DECODE(d, 1, dt)) s, MAX(DECODE(d, 2, dt)) m, MAX(DECODE(d, 3, dt)) t,
        MAX(DECODE(d, 4, dt)) w, MAX(DECODE(d, 5, dt)) th, MAX(DECODE(d, 6, dt)) f,
        MAX(DECODE(d, 7, dt)) sat
FROM
    (SELECT TO_DATE(:yyyymm, 'YYYYMM') + (LEVEL-1) dt,    -- 년 월
            TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (LEVEL-1), 'D') d, -- 요일의 번호
            TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (LEVEL), 'IW') iw  -- d보다 +1의 날짜의 요일을 가져온다
    FROM dual
    CONNECT BY LEVEL <= TO_CHAR(LAST_DAY( TO_DATE(:yyyymm, 'YYYYMM')), 'DD'))
GROUP BY TRUNC((TRUNC(dt) - TRUNC(TRUNC(dt, 'yy'), 'd')) / 7) + 1
ORDER BY TRUNC((TRUNC(dt) - TRUNC(TRUNC(dt, 'yy'), 'd')) / 7) + 1;

-- 위와 비슷한 형식 교수님방식
SELECT /*일요일이면 날짜, 화요일이면 날짜, 수요일이면 날짜....... 토요일이면 날짜*/
        /*dt, d,*/ /*iw,*/
        dt - (d-1),
        MAX(DECODE(d, 1, dt)) s, MAX(DECODE(d, 2, dt)) m, MAX(DECODE(d, 3, dt)) t,
        MAX(DECODE(d, 4, dt)) w, MAX(DECODE(d, 5, dt)) th, MAX(DECODE(d, 6, dt)) f,
        MAX(DECODE(d, 7, dt)) sat
FROM
    (SELECT TO_DATE(:yyyymm, 'YYYYMM') + (LEVEL-1) dt, 
            TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (LEVEL-1), 'D') d,
            TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (LEVEL), 'IW') iw  -- d보다 +1의 날짜의 요일을 가져온다
    FROM dual
    CONNECT BY LEVEL <= TO_CHAR(LAST_DAY( TO_DATE(:yyyymm, 'YYYYMM')), 'DD'))
GROUP BY dt - (d-1)
ORDER BY dt - (d-1);

-- 요일을 기준으로 설정. 토요일이나 일요일방식으로
SELECT /*일요일이면 날짜, 화요일이면 날짜, 수요일이면 날짜....... 토요일이면 날짜*/
        /*dt, d,*/ /*iw,*/
        MAX(DECODE(d, 1, dt)) s, MAX(DECODE(d, 2, dt)) m, MAX(DECODE(d, 3, dt)) t,
        MAX(DECODE(d, 4, dt)) w, MAX(DECODE(d, 5, dt)) th, MAX(DECODE(d, 6, dt)) f,
        MAX(DECODE(d, 7, dt)) sat
FROM
    (SELECT TO_DATE(:yyyymm, 'YYYYMM') + (LEVEL-1) dt, 
            TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (LEVEL-1), 'D') d,
            TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (LEVEL), 'IW') iw  -- d보다 +1의 날짜의 요일을 가져온다
    FROM dual
    CONNECT BY LEVEL <= TO_CHAR(LAST_DAY( TO_DATE(:yyyymm, 'YYYYMM')), 'DD'))
GROUP BY iw
ORDER BY sat;

-------------------------------------------------------------------------------------------------------------------------------
-- 과제

    -- 월 (1),   토 (7)
SELECT ldt - fdt + 1
FROM
(SELECT LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')) dt
       , LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')) + 
         7 - TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 'D') AS ldt --마지막 날짜
       , TO_DATE(:yyyymm, 'YYYYMM') -
       (TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM'), 'D') - 1 )  AS fdt 
FROM dual);
                                -----------------------------------------------------

-- 2019 10 기준 : 35,  첫주의 일요일 : 2019 09 29, 마지막 주 토요일 : 2019 11 02
-- 교수님 방식
SELECT 
        MAX(DECODE(d, 1, dt)) s, MAX(DECODE(d, 2, dt)) m, MAX(DECODE(d, 3, dt)) t,
        MAX(DECODE(d, 4, dt)) w, MAX(DECODE(d, 5, dt)) th, MAX(DECODE(d, 6, dt)) f,
        MAX(DECODE(d, 7, dt)) sat
FROM
    (SELECT TO_DATE(:yyyymm, 'YYYYMM') - (TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM'), 'D') - 1 ) + (LEVEL-1) dt -- 해당주의 일요일에 + (LEVEL-1)
            ,TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') - (TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM'), 'D') - 1 ) + (LEVEL-1), 'D') d
--            ,TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') - (TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM'), 'D') - 1 ) + (LEVEL), 'IW') iw  -- d보다 +1의 날짜의 요일을 가져온다
    FROM dual
    CONNECT BY LEVEL <= (SELECT ldt - fdt + 1
                         FROM (SELECT LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')) dt
                                   , LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')) + 
                                     7 - TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 'D') AS ldt --마지막 날짜
                                   , TO_DATE(:yyyymm, 'YYYYMM') -
                                   (TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM'), 'D') - 1 )  AS fdt 
                               FROM dual))
                        )
GROUP BY dt - (d-1)
ORDER BY dt - (d-1);


-- 다른사람이 한것
SELECT
    MAX(NVL(DECODE(d, 1, dt), dt - d + 1)) 일, 
    MAX(NVL(DECODE(d, 2, dt), dt - d + 2)) 월,
    MAX(NVL(DECODE(d, 3, dt), dt - d + 3)) 화,
    MAX(NVL(DECODE(d, 4, dt), dt - d + 4)) 수, 
    MAX(NVL(DECODE(d, 5, dt), dt - d + 5)) 목, 
    MAX(NVL(DECODE(d, 6, dt), dt - d + 6)) 금, 
    MAX(NVL(DECODE(d, 7, dt), dt - d + 7)) 토
FROM
    (SELECT 
            TO_DATE(:yyyymm, 'YYYYMM') + (LEVEL - 1) dt,
            TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (LEVEL - 1), 'D') d,
            TO_CHAR(TO_DATE(:yyyymm, 'YYYYMM') + (LEVEL), 'IW') iw
    FROM dual
    CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 'DD'))
    GROUP BY dt - (d - 1)
    ORDER BY dt - (d - 1);
-------------------------------------------------------------------------------------------------------------------------------

SELECT *
FROM sales;

SELECT  TO_CHAR(DT, 'MM') AS m, sum(sales) AS sales_sum
FROM sales
GROUP BY TO_CHAR(DT, 'MM');

SELECT
        NVL(MIN(DECODE(m, 01, sales_sum)),0) AS MONTH_1,
        NVL(MIN(DECODE(m, 02, sales_sum)),0) AS MONTH_2,
        NVL(MIN(DECODE(m, 03, sales_sum)),0) AS MONTH_3,
        NVL(MIN(DECODE(m, 04, sales_sum)),0) AS MONTH_4,
        NVL(MIN(DECODE(m, 05, sales_sum)),0) AS MONTH_5,
        NVL(MIN(DECODE(m, 06, sales_sum)),0) AS MONTH_6
FROM (
        SELECT  TO_CHAR(DT, 'MM') AS m, sum(sales) AS sales_sum
        FROM sales
        GROUP BY TO_CHAR(DT, 'MM')
     ) ;




























