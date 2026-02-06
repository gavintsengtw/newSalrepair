# NewSalrepair 專案部署指南

本指南將說明如何將 `NewSalrepair` 專案（後端 Spring Boot + 前端 Flutter）編譯並部署至伺服器。

## 1. 前提條件 (Prerequisites)

在開始之前，請確保您的部署環境（主機）已安裝以下工具：

- **Java Development Kit (JDK) 17**: 後端開發語言。
  - 檢查指令: `java -version`
- **Maven 3.8+**: 後端建置工具。
  - 檢查指令: `mvn -version`
- **Flutter SDK**: 前端建置工具（也可以在本地打包好再上傳）。
  - 檢查指令: `flutter --version`
- **Microsoft SQL Server**: 資料庫。

> [!IMPORTANT]
> 您的專案根目錄下有一個 `jdk-17.0.12_windows-x64_bin.msi`，如果主機尚未安裝 Java，可以直接使用該檔案進行安裝。

---

## 2. 後端部署 (Backend - Apache + Tomcat)

本專案已配置為產生 **WAR** 檔，適合部署於 Apache Tomcat。

### 2.1 環境準備
1.  **安裝 Java Development Kit (JDK) 17**:
    *   確保 `JAVA_HOME` 環境變數設定正確。
2.  **安裝 Apache Tomcat 10 (或 9)**:
    *   下載並解壓縮 Tomcat。
    *   (選用) 安裝 **Apache HTTP Server** 作為反向代理 (Reverse Proxy)，透過 AJP 或 HTTP 轉發請求至 Tomcat。

### 2.2 設定資料庫連線
由於 WAR 檔已將設定檔打包，建議透過**環境變數**來設定正式環境的資料庫連線：

*   **Windows**:
    ```powershell
    setx SPRING_DATASOURCE_URL "jdbc:sqlserver://<DB_IP>:<PORT>;databaseName=<DB_NAME>"
    setx SPRING_DATASOURCE_USERNAME "<USERNAME>"
    setx SPRING_DATASOURCE_PASSWORD "<PASSWORD>"
    ```
*   **Linux**:
    在 `~/.bashrc` 或 Tomcat 的 `bin/setenv.sh` 中加入：
    ```bash
    export SPRING_DATASOURCE_URL="jdbc:sqlserver://<DB_IP>:<PORT>;databaseName=<DB_NAME>"
    export SPRING_DATASOURCE_USERNAME="<USERNAME>"
    export SPRING_DATASOURCE_PASSWORD="<PASSWORD>"
    ```

### 2.3 編譯與打包 (Build)
在 `backend` 資料夾下執行：

```bash
mvn clean package -DskipTests
```
成功後，會在 `backend/target/` 目錄下產生 `.war` 檔案 (例如 `client-api-0.0.1-SNAPSHOT.war`)。

### 2.4 部署 (Deploy)
1.  停止 Tomcat 服務 (`bin/shutdown.bat` 或 `bin/shutdown.sh`)。
2.  將產生的 WAR 檔複製到 Tomcat 的 `webapps` 資料夾中。
    *   **提示**: 將檔案重新命名為 `ROOT.war`，這樣網址路徑就會是根目錄 `/` (例如 `http://your-server.com/`)。
    *   若不改名，網址路徑會包含檔名 (例如 `http://your-server.com/client-api-0.0.1-SNAPSHOT/`)。
3.  啟動 Tomcat (`bin/startup.bat` 或 `bin/startup.sh`)。
4.  Tomcat 會自動解壓縮 WAR 檔並啟動應用程式。

---

## 3. 前端部署 (Frontend - Flutter)

前端位於 `frontend` 資料夾。您需要根據目標平台（Android/iOS 或 Web）進行編譯。

### 3.1 設定環境變數
檢查 `frontend` 目錄下的 `.env` 檔案（如 `.env.android`, `.env.windows` 等），確保 API 的 URL 指向您剛剛部署的後端伺服器位址。

```env
API_URL=http://<YOUR_SERVER_IP>:8080
```

### 3.2 編譯 (Build)

#### 選項 A: 發布為 Android App (APK)
```bash
cd frontend
flutter build apk --release
```
產出檔案位於: `frontend/build/app/outputs/flutter-apk/app-release.apk`。您可以將此檔案提供給使用者安裝。

#### 選項 B: 發布為 Web 應用程式 (Web Site)
如果您希望用戶透過瀏覽器存取：
```bash
cd frontend
flutter build web --release
```
產出檔案位於: `frontend/build/web/`。
將此資料夾內的所有內容上傳至您的 Web Server (如 Nginx, Apache, 或 IIS) 的根目錄即可。

---

## 4. 簡易啟動腳本 (Windows/Linux)

專案中已有包含簡單的啟動腳本，您可以參考使用：
- **backend/start_server.sh**: 用於啟動後端的 Shell Script。

---

## 常見問題
- **JAVA_HOME error**: 如果遇到 `JAVA_HOME is not defined correctly`，請確保環境變數 `JAVA_HOME` 指向 JDK 17 的安裝路徑。
- **Database Connection Refused**: 請確認主機的防火牆已開啟 SQL Server 的連接埠 (預設 1433)。
