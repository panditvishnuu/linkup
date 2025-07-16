# ----------- Build Stage -----------
FROM node:18-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy the rest of the code
COPY . .

# Build the Next.js app
RUN npm run build

# ----------- Run Stage ------------
FROM node:18-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Copy only necessary files
COPY package*.json ./
RUN npm ci --only=production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/next.config.mjs ./next.config.mjs
COPY --from=builder /app/tailwind.config.ts ./tailwind.config.ts
COPY --from=builder /app/postcss.config.mjs ./postcss.config.mjs
COPY --from=builder /app/tsconfig.json ./tsconfig.json

# Optional: Copy any required lib/providers/hooks/constants/actions folders if referenced directly
COPY --from=builder /app/lib ./lib
COPY --from=builder /app/hooks ./hooks
COPY --from=builder /app/providers ./providers
COPY --from=builder /app/constants ./constants
COPY --from=builder /app/actions ./actions

# Load ENV from file at runtime using Docker --env-file (best practice)

EXPOSE 3000

CMD ["npm", "start"]
