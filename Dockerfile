FROM node:18-alpine

WORKDIR /app

# Копируем package.json
COPY backend/package*.json ./

# Устанавливаем зависимости
RUN npm ci --only=production

# Копируем бэкенд
COPY backend/ ./

# Создаем папки
RUN mkdir -p data && mkdir -p ../frontend

# Создаем пользователя
RUN addgroup -g 1001 -S nodejs && \
    adduser -S -u 1001 nodejs

# Меняем владельца
RUN chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 3000

CMD ["node", "server.js"]
