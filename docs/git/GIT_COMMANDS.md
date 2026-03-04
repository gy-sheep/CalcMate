# Git 명령어 모음

## 브랜치

```bash
# 현재 브랜치 확인
git branch

# 원격 포함 전체 브랜치 확인
git branch -a

# 브랜치 생성 + 이동
git checkout -b feat/기능명

# 브랜치 이동
git checkout 브랜치명

# 브랜치 삭제 (로컬)
git branch -d 브랜치명

# 브랜치 삭제 (원격)
git push origin --delete 브랜치명
```

---

## 상태 확인

```bash
# 변경 파일 목록 확인
git status

# 변경 내용 상세 확인 (스테이징 전)
git diff

# 스테이징된 변경 내용 확인
git diff --staged

# 특정 파일만 변경 내용 확인
git diff 파일경로

# 두 브랜치 간 차이 확인
git diff dev..feat/기능명
```

---

## 로그 & 그래프

```bash
# 최근 커밋 한 줄 요약
git log --oneline -10

# 날짜·작성자 포함 상세 로그
git log --pretty=format:"%h %ad %s" --date=short -10

# 브랜치 그래프 (터미널)
git log --oneline --graph --all

# 현재 브랜치 그래프만
git log --oneline --graph

# 특정 파일의 변경 이력
git log --oneline -- 파일경로

# 특정 커밋 상세 내용
git show 커밋해시
```

> **팁**: 아래 alias를 등록하면 `git graph`로 간편하게 사용할 수 있습니다.
> ```bash
> git config --global alias.graph "log --oneline --graph --all"
> ```

---

## 스테이징 & 커밋

```bash
# 특정 파일 스테이징
git add 파일경로

# 변경된 파일 전체 스테이징
git add -A

# 커밋
git commit -m "type: 메시지"

# 스테이징 + 커밋 한 번에 (untracked 파일 제외)
git commit -am "type: 메시지"
```

---

## Push & Pull

```bash
# 현재 브랜치 push (최초, 원격 브랜치 생성)
git push -u origin 브랜치명

# 이후 push
git push

# pull (fetch + merge)
git pull

# pull (fetch + rebase)
git pull --rebase
```

---

## 병합 (dev → main)

```bash
# main으로 이동
git checkout main

# main을 최신으로 갱신
git pull

# 작업 브랜치를 main에 병합
git merge feat/기능명

# 병합 후 push
git push
```

---

## 되돌리기

```bash
# 스테이징 취소 (파일 내용 유지)
git restore --staged 파일경로

# 파일 변경 내용 되돌리기 (마지막 커밋 기준)
git restore 파일경로

# 직전 커밋 메시지 수정 (push 전에만)
git commit --amend -m "새 메시지"

# 특정 커밋으로 되돌리기 (이력 유지)
git revert 커밋해시
```

---

## 임시 저장 (stash)

```bash
# 현재 변경 사항 임시 저장
git stash

# stash 목록 확인
git stash list

# 가장 최근 stash 복원
git stash pop

# 특정 stash 복원
git stash pop stash@{0}
```

---

## 이 프로젝트 브랜치 전략

```
main              ← 배포 기준 브랜치
└── dev           ← 통합 개발 브랜치
    ├── feat/*    ← 기능 개발 (예: feat/design-tokens)
    ├── fix/*     ← 버그 수정
    └── refactor/ ← 리팩토링
```

### 일반적인 작업 흐름

```bash
# 1. dev 기준으로 작업 브랜치 생성
git checkout dev
git pull
git checkout -b feat/기능명

# 2. 작업 후 커밋
git add 파일들
git commit -m "feat: 기능 설명"

# 3. 원격에 push
git push -u origin feat/기능명

# 4. 작업 완료 후 dev에 병합
git checkout dev
git merge feat/기능명
git push
```
