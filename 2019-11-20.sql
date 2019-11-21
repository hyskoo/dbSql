--DESC 테이블명;
--SELECT *
--FROM user_tablename_colum;


CLOB --> Character Large Object, 문자열 타입의 길이 제한을 피하는 타입
        --최대 사이즈 : VARCHAR(4000), CLOB(4GB)
DATE --> 날짜(일시 = 년,월,일 + 시간,분,초  YYYY/MM/DD hh/mm/ss)

--DATE 타입에 대한 연산의 결과는?
'2019/11/20 09:16:20' + 1 = ?

--연산을 통해 새로운 컬럼을 생성 (reg_dt에 숫자 연산을 한 새로운 컬럼)
--날짜 + 정수 연산 ==> 일자를 더한 날짜타입이 결과로 나온다
-- alice(별칭) : 기존 컬럼명이나 연산을 통해 생성된 가상 컬럼에 임의의 컬럼이름을 부여
--      col | express [AS] 별칭명
SELECT userid, usernm, reg_dt reg_date , reg_dt+5 AS after5day
from users;

-- 숫자 상수, 문자열 상수)( oralce : '', java : '', "")
-- table에 없는 값을 임의 컬럼으로 생성
-- 숫자에 대한 연산 ( +, -, /, * )
-- 문자에 대한 연산 ( +  가 존재하지 않음 ==> || 사용)
SELECT (10-2)*5, 'DB SQL 수업',
        /*userid + '_modified', 문자열 연산은 [ + ] 연산이 없다.*/
        usernm || '_modified', reg_dt
FROM users;

--NULL : 아직모르는값, NULL에 대한 연산 결과는 항상 NULL
-- DESC : 테이블명 : NOT NUll로 처리된 컬럼에는 값이 반드시 들어가야함

--users의 불필요한 데이터 삭제
DELETE FROM users
WHERE userid NOT IN ('brown', 'sally', 'cony', 'moon', 'james');

commit;

SELECT userid, usernm, reg_dt
FROM users;

--null 연산을 시험해보기 위해 moon의 reg_dt 컬럼을 null로 변환
UPDATE users
SET reg_dt = NULL
WHERE userid = 'moon';

--users 테이블의 reg_dt 컬럼값에 5일을 더한 새로운 컬럼을 작성
--NULL값에 대한 연산의 결과는 NULL이다.
SELECT userid, usernm, reg_dt, reg_dt+5
FROM users;


SELECT userid, usernm
FROM users;
--문자열 컬럼간 결합 ( 컬럼 || 컬럼, '문자열상수' || 컬럼)
--                ( CONCAT(컬럼, 컬럼) )
SELECT  userid, usernm,
        userid || usernm AS id_name,
        CONCAT(userid, usernm) AS concat_id_name,
        -- ||을 이용해서 userid, usernm, pass
        userid || usernm || pass id_nm_pass,
        -- CONCAT을 사용해서 userid, usernm, pass
        CONCAT(userid, CONCAT(usernm, pass))
FROM users;


--사용자가 보유한 테이블 목록 조회
SELECT 'SELECT * FROM ' || table_name || ';' AS query
FROM user_tables;

SELECT CONCAT(CONCAT('SELECT * FROM ', table_name), ';')
FROM user_tables;

--WHERE : 조건이 일치하는 행만 조회하기 위해 사용.
--WHERE절이 없으면 해당 테이블의 모든 행에 대해 조회.
SELECT userid, usernm, alias, reg_dt
FROM users
WHERE userid= 'brown';

--emp 테이블의 전체 데이터 조회 (모든 행(row), 열(column))
SELECT *
FROM emp;

SELECT *
FROM dept;

SELECT *
FROM emp
WHERE empno >=7700;

SELECT e.DEPTNO, d.DEPTNO AS DEPT_DEPTNO
FROM emp e, dept d
WHERE e.DEPTNO = d.DEPTNO;


--입사일자가 1982.1.1 이후인 사원 정보 조회.
--문자열 -> 날짜 타입으로 변경. TO_DATE('날짜문자열', '날짜문자열포맷')
SELECT empno, ename, hiredate,
        2000 no, '문자열상수' str, TO_DATE('1982.1.1', 'YYYY.MM.DD')
FROM emp
WHERE hiredate >= TO_DATE('1982.1.1', 'YYYY.MM.DD');

--범위 조회 (BETWEEN 시작기준 AND 종료기준)
--시작기준, 종료기준을 포함
--사원의 급여가 1000보다 크거나 같고, 2000보다 작거나 같은 사원의 정보
SELECT *
FROM emp
WHERE sal BETWEEN 1000 AND 2000;

--BETWEEN a AND b 연산자는 부등호 연산자로 대체 가능
SELECT *
FROM emp
WHERE sal >= 1000 
AND   sal <= 2000;

--실습1
SELECT ename, hiredate
FROM emp
WHERE hiredate BETWEEN TO_DATE('1982.1.1', 'YYYY.MM.DD') AND '1983.1.1'; --TO_DATE 생략가능(툴마다 다름)

--실습2
SELECT ename, hiredate
FROM emp
WHERE hiredate >= TO_DATE('1982.1.1', 'YYYY.MM.DD') AND hiredate <= TO_DATE('1983.1.1', 'YYYY.MM.DD');


SELECT emp.empno, EMP.DEPTNO, dept.DEPTNO, dept.DNAME, dept.LOC
FROM emp, dept
WHERE emp.DEPTNO = dept.DEPTNO;


