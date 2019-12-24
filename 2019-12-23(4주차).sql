CREATE OR REPLACE PROCEDURE UPDATEdept_test 
 (p_deptno IN dept.deptno%TYPE
 ,p_dname IN dept.dname%TYPE
 ,p_loc IN dept.loc%TYPE)
IS
    v_deptno dept.deptno%TYPE;
    v_dname dept.dname%TYPE;
    v_loc dept.loc%TYPE;
    BEGIN
        UPDATE dept_test
        SET deptno = p_deptno, dname = p_dname, loc = p_loc
        WHERE deptno = p_deptno;
        
        commit;
        
        DBMS_OUTPUT.PUT_LINE(v_deptno || ' ' || v_dname || ' ' || v_loc);
END;
/
        
exec UPDATEdept_test(99, 'ddit_m', 'daejeon_m');

SELECT * FROM dept_test;





-- ROWTYPE
-- 특정 테이블의 ROW 정보를 담을 수 있는 참조 타입
-- TYPE : 테이블명.테이블컬럼명%TYPE   --> 컬럼타입
-- ROWTYPE : 테이블명%ROWTYPE       --> 로우타입

SET SERVEROUTPUT ON;
DECLARE
    -- dept 테이블의 row 정보를 담을 수 있는 rowytpe 변수 선언
    dept_row dept%ROWTYPE;
BEGIN
    SELECT *
    INTO dept_row
    FROM dept
    WHERE deptno = 10;
    
    DBMS_OUTPUT.PUT_LINE(dept_row.dname || ',' || dept_row.loc);
END;
/


-- RECORD TYPE : 개발자가 컬럼을 직접 선언하여 개발에 필요한 TYPE을 생성
/* TYPE 타입이름 IS RECORD(
        컬럼1 컬럼1TYPE
        ,컬럼2 컬럼2TYPE
   );
*/    

/*  위의 PL/SQL은 클래스와 매우 비슷하다
    public class 클래스명(
        필드Type 필드(컬럼);      //String name;
        필드2Type 필드(컬럼)2;    //int age;
    )
*/
DECLARE TYPE dept_row IS RECORD(
    dname dept.dname%TYPE,
    loc dept.loc%TYPE
    );
    -- type선언이 완료, type을 갖고 변수를 생성
    -- java : Class 생성후 해당 class의 인스턴스를 생성(new)와 비슷
    -- PL/SQL 변수 생성 : 변수 이름 변수타입 dept.dname%TYPE
    
    dept_row_data dept_row;

BEGIN
    SELECT dname, loc
    INTO dept_row_data
    FROM dept
    WHERE deptno = 10;
    
    DBMS_OUTPUT.put_line(dept_row_data.dname || ',' || dept_row_data.loc);
END;
/


------------------- TABLE TYPE : 여러개의 ROWTYPE을 저장할 수 있는 TYPE  ------------------------------
-- col --> row --> table
-- TYPE 테이블 타입명 IS TABLE OF ROWTYPE/RECORD INDEX BY 인덱스 타입 (BINARY_INTEGER)
-- java와 다르게 PL/SQL 에서는 array 역할을 하는 table type의 인덱스를 숫자 뿐만 아니라, 문자열 형태도 가능하다.
-- 그렇기 때문에 index에 대한 타입을 명시한다. 일반적으로 array(list)
-- arr(1).name = 'brown'
-- arr('person').name = 'brown'

-- dept 테이블의 row를 여러건 저장할 수 있는 dept_tab TABLE TYPE 을 선언하여 SELECL * FROM dept;의 결과(다수)를 변수에 담는다
DECLARE
    TYPE dept_tab IS TABLE OF dept%ROWTYPE INDEX BY BINARY_INTEGER;
    v_dept dept_tab;
BEGIN
    -- 한 ROW의 값을 변수에 저장 : INTO
    -- 복수 ROW의 값을 변수에 저장 : BULK COLLECT INTO
    SELECT *
    BULK COLLECT INTO v_dept
    FROM dept;
    
    -- CORSOR
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT); 

    FOR i IN 1..v_dept.count LOOP 
        DBMS_OUTPUT.PUT_LINE(v_dept(i).dname || ',' || v_dept(i).loc);
    END LOOP;        
    
END;
/


-- 로직 제어 IF
/*  
    IF condition THEN
        statement
    ELSIF coundition THEN
        statement
    ELSE
        statement
    END IF;     
*/


-- PL/SQL IF 실습
-- 변수 p (NUMBER) 에 2라는 값을 할당하고 IF 구문을 통해 p의 값이 1,2, else 값일때 텍스트 출력

DECLARE
    p NUMBER := 2;
BEGIN
    IF p = 1 THEN
        DBMS_OUTPUT.PUT_LINE('p=1');
    ELSIF p = 2 THEN             -- > 잘보면 ELSE IF가 아닌 ELSIF로 E가 빠지고 한문자가 되었다.
        DBMS_OUTPUT.PUT_LINE('p=2');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('p=3');
    END IF;
END;
/




-- FOR LOOP
/*
    FOR 인덱스 변수 IN (REVERSE) START..END LOOP
          반복실행문
    END LOOP;
*/    
-- 0 ~ 5까지 루프 변수를 이용하여 반복문 실행
DECLARE
BEGIN
    FOR i IN 0..5 LOOP
        DBMS_OUTPUT.PUT_LINE(i);
    END LOOP;
END;
/


-- 1 - 10 까지의 합을 LOOP를 활용하여 s_val이라는 변수에 담아 화면 출력
DECLARE
    s_val NUMBER := 0;
BEGIN
    FOR i IN 1..10 LOOP
        s_val := s_val + i;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE(s_val);
END;
/


/*  while LOOP
    
    WHILE condition LOOP
        statement
    END LOOP;
*/

DECLARE
    i NUMBER := 0;
BEGIN
    WHILE i<=5 LOOP
        DBMS_OUTPUT.PUT_LINE(i);
    END LOOP;
END;
/
/*  DO While의 개념

    LOOP 
      statement;
      EXIT [WHEN condition]
    END LOOP
*/

DECLARE
    i NUMBER := 0;
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE(i);
        i := i + 1;
        EXIT WHEN i >5;
    END LOOP;
END;
/

------- CURSOR    :     SQL에서 실행결과를 보내주기 위한 메모리 용량. 이것을 조절할 수 있다.
        -- SQL개발자가 제어할 수 있는 객체
        -- TABLE TYPE의 BULK COLLECT INTO를 사용하면 그만큼의 변수가 메모리에 올라가지만 CURSOR는 변수 몇개만 올라간다.
/*
    1.묵시적 Cursor : 개발자가 별도의 커서명을 기술하지 않은 형태, 
         - ORACLE에서 자동으로 OPEN, 실행, FETCH, CLOSE를 관리한다.
    2.명시적 Cursor : 개발자가 이름을 붙인 커서. 개발자가 직접 제어한다.
         - 산안, OPEN, FETCH, CLOSE 단계가 존재
         
--  CURSOR 커서이름 IS   --> 커서 선언
        QUERY;
    OPEN 커서이름;   --> 커서 OPEN
    FETCH 커서이름 INTO 변수1, 변수2...  --> 커서 FETCH(행 인출)
    CLOSE 커서이름;  --> 커서 CLOSE
*/

-- 부서테이블의 모든 행의 부서이름, 위치 지역 정보를 출력 (CURSOR)
DECLARE
    -- 커서 선언
    CURSOR dept_cursor IS
        SELECT dname, loc
        FROM dept;
    v_dname dept.dname%TYPE;
    v_loc dept.loc%TYPE;
BEGIN
    -- 커서 오픈
    OPEN dept_cursor;
    LOOP
        FETCH dept_cursor INTO v_dname, v_loc;
        -- 종료조건 : FETCH할 데이터가 없을 때 종료
        EXIT WHEN dept_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_dname || ',' || v_loc);
    END LOOP;
    CLOSE dept_cursor;
END;
/