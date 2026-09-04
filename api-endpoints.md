# RaceDay API Endpoint Plan

This document outlines all API endpoints for the RaceDay event management system.

## Authentication

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| POST | `/api/auth/register` | Register a new user | Public | `{ firstName, lastName, email, phone, dateOfBirth, gender, idNumber, password, emergencyContact, emergencyPhone, medicalConditions }` | `201: { userId, token, message }` |
| POST | `/api/auth/login` | Login user | Public | `{ email, password }` | `200: { token, user }` |
| POST | `/api/auth/logout` | Logout user | User | - | `200: { message }` |
| POST | `/api/auth/refresh` | Refresh JWT token | User | `{ refreshToken }` | `200: { token }` |

## User Profile

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | `/api/users/profile` | Get current user profile | User | - | `200: { user }` |
| PUT | `/api/users/profile` | Update user profile | User | `{ firstName, lastName, phone, emergencyContact, emergencyPhone, medicalConditions }` | `200: { user, message }` |
| PUT | `/api/users/password` | Change password | User | `{ currentPassword, newPassword }` | `200: { message }` |
| GET | `/api/users/performance/history` | Get user's performance history | User | - | `200: { results }` |

## Events

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | `/api/events` | Get all events with filters | Public | - (Query: `?status=upcoming&type=running&location=`) | `200: { events, totalCount, page, limit }` |
| GET | `/api/events/:id` | Get event by ID with details | Public | - | `200: { event, categories }` |
| POST | `/api/events` | Create new event | Organiser | `{ eventName, description, eventType, eventDate, startTime, cutOffTime, location, address, latitude, longitude, maxParticipants, entryFee, registrationDeadline, routeDescription }` | `201: { event, message }` |
| PUT | `/api/events/:id` | Update event | Organiser | `{ eventName, description, eventDate, startTime, cutOffTime, location, address, latitude, longitude, maxParticipants, entryFee, registrationDeadline, status, routeDescription }` | `200: { event, message }` |
| DELETE | `/api/events/:id` | Delete event | Organiser | - | `200: { message }` |
| GET | `/api/events/:id/weather` | Get event weather info | Public | - | `200: { weatherInfo }` |
| GET | `/api/events/:id/route` | Get event route info | Public | - | `200: { routeDescription, map }` |

## Categories

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | `/api/events/:eventId/categories` | Get categories for an event | Public | - | `200: { categories }` |
| POST | `/api/events/:eventId/categories` | Create category for event | Organiser | `{ categoryName, ageMin, ageMax, genderRestriction, distance, difficultyLevel }` | `201: { category, message }` |
| PUT | `/api/categories/:id` | Update category | Organiser | `{ categoryName, ageMin, ageMax, genderRestriction, distance, difficultyLevel }` | `200: { category, message }` |
| DELETE | `/api/categories/:id` | Delete category | Organiser | - | `200: { message }` |

## Event Enrolments

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| POST | `/api/events/:eventId/enroll` | Enroll participant in event | User | `{ categoryId, paymentReference }` | `201: { enrolment, message }` |
| GET | `/api/users/enrolments` | Get user's enrolments | User | - | `200: { enrolments }` |
| GET | `/api/events/:eventId/enrolments` | Get all enrolments for an event | Organiser | - | `200: { enrolments, count }` |
| PUT | `/api/enrolments/:id/status` | Update enrolment status | Organiser | `{ status }` | `200: { enrolment, message }` |
| PUT | `/api/enrolments/:id/racenumber` | Assign race number | Organiser | `{ raceNumber }` | `200: { enrolment, message }` |

## Results

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| POST | `/api/events/:eventId/results` | Upload results for event | Organiser | `{ results: [{ enrolmentId, finishTime, overallRank, categoryRank, officialTime, chipTime }] }` | `201: { results, message }` |
| GET | `/api/events/:eventId/results` | Get results for event | Public | - | `200: { results }` |
| GET | `/api/events/:eventId/results/category/:categoryId` | Get category results | Public | - | `200: { results }` |
| GET | `/api/users/results` | Get user's all results | User | - | `200: { results }` |
| GET | `/api/results/:id` | Get result details | Public | - | `200: { result }` |

## Organiser Dashboard

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|-------------|-------|-------------|---------------|--------------|-------------------|
| GET | `/api/organiser/events` | Get organiser's events | Organiser | - | `200: { events }` |
| GET | `/api/organiser/events/:eventId/statistics` | Get event statistics | Organiser | - | `200: { totalEnrolments, categoriesCount, genderSplit, ageGroups }` |