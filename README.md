# HashiTalk2023Korea-

**Java앱(Spring boot)운영에 Nomad 활용**

이전의 Java기반 웹 애플리케이션은 Cloud-Native 개발방식으로 전환되면서, Tomcat같은 미들웨어 위에서 실행되는 대신 Native 형태로 미들웨어를 포함하여 실행되는 형태로 변화하고 있습니다. 대표적으로 Spring Boot에서 지원하는 내장된 Tomcat으로 독립적으로 배포되는 환경이 있습니다.
HashiCorp의 Nomad는 다수의 BM/VM에서 이런 Spring Boot의 실행과 수명주기를 관리하는 오케스트레이터 역할을 수행하고 12factor 원칙에 따라 개발 및 배포할 수 있는 환경을 제공해줍니다.
세션에서는 먼저 Nomad에 대한 간단한 소개와 아키텍처, 기능들에대해 설명하고, 간단한 데모를 통해 Nomad에서 Spring Boot 애플리케이션을 실행하면서 환경변수 주입, 사이즈 조정, 카나리 배포, 스카우터 연계 옵션 등의 동작을 확인해보려 합니다.
Java 뿐만이 아니라 다른 개발 언어 또는 컨테이너 애플리케이션 배포에도 Nomad의 활용에 대해 고려해 보는데 도움이 되면 좋겠습니다.

[![Video Label](http://img.youtube.com/vi/m7lCS_PkX2k/0.jpg)](https://youtu.be/m7lCS_PkX2k)
