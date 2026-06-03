# AquaLog 🤿

AquaLog es una aplicación completa para buceadores desarrollada en **Flutter**. Permite registrar inmersiones, gestionar el equipo de buceo y consultar las condiciones meteorológicas en tiempo real.

## 🚀 Características Principales

*   **Logbook Digital:** Registro CRUD completo de inmersiones con soporte para imágenes y geolocalización.
*   **Gestión de Equipo (Gear):** Inventario personal con búsqueda integrada (Google Custom Search API) para autocompletar detalles del equipo.
*   **Planificador Meteo:** Integración con Open-Meteo API para consultar viento y temperatura en zonas de buceo.
*   **Mapas Interactivos:** Visualización global de inmersiones usando Google Maps SDK con estilos personalizados.
*   **Autenticación:** Sistema de login y registro gestionado con Firebase Auth.

## 🛠 Tech Stack & Arquitectura

*   **Flutter & Dart**
*   **State Management:** BLoC Pattern (Business Logic Component).
*   **Backend:** Firebase (Firestore, Auth).
*   **Architecture:** Clean Architecture principles (Data layers, Repository Pattern, UI Separation).
*   **APIs Externas:** Google Maps, Open-Meteo, Google Custom Search.

## 💡 Decisiones Técnicas Destacadas

*   **Imágenes en Base64:** Para este MVP, se optó por serializar las imágenes en Base64 dentro de Firestore para reducir la complejidad de infraestructura, aunque se ha diseñado la capa de repositorio para facilitar la migración a Cloud Storage en el futuro.
*   **Reactive UI:** Uso extensivo de `BlocBuilder` y `BlocListener` para una gestión eficiente de los estados de carga y error.
