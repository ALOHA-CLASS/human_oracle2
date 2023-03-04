# ALOHA / 휴먼교육센터 오라클 데이터베이스 실습


#### ★ HR 계정 생성하기
```
[SQL]
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
CREATE USER HR IDENTIFIED BY 123456;
ALTER USER HR QUOTA UNLIMITED ON users;
GRANT DBA TO HR;
```

#### ★ HR 샘플 데이터 가져오기

```
[SQL PLUS]
@?/demo/schema/human_resources/hr_main.sql
--> 1  : 123456 [비빌번호]                                  // HR 계정 비밀번호
--> 2  : users [tablespace]             
--> 3  : temp [temp tablespace]
--> 4  : [log 경로] - C:\~\db_home\demo\schema\log          // 샘플 데이터 가져올 때, 로그파일 저장하 경로
```

<hr>

#### ★ human 계정 생성하기
```
[SQL]
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
CREATE USER human IDENTIFIED BY 123456;
ALTER USER human QUOTA UNLIMITED ON users;
GRANT DBA TO human;
```

#### ★ human 계정 에 community.dmp 가져오기
```
[CMD]
imp userid=system/123456 file='경로\community.dmp' fromuser=human touser=human
```

<hr>

#### ★ human2 계정 생성하기
```
[SQL]
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
CREATE USER human2 IDENTIFIED BY 123456;
ALTER USER human2 QUOTA UNLIMITED ON users;
GRANT DBA TO human2;
```

#### ★ human2 계정 에 human.dmp 가져오기
```
[CMD]
imp userid=system/123456 file='경로\human.dmp' fromuser=human touser=human2
```

<hr>


## CMD 창에서 덤프 명령어 사용

#### 덤프파일 가져오기 <br>
```
[CMD]
imp userid=system/123456 file='경로\덤프파일명.dmp' fromuser=덤프파일소유자명 touser=가져올계정명
```

#### 덤프파일 내보내기 <br>
```
[CMD]
exp userid=system/123456 file='경로\덤프파일명.dmp' log='경로\로그파일명.log'
```


