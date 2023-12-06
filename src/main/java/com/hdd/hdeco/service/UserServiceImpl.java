package com.hdd.hdeco.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.security.SecureRandom;
import java.sql.Date;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.hdd.hdeco.domain.OutUserDTO;
import com.hdd.hdeco.domain.SleepUserDTO;
import com.hdd.hdeco.domain.UserDTO;
import com.hdd.hdeco.mapper.UserMapper;
import com.hdd.hdeco.util.JavaMailUtil;
import com.hdd.hdeco.util.SecurityUtil;
import com.sun.mail.util.logging.MailHandler;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class UserServiceImpl implements UserService {

	// field
	private final UserMapper userMapper;
	private final JavaMailUtil javaMailUtil;
	private final SecurityUtil securityUtil;
	
	
	@Override
	public Map<String, Object> verifyId(String id) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("enableId", userMapper.selectUserById(id) == null && userMapper.selectSleepUserById(id) == null
				&& userMapper.selectOutUserById(id) == null);
		return map;
	}

	@Override
	public Map<String, Object> verifyEmail(String email) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("enableEmail",
				userMapper.selectUserByEmail(email) == null && userMapper.selectSleepUserByEmail(email) == null
						&& userMapper.selectOutUserByEmail(email) == null);
		return map;
	}

	// 이메일 인증코드 발송
	@Override
	public Map<String, Object> sendAuthCode(String email) {

		// 사용자에게 전송할 인증코드 6자리
		String authCode = securityUtil.getRandomString(6, true, true); // 6자리, 문자사용, 숫자사용
		MailHandler sendMail = new MailHandler();
		sendMail.setSubject("[HolidayDeco 인증메일 입니다.]");
		javaMailUtil.sendJavaMail(email, "[HolidayDeco] 인증메일 입니다.", "<h2>HolidayDeco 회원가입 메일 인증</h2><br><br>HolidayDeco에 오신 것을 환영합니다!<br>아래 '이메일 인증 코드'를 확인해주세요!<br>인증번호는 <strong>" + authCode + "</strong>입니다.");

		// 사용자에게 전송한 인증코드를 join.jsp로 응답
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("authCode", authCode);
		return map;

	}

	@Override
	public void join(HttpServletRequest request, HttpServletResponse response) {

		// 요청 파라미터
		String id = request.getParameter("id");
		String pw = request.getParameter("pw");
		String name = request.getParameter("name");
		String gender = request.getParameter("gender");
		String email = request.getParameter("email");
		String mobile = request.getParameter("mobile");
		String birthyear = request.getParameter("birthyear");
		String birthmonth = request.getParameter("birthmonth");
		String birthdate = request.getParameter("birthdate");
		String postcode = request.getParameter("postcode");
		String roadAddress = request.getParameter("roadAddress");
		String jibunAddress = request.getParameter("jibunAddress");
		String detailAddress = request.getParameter("detailAddress");
		String extraAddress = request.getParameter("extraAddress");
		String location = request.getParameter("location");
		String event = request.getParameter("event");

		// 비밀번호 SHA-256 암호화
		pw = securityUtil.getSha256(pw);
		// 이름 XSS 처리
		name = securityUtil.preventXSS(name);

		// 출생월일
		birthdate = birthmonth + birthdate;

		// 상세주소 XSS 처리
		detailAddress = securityUtil.preventXSS(detailAddress);

		// 참고항목 XSS 처리
		extraAddress = securityUtil.preventXSS(extraAddress);

		// agreecode
		int agreecode = 0;
		if (location.isEmpty() == false && event.isEmpty() == false) {
			agreecode = 3;
		} else if (location.isEmpty() && event.isEmpty() == false) {
			agreecode = 2;
		} else if (location.isEmpty() == false && event.isEmpty()) {
			agreecode = 1;
		}
		// UserDTO 만들기
		UserDTO userDTO = new UserDTO();
		userDTO.setId(id);
		userDTO.setPw(pw);
		userDTO.setName(name);
		userDTO.setGender(gender);
		userDTO.setEmail(email);
		userDTO.setMobile(mobile);
		userDTO.setBirthyear(birthyear);
		userDTO.setBirthdate(birthdate);
		userDTO.setPostcode(postcode);
		userDTO.setRoadAddress(roadAddress);
		userDTO.setJibunAddress(jibunAddress);
		userDTO.setDetailAddress(detailAddress);
		userDTO.setExtraAddress(extraAddress);
		userDTO.setAgreecode(agreecode);

		// 회원가입(UserDTO를 DB로 보내기)
		int joinResult = userMapper.insertUser(userDTO);

		// 응답
		try {

			response.setContentType("text/html; charset=UTF-8");
			PrintWriter out = response.getWriter();
			out.println("<script>");
			if (joinResult == 1) {
				out.println("alert('회원 가입되었습니다.');");
				out.println("location.href='" + request.getContextPath() + "/index.do';");
			} else {
				out.println("alert('회원 가입에 실패했습니다.');");
				out.println("history.go(-2);");
			}
			out.println("</script>");
			out.flush();
			out.close();

		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	@Override
	public void login(HttpServletRequest request, HttpServletResponse response) {

		// 요청 파라미터
		String url = request.getParameter("url"); // 로그인 화면의 이전 주소(로그인 후 되돌아갈 주소)
		String id = request.getParameter("id");
		String pw = request.getParameter("pw");

		// 비밀번호 SHA-256 암호화
		pw = securityUtil.getSha256(pw);

		// UserDTO 만들기
		UserDTO userDTO = new UserDTO();
		userDTO.setId(id);
		userDTO.setPw(pw);

		// DB에서 UserDTO 조회하기
		UserDTO loginUserDTO = userMapper.selectUserByUserDTO(userDTO);

		// ID, PW가 일치하는 회원이 있으면 로그인 성공
		// 0. 자동 로그인 처리하기(autologin 메소드에 맡기기)
		// 1. session에 ID 저장하기
		// 2. 회원 접속 기록 남기기
		// 3. 이전 페이지로 이동하기
		if (loginUserDTO != null) {
			
			// 자동 로그인 처리를 위한 autologin 메소드 호출하기
      autologin(request, response);

			HttpSession session = request.getSession();
			session.setAttribute("loginId", id);
			session.setAttribute("loginName", loginUserDTO.getName());
			session.setAttribute("adminChk", loginUserDTO.getAdminCheck()); // AdminCheck 값 가져와서 session에 담기

			int updateResult = userMapper.updateUserAccess(id);
			if (updateResult == 0) {
				userMapper.insertUserAccess(id);
			}

			try {
				response.sendRedirect(url);
			} catch (Exception e) {
				e.printStackTrace();
			}

		}
		// ID, PW가 일치하는 회원이 없으면 로그인 실패
		else {

			// 응답
			try {

				response.setContentType("text/html; charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.println("<script>");
				out.println("alert('일치하는 회원 정보가 없습니다.');");
				out.println("location.href='" + request.getContextPath() + "/';");
				out.println("</script>");
				out.flush();
				out.close();

			} catch (Exception e) {
				e.printStackTrace();
			}

		}

	}
	

	@Override
  public void autologin(HttpServletRequest request, HttpServletResponse response) {
    
    /*
      자동 로그인 처리하기
      
      1. 자동 로그인을 체크한 경우
        1) session의 id를 DB의 AUTOLOGIN_ID 칼럼에 저장한다. (중복이 없고, 다른 사람이 알기 어려운 정보를 이용해서 자동 로그인에서 사용할 ID를 결정한다.)
        2) 자동 로그인을 유지할 기간(예시 : 15일)을 DB의 AUTOLOGIN_EXPIRED_AT 칼럼에 저장한다.
        3) session의 id를 쿠키로 저장한다. (쿠키 : 각 사용자의 브라우저에 저장되는 정보)
           이 때 쿠키의 유지 시간을 자동 로그인을 유지할 기간과 동일하게 맞춘다.
      
      2. 자동 로그인을 체크하지 않은 경우
        1) DB에 저장된 AUTOLOGIN_ID 칼럼과 AUTOLOGIN_EXPIRED_AT 칼럼의 정보를 삭제한다.
        2) 쿠키를 삭제한다.
    */
    
    // 요청 파라미터
    String id = request.getParameter("id");
    String chkAutologin = request.getParameter("chkAutologin");
    
    // 자동 로그인을 체크한 경우
    if(chkAutologin != null) {
      
      // session의 id를 가져온다.
      HttpSession session = request.getSession();
      String sessionId = session.getId();  // session.getId() :  JSESSIONID으로 저장되는 임의의 값
      
      // DB로 보낼 UserDTO 만들기
      UserDTO userDTO = new UserDTO();
      userDTO.setId(id);
      userDTO.setAutologinId(sessionId);
      userDTO.setAutologinExpiredAt(new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 24 * 15));
                                    // 현재 + 15일 : java.sql.Date 클래스를 이용해서 작업을 수행한다.
                                    // java.sql.Date 클래스는 타임스탬프를 이용해서 날짜를 생성한다.
      
      // DB로 UserDTO 보내기
      userMapper.insertAutologin(userDTO);
      
      // session id를 쿠키에 저장하기
      Cookie cookie = new Cookie("autologinId", sessionId);
      cookie.setMaxAge(60 * 60 * 24 * 15);      // 초 단위로 15일 지정
      cookie.setPath("/");
      response.addCookie(cookie);
      
    }
    // 자동 로그인을 체크하지 않은 경우
    else {
      
      // DB에서 AUTOLOGIN_ID 칼럼과 AUTOLOGIN_EXPIRED_AT 칼럼 정보 삭제하기
      userMapper.deleteAutologin(id);
      
      // autologinId 쿠키 삭제하기
      Cookie cookie = new Cookie("autologinId", "");
      cookie.setMaxAge(0);                       // 쿠키 유지시간을 0초로 설정
      cookie.setPath("/");  // autologinId 쿠키의 path와 동일하게 설정
      response.addCookie(cookie);
      
    }
    
  }
	
	@Override
	public void logout(HttpServletRequest request, HttpServletResponse response) {
		// 1. 자동 로그인을 해제한다.

		// DB에서 AUTOLOGIN_ID 칼럼과 AUTOLOGIN_EXPIRED_AT 칼럼 정보 삭제하기
		// session에 저장된 모든 정보를 지운다.
		HttpSession session = request.getSession();
		String id = (String) session.getAttribute("loginId");
		userMapper.deleteAutologin(id);

		// autoLoginId 쿠키 삭제하기
		Cookie cookie = new Cookie("autologinId", "");
		cookie.setMaxAge(0); // 쿠키 유지시간을 0초로 설정
		cookie.setPath("/"); // autologinId 쿠키의 path와 동일하게 설정
		response.addCookie(cookie);

		// 2. session에 저장된 모든 정보를 지운다.
		session.invalidate();

	}
	
	@Override
	public void out(HttpServletRequest request, HttpServletResponse response) {
	// 탈퇴할 회원의 ID는 session에 loginId 속성으로 저장되어 있다.
				HttpSession session = request.getSession();
				String id = (String) session.getAttribute("loginId");

				// 탈퇴할 회원의 정보(USER_NO, ID, EMAIL, JOINED_AT) 가져오기
				UserDTO userDTO = userMapper.selectUserById(id);

				// OutUserDTO 만들기()
				OutUserDTO outUserDTO = new OutUserDTO();
				// outUSerDTO에 userNo,id,email,joinedAt 정보담기
				outUserDTO.setUserNo(userDTO.getUserNo());
				outUserDTO.setId(id);
				outUserDTO.setEmail(userDTO.getEmail());
				outUserDTO.setJoinedAt(userDTO.getJoinedAt());

				// 회원 탈퇴하기
				int insertResult = userMapper.insertOutUser(outUserDTO);
				int deleteResult = userMapper.deleteUser(id);

				// 응답
				try {

					response.setContentType("text/html; charset=UTF-8");
					PrintWriter out = response.getWriter();
					out.println("<script>");
					if (insertResult == 1 && deleteResult == 1) {

						// session 초기화
						session.invalidate();

						out.println("alert('회원 탈퇴되었습니다.');");
						out.println("location.href='" + request.getContextPath() + "/index.do';");

					} else {
						out.println("alert('회원 탈퇴에 실패했습니다.');");
						out.println("history.back();");
					}
					out.println("</script>");
					out.flush();
					out.close();

				} catch (Exception e) {
					e.printStackTrace();
				}
	
	}
	
	@Override
	public void sleepUserHandle() {
		 int insertResult = userMapper.insertSleepUser();
	    if(insertResult > 0) {
	      userMapper.deleteUserForSleep();
	    }
		
	}
	
	@Override
  public void restore(HttpServletRequest request, HttpServletResponse response) {
    
    // 복원할 아이디는 session에 sleepUserId로 저장되어 있다.
    HttpSession session = request.getSession();
    String id = (String) session.getAttribute("sleepUserId");
    
    // 복원
    int insertResult = userMapper.insertRestoreUser(id);
    int deleteResult = userMapper.deleteSleepUser(id);
    
    // 응답
    try {

      response.setContentType("text/html; charset=UTF-8");
      PrintWriter out = response.getWriter();
      
      out.println("<script>");
      if(insertResult == 1 && deleteResult == 1) {
        session.removeAttribute("sleepUserId");  // session에 저장된 sleepUserId 제거
        out.println("alert('휴면 계정이 복구되었습니다. 휴면 계정 활성화를 위해서 곧바로 로그인 해 주세요.');");
        out.println("location.href='/';");  // 로그인이 필요하지만 로그인 페이지로 보내지 말자!(여기서 로그인 페이지로 이동하게 되면 로그인 후 referer에 의해서 다시 restore 과정으로 돌아온다.) 
      } else {
        out.println("alert('휴면 계정이 복구되지 않았습니다. 다시 시도하세요.');");
        out.println("history.back();");
      }
      out.println("</script>");
      out.flush();
      out.close();
      
    } catch (Exception e) {
      e.printStackTrace();
    }
    
  }
  
	
	@Override
	public UserDTO getUserById(String id) {
		return userMapper.selectUserById(id);
	}
	
	@Override
	public boolean checkPw(HttpServletRequest request) {
		// 로그인한 사용자의 ID
    HttpSession session = request.getSession();
    String id = (String) session.getAttribute("loginId");

    // 로그인한 사용자의 정보를 가져옴(비밀번호를 확인하기 위해서)
    UserDTO userDTO = userMapper.selectUserById(id);
    
    // 사용자가 입력한 PW
    String pw = securityUtil.getSha256(request.getParameter("pw"));
    
    // PW 비교 결과 반환
    return pw.equals(userDTO.getPw());
	}
	
	@Override
	public Map<String, Object> findId(String name, String email) {
		Map<String,Object> map = new HashMap<String, Object>(); 
		 UserDTO userDTO = new UserDTO();
		 userDTO.setName(name);
		 userDTO.setEmail(email);
		 map.put("findUser",userMapper.selectFindUserId(userDTO)); 
		 return map; 
	}
	
	@Override
	public Map<String, Object> findPw(UserDTO userDTO) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("findUser", userMapper.selectUserById(userDTO.getId()));  // 비밀번호 찾기 : 입력한 아이디로 조회
		return map;
	}
	
	@Override
	public Map<String, Object> sendTempPw(UserDTO userDTO) {
		 // 8자리 임시비밀번호 생성
    String tempPw = securityUtil.getRandomString(8, true, true);
    
    // DB로 보낼 UserDTO (아이디가 일치하는 회원의 비밀번호 업데이트)
    userDTO.setPw(securityUtil.getSha256(tempPw));

    // 임시비밀번호로 User의 DB 정보 수정
    int pwUpdateResult = userMapper.updateUserPassword(userDTO);
    
    // 임시비밀번호로 User의 DB 정보가 수정되면 이메일로 알림
    if(pwUpdateResult == 1) {
      
      // 메일 내용
      String text = "";
      text += "<div>비밀번호가 초기화되었습니다.</div>";
      text += "<div>임시비밀번호 : <strong>" + tempPw + "</strong></div>";
      text += "<div>임시비밀번호로 로그인 후에 반드시 비밀번호를 변경해 주세요.</div>";
      
      // 메일 전송
      javaMailUtil.sendJavaMail(userDTO.getEmail(), "[HolidayDeco]임시비밀번호발급안내", text);
      
    }
    
    // 결과 반환
    Map<String, Object> map = new HashMap<String, Object>();
    map.put("pwUpdateResult", pwUpdateResult);
    return map;
	}
	
	
	@Override
	public Map<String, Object> modifyPw(HttpServletRequest request) {
		// 로그인한 사용자의 ID
    HttpSession session = request.getSession();
    String id = (String) session.getAttribute("loginId");
    
    // 사용자가 입력한 PW (이 PW로 비밀번호를 변경해야 한다.)
    String pw = securityUtil.getSha256(request.getParameter("pw"));
    
    // ID와 PW를 가진 UserDTO를 생성
    UserDTO userDTO = new UserDTO();
    userDTO.setId(id);
    userDTO.setPw(pw);
    
    // PW 수정 결과 반환
    Map<String, Object> map = new HashMap<String, Object>();
    map.put("updateUserPasswordResult", userMapper.updateUserPassword(userDTO));
    return map;
	}
	
	@Override
	public Map<String, Object> modifyEmail(HttpServletRequest request) {
		// 로그인한 사용자의 ID
    HttpSession session = request.getSession();
    String id = (String) session.getAttribute("loginId");
    
    // 사용자가 입력한 Email (이 Email로 이메일을 변경해야 한다.)
    String email = request.getParameter("email");
    
    // ID와 Email를 가진 UserDTO를 생성
    UserDTO userDTO = new UserDTO();
    userDTO.setId(id);
    userDTO.setEmail(email);
    
    // Email 수정 결과 반환
    Map<String, Object> map = new HashMap<String, Object>();
    map.put("updateUserEmailResult", userMapper.updateUserEmail(userDTO));
    return map;
    
	}
	
	@Override
	public Map<String, Object> modifyInfo(HttpServletRequest request) {
	// 요청 파라미터
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String gender = request.getParameter("gender");
    String mobile = request.getParameter("mobile");
    String birthyear = request.getParameter("birthyear");
    String birthmonth = request.getParameter("birthmonth");
    String birthdate = request.getParameter("birthdate");
    String postcode = request.getParameter("postcode");
    String roadAddress = request.getParameter("roadAddress");
    String jibunAddress = request.getParameter("jibunAddress");
    String detailAddress = request.getParameter("detailAddress");
    String extraAddress = request.getParameter("extraAddress");
    String location = request.getParameter("location");  // on 또는 off
    String event = request.getParameter("event");        // on 또는 off
    
    // 이름 XSS 처리
    name = securityUtil.preventXSS(name);
    
    // 출생월일
    birthdate = birthmonth + birthdate;
    
    // 상세주소 XSS 처리
    detailAddress = securityUtil.preventXSS(detailAddress);
    
    // 참고항목 XSS 처리
    extraAddress = securityUtil.preventXSS(extraAddress);
    
    // agreecode
    int agreecode = 0;
    if(location.equals("on")) { agreecode += 1; }
    if(event.equals("on"))    { agreecode += 2; }
    
    // UserDTO 만들기
    UserDTO userDTO = new UserDTO();
    userDTO.setId(id);
    userDTO.setName(name);
    userDTO.setGender(gender);
    userDTO.setMobile(mobile);
    userDTO.setBirthyear(birthyear);
    userDTO.setBirthdate(birthdate);
    userDTO.setPostcode(postcode);
    userDTO.setRoadAddress(roadAddress);
    userDTO.setJibunAddress(jibunAddress);
    userDTO.setDetailAddress(detailAddress);
    userDTO.setExtraAddress(extraAddress);
    userDTO.setAgreecode(agreecode);
    
    // Info 수정 결과 반환
    Map<String, Object> map = new HashMap<String, Object>();
    map.put("updateUserInfoResult", userMapper.updateUserInfo(userDTO));
    return map;
    
	}
	
	
	
	 /******************************************************************************************/
  /*** 네이버개발자센터 > Products > 네이버 로그인 > "네이버 로그인 API"를 이용 신청할 것 ***/
  /*** 제공 정보 6가지 : 회원이름, 연락처 이메일 주소, 성별, 생일, 출생연도, 휴대전화번호 ***/
  /******************************************************************************************/
	@Value("${naver.client_id}")
	private String naverClientId;

	@Value("${naver.client_secret}")
	private String naverClientSecret;
  
  @Override
  public String getNaverLoginApiURL(HttpServletRequest request) {
      
    String apiURL = null;
    
    try {
      
      String redirectURI = URLEncoder.encode("http://localhost:8080/user/naver/login.do", "UTF-8");
      SecureRandom secureRandom = new SecureRandom();
      String state = new BigInteger(130, secureRandom).toString();
      
      apiURL = "https://nid.naver.com/oauth2.0/authorize?response_type=code";
      apiURL += "&client_id=" + naverClientId;
      apiURL += "&redirect_uri=" + redirectURI;
      apiURL += "&state=" + state;
      
      HttpSession session = request.getSession();
      session.setAttribute("state", state);
      
    } catch (Exception e) {
      e.printStackTrace();
    }
    
    return apiURL;
    
  }
  
  @Override
  public String getNaverLoginToken(HttpServletRequest request) {
    
    // access_token 받기
    
    String code = request.getParameter("code");
    String state = request.getParameter("state");
    
    String redirectURI = null;
    try {
      redirectURI = URLEncoder.encode("http://localhost:8080" + request.getContextPath(), "UTF-8");
    } catch(UnsupportedEncodingException e) {
      e.printStackTrace();
    }
    
    StringBuffer res = new StringBuffer();  // StringBuffer는 StringBuilder와 동일한 역할을 수행한다.
    try {
      
      String apiURL;
      apiURL = "https://nid.naver.com/oauth2.0/token?grant_type=authorization_code&";
      apiURL += "client_id=" + naverClientId;
      apiURL += "&client_secret=" + naverClientSecret;
      apiURL += "&redirect_uri=" + redirectURI;
      apiURL += "&code=" + code;
      apiURL += "&state=" + state;
      
      URL url = new URL(apiURL);
      HttpURLConnection con = (HttpURLConnection)url.openConnection();
      con.setRequestMethod("GET");
      int responseCode = con.getResponseCode();
      BufferedReader br;
      if(responseCode == 200) {
        br = new BufferedReader(new InputStreamReader(con.getInputStream()));
      } else {
        br = new BufferedReader(new InputStreamReader(con.getErrorStream()));
      }
      String inputLine;
      while ((inputLine = br.readLine()) != null) {
        res.append(inputLine);
      }
      br.close();
      con.disconnect();
      
      /*
        res.toString() 출력 예시
        
        {
          "access_token":"AAAANipjD0VEPFITQ50DR__AgNpF2hTecVHIe9v-_uoyK5eP1mfdYX57bM3VTF_x4cWgz0v2fQlZsOOjl9uS0j8CLI4",
          "refresh_token":"2P9T9LTrnjaBf8XwF87a2UNUL4isfvk3QyLF8U1MDmju5ViiSXNSxii80ii8kvZWDiiYSiptFFYsuwqWl6C8n59NwoAEU6MmipfIis2htYMnZUlutzvRexh0PIZzzqqK3HlGYttJ",
          "token_type":"bearer",
          "expires_in":"3600"
        }
      */
    
    } catch (Exception e) {
      e.printStackTrace();
    }
      
    JSONObject obj = new JSONObject(res.toString());
    String accessToken = obj.getString("access_token");
    return accessToken;
    
  }
  
  @Override
  public UserDTO getNaverLoginProfile(String accessToken) {
    
    // accessToken을 이용해서 회원정보(profile) 받기
    String header = "Bearer " + accessToken;
    
    StringBuffer sb = new StringBuffer();
    
    try {
      
      String apiURL = "https://openapi.naver.com/v1/nid/me";
      URL url = new URL(apiURL);
      HttpURLConnection con = (HttpURLConnection)url.openConnection();
      con.setRequestMethod("GET");
      con.setRequestProperty("Authorization", header);
      int responseCode = con.getResponseCode();
      BufferedReader br;
      if(responseCode == 200) {
        br = new BufferedReader(new InputStreamReader(con.getInputStream()));
      } else {
        br = new BufferedReader(new InputStreamReader(con.getErrorStream()));
      }
      String inputLine;
      while ((inputLine = br.readLine()) != null) {
        sb.append(inputLine);
      }
      br.close();
      con.disconnect();
      
      /*
        sb.toString()
        
        {
          "resultcode": "00",
          "message": "success",
          "response": {
            "id":"asdfghjklqwertyuiopzxcvbnmadfafrgbgfg",
            "gender":"M",
            "email":"hahaha@naver.com",
            "mobile":"010-1111-1111",
            "mobile_e164":"+821011111111",
            "name":"\ubbfc\uacbd\ud0dc",
            "birthday":"10-10",
            "birthyear":"1990"
          }
        }
      */
      
    } catch (Exception e) {
      e.printStackTrace();
    }
    
    // 받아온 profile을 UserDTO로 만들어서 반환
    UserDTO userDTO = null;
    try {
      
      JSONObject profile = new JSONObject(sb.toString()).getJSONObject("response");
      String id = profile.getString("id");
      String name = profile.getString("name");
      String gender = profile.getString("gender");
      String email = profile.getString("email");
      String mobile = profile.getString("mobile").replaceAll("-", "");
      String birthyear = profile.getString("birthyear");
      String birthday = profile.getString("birthday").replace("-", "");
      
      userDTO = new UserDTO();
      userDTO.setId(id);
      userDTO.setName(name);
      userDTO.setGender(gender);
      userDTO.setEmail(email);
      userDTO.setMobile(mobile);
      userDTO.setBirthyear(birthyear);
      userDTO.setBirthdate(birthday);
      
    } catch (Exception e) {
      e.printStackTrace();
    }
      
    return userDTO;
    
  }
  
  @Transactional
  @Override
  public void naverLogin(HttpServletRequest request, HttpServletResponse response, UserDTO naverUserDTO) {
    
    /**********************************************************************/
    /****** 로그인 이전에 휴면계정(휴면 테이블에 정보가 있는지) 확인 ******/
    /****** SleepUserCheckInterceptor 코드를 옮겨온 뒤 인터셉터 제거 ******/
    /**********************************************************************/
    String id = naverUserDTO.getId();
    SleepUserDTO sleepUserDTO = userMapper.selectSleepUserById(id);
    if(sleepUserDTO != null) {                     // 휴면계정이라면(휴면 테이블에 정보가 있다면) 휴면복원페이지로 이동한다.
      HttpSession session = request.getSession();  // session에 sleepUserId를 올려 놓으면 wakeup.jsp에서 휴면회원의 아이디를 확인할 수 있다.
      session.setAttribute("sleepUserId", id);
      try {
        response.sendRedirect(request.getContextPath() + "/user/wakeup.html");  // 휴면복원페이지로 이동한다.
      } catch(Exception e) {
        e.printStackTrace();
      }
    }
    /**********************************************************************/
    
    // 로그인 처리
    HttpSession session = request.getSession();
    String loginName = naverUserDTO.getName();
    int adminChk = naverUserDTO.getAdminCheck();
    
    session.setAttribute("loginId", id);
    session.setAttribute("loginName", loginName);
    session.setAttribute("adminChk", adminChk); // AdminCheck 값 가져와서 session에 담기
    
    // 로그인 기록 남기기
    int updateResult = userMapper.updateUserAccess(id);
    if(updateResult == 0) {
      userMapper.insertUserAccess(id);
    }
    
  }
  
  @Override
  public void naverJoin(HttpServletRequest request, HttpServletResponse response) {
    
    // 파라미터
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String gender = request.getParameter("gender");
    String mobile = request.getParameter("mobile");
    String birthyear = request.getParameter("birthyear");
    String birthmonth = request.getParameter("birthmonth");
    String birthdate = request.getParameter("birthdate");
    String email = request.getParameter("email");
    String location = request.getParameter("location");
    String event = request.getParameter("event");
    
    // 출생월일 4자리
    birthdate = birthmonth + birthdate;
    
    // 비밀번호 SHA-256 암호화
    String pw = securityUtil.getSha256(birthyear + birthdate);  // // 생년월일을 초기비번 8자리로 제공하기로 한다.
    
    // 이름 XSS 처리
    name = securityUtil.preventXSS(name);
    
    // agreecode
    int agreecode = 0;
    if(location != null) { agreecode += 1; }
    if(event != null)    { agreecode += 2; }
    
    // UserDTO 만들기
    UserDTO userDTO = new UserDTO();
    userDTO.setId(id);
    userDTO.setPw(pw);
    userDTO.setName(name);
    userDTO.setGender(gender);
    userDTO.setEmail(email);
    userDTO.setMobile(mobile);
    userDTO.setBirthyear(birthyear);
    userDTO.setBirthdate(birthdate);
    userDTO.setAgreecode(agreecode);
        
    // 회원가입처리
    int naverJoinResult = userMapper.insertNaverUser(userDTO);
    
    // 응답
    try {
      
      response.setContentType("text/html; charset=UTF-8");
      PrintWriter out = response.getWriter();
      out.println("<script>");
      if(naverJoinResult == 1) {
        out.println("alert('네이버 간편가입이 완료되었습니다. 초기 비밀번호는 생년월일 8자리 숫자(예시: 20201217) 입니다.');");
        out.println("location.href='/';");
      } else {
        out.println("alert('네이버 간편가입이 실패했습니다.');");
        out.println("history.go(-2);");
      }
      out.println("</script>");
      out.flush();
      out.close();
      
    } catch (Exception e) {
      e.printStackTrace();
    }
    
  }

	
}