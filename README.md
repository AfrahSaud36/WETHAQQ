<h1 align="center">WETHAQ</h1>

<p align="center">
  <img src="https://github.com/user-attachments/assets/6e867b01-6522-45fa-963c-be0939831dbd" width="340" height="388" alt="App icon-2"/>
</p>


## Overview

**WETHAQ** is an innovative application designed to connect individuals who need services (askers) with those who offer them (helpers). The app focuses on building trust, collaboration, and interaction among users, allowing them to easily find assistance or offer their skills locally and globally. The application is developed using **Swift**, **SwiftUI**, **CloudKit**, and **Core Data**, ensuring a seamless and secure user experience with real-time data synchronization and offline functionality.

## Technologies Used

- **Swift & SwiftUI**: The app is built using **Swift** and **SwiftUI**, ensuring a modern and responsive user interface with a seamless experience.
- **CloudKit**: Provides cloud-based storage and synchronization, keeping user data updated in real-time across all devices.
- **Core Data**: Used for local data storage, allowing users to interact with the app even when offline.

## Features

### 1. **User Interface and Profile Setup**
- Upon entering the app, the user is greeted with a welcome message, guiding them to easily access services (see image 1).
- Users can navigate through various sections of the app, such as available services and managing their profiles.
- Users can view personalized messages and offers based on their interests.

### 2. **Search or Offer Services**
- **Asker users** can search for available services based on their needs.
- **Helper users** can offer their skills and services, which will be displayed to relevant askers searching for them.
- Each service includes details such as title, description, price, and provider name, making it easy for users to find what they are looking for (see image 2).

### 3. **Add and Edit Tasks**
- Users can add their own services by filling in details like title, description, price, and contact information. The form includes clear fields to easily create posts (see image 4).
- Users can also upload photos and choose to provide contact details via phone number or email.

### 4. **Profile Management**
- The app allows users to manage their profiles, view and update their posts, and switch between multiple languages (see image 3).
- Users can also modify privacy settings and access policies like the **Privacy Policy** at the bottom of the profile page.
- The simple design helps users focus on their tasks without distraction.

### 5. **Real-Time Data Synchronization**
- Through **CloudKit**, all user data, including service listings and interactions, are synchronized across different devices. Whether users access the platform from different devices, their data is always up-to-date.
- **Core Data** ensures offline functionality, allowing uninterrupted usage when there is no internet connection. Once reconnected, data is automatically updated in the cloud.

### 6. **Advanced Search and Filtering**
- An **advanced search** feature is integrated to allow users to search for services easily using multiple filters such as price or category. This helps improve the search experience and interaction with the content faster.

### 7. **Language Management**
- The app allows users to change the language at any time. Multiple languages are supported to ensure the app reaches a wide range of users across different communities (see image 3).

## Setting Up and Configuring **CloudKit**

### 1. **Enabling CloudKit in Apple Developer Account**
- **iCloud** and **CloudKit** services were enabled in the **Apple Developer** account.
- A **CloudKit container** was created in the Apple Developer Dashboard and used to store data in **iCloud**.

### 2. **Integrating CloudKit in Xcode**
- **iCloud** and **CloudKit** services were enabled under the **Signing & Capabilities** tab in **Xcode**.
- The app was linked to the **CloudKit container** created in the Apple Developer account.

### 3. **Accessing Data from CloudKit**
- We used the **CloudKit API** to access data from **publicCloudDatabase** and **privateCloudDatabase**, depending on whether the data was public or user-specific.

## App Results

### 1. **Usability**:
- **SwiftUI** ensures that the user interface is modern and easy to use, making it simple for users to interact with the app.
- **CloudKit** ensures seamless synchronization of user data across multiple devices.
- **Core Data** offers offline functionality, allowing uninterrupted use even when offline.

### 2. **Challenges**:
- **CloudKit integration** required careful configuration to maintain data consistency across devices and prevent data loss.
- Setting up **Core Data** and integrating it with **CloudKit** required meticulous planning to ensure seamless synchronization without conflicts.

## Conclusion

**WETHAQ** was built with a focus on providing a seamless, secure, and efficient user experience. By leveraging **Swift**, **CloudKit**, and **Core Data**, the app ensures real-time synchronization and offline support. It allows users to engage with their community based on trust and transparency and fosters collaboration between individuals securely.

---

## Special Thanks

I would like to extend my sincere thanks to my mentor Eng. Shahad Bagarish for providing guidance and continuous support throughout the development of this app. This achievement wouldn't have been possible without their invaluable insights and assistance.
