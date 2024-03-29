USE holidaydeco;	

-- 테이블 드랍
DROP TABLE IF EXISTS LIKE_T;
DROP TABLE IF EXISTS AMOUNT_T;
DROP TABLE IF EXISTS KAKAO_APPROVE_RESPONSE_T;
DROP TABLE IF EXISTS ORDER_CANCEL_T;
DROP TABLE IF EXISTS ORDER_DETAIL_T;
DROP TABLE IF EXISTS ITEM_ORDER_T;
DROP TABLE IF EXISTS GO_BUY_T;
DROP TABLE IF EXISTS CART_T;
DROP TABLE IF EXISTS ITEM_T;
DROP TABLE IF EXISTS SLEEP_USER_T;
DROP TABLE IF EXISTS OUT_USER_T;
DROP TABLE IF EXISTS USER_ACCESS_T;
DROP TABLE IF EXISTS USER_T;

-- -- -- -- -- -- -- -- -- --<회원> -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- 회원 테이블
CREATE TABLE USER_T (	
USER_NO        INT AUTO_INCREMENT,            -- PK회원 번호
ID             VARCHAR(50) NOT NULL UNIQUE,	  -- 회원 아이디
PW             VARCHAR(64),	                  -- 회원 비밀번호
NAME           VARCHAR(40),	                  -- 회원 이름
GENDER         VARCHAR(2),	                  -- 회원 성별
EMAIL          VARCHAR(100) NOT NULL UNIQUE,  -- 회원 이메일
MOBILE         VARCHAR(15),	                  -- 회원 전화번호
BIRTHYEAR      VARCHAR(4),	                  -- 회원 태어난 년도
BIRTHDATE      VARCHAR(4),	                  -- 회원 태어난 월일
POSTCODE       VARCHAR(5),	                  -- 우편번호
ROAD_ADDRESS   VARCHAR(100),	              -- 도로명주소
JIBUN_ADDRESS  VARCHAR(100),	              -- 지번주소
DETAIL_ADDRESS VARCHAR(100),	              -- 상세주소
EXTRA_ADDRESS  VARCHAR(100),	              -- 참고항목
AGREECODE      INT NOT NULL,	              -- 약관동의여부(0:필수, 1:위치, 2:이벤트, 3:위치+이벤트)
JOINED_AT      DATETIME,	                  -- 가입일
PW_MODIFIED_AT DATETIME,	                  -- 비밀번호 수정일
AUTOLOGIN_ID   VARCHAR(32),	                  -- 자동로그인사용아이디
AUTOLOGIN_EXPIRED_AT DATETIME,	              -- 자동로그인만료일
ADMIN_CHECK   INT DEFAULT 0,	              -- 사용자 0, 관리자 1로 구분
CONSTRAINT PK_USER_T PRIMARY KEY(USER_NO)	
	
);	
	
-- 회원 접속 기록(회원마다 마지막 로그인 날짜 1개만 기록)	
CREATE TABLE USER_ACCESS_T (	
ID VARCHAR(50)  NOT NULL UNIQUE, -- 회원 아이디(회원테이블)
LAST_LOGIN_AT   DATETIME         -- 마지막로그인날짜
);	
	
-- 탈퇴 (탈퇴한 아이디로 재가입이 불가능)	
CREATE TABLE OUT_USER_T (	
OUT_USER_NO INT AUTO_INCREMENT,             -- PK 회원번호
USER_NO     INT,							-- 회원 번호	
ID        	VARCHAR(50)  NOT NULL UNIQUE,	-- 회원 아이디
EMAIL    	VARCHAR(100) NOT NULL UNIQUE,	-- 회원 이메일
JOINED_AT 	DATETIME,	                    -- 가입일
OUT_AT    	DATETIME,                       -- 탈퇴일
CONSTRAINT FK_OUT_USER_T PRIMARY KEY(OUT_USER_NO)
);	
	
-- 휴면 (1년 이상 로그인을 안하면 휴면 처리)	
CREATE TABLE SLEEP_USER_T (	
SLEEP_USER_NO  INT NOT NULL AUTO_INCREMENT,   -- PK 휴면 회원번호
USER_NO        INT,	              			  -- FK 회원번호(회원테이블)
ID             VARCHAR(50) NOT NULL UNIQUE,	  -- 회원 아이디(회원테이블)
PW             VARCHAR(64),	                  -- 회원 비밀번호(회원테이블)
NAME           VARCHAR(40),	                  -- 회원 이름(회원테이블)
GENDER         VARCHAR(2),	                  -- 회원 성별(회원테이블)
EMAIL          VARCHAR(100) NOT NULL UNIQUE,  -- 회원 이메일(회원테이블)
MOBILE         VARCHAR(15),	                  -- 회원 전화번호(회원테이블)
BIRTHYEAR      VARCHAR(4),	                  -- 회원 태어난 년도(회원테이블)
BIRTHDATE      VARCHAR(4),	                  -- 회원 태어난 월일(회원테이블)
POSTCODE       VARCHAR(5),	                  -- 우편번호(회원테이블)
ROAD_ADDRESS   VARCHAR(100),	              -- 도로명주소(회원테이블)
JIBUN_ADDRESS  VARCHAR(100),	              -- 지번주소(회원테이블)
DETAIL_ADDRESS VARCHAR(100),	              -- 상세주소(회원테이블)
EXTRA_ADDRESS  VARCHAR(100),	              -- 참고항목(회원테이블)
AGREECODE      INT NOT NULL,	              -- 약관동의여부(회원테이블)
JOINED_AT      DATETIME,	                  -- 가입일(회원테이블)
PW_MODIFIED_AT DATETIME,	                  -- 비밀번호 수정일(회원테이블)
SLEPT_AT       DATETIME,	                  -- 휴면일
ADMIN_CHECK    INT,	                          -- 사용자, 관리자 구분(회원테이블)
CONSTRAINT PK_SLEEP_USER_T PRIMARY KEY(SLEEP_USER_NO)
);	


-- -- -- -- -- -- -- -- -- --<상품> -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- 상품 테이블
CREATE TABLE ITEM_T(	
	ITEM_NO INT NOT NULL AUTO_INCREMENT,	-- PK 상품 번호
	ITEM_TITLE VARCHAR(400) ,	        -- 상품명 
	ITEM_PRICE VARCHAR(400) ,                -- 상품 가격
	ITEM_MAIN_IMG VARCHAR(1000),	        -- 상품 메인이미지
	ITEM_DETAIL_IMG VARCHAR(1000),           -- 상품 상세이미지
	ITEM_STOCK INT,                         -- 상품 재고
    ITEM_WRITED_AT DATETIME,
	CONSTRAINT PK_ITEM_T PRIMARY KEY(ITEM_NO)
);	




-- -- -- -- -- -- -- -- -- --<장바구니> -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- 장바구니 테이블
CREATE TABLE CART_T (
    CART_NO INT NOT NULL AUTO_INCREMENT,           -- PK
    USER_NO INT NOT NULL,                          -- FK 유저번호
    ITEM_NO INT NOT NULL,                          -- FK 아이템번호
    QUANTITY INT NOT NULL,                         -- 주문수량
    ITEM_TITLE VARCHAR(40),                        -- 상품명
    ITEM_PRICE VARCHAR(40),                        -- 상품 가격
    ITEM_MAIN_IMG VARCHAR(1000),                    -- 상품 이미지
    CONSTRAINT PK_CART_T PRIMARY KEY(CART_NO),
    CONSTRAINT FK_CART_T_USER FOREIGN KEY(USER_NO) REFERENCES USER_T(USER_NO) ON DELETE CASCADE,
    CONSTRAINT FK_CART_T_ITEM FOREIGN KEY(ITEM_NO) REFERENCES ITEM_T(ITEM_NO) ON DELETE CASCADE
);


-- 바로결제 테이블
CREATE TABLE GO_BUY_T (
    CART_NO INT NOT NULL AUTO_INCREMENT,           -- PK
    USER_NO INT NOT NULL,                          -- FK 유저번호
    ITEM_NO INT NOT NULL,                          -- FK 아이템번호
    QUANTITY INT NOT NULL,                         -- 주문수량
    ITEM_TITLE VARCHAR(40),                        -- 상품명
    ITEM_PRICE VARCHAR(40),                        -- 상품 가격
    ITEM_MAIN_IMG VARCHAR(1000),                    -- 상품 이미지
    CONSTRAINT PK_GO_BUY_T PRIMARY KEY(CART_NO),
    CONSTRAINT FK_GO_BUY_T_USER FOREIGN KEY(USER_NO) REFERENCES USER_T(USER_NO) ON DELETE CASCADE,
    CONSTRAINT FK_GO_BUY_T_ITEM FOREIGN KEY(ITEM_NO) REFERENCES ITEM_T(ITEM_NO) ON DELETE CASCADE
);


-- 주문 테이블
CREATE TABLE ITEM_ORDER_T (
	ITEM_ORDER_NO          VARCHAR(20) NOT NULL,        -- PK 주문번호
	USER_NO                INT,                                   -- FK 유저번호
	ORDER_DATE             DATETIME,
	NAME                   VARCHAR(40),	                              -- 회원 이름
	MOBILE                  VARCHAR(15),	                          -- 회원 전화번호
	POSTCODE                VARCHAR(5),	                              -- 우편번호
	ROAD_ADDRESS            VARCHAR(100),			                  -- 도로명 주소 
	DETAIL_ADDRESS          VARCHAR(100),	                          -- 상세 주소
	ORDER_TOTAL             INT,                                      -- 전체 주문 금액
	IMP_UID                 VARCHAR(50),                   	          -- 아임포트 결제 번호
	PAY_METHOD              INT, 				                      -- 결제 방식 
    DELIVERY				VARCHAR(20) DEFAULT '배송준비',			  -- 배송 정보 
	CONSTRAINT PK_ITEM_ORDER_T PRIMARY KEY(ITEM_ORDER_NO),
	CONSTRAINT FK_ITEM_ORDER_T_USER_T FOREIGN KEY(USER_NO) REFERENCES USER_T(USER_NO) ON DELETE CASCADE
);

CREATE TABLE ORDER_DETAIL_T (
	ORDER_DETAIL_NO INT NOT NULL AUTO_INCREMENT,           -- PK
	ITEM_ORDER_NO VARCHAR(20),
    USER_NO INT NOT NULL,                          -- FK 유저번호
    ITEM_NO INT NOT NULL,                          -- FK 아이템번호
    QUANTITY INT NOT NULL,                         -- 주문수량
    ITEM_TITLE VARCHAR(40),                        -- 상품명
    ITEM_PRICE VARCHAR(40),                        -- 상품 가격
    ITEM_MAIN_IMG VARCHAR(1000),                    -- 상품 이미지
    CONSTRAINT PK_ORDER_DETAIL_T PRIMARY KEY(ORDER_DETAIL_NO),
    CONSTRAINT FK_ORDER_DETAIL_T_USER FOREIGN KEY(USER_NO) REFERENCES USER_T(USER_NO) ON DELETE CASCADE,
    CONSTRAINT FK_ORDER_DETAIL_T_ITEM FOREIGN KEY(ITEM_NO) REFERENCES ITEM_T(ITEM_NO) ON DELETE CASCADE,
    CONSTRAINT FK_ORDER_DETAIL_T_ITEM_ORDER FOREIGN KEY(ITEM_ORDER_NO) REFERENCES ITEM_ORDER_T(ITEM_ORDER_NO) ON DELETE CASCADE
);

	
CREATE TABLE ORDER_CANCEL_T (
    ORDER_CANCEL_NO INT NOT NULL AUTO_INCREMENT,           -- PK
    ITEM_ORDER_NO VARCHAR(20),
    USER_NO INT NOT NULL,                          -- FK 유저번호
    ORDER_TOTAL INT NOT NULL,                        
	IMP_UID VARCHAR(40) NOT NULL,                         
    CONSTRAINT PK_ORDER_CANCEL_T PRIMARY KEY(ORDER_CANCEL_NO),
    CONSTRAINT FK_ORDER_CANCEL_T_USER FOREIGN KEY(USER_NO) REFERENCES USER_T(USER_NO) ON DELETE CASCADE,
    CONSTRAINT FK_ORDER_CANCEL_T_ITEM_ORDER FOREIGN KEY(ITEM_ORDER_NO) REFERENCES ITEM_ORDER_T(ITEM_ORDER_NO) ON DELETE CASCADE
);



-- -- -- -- -- -- -- -- -- --<카카오페이> -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- 카카오페이테이블
CREATE TABLE KAKAO_APPROVE_RESPONSE_T (
	AID VARCHAR(100)   NOT NULL UNIQUE,
	TID LONGTEXT,
	CID LONGTEXT,
	SID LONGTEXT,
	PARTNER_ORDER_ID LONGTEXT,
	PARTNER_USER_ID LONGTEXT,
	PAYMENT_METHOD_TYPE LONGTEXT,
	ITEM_NAME LONGTEXT,
	ITEM_CODE LONGTEXT,
	QUANTITY INT,
	CREATED_AT DATETIME,
	APPROVED_AT DATETIME,
	CONSTRAINT PK_AID PRIMARY KEY(AID)
);


CREATE TABLE AMOUNT_T (
   TOTAL       INT      NOT NULL UNIQUE,
    TAX_FREE   INT      NULL,
    VAT        INT      NULL,
    POINT      INT      NULL,
    DISCOUNT   INT      NULL,
    CONSTRAINT PK_TOTAL PRIMARY KEY (TOTAL)
);


-- -- -- -- -- -- -- -- -- --<찜하기> -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- 찜하기 테이블
CREATE TABLE LIKE_T(	
	USER_NO INT NOT NULL,	                -- 회원 번호 
	ITEM_NO INT NOT NULL,	                -- 상품명 
	LIKE_CHECK INT DEFAULT 0,	            -- 찜하기 상태 
    CONSTRAINT FK_LIKE_T_USER FOREIGN KEY(USER_NO) REFERENCES USER_T(USER_NO) ON DELETE CASCADE,
    CONSTRAINT FK_LIKE_T_ITEM FOREIGN KEY(ITEM_NO) REFERENCES ITEM_T(ITEM_NO) ON DELETE CASCADE
);	


-- -- -- -- -- -- -- -- -- --<user Insert> -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- admin/admin1!
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT, ADMIN_CHECK)
VALUES ('admin', '437996709CDCC6223AF62072 F7652503EA225707143499EA5D34855 8BC45D1', '관리자', 'F', 'admin@naver.com', '01000000000','1998', '0105', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2023-05-01 13:01:01', 1);

-- user01/user01!
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT, ADMIN_CHECK)
VALUES ('user01', 'EC9F76A055526339 9F7D660CBBC99EB48E9A5FB3BC1B4D2C9C194 627CCAA71', '유저일', 'F', 'user01@naver.com', '01000000000','1998', '0105', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2023-11-01 13:01:01', 0);

-- user02/user02@
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT, ADMIN_CHECK)
VALUES ('user02', 'DE3089DF3F39789E8FE9295CC48AF511 D784AE6581D95312E8A6C3E E348B93', '유저이', 'M', 'user02@naver.com', '01000000000','1998', '0105', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2023-11-02 13:01:02', 0);

-- user03/user03#
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT, ADMIN_CHECK)
VALUES ('user03', '17 3FFCDBA 2E81FDA63EB6E90207D61C58B CF3A3F86E5214F3D5B28A95F9F8', '유저삼', 'M', 'user03@naver.com', '01000000000','1998', '0105', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2023-11-03 13:01:03', 0);

-- user04/user04$
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT, ADMIN_CHECK)
VALUES ('user04', 'F21122D071 489B2E69B525D22B4A96A2F 52D921BF9FDDD34AB598014 1D324', '유저사', 'M', 'user04@naver.com', '01000000000','1998', '0105', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2023-11-04 13:01:04', 0);

-- user05/user05%
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT, ADMIN_CHECK)
VALUES ('user05', '70A6E796E0 414B43217CC515E61E729C818C3EF16F320A9A0E08A5B22A3DB65', '유저오', 'M', 'user05@naver.com', '01000000000','1998', '0105', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2023-11-05 13:01:05', 0);

-- user06/user06^
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT, ADMIN_CHECK)
VALUES ('user06', '32A15B7CB8A1B4BDAF11E5CB8541B3FD3FC663C391E9 8 B40EE85A727D374F2', '유저육', 'M', 'user06@naver.com', '01000000000','1998', '0105', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2023-11-05 13:01:05', 0);

-- user07/user07&
INSERT INTO USER_T (ID , PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT, ADMIN_CHECK)
VALUES ('user07', '3E24D3BBB26E769A7581217E18BD417A1EE68A218AA640E94CFFD3EB64E4 553', '유저칠', 'F', 'user07@naver.com', '01000000000','1998', '0105', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2023-11-05 13:01:05', 0);

-- user08/user08*
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT, ADMIN_CHECK)
VALUES ('user08', '53D4C5EED9E119444355B8ACF35BDE92241813AF6FA780EC27BAA9B6ECE9A6C9', '유저팔', 'F', 'user08@naver.com', '01000000000','1998', '0105', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2022-12-03 13:01:05', 0);

-- user09/user09(
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT, ADMIN_CHECK)
VALUES ('user09', '9EA671AA55E1C428756DA15DCC1641FC8512F6E0C797 F9FCBE031B61B E2266', '유저구', 'F', 'user09@naver.com', '01000000000','1998', '0105', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2021-12-01 13:01:05', 0);

-- user10 / user10!)
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user10', 'A855A67A75ABB4B640EB387FE4F0EFAC6869E2F9EB5DEC89685E17AB5E317AE6', '유저십', 'F', 'user10@naver.com', '01000000000','1998', '0105', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2021-11-05 13:01:05', 0);

-- user11 / user11!!
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user11', ' 06C5F40595DA8 86262984EDA616D A3A 2AE1CF06C BE0BC6B B2AB1D5D0DA', '유저십일', 'M', 'user11@naver.com', '01000000000','1998', '0105', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-01-05 11:06:09', 0);

-- user12 / user12!@
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user12', '104D2CF3BC29CFEC504F85C4713C4C68F57E44908EA783ACBE3E8C5C9249C9E2', '유저십이', 'M', 'user12@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-01-05 11:06:09', 0);

-- user13 / user13!#
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user13', ' 2D2F289AB86D28ACF3DE97855 2FEDB4180E765B7352359E455F88A8E2CB362', '유저십삼', 'M', 'user13@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-01-05 11:06:09', 0);

-- user14 / user14!$
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user14', '1B 4B5F549FD6A CD539A5B1C1A95550BC243FD95E3D DDAADAC43828B356790', '유저십사', 'M', 'user14@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-01-05 11:06:09', 0);

-- user15 / user15!%
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user15', '8FF475B43C86C2C13DC6 AA5B3 8F148AC953FC7AB7FFC7E8118FAF7 2A97E51', '유저십오', 'M', 'user15@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-01-05 11:06:09', 0);

-- user16 / user16!^
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user16', 'BF F366570BA802D22652EF34A 9976A54C9F218E0D97A638EBE75F65C96 172', '유저십육', 'M', 'user16@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-01-05 11:06:09', 0);

-- user17 / user17!&
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user17', 'D61CE9AB57CD 4 1A11E5694CB9E4C1E514C438831A9E5538A6897A38B558A91', '유저십칠', 'M', 'user17@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-01-05 11:06:09', 0);

-- user18 / user18!*
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user18', 'BCD3 7C43FDEE2147BBCA2C0A35C58DB 157F41EB35FC464E4CC379A85A1432E', '유저십팔', 'M', 'user18@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-01-05 11:06:09', 0);

-- user19 / user19!(
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user19', 'CE F31ECF7AB98ABF113248CE896FF4CD171BA414D76C798BF6DEA29E8DA15D2', '유저십구', 'M', 'user19@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-01-05 11:06:09', 0);

-- user20 / user20@)
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user20', '11357AAF1416AC6E53E5916CBEDD B1B5C2CB0FA18D85F28FD C1A9DE542 F19', '유저이십', 'M', 'user20@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-01-05 11:06:09', 0);

-- user21 / user21@!
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user21', '6745D0D9E05B34BF2B9AEDF2DC5BED82F0A27758F47864653CE5E2 C8CA44B B', '유저이십일', 'F', 'user21@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-01-05 11:06:09', 0);

-- user22 / user22@@
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user22', '8B9E412693AAA54134CCC7A38DDB23C89CF628E6E277773A 7EAC036C3 CC28B', '유저이십이', 'F', 'user22@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-01-05 11:06:09', 0);

-- user23 / user23@#
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user23', '8E97C7755D1D56F65F76397BB41EF93B636D5D365F14C8 9B2F4B2 7EFAD8843', '유저이십심', 'F', 'user23@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-01-05 11:06:09', 0);

-- user24 / user24@$
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user24', 'E660F14DEE DB565B8CF15 796772A58526C3372 34055F2E14DDAC3285C8B8A', '유저이십사', 'F', 'user24@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-02-01 11:06:09', 0);

-- user25 / user25@%
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user25', 'CB6FBB466953F82D5DCCF1BD541F313DF6D9 ABBDDC52F19E449CF7DABF979CA', '유저이십오', 'F', 'user25@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-02-01 11:06:09', 0);

-- user26 / user26@^
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user26', 'FABCF37D8D90D61BC43BFFE32A 8 DF865108377418266D4B4F6B358D773DDA1', '유저이십육', 'F', 'user26@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-02-01 11:06:09', 0);

-- user27 / user27@&
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user27', '91E0B9C33E574B6BC640CEE39E9714F0628CA3185878CFFD97E2351D66E2C8B0', '유저이십칠', 'F', 'user27@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-02-01 11:06:09', 0);

-- user28 / user28@*
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user28', 'A89DF123F8 B69B0492A99AF7F1A425A91DBE7 3D3891ED73A4B9E17A53D68A6', '유저이십팔', 'F', 'user28@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-02-01 11:06:09', 0);

-- user29 / user29@(
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user29', 'EDB34240EE 9C1FED93AF574 5817C75F6 CB98F231364B758D163221F 47CEF', '유저이십구', 'F', 'user29@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-02-01 11:06:09', 0);

-- user30 / user30#)
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user30', ' DB5D0EBC09DD969 E7294 CE2493529D5 BD88A971AB09E6916AB8C3193B32B', '유저삼십', 'F', 'user30@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-02-01 11:06:09', 0);

-- user31 / user31#!
INSERT INTO USER_T (ID, PW, NAME, GENDER, EMAIL, MOBILE, BIRTHYEAR, BIRTHDATE, POSTCODE, ROAD_ADDRESS, JIBUN_ADDRESS, DETAIL_ADDRESS, EXTRA_ADDRESS, AGREECODE, JOINED_AT ,ADMIN_CHECK)
VALUES ('user31', '5B46A32B 95E A2E5AC81B2736E1 124CDD88DEF21702DFF93D93C12D5B3E0E6', '유저삼십일', 'F', 'user31@naver.com', '01000000000','1991', '1201', 34659, '대전 동구 광명길 2', '대전 동구 대동 352-1', '1-105', '(대동)', 0, '2024-02-01 11:06:09', 0);

-- -- -- -- -- -- -- -- -- --<item Insert> -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('tree paper bag','5700','/holidaydeco/storage/itemImg/상품(1).jpg','/holidaydeco/storage/itemImg/상품(1).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('cutie bear doll','12000','/holidaydeco/storage/itemImg/상품(2).jpg','/holidaydeco/storage/itemImg/상품(2).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('ornament_gold','5200','/holidaydeco/storage/itemImg/상품(3).jpg','/holidaydeco/storage/itemImg/상품(2).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('christmas candle','8900','/holidaydeco/storage/itemImg/상품(4).jpg','/holidaydeco/storage/itemImg/상품(4).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('ornament_snowman','6000','/holidaydeco/storage/itemImg/상품(5).jpg','/holidaydeco/storage/itemImg/상품(5).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('snowball','9200','/holidaydeco/storage/itemImg/상품(6).jpg','/holidaydeco/storage/itemImg/상품(6).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('christmas cookie','5000','/holidaydeco/storage/itemImg/상품(7).jpg','/holidaydeco/storage/itemImg/상품(7).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('ornament_snowman2','5300','/holidaydeco/storage/itemImg/상품(8).jpg','/holidaydeco/storage/itemImg/상품(8).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('cane candy','1200','/holidaydeco/storage/itemImg/상품(9).jpg','/holidaydeco/storage/itemImg/상품(9).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('snowball_house','15000','/holidaydeco/storage/itemImg/상품(10).jpg','/holidaydeco/storage/itemImg/상품(10).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('tree cookie tool','4500','/holidaydeco/storage/itemImg/상품(11).jpg','/holidaydeco/storage/itemImg/상품(11).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('ornament_twinkle','4600','/holidaydeco/storage/itemImg/상품(12).jpg','/holidaydeco/storage/itemImg/상품(12).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('ornament_bell','5000','/holidaydeco/storage/itemImg/상품(13).jpg','/holidaydeco/storage/itemImg/상품(13).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('ornament_horse','15700','/holidaydeco/storage/itemImg/상품(14).jpg','/holidaydeco/storage/itemImg/상품(14).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('ornament_red','5900','/holidaydeco/storage/itemImg/상품(15).jpg','/holidaydeco/storage/itemImg/상품(15).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('red candle set','22000','/holidaydeco/storage/itemImg/상품(16).jpg','/holidaydeco/storage/itemImg/상품(16).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('christmas card','3000','/holidaydeco/storage/itemImg/상품(17).jpg','/holidaydeco/storage/itemImg/상품(17).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('dishes','18200','/holidaydeco/storage/itemImg/상품(18).jpg','/holidaydeco/storage/itemImg/상품(18).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('tree wrapper','4000','/holidaydeco/storage/itemImg/상품(19).jpg','/holidaydeco/storage/itemImg/상품(19).jpg',100,NOW());
INSERT INTO ITEM_T (ITEM_TITLE, ITEM_PRICE, ITEM_MAIN_IMG, ITEM_DETAIL_IMG, ITEM_STOCK, ITEM_WRITED_AT)
VALUES ('wrapper set','8000','/holidaydeco/storage/itemImg/상품(20).jpg','/holidaydeco/storage/itemImg/상품(20).jpg',100,NOW());
