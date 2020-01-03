/*  Exception
        - 에러 발생시 프로그램을 종료시키지 않고, 해당 예외에 대해 다른 로직을 실행 시킬수 있게끔 처리한다.
    
    - 예외가 발생하였는데, 예외처리가 없는 경우 : PL/SQL 블록이 에러와 함께 종료된다.
        - 여러건의 SELECT 결과가 존재하는 상황에서 스칼라 변수에 값을 넣는 상황
*/

-- emp talbe에서 사원 이름을 조회
SET SERVEROUTPUT ON;
DECLARE
    -- 사원 이름을 저장할 수 있는 변수
    v_ename emp.ename%TYPE;
BEGIN
    -- 14건의 select 결과가 나오는 SQL --> 스칼라 변수에 저장이 불가능(에러발생)
    SELECT ename 
    INTO v_ename
    FROM emp;
    
EXCEPTION
--    WHEN TOO_MANY_ROWS THEN
--        dbms_output.put_line('여러건의 SELECT 결과가 존재');
    WHEN OTHERS THEN
        dbms_output.put_line('WHEN OTHERS');
END;
/
/*
    사용자 정의 예외
    - 오라클에서 사전에 정의한 예외 이외에도 개발자가 해당 사이트에서 비즈니스 로직으로 정의한 예외를 생성, 사용할 수 있다.
    - 예를 들어  SELECT 결과가 없는 상황에서 오라클은 NO_DATA_FOUND 예외를 던지면
                해당 예외를 잡아 NO_EMP라는 개발자가 정의한 예외로 재정의 하여 예외를 던질 수 있다.
*/

--
DECLARE
    -- emp 테이블 조회 결과가 없을때 사용할 사용자 정의 예외
    -- 예외명 EXCEPTION;
    no_emp EXCEPTION;
    v_ename emp.ename%TYPE;
BEGIN
    BEGIN
        -- NO_DATA_FOUND
        SELECT ename
        INTO v_ename
        FROM emp
        WHERE empno = 7000;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE no_emp;       -- java throw new NoEmpException()
    END;
EXCEPTION 
    WHEN no_emp THEN
        dbms_output.put_line('NO_EMP');
END;
/


--------------------------- FUNCTION ----------------------

-- 사번을 입력받아 해당 직원의 이름을 리턴하는 함수
-- getEmpName(7369) --> SMITH
CREATE OR REPLACE FUNCTION getEmpName(p_empno emp.empno%TYPE)
RETURN VARCHAR2 IS
-- 선언부
    v_ename emp.ename%TYPE;
BEGIN
    SELECT ename
    INTO v_ename
    FROM emp
    WHERE empno = p_empno;
    
    RETURN v_ename;
END;
/

SELECT getEmpName(7369)
FROM dual;

SELECT getEmpName(empno)
FROM emp;

CREATE OR REPLACE FUNCTION getDeptName(p_deptno dept.deptno%TYPE)
RETURN VARCHAR2 IS
    v_dname dept.dname%TYPE;
BEGIN
    SELECT dname
    INTO v_dname
    FROM dept
    WHERE deptno = p_deptno;
    
    RETURN v_dname;
END;
/

/*
    cache : 20  -- 데이터의 종류가 저장되는곳으로 이곳에 데이터의 종류가 저장되고 그 값이 들어오면 데이터를 바로바로 반환한다.
 - 데이터 분포도 :
    deptno (중복 발생가능) : 분포도가 좋지 못하다   -- 이 경우 함수가 좋다. 
    empno(중복X) : 분포도가 좋다
    
    emp 테이블의 데이터가 100만건인 경우
    100만건 중에서 deptno의 종류는 4건 (10~40)
    
    즉, 데이터의 종류가 적은데 데이터의 갯수가 많으면 함수가 좋다. 대표적인 예시는 성별
*/
SELECT getDeptName(deptno),     -- 4가지
        getEmpName(empno)       -- row수만큼 데이터가 존재
FROM emp;



-- 실습 2  LPAD를 함수로바꾸기
SELECT deptcd, LPAD(' ',(LEVEL-1)*4, ' ') || deptnm AS deptnm
FROM dept_h
START WITH p_deptcd IS NULL
CONNECT BY PRIOR deptcd = p_deptcd;

CREATE OR REPLACE FUNCTION indent(p_lv NUMBER, p_deptnm VARCHAR2)
RETURN VARCHAR2 IS
    v_deptnm dept_h.deptnm%TYPE;
BEGIN
    SELECT LPAD(' ', (p_lv-1)*4 , ' ') || p_deptnm
    INTO v_deptnm
    FROM dual;
    
    RETURN v_deptnm;
    
    -- RETURN LPAD(' ', (p_lv-1)*4 , ' ') || p_deptnm; 도 가능
END;
/

SELECT deptcd, indent(LEVEL, deptnm) AS deptnm
FROM dept_h
START WITH p_deptcd IS NULL
CONNECT BY PRIOR deptcd = p_deptcd;    


-------------------------------------------- Trigger ------------------------------------------------------
SELECT * 
FROM users;

-- users 테이블의 비밀번호 컬럼이 변경이 생겼을 때
-- 기존에 사용하던 비밀번호 컬럼 이력을 관리하기 위한 테이블
CREATE TABLE users_history(
    user_id VARCHAR2(20),
    pass VARCHAR2(100),
    mod_dt DATE
);

CREATE OR REPLACE TRIGGER make_history
    -- timing
    BEFORE UPDATE ON USERS
    FOR EACH ROW -- 행트리거, 행의 변경이 있을 때 마다 실행한다.
    -- 현재 데이터 참조 : OLD
    -- 갱신 데이터 참조 : NEW
    BEGIN
        -- users 테이블의 pass 컬럼을 변경할 때 trigger 실행
        IF :OLD.pass != :NEW.pass THEN
            INSERT INTO users_history
                VALUES (:OLD.userid, :OLD.pass, sysdate);
        END IF;
    END;
/

-- users 테이블의 pass 컬럼을 변경 했을 때
-- trigger에 의해서 user_history테이블에 이력이 생성되는지 확인
UPDATE users set pass = '1234'
WHERE userid='brown';

select *
from users_history;
select * 
from users;
