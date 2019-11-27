--ADD_MONTHS, NEXT_DAY, LAST_DAY

SELECT sysdate, LAST_DAY(SYSDATE)
FROM dual;

SELECT  :yyyymm param,
        TO_CHAR(LAST_DAY(TO_DATE(:yyyymm, 'YYYYMM')), 'DD') AS DT
FROM dual;

SELECT 
        TO_DATE(TO_CHAR(sysdate, 'YYYY/MM/DD'), 'YYYY/MM/DD')
        ,TO_CHAR(sysdate, 'YYYY-MM-DD HH24:MI:SS')
FROM dual;


---------------묵시적 형변환 (이 생성되지 않도록 짜는 쿼리가 좋음) -----------------
SELECT *
FROM emp
WHERE empno = '7369';

SELECT *
FROM emp
WHERE TO_CHAR(empno) = '7369';

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = 7300 + '69';


SELECT * 
FROM TABLE(DBMS_XPLAN.DISPLAY);


SELECT *
FROM emp
WHERE hiredate >= TO_DATE('81/06/01', 'RR/MM/DD');

-- YY -> 2000년도를 잡음
-- RR --> 50 / 19, 20 1900년도와 2000년도 구분
SELECT 
        TO_DATE('50/05/05', 'RR/MM/DD')
        ,TO_DATE('49/05/05', 'RR/MM/DD')
        ,TO_DATE('50/05/05', 'YY/MM/DD')
        ,TO_DATE('49/05/05', 'YY/MM/DD')
FROM dual;

--국제화라는것이 있다.
-- 숫자 -> 문자, 문자 -> 숫자
-- 1000000 --> 1,000,000.00 (한국)
-- 1000000 --> 1.000.000,00 (독일)
-- 숫자 포맷 --> 숫자표현 : 0, 자리맞춤을 위한 0표시 : 0, 화폐단위 : L, 1000자리구분 : , 소숫점 : .
-- 숫자 포맷이 길어질경우 숫자 자리수를 충분히 표현
SELECT empno, ename, sal, TO_CHAR(sal, 'L009,999') fm_sal
FROM emp;

SELECT TO_CHAR(10000000000000, '999,999,999,999,999,999')
FROM dual;


-- NULL 처리 함수 : NVL, NVL2, NULLIF, COALESCE

-- NVL(expr1, expr2) : 함수 인자 두개
-- expr1이 NULL이면 expr2를 반환
-- expr1이 NULL이 아니면 expr1를 반환

SELECT empno, ename, comm, NVL(comm, -1) AS nvl_comm
FROM emp;

-- NVL2(expr1, expr2, expr3)
-- expr1 IS NOT NULL 이면 expr2 리턴
-- expr2 IS NULL 이면 expr3 리턴
SELECT empno, ename, comm, NVL2(comm, 1000, -500) AS nvl2_comm
        , NVL2(comm, comm, -500) AS nvl_comm -- NVL과 동일한 결과
FROM emp;

-- NULLIF(expr1, expr2)
-- expr1 = expr2 이면 NULL리턴
-- expr1 != expr2 이면 expr1을 리턴
SELECT empno, ename, comm, NULLIF(comm, 0) AS NULLIF_comm
FROM emp;

-- COALESCE(expr1, expr2, expr3 .........)
-- 인자중에 첫번째로 등장하는 NULL이 아닌 exprN을 리턴
-- expr1 IS NOT NULL 이면 expr1을 리턴
-- expr1 IS NULL COALESCE(expr1, expr2, expr3 .........)
SELECT empno, ename, comm, sal, COALESCE(comm, sal) AS coal_sal
FROM emp;


--실습 : emp테이블의 정보를 다음과 같이 조회되도록 쿼리를 작성하세요 (nvl, nvl2, coalesce)
SELECT empno, ename, mgr
        ,NVL(mgr, 9999) AS MGR_N
        ,NVL2(mgr, mgr, 9999) AS MGR_N1
        ,COALESCE(mgr, 9999) MGR_N2
FROM emp;

SELECT userid, usernm, reg_dt, NVL(reg_dt, sysdate)
FROM users
WHERE userid != 'brown';

--Condition
--  CASE
--      WHEN expr1 THEN return1
--      WHEN expr2 THEN return2
--      ELSE return3
--  END
SELECT empno, ename, job, sal
        ,CASE
            WHEN job = 'SALESMAN' THEN sal * 1.05
            WHEN job = 'MANAGER' THEN sal * 1.10
            WHEN job = 'MANAGER' THEN sal * 1.20
            ELSE sal
        END bonus
FROM emp
ORDER BY job;

-- NULL처리 함수를 사용하지 않고, case절을 이용하여 comm이 null일 경우 -10을 리턴
SELECT empno, ename, sal, comm
        ,CASE 
           WHEN comm IS NULL THEN -10
           ELSE comm
         END comm_case
FROM emp;


--Decode
-- DECODE (col, expr1, return1,
--             expr2, return2,
--             expr3, return3,
--                .....
--             return_N
--        )
SELECT empno, ename, sal
        ,DECODE(job, 'SALESMAN',  sal * 1.05,
                     'MANGER',    sal * 1.10,
                     'PRESIDENT', sal * 1.20,
                                  sal 
        ) AS sal_decode
FROM emp;
        


--------실습 : emp테이블을 이용하여 deptno에 따라 부서명으로 변경해서 다음과 같이 조회되는 쿼리를 작성하세요
SELECT empno, ename
        , CASE
            WHEN deptno = 10 THEN 'ACCOUNTING'
            WHEN deptno = 20 THEN 'RESEARCH'
            WHEN deptno = 30 THEN 'SALES'
            WHEN deptno = 40 THEN 'OPERATIONS'
            ELSE 'DDIT'
          END  
FROM emp;
SELECT empno, ename
        ,DECODE(deptno, 10, 'ACCOUNTING',
                        20, 'RESEARCH',
                        30, 'SALES',
                        40, 'OPERATIONS',
                        'DDIT'
        ) AS bouns
FROM emp;

--------실습 : emp테이블을 이용하여 hiredate에 따라 올해 건강보험 검진대상자인지 조회하는 쿼리를 작성하세요. 
--            (생년을 기준으로 하나 여기서는 입사년도를 기준으로)
SELECT empno, ename, hiredate
        ,CASE 
                WHEN MOD(TO_CHAR(hiredate, 'RR'), 2)
                     = MOD(TO_CHAR(sysdate, 'RR'), 2)
                THEN '건강검진 대상자'
                ELSE '건강검진 비대상자'
        END CONTACT_TO_DOCTOR
FROM emp;

SELECT empno, ename, hiredate
        ,DECODE(MOD(TO_CHAR(hiredate, 'RR'), 2), MOD(TO_CHAR(sysdate, 'RR'), 2), '건강검진 대상자', '건강검진 비대상자'
        ) AS CONTACT_TO_DOCTOR
FROM emp;

-- 2020년도 대상자
SELECT empno, ename, hiredate
        ,CASE 
                WHEN MOD(TO_CHAR(hiredate, 'YYYY'), 2)
                     = MOD(TO_CHAR(sysdate, 'YYYY')+1, 2) -- MOD(2020, 2)
                THEN '건강검진 대상자'
                ELSE '건강검진 비대상자'
        END CONTACT_TO_DOCTOR
FROM emp;

--실습 3

SELECT userid, usernm, alias, reg_dt
        ,CASE
                WHEN MOD(TO_CHAR(reg_dt, 'YYYY'), 2) 
                     = MOD(TO_CHAR(sysdate, 'YYYY'), 2)
                THEN '건강검진 대상자'
                ELSE '건강검진 비대상자'
        END CONTACT_TO_DOCTOR
FROM users;

SELECT userid, usernm, alias, reg_dt
        ,DECODE( MOD(TO_CHAR(reg_dt, 'YYYY'),2), MOD(TO_CHAR(sysdate, 'YYYY'),2), '건강검진 대상자', '건강검진 비대상자'
        ) AS CONTACT_TO_DOCTOR
FROM users;

SELECT a.userid, a.usernm, a.alias
        ,DECODE( MOD(a.year, 2), MOD(a.year_s, 2), '건강검진 대상자' , '건강검진 비대상자')
FROM
    (
    SELECT userid, usernm, alias, TO_CHAR(reg_dt, 'YYYY') AS year, TO_CHAR(sysdate, 'YYYY') AS year_s
    FROM users
    ) a;








