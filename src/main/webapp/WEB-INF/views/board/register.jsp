<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Insert title here</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-Zenh87qX5JnK2Jl0vWa8Ck2rdkQ2Bzep5IDxbcnCeuOxjzrPF/et3URy9Bv1WTRi" crossorigin="anonymous">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css" integrity="sha512-xh6O/CkQoPOWDdYTDqeRdPCVd1SpvCA9XXcUnZS2FmJNp1coAFzvtCN9BmamE+4aHK8yyUHUSCcJHgXloTyT2A==" crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>
<body>
	<my:navBar></my:navBar>
	<div class="container-md">
		<div class="row">
			<div class="col">
			
				<h1>게시물 작성</h1>
				
				<form id="registerForm1" action="" method="post" enctype="multipart/form-data">
					<div class="mb-3">
						<label for="" class="form-label">제목</label>
						<input id="titleInput" required="required" type="text" class="form-control" name="title">
					</div>
					<div class="mb-3">
						<label for="" class="form-label">본문</label>
						<textarea id="contentInput" required="required" rows="5" class="form-control" name="content"></textarea>
					</div>
					<div class="mb-3">
						<label for="" class="form-label">파일</label>
						<input multiple type="file" accept="image/*" class="form-control" name="files">
					</div>
					<div class="mb-3">
						<label for="" class="form-label">작성자</label> 
						<input value="<sec:authentication property="name"/>"
							type="text" class="form-control" name="writer" readonly>
					</div>
					<input id="submitButton1" class="btn btn-primary" type="submit" value="등록">
				</form>
				
			</div>
		</div>
	</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-OERcA2EqjJCMA+/3y+gxIOqMEjwtxJY7qPCqsdltbNJuaOe923+mo//f6V8Qbsw3" crossorigin="anonymous"></script>
<script>
	document.querySelector("#submitButton1").addEventListener("click", function(e) {
		// 공백("  ")인 경우에도 입력값 들어가지 않도록 검증
		// submit 진행 중지
		e.preventDefault();
		
		let titleInput = document.querySelector("#titleInput");
		let contentInput = document.querySelector("#contentInput");	
				
		// 필수 입력값이 모두 있는 경우에만 submit
		if (titleInput.value.trim() != "" 
				&& contentInput.value.trim() != "") {
			document.querySelector("#registerForm1").submit();
		} 
		// 필수 입력값이 없는 경우, 해당 입력창으로 커서 이동
		else {
			if (titleInput.value.trim() == "" )  titleInput.focus();
			else if (contentInput.value.trim() == "" )  contentInput.focus();
		}
	});
	
</script>
</body>
</html>