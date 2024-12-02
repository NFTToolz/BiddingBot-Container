# Base Node image for both services
FROM node:18-alpine as base
WORKDIR /app

# Build server
FROM base as server-builder
WORKDIR /app/server
COPY server/package*.json ./
RUN npm install
COPY server .
RUN npm run build
RUN pwd && ls -la dist/

# Build client
FROM base as client-builder
WORKDIR /app/client
COPY client/package*.json ./
RUN npm install
COPY client .
RUN npm run build

# Final image
FROM base
WORKDIR /app

# Copy server with its build output
COPY --from=server-builder /app/server/dist ./server/dist
COPY --from=server-builder /app/server/package*.json ./server/
COPY --from=server-builder /app/server/node_modules ./server/node_modules

# Copy client with its build output
COPY --from=client-builder /app/client/.next ./client/.next
COPY --from=client-builder /app/client/public ./client/public
COPY --from=client-builder /app/client/package*.json ./client/
COPY --from=client-builder /app/client/node_modules ./client/node_modules

# Copy start script
COPY start.sh .
RUN chmod +x start.sh

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 3001 3003

CMD ["./start.sh"]