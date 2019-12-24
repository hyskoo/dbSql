-------- Hash JOIN -------------------------------------------------------------------------------------------------------------
SELECT /*+USE_HASH(e d)*/ * 
FROM dept d,emp e 
WHERE e.deptno=d.deptno;

-- dept 먼저 읽는 형태
-- join 컬럼을 hash 함수로 돌려서 해당 해시 함수에 해당하는 bucket에 데이터를 넣는다
-- 10 ---> hashvalue  - aadwd

-- emp 테이블에 대해 위의 진행을 동일하게 진행
-- 10 ---> hashvalue  - aadwd  위와 아래가 같은 해시값을 가지므로 같은 위치에 있다.

-- SELECT /*+인덱스명||힌트명*/*FROM 테이블명;

-------- Hash JOIN  END --------------------------------------------------------------------------------------------------------



-- 사원번호, 사원이름, 부서번호, 급여, 부서원의 전체급여합
SELECT empno, ename, deptno, sal
    ,SUM(sal) OVER(ORDER BY sal 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS C_sum -- 가장 처음부터 현재행까지
      -- BETWEEN 범위가 정해지지않은 선행 컬럼행 AND 현재 자기 행
      
      -- 바로 이전행이랑 현재행까지의 급여합
    ,SUM(sal) OVER(ORDER BY sal ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS c_sum2
FROM emp
ORDER BY sal;


-- 부서별로 급여, 사원번호를 오름차순으로 정렬했을때 자신의 그병와 선행하는 사원들의 급여합을 조회
SELECT empno, ename, deptno, sal
    ,SUM(sal) OVER(PARTITION BY deptno ORDER BY sal,empno ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS c_sum
FROM emp;

-------------------------------------------------------------------------------------------------------------------------------
/*                                            ROWS vs RANGE 차이 확인하기                                                       */
--                             Range는 동일한 값이 나오면 둘을 하나로본다.  [ 이해가 재대로 안되면 쓰지말것 ] 
--              ORDER BY 절뒤에 Windowing을 적용하지 않았으면  RANGE BETWEEN UNBOUNDED PRECEDING을 자동으로 추가해준다.
SELECT empno, ename, deptno, sal
    ,SUM(sal) OVER(ORDER BY sal ROWS UNBOUNDED PRECEDING) AS row_sum
    ,SUM(sal) OVER(ORDER BY sal RANGE UNBOUNDED PRECEDING) AS range_sum
    ,SUM(sal) OVER(ORDER BY sal ) AS c_sum
FROM emp;
    
--------------------------------------------------------------------------------------------------------------------------------





--------------------------------------------------   PL/SQL   ------------------------------------------------------------------
/*
    PL/SQL 기본구조
    - DECLARE : 선언부, 변수를 선언하는 부분
    - BEGIN : PL/SQL의 로직이 들어가는 부분
    - EXCEPTION : 예외처리부분
*/
DESC dept;

SET SERVEROUTPUT ON; -- DBMS_OUTPUT.PUT_LINE 함수가 출력하는 결과를 화면에 보여주도록 활성화
DECLARE -- 선언부
    -- java   : 타입  변수명;
    -- pl/sql : 변수명  타입;
--    v_dname VARCHAR2(14);
--    v_loc VARCHAR2 (13);

    -- 테이블 컬럼의 정의를 참조하여 데이터 타입을 선언한다.
    v_dname dept.dname%TYPE;
    v_loc dept.loc%TYPE;
BEGIN
    -- deptno 테이블에서 10번 부서의 부서이름, LOC 정보 조회
    SELECT dname, loc
    INTO v_dname, v_loc   -- INTO 변수1, 변수2
    FROM dept
    WHERE deptno = 10;
    
    DBMS_OUTPUT.PUT_LINE(v_dname || v_loc);
END;
/
-- END 뒤의 [ / ]는 DECLARE ~ END까지의 PL/SQL의 Block을 실행하라는 의미


-- PL/SQL  블록유형
-- 1. Procedure
-- 2. Function

-- 10번부서의 부서이름, 위치지역을 조회해서 변수에 담고 변수를 DBMS_OUTPUT.PUT_LINE함수를 이용하여 console에 출력
CREATE OR REPLACE PROCEDURE printdept 
-- 파라미터명 IN / OUT TYPE
-- p_ 를 접두어로 주어 인자라는것을 알려주는방식을 많이쓴다.
( p_deptno IN dept.deptno%TYPE )
IS

-- 선언부(옵션)

    dname dept.dname%TYPE;
    loc dept.loc%TYPE;
-- 실행부
    
    BEGIN
        SELECT dname, loc
        INTO dname, loc
        FROM dept
        WHERE deptno = p_deptno;

-- console 출력
    DBMS_OUTPUT.PUT_LINE(dname || ' ' || loc);
-- 예외처리 (옵션)
END;
/

exec printdept(30);



-- 실습 1. PROCEDURE

CREATE OR REPLACE PROCEDURE printemp 
( p_empno IN emp.empno%TYPE )
IS
    v_ename emp.ename%TYPE;
    v_dname dept.dname%TYPE;
    BEGIN
        SELECT ename, dname
        INTO v_ename, v_dname
        FROM emp, dept
        WHERE emp.deptno = dept.deptno
        AND empno = p_empno;
    
    DBMS_OUTPUT.PUT_LINE(v_ename || ' ' || v_dname);
END;
/

exec printemp(7369);




-- 실습2. 
CREATE OR REPLACE PROCEDURE registdept_test
( p_deptno IN dept.deptno%TYPE
  ,p_dname IN dept.dname%TYPE
  ,p_loc IN dept.loc%TYPE  )
IS
    v_deptno dept.deptno%TYPE;
    v_dname dept.dname%TYPE;
    v_loc dept.loc%TYPE;
    BEGIN
        INSERT INTO dept_test
        VALUES (p_deptno, p_dname, p_loc);
        COMMIT;
    DBMS_OUTPUT.PUT_LINE(v_deptno || ' ' || v_dname || ' ' || v_loc);
END;
/


exec registdept_test(99, 'ddit', 'daejeon');






