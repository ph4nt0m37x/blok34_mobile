# blok34_mobile

## Overview

blok34 is a mobile event management platform developed with Flutter that enables users to discover, create, and manage events and venues through an intuitive and modern interface. The application encourages community engagement by allowing users to organize public and private events, explore upcoming activities, and connect with other users.

The system combines venue management, event organization, user profiles, weather integration, and powerful search functionality into a single mobile application.

---

# Main Features

## User Authentication & Profile Management

The application uses Firebase Authentication to provide secure user registration and login functionality.

Users can:

* Create an account and log in securely
* Reset their password
* Change their email address
* Edit their profile information
* Upload or capture a profile picture
* Set a custom username
* Add a personal biography

Profile images are stored using Cloudinary, providing a cost-effective and scalable image hosting solution.

---

## Venue Management

Venues represent locations where events can be organized.

Users can create two types of venues:

### Public Venues

Public venues are visible to all users.

Any authenticated user can:

* View the venue
* Create events within the venue

### Private Venues

Private venues are restricted to the venue owner.

Only the venue owner can:

* Create events within the venue
* Edit venue information
* Delete the venue

### Venue Features

Users can:

* Create venues
* Edit venues they own
* Delete venues they own
* Browse all available venues
* View detailed venue information
* Search venues by name or category
* Filter venues by category

Each venue contains:

* Name
* Description
* Category
* Banner image
* Owner information
* Visibility type (Public/Private)

---

## Event Management

Events are created within venues and serve as the central activity of the platform.

### Event Creation Rules

| Venue Type    | Who Can Create Events  |
| ------------- | ---------------------- |
| Public Venue  | Any authenticated user |
| Private Venue | Venue owner only       |

### Event Features

Users can:

* Create events
* Edit events they created
* Delete events they created
* Browse upcoming events
* View event details
* Mark themselves as interested
* Mark themselves as attending

Each event contains:

* Title
* Description
* Category
* Start date and time
* End date and time
* Venue association
* Banner image
* Creator information

---

## Event Participation

The application provides two engagement options for users:

### Interested

Allows users to save events they may want to attend in the future.

### Attending

Allows users to indicate that they plan to participate in the event.

These features help event organizers estimate engagement and attendance levels.

---

# Search System

The application includes a centralized search engine that allows users to search across multiple entities simultaneously.

### Global Search

The central search page searches:

* Users
* Events
* Venues

Results are grouped by entity type for easier navigation.

### Event Search

Dedicated event search functionality allows users to:

* Search by title
* Search by category
* Filter upcoming events
* Browse categorized events

### Venue Search

Dedicated venue search functionality allows users to:

* Search by venue name
* Search by category
* Filter venues by category

### Search Optimization

To reduce unnecessary database requests and improve performance, all search operations use a **400ms debounce timer**.

This ensures that Firebase queries are only executed after the user pauses typing, significantly reducing backend load and improving responsiveness.

---

# Weather Integration

The application integrates with the Open-Meteo Weather API.

### Location-Based Weather

When permission is granted:

1. The user's current location is obtained.
2. Weather data is fetched for that location.
3. Relevant weather information is displayed within the application.

### Fallback Mechanism

If location access is denied:

* The application automatically displays weather information for Skopje.

### Weather Caching

To prevent excessive API calls:

* Weather information is cached.
* Data is refreshed only once per hour.

This optimization improves performance while reducing unnecessary network traffic.

---

# Image Management

The application supports both gallery uploads and direct camera capture.

Users can:

* Select images from their device gallery
* Capture photos using the device camera
* Upload venue banners
* Upload event banners
* Upload profile pictures

Images are stored using Cloudinary rather than Firebase Storage, providing a more cost-effective solution while maintaining reliable image hosting and delivery.

---

# Navigation System

The application uses a structured navigation approach designed for a smooth user experience.

## Bottom Navigation Bar

Provides quick access to:

* Home
* Events
* Venues
* Search
* Profile

## Top Navigation Actions

Provides access to:

* Settings
* My Events
* My Venues
* Logout

This layout minimizes navigation complexity and allows users to quickly access important features.

---

# State Management

The application uses the Provider package for state management.

Provider is responsible for:

* Managing authenticated user state
* Sharing user information across screens
* Managing weather data caching
* Updating UI components when application data changes

This architecture promotes maintainability, scalability, and efficient UI updates.

---

# Home Screen

The Home Screen acts as the primary dashboard of the application.

Features include:

* Upcoming events
* Quick event discovery
* Weather information
* Navigation shortcuts
* Personalized user experience

The screen is designed to provide users with immediate access to the most relevant information upon launching the application.

---

# User Content Management

The application provides dedicated pages where users can manage their own content.

### My Events

Displays all events created by the current user.

Users can:

* View
* Edit
* Delete

their events from a single location.

### My Venues

Displays all venues owned by the current user.

Users can:

* View
* Edit
* Delete

their venues from a centralized management screen.

---

# Technology Stack

## Frontend

* Flutter
* Dart

## Backend Services

* Firebase Authentication
* Cloud Firestore

## Image Hosting

* Cloudinary

## APIs

* Open-Meteo Weather API

## State Management

* Provider

## Device Features

* Camera Integration
* Location Services

---

# System Architecture

```
┌───────────────────────────┐
│        Flutter App        │
└─────────────┬─────────────┘
              │
    ┌─────────┼─────────┐
    │         │         │
    ▼         ▼         ▼
 Firebase  Cloudinary  Open-Meteo
   Auth      Images     Weather
    │
    ▼
 Cloud Firestore
    │
    ▼
 Users • Venues • Events
```

