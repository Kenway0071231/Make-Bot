#!/bin/bash

echo "🚀 Запуск развертывания MakeBot..."

# Создаем папки если их нет
mkdir -p backend/data
mkdir -p frontend/{css,js,assets}

# Копируем файлы фронтенда если они есть
if [ -f "frontend/css/style.css" ]; then
    echo "✅ Файлы фронтенда уже существуют"
else
    echo "⚠️  Файлы фронтенда не найдены, создаем базовую структуру"
    # Создаем базовый index.html если его нет
    if [ ! -f "frontend/index.html" ]; then
        echo '<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MakeBot - Сайт временно на обслуживании</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #4361ee; }
        .status { color: #4CAF50; font-weight: bold; }
    </style>
</head>
<body>
    <h1>MakeBot</h1>
    <p>Сайт временно на обслуживании</p>
    <p>Бэкенд работает: <span class="status">✅</span></p>
    <p>Проверьте консоль сервера для деталей</p>
</body>
</html>' > frontend/index.html
    fi
fi

# Проверяем .env файл
if [ ! -f "backend/.env" ]; then
    echo "⚠️  Файл .env не найден, создаем из примера"
    cp .env.example backend/.env
    echo "✅ Файл .env создан"
else
    echo "✅ Файл .env уже существует"
fi

# Проверяем и создаем файлы данных
if [ ! -f "backend/data/calculator_requests.json" ]; then
    echo '[]' > backend/data/calculator_requests.json
    echo "✅ Создан calculator_requests.json"
fi

if [ ! -f "backend/data/contact_requests.json" ]; then
    echo '[]' > backend/data/contact_requests.json
    echo "✅ Создан contact_requests.json"
fi

# Даем права на запись
chmod 755 backend/data/*.json 2>/dev/null || true

# Собираем и запускаем Docker
echo "🐳 Собираем Docker образ..."
docker-compose build

echo "🚀 Запускаем контейнер..."
docker-compose up -d

echo "⏳ Ожидаем запуск сервера..."
sleep 5

# Проверяем здоровье сервера
echo "🔍 Проверяем состояние сервера..."
if curl -s http://localhost:3000/api/health | grep -q "success.*true"; then
    echo "✅ Сервер успешно запущен!"
    echo "🌐 Откройте в браузере: http://localhost:3000"
    echo "📱 API доступен по: http://localhost:3000/api/health"
else
    echo "⚠️  Сервер запущен, но проверка здоровья не прошла"
    echo "📋 Проверьте логи: docker-compose logs"
fi

echo "📋 Полезные команды:"
echo "   Просмотр логов: docker-compose logs -f"
echo "   Остановить: docker-compose down"
echo "   Перезапустить: docker-compose restart"
echo "   Проверить статус: docker-compose ps"
