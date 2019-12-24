SELECT ename, emp.deptno, dept.dname
FROM emp, dept
WHERE emp.deptno = dept.deptno
AND emp.deptno = 10;

-- where절이 다르다라는 조건이므로 deptno가 20, 30, 40에 해당하는 사람들이 나오는데 emp테이블의 deptno을 구하므로 deptno가 10으로처리된다.
SELECT ename, emp.deptno, dept.dname
FROM emp, dept
WHERE emp.deptno != dept.deptno
AND emp.deptno = 10;



--natural Join : 조인 테이블간 같은 타입, 같은 이름의 컬럼으로 같은 값을 갖는 경우 조인
-- 조인에 활용되는 컬럼은 테이블의 위치를 알려줄 필요가 없다. 

-- AnSi SQL 사용시
SELECT deptno, emp.empno, ename
FROM emp NATURAL JOIN dept;
-- Oracle SQL 사용시
SELECT e.deptno, e.empno, ename
FROM emp e, dept d
WHERE e.deptno = d.deptno;

-- JOIN USING
-- JOIN하려고 하는 테이블간 동일한 이름의 컬럼이 두개 이상인 경우, JOIN 컬럼을 하나만 사용하고 싶을 때

-- AnSi SQL
SELECT * 
FROM emp JOIN dept USING (deptno);

-- Oracle SQL
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno;

--ANSI JOIN with ON
-- 1. 조인 하고자 하는 테이블의 컬럼 이름이 다를 때
-- 2. 개발자가 조인조건을 직접 제어할때

SELECT *
FROM emp JOIN dept ON (emp.deptno = dept.deptno);

--oracle
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno;


-- Self JOIN : 같은 테이블간 조인
-- emp 테이블간 조인 할만한 사항 : 직원의 관리자 정보 조회
-- 계층구조가 적용되어있음

--직원의 관리자 정보를 조회
-- 직원이름, 관리자이름

-- ANSI
SELECT e.ename, m.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno);

-- ORACLE
SELECT e.ename, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno;

-- 직원 이름, 직원의 상급자 이름, 직원의 상급자의 상급자 이름
SELECT e.ename, m.ename, t.ename
FROM emp e, emp m, emp t
WHERE e.mgr = m.empno
AND m.mgr = t.empno;

SELECT sub.e_ename, sub.m_ename, t.ename
FROM emp t, (SELECT e.ename AS e_ename, m.ename AS m_ename, m.mgr AS m_mgr
            FROM emp e, emp m
            WHERE e.mgr = m.empno) sub
WHERE t.empno = m_mgr;

-- 직원 이름, 직원의 상급자 이름, 직원의 상급자의 상급자 이름
SELECT e.ename, m.ename, m_up.ename, m_up2.ename
FROM emp e, emp m, emp m_up, emp m_up2
WHERE e.mgr = m.empno
AND m.mgr = m_up.empno
AND m_up.mgr = m_up2.empno;

-- 여러 테이블을 ANSI JOIN을 이용한 JOIN
SELECT e.ename, m.ename, t.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno)
    JOIN emp t ON (m.mgr = t.empno)
    JOIN emp k ON (t.mgr = k.empno);


-- 직원의 이름과, 해당 직원의 상사 이름을 조회.
-- 단, 직원의 사번이 7369~7698인 직원을 대상으로
SELECT e.ename, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno
AND e.empno BETWEEN 7369 AND 7698;

SELECT e.ename, m.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno)
WHERE e.empno BETWEEN 7369 AND 7698;

--NON-EQUI JOIN : 조인 조건이 =(equal)이 아닌 JOIN
-- != , BETWEEN AND

SELECT *
FROM salgrade;

SELECT empno, ename, sal
FROM emp
WHERE sal BETWEEN 700 AND 1200;

SELECT e.empno, e.ename, e.sal, sal_g.grade
FROM emp e, salgrade sal_g
WHERE e.sal BETWEEN sal_g.losal AND sal_g.hisal;


--실습0 JOIN
-- Oracle SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno
ORDER BY e.deptno;

-- ANSI SQL
SELECT empno, ename, e.deptno, d.dname
FROM emp e JOIN dept d ON (e.deptno = d.deptno);

-- 실습1. JOIN
-- Oracle SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno
AND e.deptno IN (10, 30);

-- ANSI SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e JOIN dept d ON (e.deptno = d.deptno)
WHERE e.deptno IN (10, 30);

-- 실습2. JOIN
-- Oracle SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno
AND e.sal > 2500;

-- ANSI SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e JOIN dept d ON (e.deptno = d.deptno)
WHERE e.sal > 2500;

-- 실습3. JOIN
-- Oracle SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno
AND e.sal > 2500
AND e.empno > 7600;

-- ANSI SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e JOIN dept d ON (e.deptno = d.deptno)
WHERE e.sal > 2500 
AND e.empno > 7600;

-- 실습4. JOIN
-- Oracle SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno
AND e.sal > 2500
AND e.empno > 7600
AND d.dname = 'RESEARCH';
-- ANSI SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e JOIN dept d ON (e.deptno = d.deptno)
WHERE e.sal > 2500 
AND e.empno > 7600
AND d.dname = 'RESEARCH';

-- 실습6. JOIN

-- 실습7. JOIN

-- 실습8. JOIN

-- 실습9. JOIN

-- 실습10. JOIN

