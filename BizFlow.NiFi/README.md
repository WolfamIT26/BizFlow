# NiFi Promotion Flow (DB -> Promotion Service)

## Muc tieu
Doc du lieu khuyen mai tu DB (promotions + promotion_targets + bundle_items), bien doi ve PromotionDTO, va POST vao Promotion Service.

## Step 0: Start NiFi (Docker)
- docker-compose up -d nifi
- UI: http://localhost:8090/nifi

## Step 1: Them JDBC driver MySQL
- Copy mysql-connector-j-8.x.x.jar vao container:
  docker cp <duong-dan>\mysql-connector-j-8.x.x.jar bizflow-nifi:/opt/nifi/nifi-current/lib/
  docker restart bizflow-nifi

## Step 2: Tao Controller Service (DBCPConnectionPool)
- Database Connection URL: jdbc:mysql://mysql:3306/bizflow_db?useSSL=false&serverTimezone=Asia/Ho_Chi_Minh&allowPublicKeyRetrieval=true
- Database Driver Class Name: com.mysql.cj.jdbc.Driver
- Database User: root
- Database Password: (de trong)

## Step 3: Flow de xuat
1) QueryDatabaseTableRecord
   - DBCPConnectionPool: <DBCP>
   - SQL: (xem file nifi/sql/promotions.sql)
   - Record Writer: JsonRecordSetWriter

2) SplitJson
   - JsonPath Expression: $.records[*]

3) JoltTransformJSON
   - Jolt Specification: nifi/jolt/promotion-dto.json

4) InvokeHTTP
   - Method: POST
   - URL: http://host.docker.internal:8082/api/v1/promotions/sync
   - Content-Type: application/json

## Luu y
- Neu Promotion Service chay trong docker-compose, thay host.docker.internal bang ten service.
- SQL da tra ve targets/bundleItems la JSON array tu MySQL.
