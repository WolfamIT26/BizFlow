# NiFi Promotion Flow

This document describes how to orchestrate Promotion ingestion and publish it to the Promotion Service.

## Goal
- Ingest promotion data from external sources.
- Transform to the PromotionDTO JSON shape expected by Promotion Service.
- Publish to Promotion Service API.
- (Optional) Emit an event for downstream services (Kafka/RabbitMQ).

## Target API (Promotion Service)
- POST /api/v1/promotions/sync
  - Body: PromotionDTO JSON
  - Response: created PromotionDTO

## PromotionDTO JSON shape
{
  "code": "PROMO10",
  "name": "10 percent off",
  "description": "Applies to selected items",
  "discountType": "PERCENT",
  "discountValue": 10.0,
  "startDate": "2026-01-01T00:00:00",
  "endDate": "2026-01-31T23:59:59",
  "active": true,
  "targets": [
    { "targetType": "PRODUCT", "targetId": 1001 }
  ],
  "bundleItems": [
    { "productId": 2001, "quantity": 2 }
  ]
}

## Step 1: Ingest (examples)
Pick one or more sources based on your integration.

- Excel file from partner
  - Processor: GetFile -> FetchFile -> ConvertRecord
  - Record Reader: ExcelReader
  - Record Writer: JsonRecordSetWriter

- Legacy database
  - Processor: QueryDatabaseTableRecord or ExecuteSQLRecord
  - Record Reader: JDBCRecordReader
  - Record Writer: JsonRecordSetWriter

- CRM API
  - Processor: InvokeHTTP
  - Parse response to JSON with EvaluateJsonPath

## Step 2: Transform
Use JoltTransformJSON to map raw fields into PromotionDTO structure.

### Jolt spec example (from raw partner format)
Assume input fields:
- promo_code
- promo_name
- promo_desc
- discount_type
- discount_value
- start_ts
- end_ts
- target_type
- target_id

Spec:
[
  {
    "operation": "shift",
    "spec": {
      "promo_code": "code",
      "promo_name": "name",
      "promo_desc": "description",
      "discount_type": "discountType",
      "discount_value": "discountValue",
      "start_ts": "startDate",
      "end_ts": "endDate",
      "target_type": "targets[0].targetType",
      "target_id": "targets[0].targetId"
    }
  },
  {
    "operation": "default",
    "spec": {
      "active": true,
      "bundleItems": []
    }
  }
]

Notes
- If your source has multiple targets per promotion, normalize to an array before Jolt or build a list in a later step.
- Ensure discountType values are one of: PERCENT, FIXED, BUNDLE.

## Step 3: Distribute / Publish
- Processor: InvokeHTTP
- Method: POST
- URL: http://<promotion-service-host>:<port>/api/v1/promotions/sync
- Content-Type: application/json
- Send body: the transformed PromotionDTO JSON

### Recommended flow
GetFile/QueryDatabase/InvokeHTTP
  -> ConvertRecord (to JSON)
  -> JoltTransformJSON
  -> InvokeHTTP (Promotion Service)
  -> RouteOnAttribute (success/error)

## (Optional) Step 4: Event publish
After a successful POST, emit a simple event.

### Kafka
- Processor: PublishKafkaRecord_2_0
- Topic: promotions.changed
- Value: { "eventType": "PROMOTION_CREATED", "code": "PROMO10" }

### RabbitMQ
- Processor: PublishRabbitMQ
- Exchange: promotions
- Routing key: promotion.created
- Body: { "eventType": "PROMOTION_CREATED", "code": "PROMO10" }

## Ops tips
- Use RetryFlowFile on HTTP errors.
- Use PutDatabaseRecord or PutFile for dead-lettering invalid data.
- Add UpdateAttribute to stamp source metadata.
