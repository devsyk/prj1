package com.study.service.board;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.study.domain.board.BoardDto;
import com.study.domain.board.PageInfo;
import com.study.mapper.board.BoardMapper;
import com.study.mapper.board.ReplyMapper;

import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.ObjectCannedACL;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

@Service
@Transactional
public class BoardService {
	
	@Autowired
	private BoardMapper boardMapper;
	
	@Autowired
	private ReplyMapper replyMapper;
	
	@Autowired
	private S3Client s3Client;
	
	@Value("${aws.s3.bucket}")
	private String bucketName;
	
	public int register(BoardDto board, MultipartFile[] files) {
		int boardId = board.getId();
		
		for (MultipartFile file : files) {
			if (file != null && file.getSize() > 0) {
				// DB에 파일 정보 저장
				boardMapper.insertFile(boardId, file.getOriginalFilename());
				
				// S3에 실제 파일 저장
				uploadFile(boardId, file);
			}
		}
		
		// DB에 게시물 정보 저장
		return boardMapper.insert(board);
	}

	public List<BoardDto> listBoard(int page, String type, String keyword, PageInfo pageInfo) {
		int records = 10;
		int offset = (page - 1) * records;
		
		int countAll = boardMapper.countAll(type, "%" + keyword + "%"); // SELECT Count(*) FROM Board
		int lastPage = (countAll - 1) / records + 1;
		
		int leftPageNumber = (page - 1) / 10 * 10 + 1;
		int rightPageNumber = leftPageNumber + 9;
		rightPageNumber = Math.min(rightPageNumber, lastPage);
		
		// 이전버튼 유무
		boolean hasPrevButton = page > 10;
		// 다음버튼 유무
		boolean hasNextButton = page <= ((lastPage - 1) / 10 * 10);

		// 이전버튼 눌렀을 때 가는 페이지 번호
		int jumpPrevPageNumber = (page - 1) / 10 * 10 - 9;
		int jumpNextPageNumber = (page - 1) / 10 * 10 + 11; 

		pageInfo.setHasPrevButton(hasPrevButton);
		pageInfo.setHasNextButton(hasNextButton);
		pageInfo.setJumpPrevPageNumber(jumpPrevPageNumber);
		pageInfo.setJumpNextPageNumber(jumpNextPageNumber);
				
		pageInfo.setCurrentPageNumber(page);
		pageInfo.setLeftPageNumber(leftPageNumber);
		pageInfo.setRightPageNumber(rightPageNumber);
		pageInfo.setLastPageNumber(lastPage);
		
		return boardMapper.list(offset, records, type, "%" + keyword + "%");
	}


	public BoardDto get(int id) {
		return boardMapper.select(id);
	}

	public int update(BoardDto board, MultipartFile[] addFiles, List<String> removeFiles) {
		int boardId = board.getId();
		
		// 기존 파일 삭제
		if (removeFiles != null) {
			for (String fileName : removeFiles) {
				// DB(File 테이블)에서 삭제할 파일 정보 삭제
				boardMapper.deleteFileByBoardIdAndFileName(boardId, fileName);
				
				// S3에서 실제 파일 삭제
				deleteFile(boardId, fileName);
			}
		}
		
		// 파일 추가 업로드
		for (MultipartFile file : addFiles) {
			if (file != null && file.getSize() > 0) {
				String name = file.getOriginalFilename();
				
				// DB(File 테이블)에서 해당 파일명 정보 삭제 - 중복 파일명 업로드 방지
				boardMapper.deleteFileByBoardIdAndFileName(boardId, name);
				
				// 추가 파일 정보 저장
				boardMapper.insertFile(boardId, name);
				
				// S3에 실제 파일 저장
				uploadFile(boardId, file);
			}
		}
		
		// DB의 게시물 정보 수정
		return boardMapper.update(board);
	}
	
	public int remove(int id) {
		BoardDto board = boardMapper.select(id);
		List<String> fileNames = board.getFileName();
				
		if (fileNames != null) {
			for (String fileName : fileNames) {
				// DB에서 파일 정보 삭제
				boardMapper.deleteFileByBoardId(id);

				// S3에서 실제 파일 삭제
				deleteFile(id, fileName);
			}
		}	
		
		// 게시물 댓글 삭제
		replyMapper.deleteByBoardId(id);
				
		// 게시물 삭제
		return boardMapper.delete(id);
	}
	
	/* 파일 업로드 - S3 */
	private void uploadFile(int id, MultipartFile file) {
		try {
			String key = "prj1/board/" + id + "/" + file.getOriginalFilename();

			PutObjectRequest putObjectRequest = PutObjectRequest.builder()
					.bucket(bucketName).key(key)
					.acl(ObjectCannedACL.PUBLIC_READ)
					.build();
			
			RequestBody requestBody = RequestBody.fromInputStream(file.getInputStream(), file.getSize());
			
			s3Client.putObject(putObjectRequest, requestBody);
			
		} catch (Exception e) {
			e.printStackTrace();
			throw new RuntimeException(e);
		}
	}
	
	/* 파일 삭제 - S3 */
	private void deleteFile(int id, String fileName) {
		String key = "prj1/board/" + id + "/" + fileName;
		
		DeleteObjectRequest deleteObjectRequest = DeleteObjectRequest.builder()
				.bucket(bucketName).key(key)
				.build();
		
		s3Client.deleteObject(deleteObjectRequest);
	}
	
}
