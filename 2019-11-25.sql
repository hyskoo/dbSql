SELECT ROWNUM, empno, ename
FROM emp
WHERE ROWNUM BETWEEN 1 AND 10;

----------- 정렬된값의 ROWNUM뽑기-------------
SELECT ROWNUM, a.*
FROM
    (
    SELECT ROWNUM rn, empno, ename
    FROM emp
    ) a
WHERE rn BETWEEN 11 AND 20;

SELECT *
FROM
    (
    SELECT ROWNUM AS rn, a.*
    FROM
        (
        SELECT empno, ename
        FROM emp
        ORDER BY ename
        ) a
    )
WHERE rn BETWEEN 11 AND 20;
---------------------------------------------

----------------------------  Function  ------------------------------
--DUAL 테이블 : sys 계정에 있는 누구나 사용가능한 테이블이며, 데이터는 한행만 존재하며 컬럼(dumy)도 하나만 존재
SELECT *
FROM dual;

-- SINGLE ROW FUNCTION : 행당 한번의 FUNCTION이 실행
-- 1개의 행 INPUT -> 1개의 행으로 OUTPUT (COLUMN))

-- 'HeLlo, WoRld'
-- 행이 1줄 - > 1개의 행
SELECT  LOWER('Hello, World') 소문자,
        UPPER('Hello, World') 대문자,
        INITCAP('Hello, World') 앞글자만대문자
FROM dual;

-- 행이 14줄 -> 14개의 행
SELECT  emp.*,
        LOWER('Hello, World') 소문자,
        UPPER('Hello, World') 대문자,
        INITCAP('Hello, World') 앞글자만대문자
FROM emp;

SELECT empno, LOWER(ename) low_ename
FROM emp
WHERE ename = 'SMITH'; --원본 데이터는 변함이 없으므로 대문자로 가져와야한다

SELECT empno, LOWER(ename) low_ename
FROM emp
WHERE ename = UPPER('smith');

------- 테이블 컬럼을 가공하지마라.  ----------
-- 가공해도 결과값은 같지만 속도면에서 상수쪽 가공이 속도면에서 유리.
-- 해당 컬럼에 인덱스가 존재하더라도 함수를 적용하게되면 값이 달라지게되어 인덱스를 활용 할 수 없게된다.
-- 예외 : FBI (Function Based Index)
SELECT empno, LOWER(ename) low_ename
FROM emp
WHERE LOWER(ename) = 'smith';
-----------------------------------------


SELECT  CONCAT('HELLO', CONCAT(', ', 'WORLD')) concat,
        'HELLO' || ', ' || 'WORLD' concat2,
        SUBSTR('HELLO, WORLD', 6, 7) substr,  --SUBSTR(문자열, 시작인덱스, 종료인덱스(갯수)) , 시작인덱스는 1부터, 종료인덱스 문자열까지 포함
        INSTR('HELLO, WORLD','O') instr1, -- 문자열에 특정 문자열이 존재하는지, 존재할 경우 문자의 인덱스를 리턴
        INSTR('HELLO, WORLD','O', 6) instr2,  --뒤의 숫자는 검색을 시작하는 인덱스의 시작위치
        INSTR('HELLO, WORLD','O', INSTRB('HELLO, WORLD','O') + 1 ) instr3,
        
        --L/RPAD 특정 문자열의 왼쪽/오른족에 설정한 문자열 길이보다 부족한 만큼 문자열을 채워넣는다.
        LPAD('HELLO, WORLD', 15, '*') lpad, -- PAD('문자열', '문자열의 길이', '부족한 문자열의 갯수만큼 채워넣을 문자열')
        LPAD('HELLO, WORLD', 15) lpad2,
        RPAD('HELLO, WORLD', 15, '*') Rpad,
        
        --REPLACE(대상문자열, 검색 문자열, 변경할문자열) : 대상문자열에서 검색 문자열을 변경할 문자열로 치환
        REPLACE('HELLO, WORLD', 'HELLO', 'hello') replace,
        
        --문자열 앞뒤의 공백 제거
        '   HELLO, WORLD   ' before_trim,
        TRIM ('   HELLO, WORLD   ') after_trim1,
        TRIM ('H' FROM 'HELLO, WORLD') after_trim2  --공백 + 특정 문자열을 앞뒤로 제거
        
FROM dual;


------------숫자 조작 Function -------------
--ROUND : 반올림  -- ROUND(숫자, 반올림 자리)
--TRUNC : 내림    -- TRUNC (숫자, 내림 자리)
--MOD : 나머지 연산 -- MOD (피제제수, 제수)

SELECT  
        ROUND(105.54, 1) r1,   -- 반올림 결과가 소숫점 1자리까지
        ROUND(105.55, 1) r2,
        ROUND(105.55, 0) r3,   -- 반올림 결과가 소숫점 0자리(즉, 정수 1번자리), 소숫점 1번째 자리에서 반올림
        ROUND(105.55, -1) r4   -- 정수 첫번째 자리에서 반올림
FROM dual;

SELECT  
        TRUNC(105.54, 1) t1,  -- 내림 결과가 소숫점 1자리까지
        TRUNC(105.55, 1) t2,
        TRUNC(105.55, 0) t3,  -- 내림 결과가 소숫점 0자리(즉, 정수 1번자리), 소숫점 1번째 자리에서 내림
        TRUNC(105.55, -1) t4  -- 정수 첫번째 자리에서 내림
FROM dual;

-- MOD (피제수, 제수) : 피제수를 제수로 나눈 나머지 값
-- MOD (M, 2) 의 결과 종류 : 0, 1 (0 ~ 제수 -1)
SELECT MOD(5, 2) M1 -- 5 % 2 = 1
FROM dual;


--emp 테이블의 sal 컬럼을 1000으로 나눴을때 사원별 나머지 값을 조회 하는 sql작성
SELECT ename, sal, TRUNC(sal/1000) ,MOD(sal, 1000), (sal - MOD(sal, 1000)) / 1000 AS 목
FROM emp;


-- DATE : 년월일, 시간, 분, 초--
SELECT ename, to_char(hiredate, 'YYYY-MM-DD hh24:mi:ss'), to_char(sysdate, 'YYYY-MM-DD hh24:mi:ss')
FROM emp;

-- DATE 연산 DATE + 정수N = DATE에 N일자 만큼 더한다
-- N/24 = N시간만큼 DATE에 더한다
SELECT 
        to_char(sysdate + 5, 'YYYY-MM-DD hh24:mi:ss'),
        to_char(sysdate + 5/24, 'YYYY-MM-DD hh24:mi:ss'),
        to_char(sysdate + 5/24/60, 'YYYY-MM-DD hh24:mi:ss'),
        to_char(sysdate + 5/24/60/60, 'YYYY-MM-DD hh24:mi:ss')
FROM dual;


--실습

SELECT 
        TO_CHAR(TO_DATE('2019/12/31', 'YYYY/MM/DD'), 'YYYY/MM/DD') LAST_DAY,
        TO_CHAR(TO_DATE('2019/12/31', 'YYYY/MM/DD') -5, 'YYYY/MM/DD') LAST_DAY_BEFORE5,
        sysdate NOW,
        sysdate - 3 NOW_BEFORE3
FROM DUAL;


---- YYYY, MM, DD, D(요일을 숫자로 : 일요일1, 월요일2, 화요일3, ... 토요일 : 7)
---- IW (주차 1~53), HH, MI, SS
SELECT  
         TO_CHAR(SYSDATE, 'YYYY') YYYY
        ,TO_CHAR(SYSDATE, 'MM') MM
        ,TO_CHAR(SYSDATE, 'DD') DD
        ,TO_CHAR(SYSDATE, 'D') D --현재 요일 (주간일자 1~7)
        ,TO_CHAR(SYSDATE, 'IW') IW --현재 일자의 주차 (해당주의 목요일을 주차의 기준으로)
        -- 2019년 12월 31일은 몇주차인가?
        ,TO_CHAR(TO_DATE('20191231', 'YYYYMMDD'), 'IW') IW_20191231
FROM DUAL;

-- 실습
SELECT 
        TO_CHAR(sysdate, 'YYYY-MM-DD')
        ,TO_CHAR(sysdate, 'YYYY-MM-DD hh24-mi-ss')
        ,TO_CHAR(sysdate, 'DD-MM-YYYY')
FROM dual;

----------- 날짜의 조작 ---------
-- ROUND, TRUNC
SELECT 
        TO_CHAR(SYSDATE, 'YYYY-MM-DD hh24:mi:ss') now        
        -- MM에서 반올림
        ,TO_CHAR(ROUND(SYSDATE, 'YYYY'), 'YYYY-MM-DD hh24:mi:ss') now_YYYY
        -- DD에서 반올림
        ,TO_CHAR(ROUND(SYSDATE, 'MM'), 'YYYY-MM-DD hh24:mi:ss') now_MM
        -- hh24에서 반올림
        ,TO_CHAR(ROUND(SYSDATE, 'DD'), 'YYYY-MM-DD hh24:mi:ss') now_DD
FROM dual;

SELECT 
        TO_CHAR(SYSDATE, 'YYYY-MM-DD hh24:mi:ss') now        
        -- MM에서 내림
        ,TO_CHAR(TRUNC(SYSDATE, 'YYYY'), 'YYYY-MM-DD hh24:mi:ss') now_YYYY
        -- DD에서 내림
        ,TO_CHAR(TRUNC(SYSDATE, 'MM'), 'YYYY-MM-DD hh24:mi:ss') now_MM
        -- hh24에서 내림
        ,TO_CHAR(TRUNC(SYSDATE, 'DD'), 'YYYY-MM-DD hh24:mi:ss') now_DD
FROM dual;


--------------- 날짜 조작 Function ------------------
-- MONTHS_BETWEEN(date1, date2) : date2와 date1 사이의 개월 수
-- ADD_MONTHS(date, 개월 수) : date에서 개월 수를 더하거나 뺀 날짜
-- NEXT_DAY(date, weekday(1-7)) : date이후 첫 번째 weekday 날짜
-- LAST_DAY (date) : date가 속한 월의 마지막 날짜

-- MONTHS_BETWEEN
SELECT MONTHS_BETWEEN ( TO_DATE('2019-11-25', 'YYYY-MM-DD'),
                        TO_DATE('2019-03-31', 'YYYY-MM-DD')) m_bet
    ,TO_DATE('2019-11-25', 'YYYY-MM-DD') -  TO_DATE('2019-03-31', 'YYYY-MM-DD') d_m -- 두 날짜 사이의 일자수
FROM dual;


-- ADD_MONTHS(date, number(+,-))
SELECT 
        ADD_MONTHS(TO_DATE('20191125', 'YYYYMMDD'), 5) NOW_AFTER5M
        ,ADD_MONTHS(TO_DATE('20191125', 'YYYYMMDD'), -5) NOW_BEFORE5M
FROM dual;

-- NEXT_DAY(date, weekday number(1-7))
SELECT NEXT_DAY(SYSDATE, 7) -- 오늘 날짜이후 등장하는첫번째 토요일의 날짜
FROM dual;