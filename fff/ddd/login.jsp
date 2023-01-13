<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.tyn.wbplus.app.App"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<%-- <title><%=App.getMessage("message.server.title") %></title> --%>
<title>TYN Project Management System</title>
<link rel="stylesheet" type="text/css" media="screen" href="<c:url value='/css/base.css'/>"/>
<link rel="stylesheet" type="text/css" media="screen" href="<c:url value='/css/login.css'/>"/>
<link rel="shortcut icon" href="<c:url value='/logo.ico'/>" type="image/x-icon"> 
 <link rel="icon" href="<c:url value='/logo.ico'/>" type="image/x-icon">

<script type="text/javascript" src="<c:url value='/js/jquery/jquery-2.1.4.js'/>"></script>
</head>
<style>
 
.log_company_ci {
	float:right;
	display:block;
	height:14px;
	margin : 15px -2px 0 0 ;
	width : 99px;
	background: url(../image/login/log_title.png) no-repeat 0 16px;
	
}  
/*  
.log_company_ci {
	display: block;
    background: url(../image/login/log_company_ci.png) no-repeat 0 16px;
    width: 183px;
    height: 165px;
    margin: 0 auto;
}
 */
 


</style>


<body id="login_body" class="log_bg" style="display: none;">
<script type="text/javascript">
window.onload = function() {
	 
	
    //if(navigator.userAgent.toLowerCase().indexOf('trident') > 0){
    	//alert('본 시스템은 Chrome 브라우저에 최적화 되어 있습니다. 타 브라우저 사용시 오류가 발생할 수 있습니다');
    //}
//    if(navigator.userAgent.toLowerCase().indexOf('chrome') < 0){
 //   	alert('본 시스템은 Chrome 브라우저에 최적화 되어 있습니다. 타 브라우저 사용시 오류가 발생할 수 있습니다');
 //   }
	
    
    if(navigator.userAgent.toLowerCase().indexOf('compatible') > 0){
    	alert('본 시스템은 Chrome 브라우저에 최적화 되어 있습니다.\n' +
    			'또한  IE의 경우 호환성보기 상태에서는 본 시스템을 사용할 수 없습니다.');
    } else if(navigator.userAgent.toLowerCase().indexOf('chrome') < 0){
    	alert('본 시스템은 Chrome 브라우저에 최적화 되어 있습니다. 타 브라우저 사용시 오류가 발생할 수 있습니다');
    }
    
    
    
    
    //프로젝트 코드 정보 비동기로 가져온다.
	getPjtCd();
	//스토리지에 저장된 코드 캐시는 삭제
	window.sessionStorage.removeItem("comcode");
	
	
	// 세션만료처리
	if (window.self !== window.parent) {
		alert("세션이 만료되었습니다.\n다시 로그인해 주시기 바랍니다.");
		top.location.href = "<c:url value='/login.do'/>";
	}
	else {
		document.getElementById("login_body").style.display = "block";
	}
	
	// 저장된아이디로딩
	if (window.localStorage) {
		var loginForm = document.forms.loginForm;
		var saveId = localStorage.getItem("loginId");
		if (saveId) {
			loginForm.rememberMe.checked = true;
			//loginForm.j_username.value = saveId;
			loginForm.j_username.value = saveId;
			
		}
	}
	
	// 로그인
	window.login = function() {
		var loginForm = document.forms.loginForm;
		
		if (loginForm.project.value == "") {
			alert("프로젝트를 선택해 주십시요.");
			return ;
		}
		
		if (loginForm.j_username.value == "") {
			alert("아이디를 입력해 주십시요.");
			loginForm.j_username.focus();
			return ;
		}
		if (loginForm.j_password.value == "") {
			alert("비밀번호를 입력해 주십시요.");
			loginForm.j_password.focus();
			return ;
		}
		
		if (window.localStorage) {
			if (loginForm.rememberMe.checked) {
				localStorage.setItem("loginId", loginForm.j_username.value);
			}
			else {
				localStorage.removeItem("loginId");
			}
		};
		//2017.03.11 장세환 추가. spring security의 로그인은 j_username와 j_password 2개의 파라미터만 사용을 한다. 
		//하지만 context-security.xml에서 로그인 인증 처리 시 사용자 테이블(USR) 에는 프로젝트ID 별로 사용자를 관리하므로
		//로그인 시 프로젝트 ID가 필요하다. 따라서 로그인 전송 시 j_username 에는 프로젝트ID + ":::" + 로그인ID로 설정하여 보내주고
		//context-security.xml 에서는 ":::"를 구분자로 하여 로그인id와 프로젝트id를 추출하여 로그인 처리 한다.
		loginForm.j_username.value = loginForm.project.value + ":::"  + loginForm.j_username.value;
		loginForm.submit();		// return true;
	}
	
	// 엔터키처리
	window.document.forms.loginForm.onkeypress = function(e) {
		if (e.keyCode === 13) {
			var src = e.target || e.srcElement;
			if (src == document.forms.loginForm.j_username || document.forms.loginForm.j_password) {
				login();
			}
		}
	}
	
	<c:if test="${not empty error}">
		var message = "${sessionScope['SPRING_SECURITY_LAST_EXCEPTION'].message}";
		if (message.length > 0) {
			alert("로그인 정보가 올바르지 않습니다.");
			return ;
		}
	</c:if>
	
	<c:if test="${not empty logout}">
	</c:if>
}
/**
 * 프로젝트 정보 가져오기
 */
function getPjtCd(){
	//var data = new FormData();
	
	$.ajax({
		async: true,
		type: "POST",
		url: "<c:url value='/NOLOGIN/getPjtInfo.do'/>",
		contentType : 'application/json;charset=UTF-8',
		processData: false,
		data: {},
		
		success: function(response, status, xhr) {
			//console.log(response);
			setProjectValue(response["grid_master"].rows);
		},
		error:function(e){  
            alert(e.responseText);  
        }  

	}); 
}

function setProjectValue(pjtList){
	var projectOptions = "";
	//projectOptions += "<option value='' selected='selected'>선택</option>";
	var i=0;
	$.each(pjtList, function(key, value){
		//select box의 option으로 조회해온 값을 세팅
		if(i==0){
        	projectOptions += "<option value='" + value.pjtId + "' selected='selected'>" + value.pjtNm +"</option>";
		}
		else{
			projectOptions += "<option value='" + value.pjtId + "'>" + value.pjtNm +"</option>";
		}
		i++;
	});
	
	
    $('#project').html(projectOptions);
	
}
</script>

<article>
	<form id="loginForm" action="<c:url value="/login"/>" method="POST" onsubmit="return true;">
	
	<section class="log_box_position">
		<div class="log_box_center">
			
			<div class="log_box">
				<div class="company_ci"></div>
				 <div class="input_top">
				 	<span class="t_sub">프로젝트12377777</span>
					<span class="f_select03 sel01">
						<select name="project"  id="project" >
								
						</select>
					</span>
					
					 
					
				</div>
				
				 
				<div class="input_top">
					<input type="text" name="j_username" class="login_input" placeholder="ID."/>
				</div>
				
				<div class="input_top">
					<!-- <div class="log_topic_txt">비밀번호</div> -->
					<input type="password" name="j_password" class="login_input" placeholder="Password."/>
				</div>
				<div class="btn_login_box">
						<!--<input type="submit"/>-->
						<a href="javascript: login();">
							<span class="btn_log_center">
								<span class="logbtn_txt">Login</span>
							</span>
						</a>
					</div>
					
					
				 <div class="idsave_btnbox">
					<div class="id_save_box">
                    <input name="remember-me" type="checkbox" class="chked_box" id="rememberMe" value="1">
                            <label for=""> 아이디저장</label>
						</div>
						
				</div>
				<div class="idsave_btnbox">
					<img src="<c:url value='/image/login/log_company_ci.png'/>"  style="display:block; float:right; width : 105px; height:14px; margin-right:34px"> 
				</div>
				
				
				  
				
				
			</div>
		</div>
	</section>
	</form>
</article>

</body>
</html>
