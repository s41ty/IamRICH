# I am RICH

**«I am RICH»** - торговый робот использующий [API Тинькофф Инвестиций](https://github.com/Tinkoff/investAPI) для платформ **iOS**, **macOS** и **tvOS**. Единый исходный код на Swift 5 позволяет использовать приложения на любых девайсах Apple - iPhone, iPad, Mac, TV и пр. Используется декларативный язык разметки SwiftUI и реактивный фреймворк Combine.

## Торговая стратегия робота
Торговый робот использует технический индикатор MACD для принятия решения о покупке или продаже. Используются минутные интервалы. ЕМАs = 12 минут, ЕМАl = 26 минут, Signal = 9 минут. Подробнее про [индикатор MACD](https://ru.wikipedia.org/wiki/Индикатор_MACD)

## Основной функционал приложения
### Авторизация
- Ввод токена авторизации
- Сохранение токена авторизации в Keychain
- Ссылка на управление токенами в кабинете Тинькофф Инвестиции
- Проверка валидности токена

### Список счетов
- Просмотр списка счетов основного аккаунта
- Просмотр списка счетов песочницы
- Удаление счёта в песочнице 
- Добавление счёта в песочнице (через настройки)

### Информация о счёте
- Информация о состоянии счёта
- Рублёвая оценка
- Текущие активные заявки
- Состав портфеля
- Пополнение счёта песочницы

### История торгового робота
- Список созданных заявок торгового робота
- Просмотр статуса созданных заявок 

### Торговый робот
- Ежеминутное получение данных, их анализ и создание заявок
- Логи работы робота
- График MACD и Signal
- Текущие активные заявки на покупку и продажу
- Текущее количество торгуемого инструмента в портфеле 
- Средневзвешенная цена портфеля по торгуемому инструменту
- Последняя цена сделки на бирже

### Настройки робота
- Выбор инструмента для торговли
- Установка лимита торговли для робота

### Размещение заявки
- Создание лимитной заявки на покупку или продажу
- Для размещения заявки необходимо указать инструмент, количество лотов и цену

### Настройки приложения
- Добавление нового счёта в песочнице
- Удаление токена из Keychain

## Используемые зависимости

[TinkoffInvestSDK](https://github.com/s41ty/TinkoffInvestSDK.git) - библиотека для работы с API Тинькофф Инвестиции

[KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) - работа с Keychain

[SwiftfulLoadingIndicators](https://github.com/SwiftfulThinking/SwiftfulLoadingIndicators.git) - отрисовка анимированного индикатора загрузки данных

[SwiftUICharts](https://github.com/willdale/SwiftUICharts.git) - построение графиков

## Требования для сборки проекта 
- macOS Monterey
- XCode 13

## Совместимость
Платформа | Минимальная версия
--- | ---
macOS | 10.15
iOS & iPadOS | 15
tvOS | 15