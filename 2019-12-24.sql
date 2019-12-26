-- FOR LOOP에서 명시적 커서 사용하기
-- 부서테이블의 모든 행의 부서이름 위치 지역정보를 출력
SET SERVEROUTPUT ON;
DECLARE
    -- 커서 선언
    CURSOR dept_cursor IS
        SELECT dname, loc
        FROM dept;
    v_dname dept.dname%TYPE;
    v_loc dept.loc%TYPE;
BEGIN
    FOR record_row IN dept_cursor LOOP
        DBMS_OUTPUT.PUT_LINE(record_row.dname || ',' || record_row.loc);
    END LOOP;
END;
/

-- 커서에 인자가 들어가는 경우. : 커서이름( 인자(변수선언문) ) IS 
DECLARE
    -- 커서 선언
    CURSOR dept_cursor(p_deptno dept.deptno%TYPE) IS
        SELECT dname, loc
        FROM dept
        WHERE deptno = p_deptno;
    v_dname dept.dname%TYPE;
    v_loc dept.loc%TYPE;
BEGIN
    FOR record_row IN dept_cursor(10) LOOP
        DBMS_OUTPUT.PUT_LINE(record_row.dname || ',' || record_row.loc);
    END LOOP;
END;
/

-- FOR LOOP Inline Cursor
-- FOR LOOP 구문에서 커서를 직접선언
DECLARE
BEGIN
    FOR record_row IN (SELECT dname, loc FROM dept) LOOP
        DBMS_OUTPUT.PUT_LINE(record_row.dname || ',' || record_row.loc);
    END LOOP;
END;
/


-- 날짜의 차이 평균구하기
DECLARE
    TYPE dt_tab IS TABLE OF dt%ROWTYPE INDEX BY BINARY_INTEGER;
    v_dt dt_tab;
    sum_dt NUMBER := 0;
BEGIN
    -- 한 ROW의 값을 변수에 저장 : INTO
    -- 복수 ROW의 값을 변수에 저장 : BULK COLLECT INTO
    SELECT *
    BULK COLLECT INTO v_dt
    FROM dt
    ORDER by dt;
    
    -- CORSOR
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT); 

    FOR i IN 1..(v_dt.count-1) LOOP 
        sum_dt := sum_dt + (v_dt(i+1).dt - v_dt(i).dt);
    END LOOP;        
    DBMS_OUTPUT.PUT_LINE(sum_dt / (v_dt.count-1));
    
END;
/


-- 1.rownum사용시
-- 2.WINDOW 분석함수 사용시
-- 3.평균구하기
SELECT AVG(sum_avg)
FROM (SELECT LEAD(dt) OVER (ORDER BY dt) - dt AS sum_avg
      FROM dt);
-- 3.평균구하기
SELECT (MAX(dt) - MIN(dt)) / (COUNT(*)-1) avg_sum
FROM dt;

--------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE create_daily_sales
(p_yyyymm IN VARCHAR2) IS
    TYPE cal_row_type IS RECORD (
        dt VARCHAR2(8),
        day NUMBER);
    TYPE cal_tab IS TABLE OF cal_row_type INDEX BY BINARY_INTEGER;
    v_cal_tab cal_tab;
BEGIN
    -- 생성전 해당년월에 해당하는 일시적 데이터를 삭제한다
    DELETE daily
    WHERE dt LIKE p_yyyymm || '%';
    
    --달력정보를 table 변수에 저장한다.
    -- 반복적인 sql 실행을 방지하기 위해 한번만 실행해서 변수에 저장
    SELECT TO_CHAR(TO_DATE(p_yyyymm, 'YYYYMM') + (LEVEL-1), 'YYYYMMDD') dt,
           TO_CHAR(TO_DATE(p_yyyymm, 'YYYYMM') + (LEVEL-1), 'D') day
    BULK COLLECT INTO v_cal_tab
    FROM dual
    CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(p_yyyymm, 'YYYYMM')), 'DD');
    
    -- 애음주기 정보를 읽는다
    FOR daily IN (SELECT * FROM cycle) LOOP
        -- 12월 일자 달력 : cycle row건수 만큼 반복
        FOR i IN 1..v_cal_tab.count LOOP
            IF daily.day = v_cal_tab(i).day THEN
                -- cid, pid, 일자, 수량
                INSERT INTO daily 
                VALUES( daily.cid, daily.pid, v_cal_tab(i).dt, daily.cnt );
            END IF;    
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(daily.cid || ',' || daily.day);
    END LOOP;
    
    COMMIT;
END;
/

exec create_daily_sales('201912');



-- 위의것은 건수가 많아지면 시간이 기하급수적으로 올라가므로 아래와 같은 방식으로 처리해보자
SELECT cycle.cid, cycle.pid, cal.dt, cycle.cnt
FROM cycle, 
(SELECT TO_CHAR(TO_DATE(:p_yyyymm, 'YYYYMM') + (LEVEL-1), 'YYYYMMDD') dt,
        TO_CHAR(TO_DATE(:p_yyyymm, 'YYYYMM') + (LEVEL-1), 'D') day
    FROM dual
    CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:p_yyyymm, 'YYYYMM')), 'DD')) cal
WHERE cycle.day = cal.day;
