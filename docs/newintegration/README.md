# GlowUp API Integration Guide for Flutter

Dokumentasi lengkap untuk integrasi Flutter app dengan backend GlowUp API v1.

## Overview

API telah diperbarui dengan fitur-fitur baru:
- **Loyalty System** - Points, rewards, redemption
- **Referral System** - Referral codes, tracking
- **Products** - Product inventory browsing
- **Dashboard** - Statistics & analytics
- **Settings** - Clinic info, operating hours, feature flags
- **Staff** - Staff/beautician management

## Base Configuration

```dart
// lib/core/constants/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://glowup.jagoflutter.com';
  static const String apiVersion = 'v1';
  static const String apiBase = '$baseUrl/api/$apiVersion';

  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

## Table of Contents

1. [Authentication](#1-authentication)
2. [Dashboard](#2-dashboard)
3. [Settings](#3-settings)
4. [Customers](#4-customers)
5. [Loyalty System](#5-loyalty-system)
6. [Referral System](#6-referral-system)
7. [Services](#7-services)
8. [Products](#8-products)
9. [Appointments](#9-appointments)
10. [Treatment Records](#10-treatment-records)
11. [Packages](#11-packages)
12. [Transactions](#12-transactions)
13. [Staff](#13-staff)

---

## 1. Authentication

### Login
```
POST /api/v1/login
```

**Request:**
```json
{
  "email": "admin@glowup.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "data": {
    "user": {
      "id": 1,
      "name": "Admin",
      "email": "admin@glowup.com",
      "phone": "081234567890",
      "role": "owner",
      "avatar": null,
      "is_active": true
    },
    "token": "1|abc123..."
  }
}
```

### Logout
```
POST /api/v1/logout
Authorization: Bearer {token}
```

### Get Profile
```
GET /api/v1/profile
Authorization: Bearer {token}
```

### Update Profile
```
PUT /api/v1/profile
Authorization: Bearer {token}
```

**Request:**
```json
{
  "name": "New Name",
  "phone": "081234567890"
}
```

---

## 2. Dashboard

### Get Dashboard Statistics
```
GET /api/v1/dashboard
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": {
    "today": {
      "revenue": 5000000,
      "appointments": 10,
      "completed_appointments": 5,
      "new_customers": 2
    },
    "month": {
      "revenue": 150000000,
      "appointments": 300,
      "completed_appointments": 250,
      "new_customers": 50,
      "total_customers": 500
    },
    "today_appointments": [
      {
        "id": 1,
        "customer": {...},
        "service": {...},
        "start_time": "09:00",
        "status": "confirmed"
      }
    ],
    "revenue_chart": [
      {"date": "2026-02-01", "day": "Sat", "revenue": 5000000},
      {"date": "2026-02-02", "day": "Sun", "revenue": 3000000}
    ]
  }
}
```

### Get Summary
```
GET /api/v1/dashboard/summary
Authorization: Bearer {token}
```

---

## 3. Settings

### Get All Settings (Public)
```
GET /api/v1/settings
```

**Response:**
```json
{
  "data": {
    "clinic": {
      "name": "GlowUp Clinic",
      "phone": "021-12345678",
      "email": "info@glowup.com",
      "address": "Jl. Sudirman No. 1",
      "city": "Jakarta",
      "whatsapp": "6281234567890",
      "instagram": "@glowupclinic"
    },
    "operating_hours": [
      {"day_of_week": 0, "day_name": "Sunday", "day_name_id": "Minggu", "is_closed": true},
      {"day_of_week": 1, "day_name": "Monday", "day_name_id": "Senin", "open_time": "09:00", "close_time": "21:00", "is_closed": false}
    ],
    "features": {
      "products": true,
      "treatment_records": true,
      "packages": true,
      "customer_packages": true,
      "loyalty": true,
      "online_booking": true,
      "customer_portal": true,
      "walk_in_queue": false
    },
    "business_type": "clinic"
  }
}
```

### Get Specific Settings (Public)
```
GET /api/v1/settings/clinic      # Clinic info only
GET /api/v1/settings/hours       # Operating hours only
GET /api/v1/settings/branding    # Logo and colors
GET /api/v1/settings/loyalty     # Loyalty program config
GET /api/v1/settings/referral    # Referral program config
```

---

## 4. Customers

### List Customers
```
GET /api/v1/customers
Authorization: Bearer {token}

Query Parameters:
- search: string (search by name, phone, email)
- page: int (default: 1)
- per_page: int (default: 15)
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "phone": "081234567890",
      "email": "john@example.com",
      "birthdate": "1990-01-15",
      "age": 36,
      "gender": "male",
      "skin_type": "combination",
      "skin_concerns": ["acne", "dark_spots"],
      "total_visits": 15,
      "total_spent": 5000000,
      "formatted_total_spent": "Rp 5.000.000",
      "loyalty_points": 500,
      "lifetime_points": 1500,
      "loyalty_tier": "silver",
      "loyalty_tier_label": "Silver",
      "referral_code": "REF-ABCD1234"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 10,
    "per_page": 15,
    "total": 150
  }
}
```

### Create Customer
```
POST /api/v1/customers
Authorization: Bearer {token}
```

**Request:**
```json
{
  "name": "Jane Doe",
  "phone": "081234567890",
  "email": "jane@example.com",
  "birthdate": "1995-05-20",
  "gender": "female",
  "address": "Jl. Sudirman No. 10",
  "skin_type": "oily",
  "skin_concerns": ["acne", "large_pores"],
  "allergies": "Aspirin",
  "notes": "First time customer"
}
```

### Get Customer
```
GET /api/v1/customers/{id}
Authorization: Bearer {token}
```

### Update Customer
```
PUT /api/v1/customers/{id}
Authorization: Bearer {token}
```

### Delete Customer
```
DELETE /api/v1/customers/{id}
Authorization: Bearer {token}
```

### Get Customer Stats
```
GET /api/v1/customers/{id}/stats
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": {
    "total_visits": 15,
    "total_spent": 5000000,
    "total_packages": 2,
    "active_packages": 1,
    "last_visit": "2026-02-01"
  }
}
```

### Get Customer Treatments
```
GET /api/v1/customers/{id}/treatments
Authorization: Bearer {token}
```

### Get Customer Packages
```
GET /api/v1/customers/{id}/packages?active_only=1
Authorization: Bearer {token}
```

### Get Customer Appointments
```
GET /api/v1/customers/{id}/appointments?status=completed&upcoming=1
Authorization: Bearer {token}
```

---

## 5. Loyalty System

### Get Customer Loyalty Summary
```
GET /api/v1/customers/{id}/loyalty
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": {
    "current_points": 500,
    "lifetime_points": 1500,
    "tier": "silver",
    "tier_label": "Silver",
    "total_earned": 1500,
    "total_redeemed": 1000,
    "pending_redemptions": 1
  }
}
```

### Get Customer Points History
```
GET /api/v1/customers/{id}/loyalty/points
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "type": "earn",
      "type_label": "Dapat Poin",
      "points": 100,
      "balance_after": 500,
      "description": "Points from transaction #INV20260206001",
      "is_earn": true,
      "is_redeem": false,
      "created_at": "2026-02-06T10:00:00.000000Z"
    }
  ]
}
```

### Get Available Rewards
```
GET /api/v1/loyalty/rewards
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Diskon 10%",
      "description": "Diskon 10% untuk semua layanan",
      "points_required": 500,
      "reward_type": "discount_percent",
      "reward_type_label": "Diskon Persen",
      "reward_value": 10,
      "formatted_reward_value": "10%",
      "stock": 100,
      "max_per_customer": 3,
      "is_active": true,
      "is_available": true
    }
  ]
}
```

### Redeem Reward
```
POST /api/v1/customers/{id}/loyalty/redeem
Authorization: Bearer {token}
```

**Request:**
```json
{
  "reward_id": 1
}
```

**Response:**
```json
{
  "message": "Reward redeemed successfully.",
  "data": {
    "id": 1,
    "code": "RWD-ABCD1234",
    "points_used": 500,
    "status": "pending",
    "valid_until": "2026-03-06",
    "reward": {...}
  }
}
```

### Get Customer Redemptions
```
GET /api/v1/customers/{id}/loyalty/redemptions?status=pending
Authorization: Bearer {token}
```

### Check Redemption Code
```
POST /api/v1/loyalty/check-code
Authorization: Bearer {token}
```

**Request:**
```json
{
  "code": "RWD-ABCD1234"
}
```

**Response:**
```json
{
  "valid": true,
  "status": "pending",
  "message": "Code is valid.",
  "data": {
    "id": 1,
    "code": "RWD-ABCD1234",
    "reward": {...},
    "customer": {...}
  }
}
```

### Use Redemption Code
```
POST /api/v1/loyalty/use-code
Authorization: Bearer {token}
```

**Request:**
```json
{
  "code": "RWD-ABCD1234",
  "transaction_id": 123
}
```

### Cancel Redemption
```
POST /api/v1/loyalty/redemptions/{id}/cancel
Authorization: Bearer {token}
```

### Adjust Points (Admin)
```
POST /api/v1/customers/{id}/loyalty/adjust
Authorization: Bearer {token}
```

**Request:**
```json
{
  "points": 100,
  "description": "Bonus birthday points"
}
```

---

## 6. Referral System

### Get Referral Program Info (Public)
```
GET /api/v1/referral/program-info
```

**Response:**
```json
{
  "data": {
    "referrer_points": 100,
    "referee_points": 50,
    "code_prefix": "REF",
    "terms": [
      "Points awarded after referee completes first transaction",
      "Referrer receives 100 points",
      "New customer receives 50 points"
    ]
  }
}
```

### Validate Referral Code (Public)
```
POST /api/v1/referral/validate
```

**Request:**
```json
{
  "code": "REF-ABCD1234"
}
```

**Response:**
```json
{
  "valid": true,
  "message": "Referral code is valid.",
  "data": {
    "referrer_name": "John Doe",
    "referrer_points": 100,
    "referee_points": 50
  }
}
```

### Get Customer Referral Info
```
GET /api/v1/customers/{id}/referral
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": {
    "referral_code": "REF-ABCD1234",
    "referral_link": "https://glowup.com/?ref=REF-ABCD1234",
    "stats": {
      "total_referrals": 10,
      "pending_referrals": 2,
      "rewarded_referrals": 8,
      "total_points_earned": 800
    },
    "referrer": null
  }
}
```

### Get Referral History
```
GET /api/v1/customers/{id}/referral/history
Authorization: Bearer {token}
```

### Get Referred Customers
```
GET /api/v1/customers/{id}/referral/referrals
Authorization: Bearer {token}
```

### Apply Referral Code
```
POST /api/v1/customers/{id}/referral/apply
Authorization: Bearer {token}
```

**Request:**
```json
{
  "code": "REF-ABCD1234"
}
```

---

## 7. Services

### List Service Categories
```
GET /api/v1/service-categories?with_services=1&with_count=1
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Facial Treatment",
      "description": "Perawatan wajah",
      "icon": "face",
      "sort_order": 1,
      "is_active": true,
      "services_count": 5,
      "services": [
        {
          "id": 1,
          "name": "Basic Facial",
          "duration_minutes": 60,
          "price": 150000,
          "formatted_price": "Rp 150.000"
        }
      ]
    }
  ]
}
```

### Get Category Detail
```
GET /api/v1/service-categories/{id}
Authorization: Bearer {token}
```

### List Services
```
GET /api/v1/services?category_id=1&search=facial
Authorization: Bearer {token}
```

### Get Service Detail
```
GET /api/v1/services/{id}
Authorization: Bearer {token}
```

---

## 8. Products

### List Product Categories
```
GET /api/v1/product-categories?with_products=1&with_count=1
Authorization: Bearer {token}
```

**Response:**
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
      "products": [...]
    }
  ]
}
```

### Get Category Detail
```
GET /api/v1/product-categories/{id}
Authorization: Bearer {token}
```

### List Products
```
GET /api/v1/products?category_id=1&search=serum&in_stock_only=1
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Vitamin C Serum",
      "sku": "SKU-001",
      "description": "Serum vitamin C untuk mencerahkan kulit",
      "price": 250000,
      "formatted_price": "Rp 250.000",
      "stock": 50,
      "min_stock": 10,
      "unit": "pcs",
      "image_url": "https://...",
      "is_active": true,
      "track_stock": true,
      "is_low_stock": false,
      "is_out_of_stock": false
    }
  ]
}
```

### Get Product Detail
```
GET /api/v1/products/{id}
Authorization: Bearer {token}
```

---

## 9. Appointments

### List Appointments
```
GET /api/v1/appointments?status=confirmed&start_date=2026-02-01&end_date=2026-02-28&staff_id=1&customer_id=1
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "appointment_date": "2026-02-06",
      "start_time": "09:00",
      "end_time": "10:00",
      "status": "confirmed",
      "status_label": "Dikonfirmasi",
      "status_color": "blue",
      "source": "online",
      "source_label": "Online Booking",
      "customer": {...},
      "service": {...},
      "staff": {...}
    }
  ]
}
```

### Create Appointment
```
POST /api/v1/appointments
Authorization: Bearer {token}
```

**Request:**
```json
{
  "customer_id": 1,
  "service_id": 1,
  "staff_id": 2,
  "appointment_date": "2026-02-10",
  "start_time": "10:00",
  "notes": "First time customer",
  "source": "phone"
}
```

### Get Appointment
```
GET /api/v1/appointments/{id}
Authorization: Bearer {token}
```

### Update Appointment
```
PUT /api/v1/appointments/{id}
Authorization: Bearer {token}
```

### Delete Appointment
```
DELETE /api/v1/appointments/{id}
Authorization: Bearer {token}
```

### Update Appointment Status
```
PATCH /api/v1/appointments/{id}/status
Authorization: Bearer {token}
```

**Request:**
```json
{
  "status": "completed"
}
```

Or for cancellation:
```json
{
  "status": "cancelled",
  "cancelled_reason": "Customer request"
}
```

### Get Today's Appointments
```
GET /api/v1/appointments-today
Authorization: Bearer {token}
```

### Get Calendar Appointments
```
GET /api/v1/appointments-calendar?start=2026-02-01&end=2026-02-28
Authorization: Bearer {token}
```

### Get Available Slots
```
GET /api/v1/appointments-available-slots?date=2026-02-10&service_id=1&staff_id=2
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {"time": "09:00", "is_available": true},
    {"time": "09:30", "is_available": true},
    {"time": "10:00", "is_available": false},
    {"time": "10:30", "is_available": true}
  ]
}
```

---

## 10. Treatment Records

### List Treatment Records
```
GET /api/v1/treatments?customer_id=1&with_photos=1
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "appointment_id": 1,
      "customer_id": 1,
      "staff_id": 2,
      "notes": "Treatment notes here",
      "before_photos": ["photos/before1.jpg"],
      "before_photo_urls": ["https://.../photos/before1.jpg"],
      "after_photos": ["photos/after1.jpg"],
      "after_photo_urls": ["https://.../photos/after1.jpg"],
      "recommendations": "Use sunscreen daily",
      "follow_up_date": "2026-02-20",
      "appointment": {...},
      "customer": {...},
      "staff": {...}
    }
  ]
}
```

### Create Treatment Record
```
POST /api/v1/treatments
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request (multipart):**
```
appointment_id: 1
customer_id: 1
staff_id: 2
notes: Treatment went well
recommendations: Use moisturizer twice daily
follow_up_date: 2026-02-20
before_photos[]: (file)
before_photos[]: (file)
after_photos[]: (file)
```

### Get Treatment Record
```
GET /api/v1/treatments/{id}
Authorization: Bearer {token}
```

### Update Treatment Record
```
PUT /api/v1/treatments/{id}
Authorization: Bearer {token}
```

### Delete Treatment Record
```
DELETE /api/v1/treatments/{id}
Authorization: Bearer {token}
```

---

## 11. Packages

### List Packages
```
GET /api/v1/packages?service_id=1
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Facial Package 5x",
      "description": "5 sessions of basic facial",
      "total_sessions": 5,
      "original_price": 750000,
      "formatted_original_price": "Rp 750.000",
      "package_price": 600000,
      "formatted_package_price": "Rp 600.000",
      "discount_percentage": 20,
      "savings": 150000,
      "formatted_savings": "Rp 150.000",
      "price_per_session": 120000,
      "formatted_price_per_session": "Rp 120.000",
      "validity_days": 90,
      "service": {...}
    }
  ]
}
```

### Get Package Detail
```
GET /api/v1/packages/{id}
Authorization: Bearer {token}
```

### List Customer Packages
```
GET /api/v1/customer-packages?customer_id=1&active_only=1&status=active
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "customer_id": 1,
      "package_id": 1,
      "price_paid": 600000,
      "formatted_price_paid": "Rp 600.000",
      "sessions_total": 5,
      "sessions_used": 2,
      "sessions_remaining": 3,
      "usage_percentage": 40,
      "purchased_at": "2026-01-15",
      "expires_at": "2026-04-15",
      "days_remaining": 68,
      "is_expired": false,
      "is_usable": true,
      "status": "active",
      "status_label": "Aktif",
      "package": {...},
      "customer": {...}
    }
  ]
}
```

### Get Customer Package Detail
```
GET /api/v1/customer-packages/{id}
Authorization: Bearer {token}
```

---

## 12. Transactions

### List Transactions
```
GET /api/v1/transactions?customer_id=1&status=paid&start_date=2026-02-01&end_date=2026-02-28
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "invoice_number": "INV20260206001",
      "subtotal": 500000,
      "formatted_subtotal": "Rp 500.000",
      "discount_amount": 50000,
      "formatted_discount_amount": "Rp 50.000",
      "discount_type": "percent",
      "points_used": 100,
      "points_discount": 10000,
      "tax_amount": 0,
      "total_amount": 440000,
      "formatted_total_amount": "Rp 440.000",
      "paid_amount": 440000,
      "formatted_paid_amount": "Rp 440.000",
      "status": "paid",
      "status_label": "Lunas",
      "is_paid": true,
      "paid_at": "2026-02-06T10:00:00.000000Z",
      "customer": {...},
      "items": [...],
      "payments": [...]
    }
  ]
}
```

### Get Transaction Detail
```
GET /api/v1/transactions/{id}
Authorization: Bearer {token}
```

### Get Transaction Receipt
```
GET /api/v1/transactions/{id}/receipt
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": {
    "transaction": {...},
    "clinic": {
      "name": "GlowUp Clinic",
      "address": "Jl. Sudirman No. 1",
      "phone": "021-12345678"
    }
  }
}
```

---

## 13. Staff

### List Staff
```
GET /api/v1/staff?role=beautician&active_only=1&search=john
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Dr. Jane",
      "email": "jane@glowup.com",
      "phone": "081234567890",
      "role": "beautician",
      "role_label": "Beautician",
      "avatar": null,
      "is_active": true
    }
  ]
}
```

### Get Beauticians Only
```
GET /api/v1/staff/beauticians
Authorization: Bearer {token}
```

### Get Staff Detail
```
GET /api/v1/staff/{id}
Authorization: Bearer {token}
```

---

## Error Handling

### Standard Error Response
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email field is required."],
    "phone": ["The phone format is invalid."]
  }
}
```

### HTTP Status Codes
- `200` - Success
- `201` - Created
- `401` - Unauthorized (invalid/expired token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `422` - Validation Error
- `500` - Server Error

---

## Pagination

All list endpoints return paginated responses:

```json
{
  "data": [...],
  "links": {
    "first": "...",
    "last": "...",
    "prev": null,
    "next": "..."
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 10,
    "path": "...",
    "per_page": 15,
    "to": 15,
    "total": 150
  }
}
```

---

## Next Steps for Flutter

Lihat file berikut untuk panduan implementasi Flutter:
- [models.md](./models.md) - Dart models untuk semua data types
- [services.md](./services.md) - API service/datasource implementation
- [blocs.md](./blocs.md) - BLoC implementation untuk state management
