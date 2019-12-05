
-- 서브쿼리 실습4. 직원이 속하지 않는 부서를 조회
SELECT *
FROM dept
WHERE deptno NOT IN (SELECT deptno
                     FROM emp);

-- 서브쿼리 실습5. cid = 1인 고객이 애음하지 않는 제품
SELECT *
FROM product
WHERE pid NOT IN (SELECT pid
                  FROM cycle
                  WHERE cid = 1);

-- 서브쿼리 실습6. cid = 2인 고객이 애음하는 제품중 cid = 1인 고객도 애음하는 제품
SELECT *
FROM cycle
WHERE cid = 1
AND pid IN (SELECT pid
            FROM cycle
            WHERE cid = 2);


-- 서브쿼리 실습7. cid = 2인 고객이 애음하는 제품중 cid = 1인 고객도 애음하는 제품을 조회하고, 고객명과 제품명을 조회

--교수님이 한것
SELECT customer.cid, customer.cnm, product.pid, product.pnm, cycle.day, cycle.cnt
FROM cycle, customer, product
WHERE cycle.cid = 1
AND cycle.cid = customer.cid
AND cycle.pid = product.pid
AND cycle.pid IN (SELECT pid
                  FROM cycle
                  WHERE cid = 2);
-----------------------------------------


SELECT customer.cid, customer.cnm, product.pid, product.pnm, a.day, a.cnt
FROM customer, product,(SELECT *
                        FROM cycle
                        WHERE cid = 1
                        AND pid IN (SELECT pid
                                    FROM cycle
                                    WHERE cid = 2)) a
WHERE customer.cid = a.cid
AND a.pid = product.pid;

SELECT cus.cid, cus.cnm, p.pid, p.pnm, c.day, c.cnt
FROM customer cus, product p, cycle c
WHERE c.cid = cus.cid
AND c.pid = p.pid
AND (cus.cid, p.pid, c.day, c.cnt) IN (SELECT *
                                       FROM cycle
                                       WHERE cid = 1
                                       AND pid IN (SELECT pid
                                                   FROM cycle
                                                   WHERE cid = 2));
                                                   
---------------------------------------------------------------------------------------------------------

--          EXISTS 연산자 : 서브쿼리가 뒤에 와야한다. (상호 연관 서브쿼리)
--  조건을 만족하는 서브쿼리의 결과값이 존재하는지 체크
--  조건을 만족하는 데이터를 찾으면 서브 쿼리에서 값을 찾지 않는다.

-- 서브쿼리에 결과셋이 있을때 항상 참이 되므로, 서브쿼리에 메인쿼리의 테이블을 이용하여 조건을 만들어준다. 

---------------------------------------------------------------------------------------------------------

-- 매니저가 존재하는 직원 정보 조회
SELECT *
FROM emp a
WHERE EXISTS (SELECT 1
              FROM emp b
              WHERE a.mgr = b.empno);
-- 서브쿼리 실습8. (Exists)
SELECT *
FROM emp
WHERE mgr IS NOT NULL;

-- 서브쿼리 실습9. cid = 1인 고객이 애음하는 제품 조회
SELECT *
FROM product
WHERE EXISTS (SELECT 22
              FROM cycle
              WHERE cid = 1
              AND product.pid = cycle.pid);

-- 서브쿼리 실습10. cid = 1인 고객이 애음하지 않는 제품 조회
SELECT *
FROM product
WHERE NOT EXISTS (SELECT 'ㅁㄴㅇ'
                  FROM cycle
                  WHERE cid = 1
                  AND product.pid = cycle.pid);

---------------------------------------------------------------------------------------------------------

--          집합연산

--      UNION       :   합집합, 두 집합간의 중복건은 제거한다
--      UNION ALL   :   중복을 포함하여 합집합
--      INTERSECT   :   교집합, 두 집합간 공통적인 데이터만 조합
--      MINUS       :   차집합, 위, 아래 집합의 교집합을 위 집합에서 제거한 집합을 조회. (순서가 중요하다)


---------------------------------------------------------------------------------------------------------

-- UNION
--  담당업무가 SALES인 직원의 직원번호, 직원 이름 조회
-- 위아래 결과셋이 동일하기에 합집합 연산을 하게 될 경우 중복되는 데이터는 한번만 표현한다.
SELECT empno, ename
FROM emp
WHERE job = 'SALESMAN'

UNION

SELECT empno, ename
FROM emp
WHERE job = 'SALESMAN';

-- 서로 다른 집합의 합집합
SELECT empno, ename
FROM emp
WHERE job = 'SALESMAN'

UNION

SELECT empno, ename
FROM emp
WHERE job = 'CLERK';


-- UNION ALL
SELECT empno, ename
FROM emp
WHERE job = 'SALESMAN'

UNION ALL

SELECT empno, ename
FROM emp
WHERE job = 'SALESMAN';

-- 집합 연산시 집합셋의 컬럼이 동일해야 한다.
SELECT empno, ename
FROM emp
WHERE job = 'SALESMAN'

UNION ALL

SELECT empno, ename, job
FROM emp
WHERE job = 'SALESMAN';


-- INTERSECT
SELECT *
FROM emp
WHERE job IN ('SALESMAN', 'CLERK')

INTERSECT

SELECT *
FROM emp
WHERE job = 'SALESMAN';

-- MINUS
SELECT *
FROM emp
WHERE job IN ('SALESMAN', 'CLERK')

MINUS

SELECT *
FROM emp
WHERE job = 'SALESMAN';


-- ORDER BY 사용. 첫집합의 순서가 중요하면 아래와 같이 인라인뷰로 만들어서 조회. 그게아니면 그냥 마지막에 붙인다.
-- *로 조회시 ORDER BY ename이 오류가 발생한다
SELECT empno, ename
FROM (SELECT *
      FROM emp
      WHERE job IN ('SALESMAN', 'CLERK')
      ORDER BY job)

UNION ALL

SELECT empno, ename
FROM emp
WHERE job = 'SALESMAN'
ORDER BY ename;


-- DML
-- INSERT : 테이블에 새로운 데이터 입력

-- INSERT 시 컬럼을 나열한 경우
-- 나열한 컬럼에 맞춰 입력할 값을 동일한 순서로 기술한다.
-- INSERT INTO table_name (column1, column2 ......)
-- VALUES (값1, 값2 .....)


-- dept 테이블에 부서번호 99, 조직명 ddit, 지역명 daejeon 을 갖는 데이터 입력
INSERT INTO dept (deptno, dname, loc)
VALUES (99, 'ddit', 'daejeon');

-- 컬럼을 기술할 경우 테이블의 컬럼 정의 순서와 다르게 나열해도 된다
INSERT INTO dept (dname, deptno, loc)
VALUES ('ddit', 99, 'daejeon');

-- 컬럼을 기술하지 않을경우 테이블의 컬럼 정의 순서에 맞춰 값을 기술한다
INSERT INTO dep t
VALUES ('ddit', 99, 'daejeon');


-- 날짜 값 입력하기
-- 1. sysdate
-- 2. 사용자로 부터 받은 문자열을 DATE 타입으로 변경하여 입력

INSERT INTO emp
VALUES (9998, 'sally', 'SALESMAN', NULL, SYSDATE, 500, NULL, NULL);

-- 2019-12-02일 입사
INSERT INTO emp
VALUES (9997, 'james', 'CLERK', NULL, TO_DATE('2019/12/02', 'YYYY/MM/DD'), 500, NULL, NULL);

--------------------------------------------------------------------------------

-- 여러건의 데이터를 한번에 입력
-- SELECT 결과를 테이블에 입력 할 수 있다,

--------------------------------------------------------------------------------
INSERT INTO emp
    SELECT 9998, 'sally', 'SALESMAN', NULL, SYSDATE, 500, NULL, NULL
    FROM dual
    UNION ALL
    SELECT 9997, 'james', 'CLERK', NULL, TO_DATE('2019/12/02', 'YYYY/MM/DD'), 500, NULL, NULL
    FROM dual;
