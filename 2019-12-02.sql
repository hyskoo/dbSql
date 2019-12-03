--OUTER join : 조인 연결에 실패하더라도, 기준이 되는 테이블의 데이터는 나오도록 하는 join
-- LEFT OUTER JOIN : 테이블 1 LEFT OUTER JOIN 테이블2
-- 테이블 1과 테이블 2를 조인할때 조인에 실패하더라도 [ 테이블 1] 쪽의 데이터는 조회가 되도록한다.
-- 조인에 실패한 행에서 테이블2의 컬럼값은 존재하지 않으므로 NULL로 표시 된다.

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m
                      ON (e.mgr = m.empno);

-- LEFT OUTER 조인에 영향을 받음.  (FROM 절이 먼저 실행되므로)
SELECT e.empno, e.ename, e.deptno, m.empno, m.ename, m.deptno
FROM emp e LEFT OUTER JOIN emp m
                      ON (e.mgr = m.empno AND m.deptno = 10);

-- LEFT OUTER 조인에 영향을 받지 않음.
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e LEFT OUTER JOIN emp m
                      ON (e.mgr = m.empno)
WHERE m.deptno = 10;

-- Oracle에서 표현 OUTER JOIN syntax
-- 일반조인과 차이점은 컬럼명에 ( + )
-- ( + )표시 : 데이터가 존재하지 않는데 나와야 하는 테이블의 컬럼
    -- ON (직원.매니저번호 = 매니저.직원번호)

-- Orcle OUTER 
-- WHERE 직원.매니저번호 = 매니저.직원번호(+) -- 매니저쪽 데이터가 존재하지 않음.
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno(+);

-- 매니저 부서번호 제한
-- ANSI SQL ON 절에 기술.
-- --> OUTER JOIN이 적용되지 않은 상황
-- 아우터 조인이 적용되어야 하는 테이블의 모든 컬럼에 (+)가 붙어야 한다.
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno(+)
AND m.deptno(+) = 10;

-- ANSI SQL의 WHERE절에 기술한 경우와 동일
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno(+)
AND m.deptno = 10;


-- emp 테이블에는 14명의 직원이 있고 14명은 10, 20, 30부서중에 한 부서에 속한다.
-- 하지만 dept테이블에는 10, 20, 30, 40번 부서가 존재
-- 부서번호, 부서명, 해당부서에 속한 직원수가 나오도록 쿼리를 작성

SELECT d.deptno, d.dname, COUNT(e.deptno)
FROM dept d, emp e
WHERE d.deptno = e.deptno(+)
GROUP BY d.deptno, d.dname
ORDER BY d.deptno;

SELECT d.deptno, d.dname, COUNT(e.deptno)
FROM dept d LEFT OUTER JOIN emp e
                      ON (e.deptno = d.deptno)
GROUP BY d.deptno, d.dname;

-- dept : deptno, dname
-- inline : deptno, cnt(직원의 수)
SELECT dept.deptno, dept.dname, NVL(emp_cnt.cnt, 0) cnt
FROM dept, (SELECT deptno, COUNT(*) cnt
            FROM emp
            GROUP BY deptno) emp_cnt
WHERE dept.deptno = emp_cnt.deptno(+);

--ANSI
SELECT dept.deptno, dept.dname, NVL(emp_cnt.cnt, 0) cnt
FROM dept LEFT OUTER JOIN (SELECT deptno, COUNT(*) cnt
                            FROM emp
                            GROUP BY deptno) emp_cnt
                           ON (dept.deptno = emp_cnt.deptno);
                      
                      
                      
-- RIGHT OUTER JOIN
-- 테이블 1과 테이블 2를 조인할때 조인에 실패하더라도 [ 테이블 2 ] 쪽의 데이터는 조회가 되도록한다.
-- 조인에 실패한 행에서 테이블2의 컬럼값은 존재하지 않으므로 NULL로 표시 된다.

SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e RIGHT OUTER JOIN emp m
                      ON (e.mgr = m.empno);


-- FULL OUTER JOIN (잘사용안함) : LEFT OUTER + RIGHT OUTER - 중복데이터 삭제
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e FULL OUTER JOIN emp m
                      ON (e.mgr = m.empno);
                      
                      
                      
                      
                      
-- 실습 1.
SELECT b.buy_date, b.buy_prod, p.prod_id, p.prod_name, b.buy_qty
FROM buyprod b RIGHT OUTER JOIN prod p
ON ( b.buy_prod = p.prod_id AND b.buy_date = TO_DATE('2005/01/25', 'YYYY/MM/DD'));

SELECT b.buy_date, b.buy_prod, p.prod_id, p.prod_name, b.buy_qty
FROM buyprod b, prod p
WHERE b.buy_prod(+) = p.prod_id
AND b.buy_date(+) = TO_DATE('2005/01/25', 'YYYY/MM/DD');
                      
-- 실습2.
SELECT NVL(b.buy_date,'2005-01-15') AS buydate, b.buy_prod, p.prod_id, p.prod_name, b.buy_qty
FROM buyprod b RIGHT OUTER JOIN prod p
ON ( b.buy_prod = p.prod_id AND b.buy_date = TO_DATE('2005/01/25', 'YYYY/MM/DD'));

SELECT NVL(b.buy_date,'2005-01-15') AS buydate, b.buy_prod, p.prod_id, p.prod_name, b.buy_qty
FROM buyprod b, prod p
WHERE b.buy_prod(+) = p.prod_id
AND b.buy_date(+) = TO_DATE('2005/01/25', 'YYYY/MM/DD');

-- 실습3.
SELECT TO_DATE(:yyyymmdd, 'YYYYMMDD'), b.buy_prod, p.prod_id, p.prod_name, NVL(b.buy_qty, 0)
FROM buyprod b RIGHT OUTER JOIN prod p
ON ( b.buy_prod = p.prod_id AND b.buy_date = TO_DATE('2005/01/25', 'YYYY/MM/DD'));

-- 실습4.
SELECT p.pid, p.pnm, NVL(c.cid, 1) AS cid, NVL(c.day, 0) AS day, NVL(c.cnt, 0) AS cnt
FROM cycle c RIGHT OUTER JOIN product p
ON (c.pid = p.pid AND c.cid = 1);

--바인드 변수를 활용하자
SELECT p.pid, p.pnm,          --product
       :cid, NVL(c.day, 0) AS day, NVL(c.cnt, 0) AS cnt  --cycle
FROM cycle c, product p
WHERE c.pid(+) = p.pid
AND c.cid(+)=1;

-- 실습5.


-- inline에서 null값이 없으므로 마지막에 outer join을 할필요가 없다.
SELECT a.pid, a.pnm, a.cid, customer.cnm, a.day, a.cnt
FROM (SELECT p.pid, p.pnm, :cid cid, NVL(c.day, 0) AS day, NVL(c.cnt, 0) AS cnt
      FROM cycle c, product p
      WHERE c.cid(+) = :cid
      AND c.pid(+) = p.pid) a, customer
WHERE a.cid = customer.cid;

-- cross 조인 : 묻지마 조인이라고 하며, 모든 경우의 수가 다나온다.
SELECT * FROM customer, product;
