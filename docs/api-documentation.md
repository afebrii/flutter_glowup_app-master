# GlowUp Clinic - API Documentation

**Base URL:** `/api/v1`
**Authentication:** Laravel Sanctum (Bearer Token)
**Content-Type:** `application/json`

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Settings (Public)](#2-settings-public)
3. [Referral (Public)](#3-referral-public)
4. [Dashboard](#4-dashboard)
5. [Service Categories](#5-service-categories)
6. [Services](#6-services)
7. [Product Categories](#7-product-categories)
8. [Products](#8-products)
9. [Staff](#9-staff)
10. [Customers](#10-customers)
11. [Customer Loyalty](#11-customer-loyalty)
12. [Customer Referral](#12-customer-referral)
13. [Loyalty Rewards](#13-loyalty-rewards)
14. [Appointments](#14-appointments)
15. [Treatment Records](#15-treatment-records)
16. [Packages](#16-packages)
17. [Transactions](#17-transactions)

---

## Common Headers

### Public Endpoints
```
Accept: application/json
Content-Type: application/json
```

### Protected Endpoints
```
Accept: application/json
Content-Type: application/json
Authorization: Bearer {token}
```

### File Upload Endpoints
```
Accept: application/json
Content-Type: multipart/form-data
Authorization: Bearer {token}
```

## Common Response Format

### Success Response
```json
{
  "data": { ... }
}
```

### Paginated Response
```json
{
  "data": [ ... ],
  "links": {
    "first": "...",
    "last": "...",
    "prev": null,
    "next": "..."
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 5,
    "per_page": 15,
    "to": 15,
    "total": 72
  }
}
```

### Error Response (Validation)
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "field_name": [
      "Error message."
    ]
  }
}
```

### Error Response (Unauthenticated)
```json
{
  "message": "Unauthenticated."
}
```

---

## 1. Authentication

### 1.1 Login

| | |
|---|---|
| **URL** | `POST /api/v1/login` |
| **Auth** | Public |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `email` | string | Yes | Valid email |
| `password` | string | Yes | - |
| `device_name` | string | No | max:255 |

**Request Example:**
```json
{
  "email": "admin@glowup.com",
  "password": "password123",
  "device_name": "iPhone 15"
}
```

**Success Response (200):**
```json
{
  "data": {
    "user": {
      "id": 1,
      "name": "Admin",
      "email": "admin@glowup.com",
      "phone": "081234567890",
      "role": "owner",
      "role_label": "Owner",
      "avatar": null,
      "is_active": true,
      "created_at": "2024-01-01T00:00:00.000000Z"
    },
    "token": "1|abc123def456..."
  }
}
```

**Error Response (401):**
```json
{
  "message": "Email atau password salah."
}
```

---

### 1.2 Logout

| | |
|---|---|
| **URL** | `POST /api/v1/logout` |
| **Auth** | Bearer Token |

**Request Body:** None

**Success Response (200):**
```json
{
  "message": "Berhasil logout."
}
```

---

### 1.3 Get Profile

| | |
|---|---|
| **URL** | `GET /api/v1/profile` |
| **Auth** | Bearer Token |

**Request Body:** None

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "name": "Admin",
    "email": "admin@glowup.com",
    "phone": "081234567890",
    "role": "owner",
    "role_label": "Owner",
    "avatar": null,
    "is_active": true,
    "created_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

### 1.4 Update Profile

| | |
|---|---|
| **URL** | `PUT /api/v1/profile` |
| **Auth** | Bearer Token |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `name` | string | Sometimes | max:255 |
| `phone` | string | No | max:20 |
| `current_password` | string | Required with new_password | Must match current password |
| `new_password` | string | No | min:8, confirmed |
| `new_password_confirmation` | string | Required with new_password | Must match new_password |

**Request Example:**
```json
{
  "name": "Admin Updated",
  "phone": "081234567899",
  "current_password": "oldpassword",
  "new_password": "newpassword123",
  "new_password_confirmation": "newpassword123"
}
```

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "name": "Admin Updated",
    "email": "admin@glowup.com",
    "phone": "081234567899",
    "role": "owner",
    "role_label": "Owner",
    "avatar": null,
    "is_active": true,
    "created_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

## 2. Settings (Public)

### 2.1 Get All Settings

| | |
|---|---|
| **URL** | `GET /api/v1/settings` |
| **Auth** | Public |

**Success Response (200):**
```json
{
  "data": {
    "clinic": {
      "name": "GlowUp Clinic",
      "address": "Jl. Contoh No. 123",
      "phone": "021-1234567",
      "email": "info@glowup.com",
      "description": "Klinik kecantikan terbaik"
    },
    "operating_hours": [
      {
        "id": 1,
        "day_of_week": 1,
        "day_name": "Monday",
        "day_name_id": "Senin",
        "open_time": "09:00",
        "close_time": "21:00",
        "is_closed": false
      }
    ],
    "features": {
      "loyalty_enabled": true,
      "referral_enabled": true,
      "online_booking_enabled": true
    }
  }
}
```

---

### 2.2 Get Clinic Settings

| | |
|---|---|
| **URL** | `GET /api/v1/settings/clinic` |
| **Auth** | Public |

**Success Response (200):**
```json
{
  "data": {
    "name": "GlowUp Clinic",
    "address": "Jl. Contoh No. 123",
    "phone": "021-1234567",
    "email": "info@glowup.com",
    "description": "Klinik kecantikan terbaik"
  }
}
```

---

### 2.3 Get Operating Hours

| | |
|---|---|
| **URL** | `GET /api/v1/settings/hours` |
| **Auth** | Public |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "day_of_week": 1,
      "day_name": "Monday",
      "day_name_id": "Senin",
      "open_time": "09:00",
      "close_time": "21:00",
      "is_closed": false
    }
  ]
}
```

---

### 2.4 Get Branding Settings

| | |
|---|---|
| **URL** | `GET /api/v1/settings/branding` |
| **Auth** | Public |

**Success Response (200):**
```json
{
  "data": {
    "logo": "logo.png",
    "logo_url": "https://example.com/storage/logo.png",
    "primary_color": "#FF6B9D",
    "secondary_color": "#C44569"
  }
}
```

---

### 2.5 Get Loyalty Settings

| | |
|---|---|
| **URL** | `GET /api/v1/settings/loyalty` |
| **Auth** | Public |

**Success Response (200):**
```json
{
  "data": {
    "enabled": true,
    "points_per_amount": 1,
    "amount_per_point": 10000,
    "min_redeem_points": 100
  }
}
```

---

### 2.6 Get Referral Settings

| | |
|---|---|
| **URL** | `GET /api/v1/settings/referral` |
| **Auth** | Public |

**Success Response (200):**
```json
{
  "data": {
    "enabled": true,
    "referrer_points": 50,
    "referee_points": 25
  }
}
```

---

## 3. Referral (Public)

### 3.1 Validate Referral Code

| | |
|---|---|
| **URL** | `POST /api/v1/referral/validate` |
| **Auth** | Public |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `code` | string | Yes | - |

**Request Example:**
```json
{
  "code": "REF-ABC123"
}
```

**Success Response (200):**
```json
{
  "data": {
    "valid": true,
    "referrer": {
      "id": 1,
      "name": "Jane Doe"
    }
  }
}
```

**Error Response (422):**
```json
{
  "message": "Kode referral tidak valid."
}
```

---

### 3.2 Get Program Info

| | |
|---|---|
| **URL** | `GET /api/v1/referral/program-info` |
| **Auth** | Public |

**Success Response (200):**
```json
{
  "data": {
    "enabled": true,
    "referrer_points": 50,
    "referee_points": 25,
    "description": "Ajak teman dan dapatkan poin!"
  }
}
```

---

## 4. Dashboard

### 4.1 Get Dashboard

| | |
|---|---|
| **URL** | `GET /api/v1/dashboard` |
| **Auth** | Bearer Token |

**Success Response (200):**
```json
{
  "data": {
    "today": {
      "appointments": 5,
      "completed": 3,
      "revenue": 1500000,
      "new_customers": 2
    },
    "month": {
      "total_revenue": 45000000,
      "total_appointments": 120,
      "total_customers": 85
    },
    "today_appointments": [
      {
        "id": 1,
        "customer_id": 1,
        "service_id": 1,
        "appointment_date": "2024-01-15",
        "start_time": "10:00",
        "end_time": "11:00",
        "status": "confirmed",
        "customer": { "..." },
        "service": { "..." },
        "staff": { "..." }
      }
    ],
    "revenue_chart": {
      "labels": ["Jan", "Feb", "Mar"],
      "data": [10000000, 12000000, 15000000]
    },
    "popular_services": [
      {
        "name": "Facial Treatment",
        "count": 45,
        "revenue": 22500000
      }
    ]
  }
}
```

---

### 4.2 Get Dashboard Summary

| | |
|---|---|
| **URL** | `GET /api/v1/dashboard/summary` |
| **Auth** | Bearer Token |

**Success Response (200):**
```json
{
  "data": {
    "total_customers": 250,
    "total_services": 30,
    "total_staff": 10,
    "today_appointments": 5,
    "month_revenue": 45000000,
    "month_transactions": 120
  }
}
```

---

## 5. Service Categories

### 5.1 List Service Categories

| | |
|---|---|
| **URL** | `GET /api/v1/service-categories` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `with_services` | boolean | Include services in response |
| `with_count` | boolean | Include services count |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Facial",
      "description": "Perawatan wajah",
      "icon": "face",
      "sort_order": 1,
      "is_active": true,
      "services_count": 5,
      "services": [
        {
          "id": 1,
          "category_id": 1,
          "name": "Basic Facial",
          "description": "Facial dasar",
          "duration_minutes": 60,
          "formatted_duration": "1 jam",
          "price": 150000.0,
          "formatted_price": "Rp 150.000",
          "image": null,
          "is_active": true,
          "created_at": "2024-01-01T00:00:00.000000Z"
        }
      ],
      "created_at": "2024-01-01T00:00:00.000000Z"
    }
  ]
}
```

---

### 5.2 Get Service Category Detail

| | |
|---|---|
| **URL** | `GET /api/v1/service-categories/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Service Category ID |

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "name": "Facial",
    "description": "Perawatan wajah",
    "icon": "face",
    "sort_order": 1,
    "is_active": true,
    "services_count": 5,
    "services": [ "..." ],
    "created_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

## 6. Services

### 6.1 List Services

| | |
|---|---|
| **URL** | `GET /api/v1/services` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `category_id` | integer | Filter by category |
| `search` | string | Search by name |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "category_id": 1,
      "name": "Basic Facial",
      "description": "Facial dasar untuk semua jenis kulit",
      "duration_minutes": 60,
      "formatted_duration": "1 jam",
      "price": 150000.0,
      "formatted_price": "Rp 150.000",
      "image": null,
      "is_active": true,
      "category": {
        "id": 1,
        "name": "Facial",
        "description": "Perawatan wajah",
        "icon": "face",
        "sort_order": 1,
        "is_active": true,
        "created_at": "2024-01-01T00:00:00.000000Z"
      },
      "created_at": "2024-01-01T00:00:00.000000Z"
    }
  ]
}
```

---

### 6.2 Get Service Detail

| | |
|---|---|
| **URL** | `GET /api/v1/services/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Service ID |

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "category_id": 1,
    "name": "Basic Facial",
    "description": "Facial dasar untuk semua jenis kulit",
    "duration_minutes": 60,
    "formatted_duration": "1 jam",
    "price": 150000.0,
    "formatted_price": "Rp 150.000",
    "image": null,
    "is_active": true,
    "category": { "..." },
    "created_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

## 7. Product Categories

### 7.1 List Product Categories

| | |
|---|---|
| **URL** | `GET /api/v1/product-categories` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `with_products` | boolean | Include products in response |
| `with_count` | boolean | Include products count |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Skincare",
      "description": "Produk perawatan kulit",
      "sort_order": 1,
      "is_active": true,
      "products_count": 10,
      "products": [ "..." ],
      "created_at": "2024-01-01T00:00:00.000000Z"
    }
  ]
}
```

---

### 7.2 Get Product Category Detail

| | |
|---|---|
| **URL** | `GET /api/v1/product-categories/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Product Category ID |

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "name": "Skincare",
    "description": "Produk perawatan kulit",
    "sort_order": 1,
    "is_active": true,
    "products_count": 10,
    "products": [ "..." ],
    "created_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

## 8. Products

### 8.1 List Products

| | |
|---|---|
| **URL** | `GET /api/v1/products` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `category_id` | integer | Filter by category |
| `search` | string | Search by name |
| `in_stock_only` | boolean | Show only in-stock products |
| `per_page` | integer | Items per page (default: 15) |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "category_id": 1,
      "name": "Sunscreen SPF 50",
      "sku": "SKU-001",
      "description": "Sunscreen untuk perlindungan UV",
      "price": 250000.0,
      "formatted_price": "Rp 250.000",
      "cost_price": 150000.0,
      "formatted_cost_price": "Rp 150.000",
      "stock": 50,
      "min_stock": 10,
      "unit": "pcs",
      "image": "products/sunscreen.jpg",
      "image_url": "https://example.com/storage/products/sunscreen.jpg",
      "is_active": true,
      "track_stock": true,
      "is_low_stock": false,
      "is_out_of_stock": false,
      "category": {
        "id": 1,
        "name": "Skincare",
        "description": "Produk perawatan kulit",
        "sort_order": 1,
        "is_active": true,
        "created_at": "2024-01-01T00:00:00.000000Z"
      },
      "created_at": "2024-01-01T00:00:00.000000Z"
    }
  ]
}
```

---

### 8.2 Get Product Detail

| | |
|---|---|
| **URL** | `GET /api/v1/products/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Product ID |

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "category_id": 1,
    "name": "Sunscreen SPF 50",
    "sku": "SKU-001",
    "description": "Sunscreen untuk perlindungan UV",
    "price": 250000.0,
    "formatted_price": "Rp 250.000",
    "cost_price": 150000.0,
    "formatted_cost_price": "Rp 150.000",
    "stock": 50,
    "min_stock": 10,
    "unit": "pcs",
    "image": "products/sunscreen.jpg",
    "image_url": "https://example.com/storage/products/sunscreen.jpg",
    "is_active": true,
    "track_stock": true,
    "is_low_stock": false,
    "is_out_of_stock": false,
    "category": { "..." },
    "created_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

## 9. Staff

### 9.1 List Staff

| | |
|---|---|
| **URL** | `GET /api/v1/staff` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `role` | string | Filter by role (`owner`, `admin`, `beautician`) |
| `active_only` | boolean | Show only active staff |
| `search` | string | Search by name |
| `per_page` | integer | Items per page (default: 15) |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Dr. Sarah",
      "email": "sarah@glowup.com",
      "phone": "081234567890",
      "role": "beautician",
      "role_label": "Beautician",
      "avatar": null,
      "is_active": true,
      "created_at": "2024-01-01T00:00:00.000000Z"
    }
  ]
}
```

---

### 9.2 List Beauticians

| | |
|---|---|
| **URL** | `GET /api/v1/staff/beauticians` |
| **Auth** | Bearer Token |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Dr. Sarah",
      "email": "sarah@glowup.com",
      "phone": "081234567890",
      "role": "beautician",
      "role_label": "Beautician",
      "avatar": null,
      "is_active": true,
      "created_at": "2024-01-01T00:00:00.000000Z"
    }
  ]
}
```

---

### 9.3 Get Staff Detail

| | |
|---|---|
| **URL** | `GET /api/v1/staff/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | User ID |

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "name": "Dr. Sarah",
    "email": "sarah@glowup.com",
    "phone": "081234567890",
    "role": "beautician",
    "role_label": "Beautician",
    "avatar": null,
    "is_active": true,
    "created_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

## 10. Customers

### 10.1 List Customers

| | |
|---|---|
| **URL** | `GET /api/v1/customers` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `search` | string | Search by name/phone/email |
| `per_page` | integer | Items per page (default: 15) |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Jane Doe",
      "phone": "081234567890",
      "email": "jane@example.com",
      "birthdate": "1990-05-15",
      "age": 34,
      "gender": "female",
      "address": "Jl. Contoh No. 1",
      "skin_type": "combination",
      "skin_concerns": ["acne", "pores"],
      "allergies": null,
      "notes": null,
      "total_visits": 12,
      "total_spent": 3500000.0,
      "formatted_total_spent": "Rp 3.500.000",
      "last_visit": "2024-01-10",
      "loyalty_points": 350,
      "lifetime_points": 500,
      "loyalty_tier": "silver",
      "loyalty_tier_label": "Silver",
      "referral_code": "REF-JANE01",
      "referred_by_id": null,
      "created_at": "2024-01-01T00:00:00.000000Z",
      "updated_at": "2024-01-10T00:00:00.000000Z"
    }
  ]
}
```

---

### 10.2 Create Customer

| | |
|---|---|
| **URL** | `POST /api/v1/customers` |
| **Auth** | Bearer Token |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `name` | string | Yes | max:255 |
| `phone` | string | Yes | max:20, regex: `/^08[0-9]{8,13}$/`, unique |
| `email` | string | No | valid email, max:255 |
| `birthdate` | string | No | date, before:today (format: `Y-m-d`) |
| `gender` | string | No | `male`, `female`, `other` |
| `address` | string | No | max:500 |
| `skin_type` | string | No | `normal`, `oily`, `dry`, `combination`, `sensitive` |
| `skin_concerns` | array | No | Array of strings |
| `skin_concerns.*` | string | No | `acne`, `aging`, `pigmentation`, `dull`, `pores`, `redness`, `dehydration`, `oily`, `sensitive`, `blackheads` |
| `allergies` | string | No | max:500 |
| `notes` | string | No | max:1000 |
| `referral_code` | string | No | max:20 |

**Request Example:**
```json
{
  "name": "Jane Doe",
  "phone": "081234567890",
  "email": "jane@example.com",
  "birthdate": "1990-05-15",
  "gender": "female",
  "address": "Jl. Contoh No. 1",
  "skin_type": "combination",
  "skin_concerns": ["acne", "pores"],
  "allergies": "Retinol",
  "notes": "Prefer morning appointments",
  "referral_code": "REF-ABC123"
}
```

**Success Response (201):**
```json
{
  "data": {
    "id": 1,
    "name": "Jane Doe",
    "phone": "081234567890",
    "email": "jane@example.com",
    "birthdate": "1990-05-15",
    "age": 34,
    "gender": "female",
    "address": "Jl. Contoh No. 1",
    "skin_type": "combination",
    "skin_concerns": ["acne", "pores"],
    "allergies": "Retinol",
    "notes": "Prefer morning appointments",
    "total_visits": 0,
    "total_spent": 0.0,
    "formatted_total_spent": "Rp 0",
    "last_visit": null,
    "loyalty_points": 0,
    "lifetime_points": 0,
    "loyalty_tier": null,
    "loyalty_tier_label": null,
    "referral_code": "REF-JANE01",
    "referred_by_id": null,
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

### 10.3 Get Customer Detail

| | |
|---|---|
| **URL** | `GET /api/v1/customers/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "name": "Jane Doe",
    "phone": "081234567890",
    "email": "jane@example.com",
    "birthdate": "1990-05-15",
    "age": 34,
    "gender": "female",
    "address": "Jl. Contoh No. 1",
    "skin_type": "combination",
    "skin_concerns": ["acne", "pores"],
    "allergies": "Retinol",
    "notes": "Prefer morning appointments",
    "total_visits": 12,
    "total_spent": 3500000.0,
    "formatted_total_spent": "Rp 3.500.000",
    "last_visit": "2024-01-10",
    "loyalty_points": 350,
    "lifetime_points": 500,
    "loyalty_tier": "silver",
    "loyalty_tier_label": "Silver",
    "referral_code": "REF-JANE01",
    "referred_by_id": null,
    "referrer": null,
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-10T00:00:00.000000Z"
  }
}
```

---

### 10.4 Update Customer

| | |
|---|---|
| **URL** | `PUT /api/v1/customers/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Request Body:** Same as [Create Customer](#102-create-customer) (phone unique rule ignores current customer)

**Success Response (200):**
```json
{
  "data": { "..." }
}
```

---

### 10.5 Delete Customer

| | |
|---|---|
| **URL** | `DELETE /api/v1/customers/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Success Response (200):**
```json
{
  "message": "Customer berhasil dihapus."
}
```

---

### 10.6 Get Customer Statistics

| | |
|---|---|
| **URL** | `GET /api/v1/customers/{id}/stats` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Success Response (200):**
```json
{
  "data": {
    "total_visits": 12,
    "total_spent": 3500000,
    "total_appointments": 15,
    "completed_appointments": 12,
    "cancelled_appointments": 1,
    "active_packages": 2,
    "last_visit": "2024-01-10"
  }
}
```

---

### 10.7 Get Customer Treatments

| | |
|---|---|
| **URL** | `GET /api/v1/customers/{id}/treatments` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `per_page` | integer | Items per page (default: 15) |

**Success Response (200):** Paginated list of `TreatmentRecordResource` (see [Treatment Records](#15-treatment-records))

---

### 10.8 Get Customer Packages

| | |
|---|---|
| **URL** | `GET /api/v1/customers/{id}/packages` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `active_only` | boolean | Show only active/usable packages |
| `per_page` | integer | Items per page (default: 15) |

**Success Response (200):** Paginated list of `CustomerPackageResource` (see [Packages](#16-packages))

---

### 10.9 Get Customer Appointments

| | |
|---|---|
| **URL** | `GET /api/v1/customers/{id}/appointments` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `status` | string | Filter by status |
| `upcoming` | boolean | Show only upcoming appointments |
| `per_page` | integer | Items per page (default: 15) |

**Success Response (200):** Paginated list of `AppointmentResource` (see [Appointments](#14-appointments))

---

## 11. Customer Loyalty

### 11.1 Get Customer Loyalty Summary

| | |
|---|---|
| **URL** | `GET /api/v1/customers/{id}/loyalty` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Success Response (200):**
```json
{
  "data": {
    "customer_id": 1,
    "current_points": 350,
    "lifetime_points": 500,
    "tier": "silver",
    "tier_label": "Silver",
    "points_to_next_tier": 150,
    "total_redemptions": 3,
    "total_points_redeemed": 150
  }
}
```

---

### 11.2 Get Customer Points History

| | |
|---|---|
| **URL** | `GET /api/v1/customers/{id}/loyalty/points` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "customer_id": 1,
      "transaction_id": 5,
      "type": "earn",
      "type_label": "Earned",
      "points": 50,
      "balance_after": 350,
      "description": "Points dari transaksi #INV-001",
      "expires_at": "2025-01-01",
      "is_earn": true,
      "is_redeem": false,
      "customer": { "..." },
      "transaction": { "..." },
      "created_at": "2024-01-10T00:00:00.000000Z"
    }
  ]
}
```

---

### 11.3 Redeem Loyalty Reward

| | |
|---|---|
| **URL** | `POST /api/v1/customers/{id}/loyalty/redeem` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `reward_id` | integer | Yes | exists:loyalty_rewards,id |

**Request Example:**
```json
{
  "reward_id": 1
}
```

**Success Response (200):**
```json
{
  "data": {
    "redemption": {
      "id": 1,
      "customer_id": 1,
      "loyalty_reward_id": 1,
      "transaction_id": null,
      "points_used": 100,
      "status": "active",
      "status_label": "Active",
      "code": "RDM-ABC123",
      "valid_until": "2024-02-10",
      "used_at": null,
      "is_valid": true,
      "reward": { "..." },
      "created_at": "2024-01-10T00:00:00.000000Z"
    },
    "remaining_points": 250
  }
}
```

---

### 11.4 Get Customer Redemptions

| | |
|---|---|
| **URL** | `GET /api/v1/customers/{id}/loyalty/redemptions` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `status` | string | Filter by status |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "customer_id": 1,
      "loyalty_reward_id": 1,
      "transaction_id": null,
      "points_used": 100,
      "status": "active",
      "status_label": "Active",
      "code": "RDM-ABC123",
      "valid_until": "2024-02-10",
      "used_at": null,
      "is_valid": true,
      "customer": { "..." },
      "reward": { "..." },
      "transaction": null,
      "created_at": "2024-01-10T00:00:00.000000Z"
    }
  ]
}
```

---

### 11.5 Adjust Customer Points

| | |
|---|---|
| **URL** | `POST /api/v1/customers/{id}/loyalty/adjust` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `points` | integer | Yes | Can be positive or negative |
| `description` | string | Yes | max:255 |

**Request Example:**
```json
{
  "points": 50,
  "description": "Bonus points for birthday"
}
```

**Success Response (200):**
```json
{
  "data": {
    "message": "Points berhasil disesuaikan.",
    "current_points": 400
  }
}
```

---

## 12. Customer Referral

### 12.1 Get Customer Referral Info

| | |
|---|---|
| **URL** | `GET /api/v1/customers/{id}/referral` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Success Response (200):**
```json
{
  "data": {
    "referral_code": "REF-JANE01",
    "total_referrals": 5,
    "total_points_earned": 250,
    "referred_by": null
  }
}
```

---

### 12.2 Get Referral History

| | |
|---|---|
| **URL** | `GET /api/v1/customers/{id}/referral/history` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "referrer_id": 1,
      "referee_id": 5,
      "referrer_points": 50,
      "referee_points": 25,
      "transaction_id": null,
      "status": "rewarded",
      "status_label": "Rewarded",
      "rewarded_at": "2024-01-10T00:00:00.000000Z",
      "referrer": { "..." },
      "referee": { "..." },
      "transaction": null,
      "created_at": "2024-01-05T00:00:00.000000Z"
    }
  ]
}
```

---

### 12.3 Get Customer's Referrals

| | |
|---|---|
| **URL** | `GET /api/v1/customers/{id}/referral/referrals` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Success Response (200):** Paginated list of `ReferralLogResource` (same as [Referral History](#122-get-referral-history))

---

### 12.4 Apply Referral Code

| | |
|---|---|
| **URL** | `POST /api/v1/customers/{id}/referral/apply` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer ID |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `code` | string | Yes | - |

**Request Example:**
```json
{
  "code": "REF-ABC123"
}
```

**Success Response (200):**
```json
{
  "data": {
    "message": "Kode referral berhasil diterapkan.",
    "referrer": { "..." }
  }
}
```

---

## 13. Loyalty Rewards

### 13.1 List Available Rewards

| | |
|---|---|
| **URL** | `GET /api/v1/loyalty/rewards` |
| **Auth** | Bearer Token |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Diskon 10%",
      "description": "Diskon 10% untuk semua layanan",
      "points_required": 100,
      "reward_type": "discount_percent",
      "reward_type_label": "Diskon Persentase",
      "reward_value": 10.0,
      "formatted_reward_value": "10%",
      "service_id": null,
      "product_id": null,
      "stock": 50,
      "max_per_customer": 3,
      "valid_from": "2024-01-01",
      "valid_until": "2024-12-31",
      "is_active": true,
      "is_available": true,
      "sort_order": 1,
      "service": null,
      "product": null,
      "created_at": "2024-01-01T00:00:00.000000Z"
    }
  ]
}
```

---

### 13.2 Get Reward Detail

| | |
|---|---|
| **URL** | `GET /api/v1/loyalty/rewards/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Loyalty Reward ID |

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "name": "Diskon 10%",
    "description": "Diskon 10% untuk semua layanan",
    "points_required": 100,
    "reward_type": "discount_percent",
    "reward_type_label": "Diskon Persentase",
    "reward_value": 10.0,
    "formatted_reward_value": "10%",
    "service_id": null,
    "product_id": null,
    "stock": 50,
    "max_per_customer": 3,
    "valid_from": "2024-01-01",
    "valid_until": "2024-12-31",
    "is_active": true,
    "is_available": true,
    "sort_order": 1,
    "service": null,
    "product": null,
    "created_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

### 13.3 Check Redemption Code

| | |
|---|---|
| **URL** | `POST /api/v1/loyalty/check-code` |
| **Auth** | Bearer Token |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `code` | string | Yes | - |

**Request Example:**
```json
{
  "code": "RDM-ABC123"
}
```

**Success Response (200):**
```json
{
  "data": {
    "valid": true,
    "redemption": {
      "id": 1,
      "code": "RDM-ABC123",
      "reward": { "..." },
      "valid_until": "2024-02-10",
      "is_valid": true
    }
  }
}
```

---

### 13.4 Use Redemption Code

| | |
|---|---|
| **URL** | `POST /api/v1/loyalty/use-code` |
| **Auth** | Bearer Token |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `code` | string | Yes | - |
| `transaction_id` | integer | No | exists:transactions,id |

**Request Example:**
```json
{
  "code": "RDM-ABC123",
  "transaction_id": 10
}
```

**Success Response (200):**
```json
{
  "data": {
    "message": "Kode reward berhasil digunakan.",
    "redemption": { "..." }
  }
}
```

---

### 13.5 Cancel Redemption

| | |
|---|---|
| **URL** | `POST /api/v1/loyalty/redemptions/{id}/cancel` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Loyalty Redemption ID |

**Success Response (200):**
```json
{
  "data": {
    "message": "Redemption berhasil dibatalkan.",
    "points_refunded": 100
  }
}
```

---

## 14. Appointments

### 14.1 List Appointments

| | |
|---|---|
| **URL** | `GET /api/v1/appointments` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `status` | string | Filter by status (`pending`, `confirmed`, `in_progress`, `completed`, `cancelled`) |
| `start_date` | string | Filter from date (Y-m-d) |
| `end_date` | string | Filter to date (Y-m-d) |
| `staff_id` | integer | Filter by staff |
| `customer_id` | integer | Filter by customer |
| `per_page` | integer | Items per page (default: 15) |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "customer_id": 1,
      "service_id": 1,
      "staff_id": 2,
      "customer_package_id": null,
      "appointment_date": "2024-01-15",
      "start_time": "10:00",
      "end_time": "11:00",
      "status": "confirmed",
      "status_label": "Confirmed",
      "status_color": "blue",
      "source": "online",
      "source_label": "Online",
      "notes": null,
      "cancelled_at": null,
      "cancelled_reason": null,
      "customer": {
        "id": 1,
        "name": "Jane Doe",
        "phone": "081234567890",
        "email": "jane@example.com",
        "..."
      },
      "service": {
        "id": 1,
        "name": "Basic Facial",
        "price": 150000.0,
        "formatted_price": "Rp 150.000",
        "..."
      },
      "staff": {
        "id": 2,
        "name": "Dr. Sarah",
        "..."
      },
      "treatment_record": null,
      "created_at": "2024-01-10T00:00:00.000000Z",
      "updated_at": "2024-01-10T00:00:00.000000Z"
    }
  ]
}
```

---

### 14.2 Create Appointment

| | |
|---|---|
| **URL** | `POST /api/v1/appointments` |
| **Auth** | Bearer Token |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `customer_id` | integer | Yes | exists:customers,id |
| `service_id` | integer | Yes | exists:services,id |
| `staff_id` | integer | No | exists:users,id |
| `customer_package_id` | integer | No | exists:customer_packages,id |
| `appointment_date` | string | Yes | date, after_or_equal:today (format: `Y-m-d`) |
| `start_time` | string | Yes | format: `H:i` (e.g. `"10:00"`) |
| `source` | string | No | `walk_in`, `phone`, `whatsapp`, `online` |
| `notes` | string | No | max:1000 |

**Request Example:**
```json
{
  "customer_id": 1,
  "service_id": 1,
  "staff_id": 2,
  "appointment_date": "2024-01-20",
  "start_time": "10:00",
  "source": "online",
  "notes": "First visit"
}
```

**Success Response (201):**
```json
{
  "data": {
    "id": 1,
    "customer_id": 1,
    "service_id": 1,
    "staff_id": 2,
    "customer_package_id": null,
    "appointment_date": "2024-01-20",
    "start_time": "10:00",
    "end_time": "11:00",
    "status": "pending",
    "status_label": "Pending",
    "status_color": "yellow",
    "source": "online",
    "source_label": "Online",
    "notes": "First visit",
    "cancelled_at": null,
    "cancelled_reason": null,
    "customer": { "..." },
    "service": { "..." },
    "staff": { "..." },
    "treatment_record": null,
    "created_at": "2024-01-15T00:00:00.000000Z",
    "updated_at": "2024-01-15T00:00:00.000000Z"
  }
}
```

---

### 14.3 Get Appointment Detail

| | |
|---|---|
| **URL** | `GET /api/v1/appointments/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Appointment ID |

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "customer_id": 1,
    "service_id": 1,
    "staff_id": 2,
    "customer_package_id": null,
    "appointment_date": "2024-01-20",
    "start_time": "10:00",
    "end_time": "11:00",
    "status": "confirmed",
    "status_label": "Confirmed",
    "status_color": "blue",
    "source": "online",
    "source_label": "Online",
    "notes": "First visit",
    "cancelled_at": null,
    "cancelled_reason": null,
    "customer": { "..." },
    "service": { "..." },
    "staff": { "..." },
    "treatment_record": { "..." },
    "created_at": "2024-01-15T00:00:00.000000Z",
    "updated_at": "2024-01-15T00:00:00.000000Z"
  }
}
```

---

### 14.4 Update Appointment

| | |
|---|---|
| **URL** | `PUT /api/v1/appointments/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Appointment ID |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `customer_id` | integer | Sometimes | exists:customers,id |
| `service_id` | integer | Sometimes | exists:services,id |
| `staff_id` | integer | No | exists:users,id |
| `appointment_date` | string | Sometimes | date (format: `Y-m-d`) |
| `start_time` | string | Sometimes | format: `H:i` |
| `notes` | string | No | max:1000 |

**Success Response (200):**
```json
{
  "data": { "..." }
}
```

---

### 14.5 Delete Appointment

| | |
|---|---|
| **URL** | `DELETE /api/v1/appointments/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Appointment ID |

**Success Response (200):**
```json
{
  "message": "Appointment berhasil dihapus."
}
```

---

### 14.6 Update Appointment Status

| | |
|---|---|
| **URL** | `PATCH /api/v1/appointments/{id}/status` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Appointment ID |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `status` | string | Yes | `pending`, `confirmed`, `in_progress`, `completed`, `cancelled` |
| `cancelled_reason` | string | Required if status=cancelled | - |

**Request Example (Cancel):**
```json
{
  "status": "cancelled",
  "cancelled_reason": "Customer tidak bisa hadir"
}
```

**Request Example (Confirm):**
```json
{
  "status": "confirmed"
}
```

**Success Response (200):**
```json
{
  "data": { "..." }
}
```

---

### 14.7 Get Today's Appointments

| | |
|---|---|
| **URL** | `GET /api/v1/appointments-today` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `staff_id` | integer | Filter by staff |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "appointment_date": "2024-01-15",
      "start_time": "10:00",
      "end_time": "11:00",
      "status": "confirmed",
      "customer": { "..." },
      "service": { "..." },
      "staff": { "..." },
      "..."
    }
  ]
}
```

---

### 14.8 Get Appointments Calendar

| | |
|---|---|
| **URL** | `GET /api/v1/appointments-calendar` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `start_date` | string | Yes | Start date (Y-m-d) |
| `end_date` | string | Yes | End date (Y-m-d), must be after_or_equal start_date |

**Request Example:**
```
GET /api/v1/appointments-calendar?start_date=2024-01-01&end_date=2024-01-31
```

**Success Response (200):**
```json
{
  "data": [
    {
      "date": "2024-01-15",
      "appointments": [
        {
          "id": 1,
          "start_time": "10:00",
          "end_time": "11:00",
          "status": "confirmed",
          "status_color": "blue",
          "customer": { "name": "Jane Doe" },
          "service": { "name": "Basic Facial" },
          "staff": { "name": "Dr. Sarah" }
        }
      ]
    }
  ]
}
```

---

### 14.9 Get Available Slots

| | |
|---|---|
| **URL** | `GET /api/v1/appointments-available-slots` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `date` | string | Yes | Date to check (Y-m-d) |
| `service_id` | integer | Yes | Service ID |
| `staff_id` | integer | No | Specific staff to check |

**Request Example:**
```
GET /api/v1/appointments-available-slots?date=2024-01-20&service_id=1&staff_id=2
```

**Success Response (200):**
```json
{
  "data": {
    "date": "2024-01-20",
    "service": { "name": "Basic Facial", "duration_minutes": 60 },
    "slots": [
      { "time": "09:00", "available": true },
      { "time": "10:00", "available": false },
      { "time": "11:00", "available": true },
      { "time": "13:00", "available": true },
      { "time": "14:00", "available": true },
      { "time": "15:00", "available": true }
    ]
  }
}
```

---

## 15. Treatment Records

### 15.1 List Treatment Records

| | |
|---|---|
| **URL** | `GET /api/v1/treatments` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `customer_id` | integer | Filter by customer |
| `with_photos` | boolean | Include photo URLs |
| `per_page` | integer | Items per page (default: 15) |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "appointment_id": 1,
      "customer_id": 1,
      "staff_id": 2,
      "notes": "Kulit responsif terhadap treatment",
      "products_used": ["Serum A", "Toner B"],
      "before_photo": "treatments/before_1.jpg",
      "before_photo_url": "https://example.com/storage/treatments/before_1.jpg",
      "after_photo": "treatments/after_1.jpg",
      "after_photo_url": "https://example.com/storage/treatments/after_1.jpg",
      "recommendations": "Gunakan sunscreen setiap hari",
      "follow_up_date": "2024-02-15",
      "appointment": { "..." },
      "customer": { "..." },
      "staff": { "..." },
      "created_at": "2024-01-15T00:00:00.000000Z",
      "updated_at": "2024-01-15T00:00:00.000000Z"
    }
  ]
}
```

---

### 15.2 Create Treatment Record

| | |
|---|---|
| **URL** | `POST /api/v1/treatments` |
| **Auth** | Bearer Token |
| **Content-Type** | `multipart/form-data` |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `appointment_id` | integer | Yes | exists:appointments,id, unique |
| `customer_id` | integer | Yes | exists:customers,id |
| `notes` | string | No | max:5000 |
| `products_used` | array | No | - |
| `products_used.*` | string | No | max:255 |
| `before_photos` | array | No | max:5 files |
| `before_photos.*` | file | No | image (jpeg,png,jpg,webp), max:5120KB |
| `after_photos` | array | No | max:5 files |
| `after_photos.*` | file | No | image (jpeg,png,jpg,webp), max:5120KB |
| `recommendations` | string | No | max:2000 |
| `follow_up_date` | string | No | date, after:today (format: `Y-m-d`) |

**Success Response (201):**
```json
{
  "data": {
    "id": 1,
    "appointment_id": 1,
    "customer_id": 1,
    "staff_id": 2,
    "notes": "Treatment notes",
    "products_used": ["Serum A"],
    "before_photo": "treatments/before_1.jpg",
    "before_photo_url": "https://example.com/storage/treatments/before_1.jpg",
    "after_photo": null,
    "after_photo_url": null,
    "recommendations": "Use sunscreen daily",
    "follow_up_date": "2024-02-15",
    "appointment": { "..." },
    "customer": { "..." },
    "staff": { "..." },
    "created_at": "2024-01-15T00:00:00.000000Z",
    "updated_at": "2024-01-15T00:00:00.000000Z"
  }
}
```

---

### 15.3 Get Treatment Record Detail

| | |
|---|---|
| **URL** | `GET /api/v1/treatments/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Treatment Record ID |

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "appointment_id": 1,
    "customer_id": 1,
    "staff_id": 2,
    "notes": "Treatment notes",
    "products_used": ["Serum A", "Toner B"],
    "before_photo": "treatments/before_1.jpg",
    "before_photo_url": "https://example.com/storage/treatments/before_1.jpg",
    "after_photo": "treatments/after_1.jpg",
    "after_photo_url": "https://example.com/storage/treatments/after_1.jpg",
    "recommendations": "Gunakan sunscreen setiap hari",
    "follow_up_date": "2024-02-15",
    "appointment": { "..." },
    "customer": { "..." },
    "staff": { "..." },
    "created_at": "2024-01-15T00:00:00.000000Z",
    "updated_at": "2024-01-15T00:00:00.000000Z"
  }
}
```

---

### 15.4 Update Treatment Record

| | |
|---|---|
| **URL** | `PUT /api/v1/treatments/{id}` |
| **Auth** | Bearer Token |
| **Content-Type** | `multipart/form-data` |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Treatment Record ID |

**Request Body:**
| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `notes` | string | No | max:5000 |
| `products_used` | array | No | - |
| `products_used.*` | string | No | max:255 |
| `before_photos` | array | No | max:5 files |
| `before_photos.*` | file | No | image (jpeg,png,jpg,webp), max:5120KB |
| `after_photos` | array | No | max:5 files |
| `after_photos.*` | file | No | image (jpeg,png,jpg,webp), max:5120KB |
| `recommendations` | string | No | max:2000 |
| `follow_up_date` | string | No | date, after:today (format: `Y-m-d`) |

**Success Response (200):**
```json
{
  "data": { "..." }
}
```

---

### 15.5 Delete Treatment Record

| | |
|---|---|
| **URL** | `DELETE /api/v1/treatments/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Treatment Record ID |

**Success Response (200):**
```json
{
  "message": "Treatment record berhasil dihapus."
}
```

---

## 16. Packages

### 16.1 List Packages

| | |
|---|---|
| **URL** | `GET /api/v1/packages` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `service_id` | integer | Filter by service |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Facial 5 Sessions",
      "description": "Paket facial 5 sesi dengan harga spesial",
      "service_id": 1,
      "total_sessions": 5,
      "original_price": 750000.0,
      "formatted_original_price": "Rp 750.000",
      "package_price": 600000.0,
      "formatted_package_price": "Rp 600.000",
      "discount_percentage": 20.0,
      "savings": 150000.0,
      "formatted_savings": "Rp 150.000",
      "price_per_session": 120000.0,
      "formatted_price_per_session": "Rp 120.000",
      "validity_days": 90,
      "is_active": true,
      "service": {
        "id": 1,
        "name": "Basic Facial",
        "..."
      },
      "created_at": "2024-01-01T00:00:00.000000Z"
    }
  ]
}
```

---

### 16.2 Get Package Detail

| | |
|---|---|
| **URL** | `GET /api/v1/packages/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Package ID |

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "name": "Facial 5 Sessions",
    "description": "Paket facial 5 sesi",
    "service_id": 1,
    "total_sessions": 5,
    "original_price": 750000.0,
    "formatted_original_price": "Rp 750.000",
    "package_price": 600000.0,
    "formatted_package_price": "Rp 600.000",
    "discount_percentage": 20.0,
    "savings": 150000.0,
    "formatted_savings": "Rp 150.000",
    "price_per_session": 120000.0,
    "formatted_price_per_session": "Rp 120.000",
    "validity_days": 90,
    "is_active": true,
    "service": { "..." },
    "created_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

### 16.3 List Customer Packages

| | |
|---|---|
| **URL** | `GET /api/v1/customer-packages` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `customer_id` | integer | Filter by customer |
| `active_only` | boolean | Show only active packages |
| `status` | string | Filter by status |
| `per_page` | integer | Items per page (default: 15) |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "customer_id": 1,
      "package_id": 1,
      "sold_by": 2,
      "price_paid": 600000.0,
      "formatted_price_paid": "Rp 600.000",
      "sessions_total": 5,
      "sessions_used": 2,
      "sessions_remaining": 3,
      "usage_percentage": 40.0,
      "purchased_at": "2024-01-01",
      "expires_at": "2024-04-01",
      "days_remaining": 75,
      "is_expired": false,
      "is_usable": true,
      "status": "active",
      "status_label": "Active",
      "notes": null,
      "customer": { "..." },
      "package": { "..." },
      "seller": { "..." },
      "created_at": "2024-01-01T00:00:00.000000Z"
    }
  ]
}
```

---

### 16.4 Get Customer Package Detail

| | |
|---|---|
| **URL** | `GET /api/v1/customer-packages/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Customer Package ID |

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "customer_id": 1,
    "package_id": 1,
    "sold_by": 2,
    "price_paid": 600000.0,
    "formatted_price_paid": "Rp 600.000",
    "sessions_total": 5,
    "sessions_used": 2,
    "sessions_remaining": 3,
    "usage_percentage": 40.0,
    "purchased_at": "2024-01-01",
    "expires_at": "2024-04-01",
    "days_remaining": 75,
    "is_expired": false,
    "is_usable": true,
    "status": "active",
    "status_label": "Active",
    "notes": null,
    "customer": { "..." },
    "package": { "..." },
    "seller": { "..." },
    "created_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

## 17. Transactions

### 17.1 List Transactions

| | |
|---|---|
| **URL** | `GET /api/v1/transactions` |
| **Auth** | Bearer Token |

**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `customer_id` | integer | Filter by customer |
| `status` | string | Filter by status |
| `start_date` | string | Filter from date (Y-m-d) |
| `end_date` | string | Filter to date (Y-m-d) |
| `per_page` | integer | Items per page (default: 15) |

**Success Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "invoice_number": "INV-20240115-001",
      "customer_id": 1,
      "appointment_id": 1,
      "cashier_id": 2,
      "subtotal": 150000.0,
      "formatted_subtotal": "Rp 150.000",
      "discount_amount": 0.0,
      "formatted_discount_amount": "Rp 0",
      "discount_type": null,
      "tax_amount": 0.0,
      "total_amount": 150000.0,
      "formatted_total_amount": "Rp 150.000",
      "paid_amount": 150000.0,
      "formatted_paid_amount": "Rp 150.000",
      "change_amount": 0.0,
      "outstanding_amount": 0.0,
      "formatted_outstanding_amount": "Rp 0",
      "status": "paid",
      "status_label": "Paid",
      "is_paid": true,
      "notes": null,
      "paid_at": "2024-01-15T10:30:00.000000Z",
      "customer": { "..." },
      "appointment": { "..." },
      "cashier": { "..." },
      "items": [
        {
          "id": 1,
          "transaction_id": 1,
          "item_type": "service",
          "item_id": 1,
          "item_name": "Basic Facial",
          "quantity": 1,
          "unit_price": 150000.0,
          "total_price": 150000.0,
          "notes": null
        }
      ],
      "payments": [
        {
          "id": 1,
          "transaction_id": 1,
          "amount": 150000.0,
          "payment_method": "cash",
          "payment_method_label": "Cash",
          "reference_number": null,
          "notes": null,
          "received_by": 2,
          "receiver": { "..." },
          "paid_at": "2024-01-15T10:30:00.000000Z"
        }
      ],
      "created_at": "2024-01-15T10:00:00.000000Z",
      "updated_at": "2024-01-15T10:30:00.000000Z"
    }
  ]
}
```

---

### 17.2 Get Transaction Detail

| | |
|---|---|
| **URL** | `GET /api/v1/transactions/{id}` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Transaction ID |

**Success Response (200):**
```json
{
  "data": {
    "id": 1,
    "invoice_number": "INV-20240115-001",
    "customer_id": 1,
    "appointment_id": 1,
    "cashier_id": 2,
    "subtotal": 150000.0,
    "formatted_subtotal": "Rp 150.000",
    "discount_amount": 0.0,
    "formatted_discount_amount": "Rp 0",
    "discount_type": null,
    "tax_amount": 0.0,
    "total_amount": 150000.0,
    "formatted_total_amount": "Rp 150.000",
    "paid_amount": 150000.0,
    "formatted_paid_amount": "Rp 150.000",
    "change_amount": 0.0,
    "outstanding_amount": 0.0,
    "formatted_outstanding_amount": "Rp 0",
    "status": "paid",
    "status_label": "Paid",
    "is_paid": true,
    "notes": null,
    "paid_at": "2024-01-15T10:30:00.000000Z",
    "customer": { "..." },
    "appointment": { "..." },
    "cashier": { "..." },
    "items": [ "..." ],
    "payments": [ "..." ],
    "created_at": "2024-01-15T10:00:00.000000Z",
    "updated_at": "2024-01-15T10:30:00.000000Z"
  }
}
```

---

### 17.3 Get Transaction Receipt

| | |
|---|---|
| **URL** | `GET /api/v1/transactions/{id}/receipt` |
| **Auth** | Bearer Token |

**Path Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `id` | integer | Transaction ID |

**Success Response (200):**
```json
{
  "data": {
    "clinic": {
      "name": "GlowUp Clinic",
      "address": "Jl. Contoh No. 123",
      "phone": "021-1234567"
    },
    "transaction": {
      "invoice_number": "INV-20240115-001",
      "date": "2024-01-15",
      "cashier": "Admin"
    },
    "customer": {
      "name": "Jane Doe",
      "phone": "081234567890"
    },
    "items": [
      {
        "name": "Basic Facial",
        "quantity": 1,
        "unit_price": 150000,
        "total_price": 150000
      }
    ],
    "subtotal": 150000,
    "discount": 0,
    "tax": 0,
    "total": 150000,
    "payments": [
      {
        "method": "Cash",
        "amount": 150000
      }
    ],
    "paid_amount": 150000,
    "change": 0
  }
}
```

---

## Endpoint Summary

| # | Method | URL | Auth | Description |
|---|--------|-----|------|-------------|
| 1 | POST | `/api/v1/login` | Public | Login |
| 2 | GET | `/api/v1/settings` | Public | All settings |
| 3 | GET | `/api/v1/settings/clinic` | Public | Clinic info |
| 4 | GET | `/api/v1/settings/hours` | Public | Operating hours |
| 5 | GET | `/api/v1/settings/branding` | Public | Branding settings |
| 6 | GET | `/api/v1/settings/loyalty` | Public | Loyalty settings |
| 7 | GET | `/api/v1/settings/referral` | Public | Referral settings |
| 8 | POST | `/api/v1/referral/validate` | Public | Validate referral code |
| 9 | GET | `/api/v1/referral/program-info` | Public | Referral program info |
| 10 | POST | `/api/v1/logout` | Token | Logout |
| 11 | GET | `/api/v1/profile` | Token | Get profile |
| 12 | PUT | `/api/v1/profile` | Token | Update profile |
| 13 | GET | `/api/v1/dashboard` | Token | Dashboard data |
| 14 | GET | `/api/v1/dashboard/summary` | Token | Dashboard summary |
| 15 | GET | `/api/v1/service-categories` | Token | List service categories |
| 16 | GET | `/api/v1/service-categories/{id}` | Token | Service category detail |
| 17 | GET | `/api/v1/services` | Token | List services |
| 18 | GET | `/api/v1/services/{id}` | Token | Service detail |
| 19 | GET | `/api/v1/product-categories` | Token | List product categories |
| 20 | GET | `/api/v1/product-categories/{id}` | Token | Product category detail |
| 21 | GET | `/api/v1/products` | Token | List products |
| 22 | GET | `/api/v1/products/{id}` | Token | Product detail |
| 23 | GET | `/api/v1/staff` | Token | List staff |
| 24 | GET | `/api/v1/staff/beauticians` | Token | List beauticians |
| 25 | GET | `/api/v1/staff/{id}` | Token | Staff detail |
| 26 | GET | `/api/v1/customers` | Token | List customers |
| 27 | POST | `/api/v1/customers` | Token | Create customer |
| 28 | GET | `/api/v1/customers/{id}` | Token | Customer detail |
| 29 | PUT | `/api/v1/customers/{id}` | Token | Update customer |
| 30 | DELETE | `/api/v1/customers/{id}` | Token | Delete customer |
| 31 | GET | `/api/v1/customers/{id}/stats` | Token | Customer statistics |
| 32 | GET | `/api/v1/customers/{id}/treatments` | Token | Customer treatments |
| 33 | GET | `/api/v1/customers/{id}/packages` | Token | Customer packages |
| 34 | GET | `/api/v1/customers/{id}/appointments` | Token | Customer appointments |
| 35 | GET | `/api/v1/customers/{id}/loyalty` | Token | Loyalty summary |
| 36 | GET | `/api/v1/customers/{id}/loyalty/points` | Token | Points history |
| 37 | POST | `/api/v1/customers/{id}/loyalty/redeem` | Token | Redeem reward |
| 38 | GET | `/api/v1/customers/{id}/loyalty/redemptions` | Token | Redemption history |
| 39 | POST | `/api/v1/customers/{id}/loyalty/adjust` | Token | Adjust points |
| 40 | GET | `/api/v1/customers/{id}/referral` | Token | Referral info |
| 41 | GET | `/api/v1/customers/{id}/referral/history` | Token | Referral history |
| 42 | GET | `/api/v1/customers/{id}/referral/referrals` | Token | Customer's referrals |
| 43 | POST | `/api/v1/customers/{id}/referral/apply` | Token | Apply referral code |
| 44 | GET | `/api/v1/loyalty/rewards` | Token | List rewards |
| 45 | GET | `/api/v1/loyalty/rewards/{id}` | Token | Reward detail |
| 46 | POST | `/api/v1/loyalty/check-code` | Token | Check redemption code |
| 47 | POST | `/api/v1/loyalty/use-code` | Token | Use redemption code |
| 48 | POST | `/api/v1/loyalty/redemptions/{id}/cancel` | Token | Cancel redemption |
| 49 | GET | `/api/v1/appointments` | Token | List appointments |
| 50 | POST | `/api/v1/appointments` | Token | Create appointment |
| 51 | GET | `/api/v1/appointments/{id}` | Token | Appointment detail |
| 52 | PUT | `/api/v1/appointments/{id}` | Token | Update appointment |
| 53 | DELETE | `/api/v1/appointments/{id}` | Token | Delete appointment |
| 54 | PATCH | `/api/v1/appointments/{id}/status` | Token | Update status |
| 55 | GET | `/api/v1/appointments-today` | Token | Today's appointments |
| 56 | GET | `/api/v1/appointments-calendar` | Token | Calendar view |
| 57 | GET | `/api/v1/appointments-available-slots` | Token | Available slots |
| 58 | GET | `/api/v1/treatments` | Token | List treatments |
| 59 | POST | `/api/v1/treatments` | Token | Create treatment |
| 60 | GET | `/api/v1/treatments/{id}` | Token | Treatment detail |
| 61 | PUT | `/api/v1/treatments/{id}` | Token | Update treatment |
| 62 | DELETE | `/api/v1/treatments/{id}` | Token | Delete treatment |
| 63 | GET | `/api/v1/packages` | Token | List packages |
| 64 | GET | `/api/v1/packages/{id}` | Token | Package detail |
| 65 | GET | `/api/v1/customer-packages` | Token | List customer packages |
| 66 | GET | `/api/v1/customer-packages/{id}` | Token | Customer package detail |
| 67 | GET | `/api/v1/transactions` | Token | List transactions |
| 68 | GET | `/api/v1/transactions/{id}` | Token | Transaction detail |
| 69 | GET | `/api/v1/transactions/{id}/receipt` | Token | Transaction receipt |
