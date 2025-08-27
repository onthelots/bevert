<img width="80" height="80" alt="splash_light" src="https://github.com/user-attachments/assets/043857a3-35ba-49b0-967e-de1c02d659ca" />

# BEVERT
> Be heard. Be clear. BeVERT
- 목소리를 또렷하게, 회의 내용을 빠짐없이. AI가 음성을 분석하고 자동으로 회의록까지 만들어주는 서비스
  
<img width="7275" height="2556" alt="store_screenshot" src="https://github.com/user-attachments/assets/efc2886e-0618-4427-ac54-aa0d44c652a3" />


<br>

--- 
⚠️ **참고사항**
- 이 앱은 **비공개 프로젝트**이며, 제한된 사용자만 사용할 수 있습니다.  
- 스토어 배포 계획이 없으며, 오픈소스가 아닙니다.  
- 코드나 리소스는 외부에서 사용, 복제, 배포할 수 없습니다.

<br> 

# 목차

[1-프로젝트 소개](#1-프로젝트-소개)

- [1-1 개요](#1-1-개요)
- [1-2 개발환경](#1-2-개발환경)

[2-앱-디자인](#2-앱-디자인)
- [2-1 설계 및 구현 단계](#2-1-설계-및-구현-단계)

[3-프로젝트 특징](#3-프로젝트-특징)

[4-업데이트 및 리팩토링 사항](#4-업데이트-및-리팩토링-사항)


--- 

## 1-프로젝트 소개

### 1-1 개요
`VAD, LLM을 활용한 자동 문서 생성 및 관리 서비스`
- **개발기간** : 2025.07 - 2025.08 (약 3주)
- **참여인원** : 1인 (개인 프로젝트)
- **주요내용**

  - VAD 기반 실시간 음성 감지, Whisper 기반 STT, LLM 기반 회의록 자동 생성 기능 중심
  - 회의 녹음, 음성 텍스트 변환, 핵심 내용 요약, 노트 정리 및 공유 기능 제공
  - 폴더 단위 회의록 정리, 이동·삭제·편집 지원, 팀 공유 및 협업 가능

<br>

### 1-2 개발환경
- **활용기술 외 키워드**
  - Flutter
    - 사용자 (iOS, Android)
   
  - 상태관리 : BloC, Provider
  - AI/ML : Whisper(STT), LLM(Gemini), VAD(음성감지)
  - DI : get_it
  - Server : Supabase
  - DB : Shared Preferences

<br>

## 2-앱 디자인

### 2-1 설계 및 구현 단계

1. **노트 생성** – 회의 및 미팅 정보 생성
2. **실시간 음성 감지 (VAD)** – 발화 구간을 감지하고 불필요한 배경음 제거  
3. **STT 변환** – 음성을 텍스트로 변환하여 기록  
4. **LLM 기반 회의록 생성** – 요약/분류 등 AI를 활용해 회의록 자동 생성  
5. **폴더/노트 관리 및 공유** – 회의록 저장, 분류, 공유 기능 제공

> 단계별 앱 설계 및 구현을 순차적으로 진행하며, 각 단계에서 사용자 경험과 성능 최적화를 고려함.

<br>

<img width="2656" height="772" alt="Group 1" src="https://github.com/user-attachments/assets/5727c725-7071-4e69-8e3a-c4b87544c4f2" />

<br>

## 3-프로젝트 특징

### 3-1 AI 노트 생성
- VAD로 감지된 음성을 실시간으로 Whisper STT에 전달해 텍스트 변환
- 짧거나 의미 없는 발화는 자동 필터링, 회의록에 포함할 핵심 내용만 기록
- STT로 변환된 텍스트를 LLM으로 분석해 핵심 발언만 요약

<table>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/1d28b769-a1d3-4b20-975d-a0b01acedeec" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/dccd9676-8990-4bdc-9206-29dda20199c1" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/52050f1d-976a-4595-9640-a4c89090e5ab" width="250" height="541"/></td>
  </tr>
  <tr>
    <td align="center">노트개요</td>
    <td align="center">STT</td>
    <td align="center">문서정리</td>
  </tr>
</table>

<br>

### 3-2 폴더·노트 관리
- 생성된 회의록을 폴더별로 정리, 이동, 삭제, 편집 가능
- 캘린더를 활용, 년도/월 별 생성 노트 확인

<table>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/1d245d25-e727-46d2-babf-668604b375b9" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/df22ea60-0242-4359-9a4a-3e76e7f2558f" width="250" height="541"/></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/72f5cf07-2bba-4474-b13e-b9e2b132f174" width="250" height="541"/></td>
  </tr>
  <tr>
    <td align="center">폴더별 정리</td>
    <td align="center">캘린더 관리</td>
    <td align="center">폴더관리</td>
  </tr>
</table>

<br>

## 4-업데이트 및 리팩토링 사항
### 4-1 우선 순위별 개선항목
1) Issue
- [ ] 아, 음 등 간투어 제거 필요 

2) Develop
- [ ] 회의록 외 기타 템플릿 제공
- [ ] 실시간 발화 UX를 목표로 STT 및 placeholder 적용
- [ ] 음성인식 정확도 제고

<br>
