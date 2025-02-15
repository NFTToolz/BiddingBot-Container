# Base Node image for both services
FROM node:18-alpine as base
WORKDIR /app

# Build server
FROM base as server-builder
WORKDIR /app/server
COPY server/package*.json ./
RUN npm ci --only=production
COPY server .
RUN npm run build

# Build client
FROM base as client-builder
WORKDIR /app/client
COPY client/package*.json ./
RUN npm ci --only=production
COPY client .
RUN npm run build

# Production image
FROM node:18-alpine
WORKDIR /app

# Copy only necessary files from builders
COPY --from=server-builder /app/server/dist ./server/dist
COPY --from=server-builder /app/server/package*.json ./server/
COPY --from=client-builder /app/client/.next ./client/.next
COPY --from=client-builder /app/client/package*.json ./client/

# Install only production dependencies
WORKDIR /app/server
RUN npm ci --only=production
WORKDIR /app/client
RUN npm ci --only=production
WORKDIR /app

# Copy start script
COPY start.sh .
RUN chmod +x start.sh

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 3001 3003

CMD ["./start.sh"]