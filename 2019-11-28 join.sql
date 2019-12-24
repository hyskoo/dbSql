SELECT ename, emp.deptno, dept.dname
FROM emp, dept
WHERE emp.deptno = dept.deptno
AND emp.deptno = 10;

-- where���� �ٸ��ٶ�� �����̹Ƿ� deptno�� 20, 30, 40�� �ش��ϴ� ������� �����µ� emp���̺��� deptno�� ���ϹǷ� deptno�� 10����ó���ȴ�.
SELECT ename, emp.deptno, dept.dname
FROM emp, dept
WHERE emp.deptno != dept.deptno
AND emp.deptno = 10;



--natural Join : ���� ���̺� ���� Ÿ��, ���� �̸��� �÷����� ���� ���� ���� ��� ����
-- ���ο� Ȱ��Ǵ� �÷��� ���̺��� ��ġ�� �˷��� �ʿ䰡 ����. 

-- AnSi SQL ����
SELECT deptno, emp.empno, ename
FROM emp NATURAL JOIN dept;
-- Oracle SQL ����
SELECT e.deptno, e.empno, ename
FROM emp e, dept d
WHERE e.deptno = d.deptno;

-- JOIN USING
-- JOIN�Ϸ��� �ϴ� ���̺� ������ �̸��� �÷��� �ΰ� �̻��� ���, JOIN �÷��� �ϳ��� ����ϰ� ���� ��

-- AnSi SQL
SELECT * 
FROM emp JOIN dept USING (deptno);

-- Oracle SQL
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno;

--ANSI JOIN with ON
-- 1. ���� �ϰ��� �ϴ� ���̺��� �÷� �̸��� �ٸ� ��
-- 2. �����ڰ� ���������� ���� �����Ҷ�

SELECT *
FROM emp JOIN dept ON (emp.deptno = dept.deptno);

--oracle
SELECT *
FROM emp, dept
WHERE emp.deptno = dept.deptno;


-- Self JOIN : ���� ���̺� ����
-- emp ���̺� ���� �Ҹ��� ���� : ������ ������ ���� ��ȸ
-- ���������� ����Ǿ�����

--������ ������ ������ ��ȸ
-- �����̸�, �������̸�

-- ANSI
SELECT e.ename, m.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno);

-- ORACLE
SELECT e.ename, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno;

-- ���� �̸�, ������ ����� �̸�, ������ ������� ����� �̸�
SELECT e.ename, m.ename, t.ename
FROM emp e, emp m, emp t
WHERE e.mgr = m.empno
AND m.mgr = t.empno;

SELECT sub.e_ename, sub.m_ename, t.ename
FROM emp t, (SELECT e.ename AS e_ename, m.ename AS m_ename, m.mgr AS m_mgr
            FROM emp e, emp m
            WHERE e.mgr = m.empno) sub
WHERE t.empno = m_mgr;

-- ���� �̸�, ������ ����� �̸�, ������ ������� ����� �̸�
SELECT e.ename, m.ename, m_up.ename, m_up2.ename
FROM emp e, emp m, emp m_up, emp m_up2
WHERE e.mgr = m.empno
AND m.mgr = m_up.empno
AND m_up.mgr = m_up2.empno;

-- ���� ���̺��� ANSI JOIN�� �̿��� JOIN
SELECT e.ename, m.ename, t.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno)
    JOIN emp t ON (m.mgr = t.empno)
    JOIN emp k ON (t.mgr = k.empno);


-- ������ �̸���, �ش� ������ ��� �̸��� ��ȸ.
-- ��, ������ ����� 7369~7698�� ������ �������
SELECT e.ename, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno
AND e.empno BETWEEN 7369 AND 7698;

SELECT e.ename, m.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno)
WHERE e.empno BETWEEN 7369 AND 7698;

--NON-EQUI JOIN : ���� ������ =(equal)�� �ƴ� JOIN
-- != , BETWEEN AND

SELECT *
FROM salgrade;

SELECT empno, ename, sal
FROM emp
WHERE sal BETWEEN 700 AND 1200;

SELECT e.empno, e.ename, e.sal, sal_g.grade
FROM emp e, salgrade sal_g
WHERE e.sal BETWEEN sal_g.losal AND sal_g.hisal;


--�ǽ�0 JOIN
-- Oracle SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno
ORDER BY e.deptno;

-- ANSI SQL
SELECT empno, ename, e.deptno, d.dname
FROM emp e JOIN dept d ON (e.deptno = d.deptno);

-- �ǽ�1. JOIN
-- Oracle SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno
AND e.deptno IN (10, 30);

-- ANSI SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e JOIN dept d ON (e.deptno = d.deptno)
WHERE e.deptno IN (10, 30);

-- �ǽ�2. JOIN
-- Oracle SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e, dept d
WHERE e.deptno = d.deptno
AND e.sal > 2500;

-- ANSI SQL
SELECT e.empno, e.ename, e.deptno, d.dname
FROM emp e JOIN dept d ON (e.deptno = d.deptno)
WHERE e.sal > 2500;

-- �ǽ�3. JOIN
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

-- �ǽ�4. JOIN
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

-- �ǽ�6. JOIN

-- �ǽ�7. JOIN

-- �ǽ�8. JOIN

-- �ǽ�9. JOIN

-- �ǽ�10. JOIN

