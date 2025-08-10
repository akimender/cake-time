FROM node:20-alpine
WORKDIR /app

# if your app lives in frontend/frontend/, copy from there:
COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 5173
CMD ["npm","run","dev","--","--host","0.0.0.0","--port","5173"]