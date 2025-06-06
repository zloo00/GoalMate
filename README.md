# 🌱 GoalMate

**GoalMate** — это современное iOS-приложение для постановки и отслеживания целей, выполненное с использованием архитектуры **MVVM**, Firebase и технологий дополненной реальности (ARKit).

---

## 🚀 Основные возможности

- 📌 Добавление целей с указанием:
  - Названия
  - Приоритета
  - Даты начала и окончания
- ✏️ Полный CRUD:
  - Добавление, редактирование и удаление целей
- 📋 Список целей:
  - Сортировка по приоритету, дедлайну и алфавиту
  - Отметка выполнения цели
- 🧱 Подцели:
  - Добавление и отметка выполнения
  - Автоматический расчёт процента выполненных подцелей
- 🔐 Firebase Authentication:
  - Регистрация и вход пользователя
- ☁️ Firebase Firestore:
  - Хранение и загрузка данных
- 💬 Мотивационные цитаты:
  - Загрузка с внешнего REST API
  - Обработка состояний загрузки: `loading`, `empty`, `error`
- 📷 ARKit интеграция:
  - Визуализация дерева целей в дополненной реальности
- ✅ Валидация данных и Unit-тесты
- ⚙️ CI/CD с GitHub Actions

---

## 🧠 Архитектура MVVM

Проект разделён на слои:

```plaintext
/Sources
  /Views         — интерфейсы пользователя (SwiftUI)
  /ViewModels    — логика отображения, биндинг данных
  /Models        — модели целей, подцелей, пользователя
  /Services      — работа с внешним API
  /Resources     — изображения, цвета, строки и т.д.
/Tests           — модульные тесты

---

## 🧪 Тестирование и CI/CD

- Все ключевые компоненты покрыты Unit-тестами
- Настроен GitHub Actions:
  - Проверка сборки
  - Прогон тестов при каждом Pull Request

---

## 🧰 Используемые технологии

- Swift + SwiftUI
- MVVM
- Firebase Authentication & Firestore
- REST API для цитат
- ARKit + RealityKit
- GitHub Actions
- Unit Testing (XCTest)

---

## 📱 Скриншоты

*(добавьте сюда скриншоты приложения)*

---

## 🛠 Установка и запуск

1. Клонируйте репозиторий:
```bash
git clone https://github.com/zloo00/GoalMate.git
