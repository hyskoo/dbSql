--col IN (vlaue1, vlaue2...)
--coloum의 값이  IN 연산자 안에 나열된 값중에 포함될 때 참으로 판정

--RDBMS - 집합개념
-- 집합의 특징 --
--1. 순서가 없다. {1, 5, 7} == {7, 1, 5}
--2. 중복이없다. {1, 5, 7, 1} == {1, 5, 7, 1}
SELECT *
FROM emp
WHERE deptno IN (10,20); -- emp 테이블의 직원 소속 부서가 10번 이거나 20번인 직원 정보만 조회 ( OR 로 대체가능)

SELECT userid AS "아이디", usernm AS "이름", ALIAS AS "발명", '어린애'
FROM users
WHERE userid IN ('brown', 'cony', 'sally');

--LIKE 연산자 : 문자열 매칭 연산 (검색에서 활용)
-- % : 여러 문자 (문자가 없을 수도 있다.)
-- _ : 하나의 문자

--1번 글자 S 4번 글자 T
SELECT * 
FROM emp
WHERE ename LIKE 'S__T_'; --T뒤에 반드시 한글자이상이 와야함(마지막글자이전에 T이면 TT로끝나기 가능).  ex) 'S'
--WHERE ename LIKE 'S%T_'; --T뒤에 반드시 한글자이상이 와야함.  ex) 'STdT'-X , 'STETE' - O

SELECT mem_id, mem_name
FROM member
WHERE mem_name LIKE '신%';

SELECT mem_id, mem_name
FROM member
WHERE mem_name LIKE '%이%';

SELECT *
FROM emp
WHERE comm IS NOT NULL;

-- AND : 조건을 동시에 만족
-- OR : 조건을 하나만 충족하면 만족
SELECT *
FROM emp
WHERE mgr=7698
AND sal > 1000
ORDER BY sal;

SELECT *
FROM emp
WHERE mgr = 7698
OR sal > 1000;

SELECT *
FROM emp
WHERE mgr != 7698
AND mgr != 7839;

SELECT *
FROM emp
WHERE mgr NOT IN (7698, 7839)
OR mgr IS NULL;

SELECT *
FROM emp
WHERE job = 'SALESMAN'
AND hiredate >= TO_DATE('1981.6.1','YYYY.MM.DD');