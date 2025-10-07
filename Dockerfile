# ---------- Stage 1: Build WAR bằng Maven ----------
FROM maven:3.9.6-eclipse-temurin-11 AS build
WORKDIR /workspace

# Tách bước copy để cache dependency cho nhanh
COPY pom.xml .
RUN mvn -B -ntp -DskipTests dependency:go-offline

# Copy source và build
COPY src ./src
RUN mvn -B -ntp -DskipTests clean package

# ---------- Stage 2: Chạy bằng Tomcat ----------
FROM tomcat:10.1.44-jdk11

# Xóa webapp mặc định
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR vừa build vào ROOT.war để truy cập trực tiếp trên /
COPY --from=build /workspace/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
