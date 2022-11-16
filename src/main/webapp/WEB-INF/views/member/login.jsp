<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<form action="" method="post">
		id <input type="text" name="username"> <br>
		pw <input type="text" name="password"> <br>
		<%--
		<sec:csrfInput/>
		 --%>
		<input type="submit" value="로그인">
	</form>
</body>
</html>