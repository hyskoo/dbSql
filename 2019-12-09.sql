-- PARIMARY KEY 제약 : UNIQUE + NOT NULL

UNIQUE : 해당 컬럼에 동일한 값이 중복될 수 없다.
        (EX : emp테이블의 empno(사번)
            dept테이블의 deptno(부서번호)
            해당 컬럼에 NULL값은 들어갈 수 있다.
            
            
NOT NULL : 데이터 입력시 해당 컬럼에 값이 반드시 들어와야 한다.

--컬럼레벨의 PRIMARY KEY 제약 생성
--오라클의 제약조건 이름을 임의로 생성 (SYS-C00701)
CREATE TALBE dept_test(
    deptno NUMBER(2) PRIMARY KEY,)
    
-- 오라클 제약조건의 이름을 임의로 명명한다. CONSTRAINT 사용
CREATE TALBE dept_test(
    deptno NUMBER(2) CONSTRAINT pk_dept_test PRIMARY KEY,);
    
    

--PARIWISE : 쌍의 개념
--상단의 PRIMARY KEY 제약 조건의 경우 하나의 컬럼에 제약조건을 사용
-- 여러 컬럼을 복합으로 PRIMARY KEY 제약으로 생성 할 수 있다.
-- 해당 방법은 위의 두가지 예시처럼 컬럼 레벨에서는 생성 할 수 없다.
--> TALBE LEVEL 제약 조건 생성

-- 기존에 생성한 dept_test 테이블 삭제 (drop)

DROP TABLE dept_test;

CREATE TABLE dept_test (
    deptno NUMBER(2),
    dname VARCHAR2(14),
    loc VARCHAR2(13), --마지막 컬럼 선언후 콤마 빼먹지 않기
    
    --deptno, dname 컬럼이 같을때 동일한(중복된) 데이터로 인식
    CONSTRAINT pk_dept_test PRIMARY KEY (deptno, dname)
    );
    
-- 부서번호, 부서이름 순서쌍으로 중복 데이터를 검증
-- 아래 두개의 insert 구문은 부서번호는 같지만 부서이름이 다르므로
-- 부서명은 다르므로 서로 다른 데이터로 인식 --> insert 가능

INSERT INTO dept_test VALUES (99, 'ddit', 'daejeon');
INSERT INTO dept_test VALUES (99, '대덕', '대전');

-- 두번째 INSERT 쿼리와 키값이 중복되므로 에러
INSERT INTO dept_test VALUES (99, '대덕', '대전');

SELECT * FROM dept_test;


-- NOT NULL 제약조건
-- 해당 컬럼에 NULL값이 들어오는 것을 제한
-- 복합 컬럼과 거리가 멀다.

-- 컬럼이 아닌, 테이블 레벨의 제약조건 새엇ㅇ
-- dname 컬럼이 NULL 값이 들어오지 못하도록 NOT NULL 제약조건 생성
CREATE TABLE dept_test (
    deptno NUMBER(2) PRIMARY KEY,
    dname VARCHAR2(14) NOT NULL,
    loc VARCHAR2(13)
    );
    
-- deptno 컬럼이 primary key 제약에 걸리지 않고,
-- loc 컬럼은 nullable 이기 때문에 null 값이 입력될 수 있다.
INSERT INTO dept_test VALUES (99, 'ddit', NULL);

-- deptno 컬럼이 primary key 제약에 걸리지 않지만,
-- dname 컬럼의 NOT NULL 제약 조건을 위배
INSERT INTO dept_test VALUES (98, NULL, '대전');


-- 
DROP TABLE dept_test;
CREATE TABLE dept_test (
    deptno NUMBER(2) PRIMARY KEY,
    --deptno NUMBER(2) CONSTRAINT pk_dept_test PRIMARY KEY,
    dname VARCHAR2(14)
    --dname VARCHAR2(14) NOT NULL,
    --dname VARCHAR2(14) CONSTRAINT NN_dname NOT NULL,
    loc VARCHAR2(13)
    
--    CONSTRAINT pk_dept_test PRIMARY KEY (deptno, dname) : 허용 O
--    CONSTRAINT NN_dname NOT NULL (dname) : 허용 되지 않는다.
    );
    
    
------------------------------------------------------------------------------------------------------------------------

-- 1. 컬럼 레벨
-- 2. 컬럼레벨 제약조건 이름 붙이기
-- 3. 테이블 레벨
-- 4. 테이블 수정시 제약조건 적용

-- UNIQUE 제약 조건 : 해당컬럼에 값이 중복되는 것을 제한. 
-- 단, NULL은 허용된다,
-- GLOBAL solution의 경우 국가간 법적 적용 사항이 다르기 때문에 PK제약 보다는 UNIQUE제약을 사용하는 편이며,
-- 부족한 제약 조건은 APPLICATION 레벨에서 체크하도록 설계하는 경향이 있다.

------------------------------------------------------------------------------------------------------------------------

-- 컬럼 레벨 UNIQUE 제약 생성
-- dname 컬럼이 NULL 값이 들어오지 못하도록 NOT NULL 제약조건 생성
DROP TABLE dept_test;
CREATE TABLE dept_test (
    deptno NUMBER(2) PRIMARY KEY,
    dname VARCHAR2(14) CONSTRAINT IDX_U_dept_test_01 UNIQUE,
    loc VARCHAR2(13)
    );

-- 두개의 insert 구문을 통해 dname이 같은 값을 입력하기 때문에
-- dname 컬럼에 적용된 UNIQUE 제약에 의해 두번째 쿼리는 정상적으로 실행 될 수 없다.
INSERT INTO dept_test VALUES (99, 'ddit', 'daejeon');
INSERT INTO dept_test VALUES (98, 'ddit', '대전');


-- 테이블 레벨 UNIQUE 제약
DROP TABLE dept_test;
CREATE TABLE dept_test (
    deptno NUMBER(2) PRIMARY KEY,
    dname VARCHAR2(14),
    loc VARCHAR2(13),
    CONSTRAINT IDX_U_dept_test_01 UNIQUE (dname)
    );
    
    
-- Froeign key(외래키) : 다른 테이블에 존재하는 값만 입력될 수 있도록 제한

-- emp_test,deptno -> dept_test_deptno 컬럼을 참조하도록
-- dept_test 테이블 생성 (deptno 컬럼 primary key 제약 )
CREATE TABLE dept_test (
    deptno NUMBER(2) PRIMARY KEY,
    dname VARCHAR2(14),
    loc VARCHAR2(13)
    );

-- 컬럼 레벨 FOREIGN KEY
CREATE TABLE emp_test (
    empno NUMBER(4) PRIMARY KEY,
    ename VARCHAR2(14),
    deptno NUMBER(2) REFERENCES dept_test (deptno)
    );

INSERT INTO dept_test VALUES (99, 'ddit', 'daejeon');
-- dept_test에 존재하는 deptno로 값을 입력
INSERT INTO emp_test VALUES (9999, 'brown', 99);

-- dept_test에 존재하지 않는 deptno로 값을 입력
INSERT INTO emp_test VALUES (9998, 'sally', 98);

-- 테이블 삭제
DROP TABLE emp_test;
DROP TABLE dept_test;

-- 참조하는 dept테이블이 존재해야 한다
CREATE TABLE dept_test (
    deptno NUMBER(2) PRIMARY KEY,
    dname VARCHAR2(14),
    loc VARCHAR2(13)
    );
CREATE TABLE emp_test (
    empno NUMBER(4) PRIMARY KEY,
--     empno NUMBER(4) CONSTRAINT 제약조건 이름  PRIMARY KEY,
    ename VARCHAR2(14),
--    deptno NUMBER(2) REFERENCES dept_test (deptno)
    deptno NUMBER(2),
    
    CONSTRAINT FK_dept_test FOREIGN KEY (deptno)
    REFERENCES dept_test (deptno)
    );

-- 부서정보 삭제시
-- 지우려고하는 부서번호를 참조하는 직원정보를 삭제 또는 컬럼을 NULL 처리
-- emp 테이블에서 작업후 dept 테이블에서 작업을 한다.

-- 테이블 생성시 CASCADE 와 SET NULL
-- ON DELETE CASCADE
CREATE TABLE emp_test (
    empno NUMBER(4) PRIMARY KEY,
    ename VARCHAR2(14),
    deptno NUMBER(2),
    
    CONSTRAINT FK_dept_test FOREIGN KEY (deptno)
    REFERENCES dept_test (deptno) ON DELETE CASCADE
    );
    
INSERT INTO emp_test VALUES (9999, 'brown', 99);

--데이터 입력확인
SELECT * FROM emp_test;

-- ON DELETE CASCADE 옵션에 따라 DEPT 데이터를 삭제할 경우
-- 해당 데이터를 참조 하고 있는 EMP 테이블의 사원 데이터도 삭제된다.
DELETE FROM dept_test WHERE deptno = 99;


-- ON DELETE SET NULL
CREATE TABLE emp_test (
    empno NUMBER(4) PRIMARY KEY,
    ename VARCHAR2(14),
    deptno NUMBER(2),
    
    CONSTRAINT FK_dept_test FOREIGN KEY (deptno)
    REFERENCES dept_test (deptno) ON DELETE SET NULL
    );
    
INSERT INTO emp_test VALUES (9999, 'brown', 99);

--데이터 입력확인
SELECT * FROM emp_test;

-- ON DELETE CASCADE 옵션에 따라 DEPT 데이터를 삭제할 경우
-- 해당 데이터를 참조 하고 있는 EMP 테이블의 사원 데이터도 삭제된다.
DELETE FROM dept_test WHERE deptno = 99;

INSERT INTO dept_test VALUES (99, 'ddit', 'daejeon');


--------------------------------------------------------------------------------------------------------------------------------

--CHECK 제약조건
-- 컬럼에 들어가는 값을 검증할 때
-- EX : 급여 컬럼에는 값이 0보다 큰 값만 들어가도록 체크
--      성별 컬럼에는 남/녀 혹은 F/M 값만 들어가도록 제한

-- emp_test테이블계열 삭제

--------------------------------------------------------------------------------------------------------------------------------
DROP TABLE emp_test;

-- emp_test 테이블 컬럼
-- empno NUMBER(4)
-- ename VARCHAR2(10)
-- sal NUMBER(7,2)
-- emp_gb VARCHAR2 (2) -- 직원 구분. 01- 정규직, 02- 인턴
CREATE TABLE emp_test(
    empno NUMBER(4) PRIMARY KEY,
    ename VARCHAR2(10),
    sal NUMBER(7,2) CHECK (sal > 0),
    emp_gb VARCHAR2(2) CHECK ( emp_gb IN ('01', '02') )
    );

--emp_test 데이터 입력
-- sal컬럼 check 제약조건 (sal > 0)에 의해서 음수값은 입력될수 없다.
INSERT INTO emp_test VALUES (9999, 'brown', -1, '01');

-- check 제약 조건 위배 하지 않으므로 정상 입력 (sal, emp_gb)
INSERT INTO emp_test VALUES (9999, 'brown', 1000, '01');

--emp_gb check 조건에 위배 (emp_gb IN ('01', '02' ))
INSERT INTO emp_test VALUES (9999, 'brown', 1000, '03');

-- 정삭적으로 입력
INSERT INTO emp_test VALUES (9999, 'brown', 1000, '02');

select * from emp_test;
desc emp_test;


-- CHECK제약 조건 이름생서
DROP TABLE emp_test;
CREATE TABLE emp_test(
    empno NUMBER(4) PRIMARY KEY,
    ename VARCHAR2(10),
--    sal NUMBER(7,2) CHECK (sal > 0),
    sal NUMBER(7,2) CONSTRAINT C_SAL CHECK (sal > 0),
    emp_gb VARCHAR2(2) CONSTRAINT C_EMP_GB CHECK ( emp_gb IN ('01', '02') )
    );


-- talbe level CHECK 제약조건. 제약조건 이름 생성
CREATE TABLE emp_test(
    empno NUMBER(4) PRIMARY KEY,
    ename VARCHAR2(10),
    sal NUMBER(7,2),
    emp_gb VARCHAR2(2),
    
     CONSTRAINT C_SAL CHECK (sal > 0),
     CONSTRAINT C_EMP_GB CHECK ( emp_gb IN ('01', '02') )
    );


-- 테이블 생성 : CREATE TALBE 테이블명 (
--               컬럼 컬럼타입 .....  );

-- 기존 테이블을 활용해서 테이블 생성하기
-- Create Table AS : CTAS (씨타스)
--       CREATE TABLE 테이블명 [ (컬럼1, 컬럼2, ...... ) ] AS
--       SELECT col1, col2...
--       FROM 다른 테이블명
--       WHERE 조건


--emp_test 테이블 삭제 (drop)
DROP TABLE emp_test;

-- emp테이블의 데이터를 포함해서 emp_test 테이블을 생성
CREATE TABLE emp_test AS 
    SELECT * 
    FROM emp;

-- emp - emp_test == emp_test - emp
SELECT * FROM emp
MINUS
select * from emp_test;


--emp_test 테이블 삭제 (drop)
DROP TABLE emp_test;

-- emp테이블의 데이터를 포함해서 emp_test을 변경하여 생성 (select 쿼리의 컬럼의 갯수만큼 컬럼명을 변경하여야 한다.)
CREATE TABLE emp_test (c1, c2, c3, c4, c5, c6, c7, c8)AS 
    SELECT * 
    FROM emp;    
    
SELECT * FROM emp_test;

--emp_test 테이블 삭제 (drop)
DROP TABLE emp_test;

-- 데이터는 제외하고 테이블의 형체(컬럼 구성)만 복사하여 테이블 생성 --> WHERE절에 값이 안나오는것으로
CREATE TABLE emp_test AS 
    SELECT *
    FROM emp
    WHERE 1=2;
    
    

    
--------------------------------------------------------------------------------------------------------------------------------

--      ALTER : 컬럼에 데이터가 없을시 변경가능. 단 데이터의 크기를 늘려주는것은 가능하다.
-- 기본
--  ALTER TABLE 테이블명 ADD (컬럼명 컬럼타입 [default value]);

-- 컬럼명 변경
--  ALTER TABLE 테이블명 RENAME COLUMN 기본컬럼명 TO 변경컬럼명;

-- 컬럼삭제
--  ALTER TABLE 테이블명 DROP (컬럼);
--  ALTER TABLE 테이블명 DROP COLUMN 컬럼;

-- 제약조건 추가
--  ALTER TABLE 테이블명 ADD -- 테이블 레벨 제약조건 스크립트

-- 제약 조건 삭제
--  ALTER TABLE 테이블명 DROP CONSTRAINT 제약조건이름;


-- 테이블 컬럼, 타입 변경은 제한적으로나마 가능.
-- 단, 테이블의 커럼 순서를 변경하는 것은 불가능하다.

--------------------------------------------------------------------------------------------------------------------------------
    
-- emp_test 삭제
DROP TABLE emp_test;

-- empno, ename, deptno 컬럼으로 emp_test생성
CREATE TABLE emp_test AS
    SELECT empno, ename, deptno
    FROM emp
    WHERE 1=2;
    
--emp_test 테이블에 신규 컬럼 추가
-- HP VARCHAR(20) DEFAULT '010'
-- ALTER TABLE 테이블명 ADD (컬럼명 컬럼타입 [default value]);

ALTER TABLE emp_test ADD (HP VARCHAR(20) DEFAULT '010');

SELECT *
FROM emp_test;


-- 기존 컬럼 수정
-- ALTER TABLE 테이블명 NODIFY (컬럼 컬럼타입 [default value]);;
-- hp 컬럼의 타입을 VARCHAR(20) -> VARCHAR(30)

ALTER TABLE emp_test MODIFY (HP VARCHAR2(30));

desc emp_test;

-- 현재 emp_test 테이블에 데이터가 없기때문에 컬럼 타입을 변경하는 것이 가능하다.
-- hp 컬럼의 타입을 VARCHAR2(30) -> NUMBER
ALTER TABLE emp_test MODIFY (HP NUMBER);


-- 컬럼명 변경
-- 해당 컬럼이 PK, UNIQUE, NOT NULL, CHECK제약 조건 기술시 컬럼명에 대해서도 자동적으로 변경이 된다.
-- HP 컬럼 -> hp_n
--ALTER TABLE 테이블명 RENAME COLUMN 기본컬럼명 TO 변경컬럼명;
ALTER TABLE emp_test RENAME COLUMN hp TO hp_m;
desc emp_test;

-- 컬럼 삭제
-- ALTER TABLE 테이블명 DROP (컬럼);
-- ALTER TABLE 테이블명 DROP COLUMN 컬럼;
ALTER TABLE emp_test DROP (hp_m);
ALTER TABLE emp_test DROP COLUMN hp_m;

-- 제약조건 추가
--ALTER TABLE 테이블명 ADD -- 테이블 레벨 제약조건 스크립트
-- emp_test 테이블의 empno컬럼을 PK제약조건 추가
ALTER TABLE emp_test ADD CONSTRAINT pk_emp_test PRIMARY KEY (empno);
DESC emp_test;

-- 제약 조건 삭제
--  ALTER TABLE 테이블명 DROP CONSTRAINT 제약조건이름;
ALTER TABLE emp_test DROP CONSTRAINT pk_emp_test;


