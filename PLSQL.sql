-- 프로시저 생성
CREATE OR REPLACE PROCEDURE pro_print
IS  --선언부
    V_A NUMBER := 10;
    V_B NUMBER := 20;
    V_C NUMBER;
BEGIN -- 실행부
    V_C := V_A + V_B;
    -- 출력문
    DBMS_OUTPUT.PUT_LINE('V_C : ' || V_C);
END;
/

SET SERVEROUTPUT ON;
-- 프로시저 실행
EXECUTE pro_print();


-- 
CREATE OR REPLACE PROCEDURE pro_emp_write 
(
    IN_EMP_ID IN employee.emp_id%TYPE,
    IN_TITLE IN VARCHAR2 DEFAULT '제목없음',
    IN_CONTENT IN CLOB DEFAULT '내용없음'
)
IS
    V_EMP_NAME employee.emp_name%TYPE;
BEGIN
    -- INTO : 조회결과를 변수에 대입하는 키워드
    SELECT emp_name INTO V_EMP_NAME
    FROM employee
    WHERE emp_id = IN_EMP_ID;

    INSERT INTO ms_board( board_no, title, content, writer, hit, like_cnt )
    VALUES ( SEQ_MS_BOARD.nextval, IN_TITLE, IN_CONTENT, V_EMP_NAME, 0, 0 );

    DBMS_OUTPUT.PUT_LINE('제목 : ' || IN_TITLE);
    DBMS_OUTPUT.PUT_LINE('내용 : ' || IN_CONTENT);
    DBMS_OUTPUT.PUT_LINE('작성자 : ' || V_EMP_NAME);
END;
/

SELECT * FROM employee;
SELECT * FROM ms_board;

EXECUTE pro_emp_write( '200', '제목', '내용' );
EXECUTE pro_emp_write( '200' );


-- 프로시저 + 조건문
-- 사원의 업무 이력을 갱신하는 프로시저
CREATE OR REPLACE PROCEDURE pro_app_emp (
    -- 파라미터
    IN_EMP_ID IN employee.employee_id%TYPE, -- 사원번호
    IN_JOB_ID IN jobs.job_id%TYPE,          -- 직무ID
    IN_STD_DATE IN DATE,                    -- 직무 시작일
    IN_END_DATE IN DATE                     -- 직무 종료일
)
IS
    -- 선언부
    V_DEPT_ID employees.department_id%TYPE;
    V_CNT NUMBER := 0;             -- 업무이력 개수 
BEGIN
    -- 실행부
    -- 1. 사원정보 조회
    SELECT department_id INTO V_DEPT_ID
    FROM employees
    WHERE employee_id = IN_EMP_ID;

    -- 2. 사원 JOB_ID 수정
    -- AC_MGR  -->  IT_PROG
    UPDATE employees
       SET job_id = IN_JOB_ID
     WHERE employee_id = IN_EMP_ID;

    -- 3. job_history 업무이력 갱신
    SELECT COUNT(*) INTO V_CNT
      FROM job_history
     WHERE employee_id = IN_EMP_ID
       AND job_id = IN_JOB_ID;

    DBMS_OUTPUT.PUT_LINE('기본업무 개수 : ' || V_CNT);

    -- 업무 이력이 없으면, 새로 추가
    IF V_CNT = 0 THEN
        INSERT INTO job_history ( employee_id, start_date, end_date, job_id, department_id )
        VALUES ( IN_EMP_ID, IN_STD_DATE, IN_END_DATE, IN_JOB_ID, V_DEPT_ID );
    -- 업무 이력이 있으면, 시작일 종료일을 변경
    ELSE
        UPDATE job_history
           SET start_date = IN_STD_DATE
              ,end_date = IN_END_DATE
        WHERE employee_id = IN_EMP_ID
          AND job_id = IN_JOB_ID;
    END IF;
END;
/


EXECUTE pro_app_emp ('103', 'IT_PROG', '2026/01/01', '2026/12/31' );
EXECUTE pro_app_emp ('103', 'AC_MGR', '2027/01/01', '2028/12/31' );

EXECUTE pro_app_emp ('103', 'AC_MGR', '2027/01/01', '2030/12/31' );

SELECT * FROM employees WHERE employee_id = 103;
SELECT * FROM job_history WHERE employee_id = 103;

DELETE FROM job_history WHERE employee_id = 103;
commit;



-- 프로시저에서 에외 처리
CREATE OR REPLACE PROCEDURE pro_print_emp (
    IN_EMP_ID IN employee.emp_id%TYPE
)
IS
    STR_EMP_INFO CLOB;     
    -- V_EMP_NAME employee.emp_name%TYPE;
    -- V_EMP_EMAIL employee.emp_eamil%TYPE;
    -- V_EMP_PHONE employee.emp_phone%TYPE;
    -- %ROWTYPE
    -- : 해당 테이블 또는 뷰의 컬럼들을 참조타입으로 선언한다 
    V_EMP employee%ROWTYPE;

BEGIN
    SELECT * INTO V_EMP
    FROM employee
    WHERE emp_id = IN_EMP_ID;

    /*
        SELECT emp_name INTO V_EMP_NAME
              ,email INTO V_EMP_EMAIL
              ,phone INTO V_EMP_PHONE
        FROM employee
        WHERE emp_id = IN_EMP_ID;
    */

    -- CHR(10) : 줄바꿈 (엔터)
    STR_EMP_INFO := '사원정보' || CHR(10) ||
                    '사원명 : ' || V_EMP.emp_name || CHR(10) ||
                    '이메일 : ' || V_EMP.email || CHR(10) ||
                    '전화번호 : ' || V_EMP.phone;
    
    DBMS_OUTPUT.PUT_LINE(STR_EMP_INFO);

    -- DBMS_OUTPUT.PUT_LINE('사원정보');
    -- DBMS_OUTPUT.PUT_LINE('사원명 : ' || V_EMP_NAME);
    -- DBMS_OUTPUT.PUT_LINE('이메일 : ' || V_EMP_EMAIL);
    -- DBMS_OUTPUT.PUT_LINE('전화번호 : ' || V_EMP_PHONE);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             STR_EMP_INFO := '존재하지 않는 사원ID 입니다.';
             DBMS_OUTPUT.PUT_LINE(STR_EMP_INFO);
END;
/

SET SERVEROUTPUT ON;
EXECUTE pro_print_emp('200');
EXECUTE pro_print_emp('300');



-- OUT 파라미터로 프로시저 사용하기
CREATE OR REPLACE PROCEDURE pro_out_emp (
    IN_EMP_ID IN employee.emp_id%TYPE,
    OUT_RESULT_STR OUT CLOB
)
IS
    V_EMP employee%ROWTYPE;
BEGIN
    SELECT * INTO V_EMP
    FROM employee
    WHERE emp_id = IN_EMP_ID;

    OUT_RESULT_STR := V_EMP.emp_id 
                      || '/' || V_EMP.emp_name 
                      || '/' || V_EMP.salary;
END;
/

SET SERVEROUTPUT ON;
DECLARE
    out_result_str CLOB;
BEGIN
    pro_out_emp('200', out_result_str);
    DBMS_OUTPUT.PUT_LINE( out_result_str );
END;
/



-- 프로시저로 OUT 파라미터 2개 이상 사용하기
CREATE OR REPLACE PROCEDURE pro_out_mul (
    IN_EMP_ID IN employee.emp_id%TYPE,
    OUT_DEPT_CODE OUT employee.dept_code%TYPE,
    OUT_JOB_CODE OUT employee.job_code%TYPE
)
IS
    V_EMP employee%ROWTYPE;

BEGIN
    SELECT * INTO V_EMP
    FROM employee
    WHERE emp_id = IN_EMP_ID;

    OUT_DEPT_CODE := V_EMP.dept_code;
    OUT_JOB_CODE := V_EMP.job_code;

END;
/

-- 프로시저 호출
-- 1) 매개변수 없거나, IN 매개변수 만 : EXCUTE 프로시저명(인자1, 인자2);
-- 2) OUT 매개변수                  : PL/SQL 블록 안에서 호출

DECLARE
    out_dept_code employee.dept_code%TYPE;
    out_job_code employee.job_code%TYPE;
BEGIN
    pro_out_mul('200', out_dept_code, out_job_code);
    DBMS_OUTPUT.PUT_LINE( out_dept_code );
    DBMS_OUTPUT.PUT_LINE( out_job_code );
END;
/


-- 함수 생성
-- 세후 급여
CREATE OR REPLACE FUNCTION func_sal_tax (
    IN_SALARY IN NUMBER
)
RETURN NUMBER
IS 
    tax NUMBER := 0.10;
    result NUMBER;
BEGIN
    result := TRUNC( IN_SALARY - ( IN_SALARY * tax ), 2 );
    RETURN result;
END;
/

SELECT emp_id
      ,emp_name
      ,salary 세전급여
      ,func_sal_tax( salary ) 세후급여
FROM employee;


